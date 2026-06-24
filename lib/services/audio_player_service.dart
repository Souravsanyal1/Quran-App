import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_urls.dart';
import '../data/repositories/quran_repository.dart';
import '../data/providers/quran_api_provider.dart';
import '../data/models/ayah_model.dart';
import '../modules/settings/settings_controller.dart';

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
  String? _playingQariId;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> onInit() async {
    super.onInit();
    // Do NOT pass userAgent here — it triggers just_audio's internal HTTP proxy
    // which causes Source errors on Android 9+. We handle caching ourselves.
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

  Future<void> playAyah(AyahModel ayah, {String? qariId}) async {
    final repo = Get.find<QuranRepository>();
    final api  = Get.find<QuranApiProvider>();
    final activeQariId = qariId ?? Get.find<SettingsController>().selectedQari.value;

    // Toggle pause / resume
    if (playingAyahNumber.value == ayah.number && _playingQariId == activeQariId) {
      if (isPlaying.value) {
        await _player.pause();
        return;
      } else {
        await _player.play();
        return;
      }
    }

    try {
      isPlayerLoading.value = true;
      playingAyahNumber.value = ayah.number;

      final qariName = AppUrls.qariList.firstWhere(
        (q) => q['id'] == activeQariId,
        orElse: () => {'id': activeQariId, 'name': 'Reciter'},
      )['name'] ?? 'Reciter';

      final tag = MediaItem(
        id: 'ayah_${ayah.number}',
        album: nowPlayingContext.value,
        title: 'Ayah ${ayah.numberInSurah}',
        artist: qariName,
      );

      final hasLocal = await repo.isAyahAudioDownloaded(ayah.number, activeQariId);
      final AudioSource source;

      if (hasLocal) {
        final localPath = await repo.getLocalAudioPath(ayah.number, activeQariId);
        debugPrint('[AudioPlayerService] Playing local file: $localPath');
        source = AudioSource.file(localPath, tag: tag);
      } else {
        final url = api.getAyahAudioUrl(ayah.number, qariId: activeQariId);
        debugPrint('[AudioPlayerService] Playing online URL: $url');

        // Use LockCachingAudioSource to bypass the internal HTTP proxy.
        // It downloads the MP3 to a temp file first, then plays from disk —
        // completely avoiding the CleartextNotPermittedException / Source error
        // that occurs when just_audio tries to stream through its local proxy.
        final cacheFile = await _getCacheFile(ayah.number, activeQariId);
        // ignore: experimental_member_use
        source = LockCachingAudioSource(
          Uri.parse(url),
          cacheFile: cacheFile,
          tag: tag,
        );
      }

      await _player.setAudioSource(source);
      _playingQariId = activeQariId;
      isPlayerLoading.value = false;
      await _player.play();
    } catch (e, stack) {
      isPlayerLoading.value = false;
      debugPrint('[AudioPlayerService] playAyah error: $e\nStacktrace:\n$stack');
      Get.snackbar(
        'Audio Error',
        'Could not load audio. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
    }
  }

  /// Returns a [File] in the app's temp cache directory for this ayah + qari.
  /// Using a stable file path means repeated plays won't re-download.
  Future<File> _getCacheFile(int globalAyahNumber, String qariId) async {
    final tempDir = await getTemporaryDirectory();
    final dir = Directory('${tempDir.path}/audio_cache/$qariId');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$globalAyahNumber.mp3');
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
