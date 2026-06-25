import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_urls.dart';
import '../core/theme/app_colors.dart';
import '../data/repositories/quran_repository.dart';
import '../data/providers/quran_api_provider.dart';
import '../data/models/ayah_model.dart';
import '../modules/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerService extends GetxService {
  final RxnInt playingAyahNumber = RxnInt();
  final RxBool isPlaying = false.obs;
  final RxBool isPlayerLoading = false.obs;
  final RxString nowPlayingContext = ''.obs;

  late final AudioPlayer _player;
  List<AyahModel> _playlist = [];
  bool _autoPlayNext = true;
  String? _playingQariId;

  @override
  Future<void> onInit() async {
    super.onInit();
    _player = AudioPlayer();
    if (!kIsWeb) await _configureAudioSession();
    _listenToPlayerState();
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
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

  void setPlaylist({required List<AyahModel> ayahs, required String contextLabel, bool autoPlayNext = true}) {
    _playlist = ayahs;
    nowPlayingContext.value = contextLabel;
    _autoPlayNext = autoPlayNext;
  }

  Future<void> playAyah(AyahModel ayah, {String? qariId}) async {
    if (!kIsWeb) await _checkAndPromptBackgroundPermission();

    final repo = Get.find<QuranRepository>();
    final api = Get.find<QuranApiProvider>();
    final activeQariId = qariId ?? Get.find<SettingsController>().selectedQari.value;

    if (playingAyahNumber.value == ayah.number && _playingQariId == activeQariId) {
      isPlaying.value ? await _player.pause() : await _player.play();
      return;
    }

    try {
      isPlayerLoading.value = true;
      playingAyahNumber.value = ayah.number;

      final qariData = AppUrls.qariList.firstWhere(
        (q) => q['id'] == activeQariId,
        orElse: () => {'id': activeQariId, 'name': 'Reciter', 'bitrate': '128'},
      );

      final tag = MediaItem(
        id: 'ayah_${ayah.number}',
        album: nowPlayingContext.value,
        title: 'Ayah ${ayah.numberInSurah}',
        artist: qariData['name'],
      );

      final url = api.getAyahAudioUrl(ayah.number, qariId: activeQariId);
      final AudioSource source;

      if (kIsWeb) {
        source = AudioSource.uri(Uri.parse(url), tag: tag);
      } else {
        final hasLocal = await repo.isAyahAudioDownloaded(ayah.number, activeQariId);
        if (hasLocal) {
          final localPath = await repo.getLocalAudioPath(ayah.number, activeQariId);
          source = AudioSource.file(localPath, tag: tag);
        } else {
          final cacheFile = await _getCacheFile(ayah.number, activeQariId);
          if (await cacheFile.exists() && await cacheFile.length() == 0) await cacheFile.delete();
          // ignore: experimental_member_use
          source = LockCachingAudioSource(Uri.parse(url), cacheFile: cacheFile, tag: tag);
        }
      }

      await _player.setAudioSource(source);
      _playingQariId = activeQariId;
      isPlayerLoading.value = false;
      await _player.play();
    } catch (e) {
      isPlayerLoading.value = false;
      debugPrint('[AudioPlayerService] Error: $e');
      // Fallback for failed source
      final url = api.getAyahAudioUrl(ayah.number, qariId: activeQariId);
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _player.play();
    }
  }

  Future<void> playUrl(String url) async {
    try {
      isPlayerLoading.value = true;
      playingAyahNumber.value = null;
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      isPlayerLoading.value = false;
      await _player.play();
    } catch (e) {
      isPlayerLoading.value = false;
    }
  }

  Future<File> _getCacheFile(int globalAyahNumber, String qariId) async {
    final tempDir = await getTemporaryDirectory();
    final dir = Directory('${tempDir.path}/audio_cache/$qariId');
    if (!await dir.exists()) await dir.create(recursive: true);
    return File('${dir.path}/$globalAyahNumber.mp3');
  }

  Future<void> stopAudio() async { await _player.stop(); playingAyahNumber.value = null; }
  void setAutoPlayNext(bool value) => _autoPlayNext = value;

  Future<void> _checkAndPromptBackgroundPermission() async {
    final settings = Get.find<SettingsController>();
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('background_play_prompted') ?? false)) {
      await prefs.setBool('background_play_prompted', true);
      // Optional: Show dialog here if needed
    }
  }

  void _onTrackCompleted() {
    if (!_autoPlayNext || playingAyahNumber.value == null || _playlist.isEmpty) return;
    final currentIndex = _playlist.indexWhere((a) => a.number == playingAyahNumber.value);
    if (currentIndex != -1 && currentIndex < _playlist.length - 1) {
      playAyah(_playlist[currentIndex + 1]);
    } else {
      playingAyahNumber.value = null;
    }
  }

  @override
  void onClose() { _player.dispose(); super.onClose(); }
}
