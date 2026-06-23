import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../core/constants/app_urls.dart';
import '../data/repositories/quran_repository.dart';
import '../data/providers/quran_api_provider.dart';
import '../data/models/ayah_model.dart';

/// A global singleton GetxService that owns the single AudioPlayer instance.
///
/// Because this is registered with `permanent: true` it is NEVER disposed
/// by GetX route cleanup, so audio keeps playing even when the user navigates
/// away from the Surah/Para screen or minimises the app.
///
/// Both [SurahDetailsController] and [ParaDetailsController] delegate all
/// audio work to this service.
class AudioPlayerService extends GetxService {
  // ── Observable state ──────────────────────────────────────────────────────
  final RxnInt playingAyahNumber = RxnInt();
  final RxBool isPlaying = false.obs;
  final RxBool isPlayerLoading = false.obs;

  /// The context string shown in the notification / mini-player label
  /// e.g. "Surah Al-Baqarah"  or  "Juz 1"
  final RxString nowPlayingContext = ''.obs;

  // ── Internal ──────────────────────────────────────────────────────────────
  late final AudioPlayer _player;
  List<AyahModel> _playlist = [];           // current ayah list (surah or para)
  bool _autoPlayNext = true;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> onInit() async {
    super.onInit();
    _player = AudioPlayer();
    await _configureAudioSession();
    _listenToPlayerState();
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  void _listenToPlayerState() {
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  // ── Public API ────────────────────────────────────────────────────────────

  AudioPlayer get rawPlayer => _player;

  /// Load a new playlist and context label.
  /// Call this from the screen controller when the screen opens.
  void setPlaylist({
    required List<AyahModel> ayahs,
    required String contextLabel,
    bool autoPlayNext = true,
  }) {
    _playlist = ayahs;
    nowPlayingContext.value = contextLabel;
    _autoPlayNext = autoPlayNext;
  }

  bool get hasActivePlayback => playingAyahNumber.value != null;

  Future<void> playAyah(AyahModel ayah, {String qariId = AppUrls.defaultQariId}) async {
    final repo = Get.find<QuranRepository>();
    final api  = Get.find<QuranApiProvider>();

    // Toggle pause / resume
    if (playingAyahNumber.value == ayah.number && isPlaying.value) {
      await _player.pause();
      return;
    }
    if (playingAyahNumber.value == ayah.number && !isPlaying.value) {
      await _player.play();
      return;
    }

    try {
      isPlayerLoading.value = true;
      playingAyahNumber.value = ayah.number;

      final qariName = AppUrls.qariList.firstWhere(
        (q) => q['id'] == qariId,
        orElse: () => {'id': qariId, 'name': 'Reciter'},
      )['name'] ?? 'Reciter';

      final hasLocal = await repo.isAyahAudioDownloaded(ayah.number, qariId);
      final AudioSource source;

      if (hasLocal) {
        final localPath = await repo.getLocalAudioPath(ayah.number, qariId);
        source = AudioSource.file(
          localPath,
          tag: MediaItem(
            id: 'ayah_${ayah.number}',
            album: nowPlayingContext.value,
            title: 'Ayah ${ayah.numberInSurah}',
            artist: qariName,
          ),
        );
      } else {
        final url = api.getAyahAudioUrl(ayah.number, qariId: qariId);
        source = AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: 'ayah_${ayah.number}',
            album: nowPlayingContext.value,
            title: 'Ayah ${ayah.numberInSurah}',
            artist: qariName,
          ),
        );
      }

      await _player.setAudioSource(source);
      isPlayerLoading.value = false;
      await _player.play();
    } catch (e) {
      isPlayerLoading.value = false;
      Get.log('[AudioPlayerService] playAyah error: $e');
      Get.snackbar(
        'Audio Error',
        'Could not load audio. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
    }
  }

  Future<void> stopAudio() async {
    await _player.stop();
    playingAyahNumber.value = null;
  }

  Future<void> pauseAudio() async {
    await _player.pause();
  }

  Future<void> resumeAudio() async {
    await _player.play();
  }

  void setAutoPlayNext(bool value) => _autoPlayNext = value;

  // ── Internal ──────────────────────────────────────────────────────────────

  void _onTrackCompleted() {
    if (!_autoPlayNext || playingAyahNumber.value == null || _playlist.isEmpty) return;

    final currentIndex =
        _playlist.indexWhere((a) => a.number == playingAyahNumber.value);
    if (currentIndex != -1 && currentIndex < _playlist.length - 1) {
      playAyah(_playlist[currentIndex + 1]);
    } else {
      playingAyahNumber.value = null;
    }
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
