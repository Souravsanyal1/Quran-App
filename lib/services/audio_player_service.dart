import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/ayah_model.dart';
import '../modules/settings/settings_controller.dart';
import '../core/constants/app_urls.dart';
import '../modules/auth/auth_controller.dart';

class AudioPlayerService extends GetxService {
  late AudioPlayer _player;
  AudioPlayer get player => _player;
  
  final RxnInt playingAyahNumber = RxnInt();
  final RxBool isPlaying = false.obs;
  final RxBool isPlayerLoading = false.obs;
  
  List<AyahModel> _playlist = [];
  int _currentIndex = -1;
  bool _autoPlayNext = true;
  String _currentContextLabel = '';

  Future<AudioPlayerService> init() async {
    _player = AudioPlayer();
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isPlayerLoading.value = state.processingState == ProcessingState.loading || 
                            state.processingState == ProcessingState.buffering;
      
      if (state.processingState == ProcessingState.completed) {
        if (_autoPlayNext) {
          _playNext();
        } else {
          stopAudio();
        }
      }
    });
    return this;
  }

  void setPlaylist({required List<AyahModel> ayahs, required String contextLabel, bool autoPlayNext = true}) {
    _playlist = ayahs;
    _currentContextLabel = contextLabel;
    _autoPlayNext = autoPlayNext;
  }

  void setAutoPlayNext(bool value) => _autoPlayNext = value;

  Future<void> playAyah(AyahModel ayah, {required String qariId}) async {
    try {
      // If already playing this ayah, toggle pause/play
      if (playingAyahNumber.value == ayah.number && _player.processingState != ProcessingState.idle) {
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play();
        }
        return;
      }

      // Reset state to avoid UI freeze if previous load failed
      if (_player.processingState == ProcessingState.loading || _player.processingState == ProcessingState.buffering) {
        await _player.stop();
      }

      isPlayerLoading.value = true;
      playingAyahNumber.value = ayah.number;
      _currentIndex = _playlist.indexWhere((a) => a.number == ayah.number);

      // Get bitrate for the selected Qari
      final qari = AppUrls.qariList.firstWhere(
        (q) => q['id'] == qariId,
        orElse: () => {'id': qariId, 'bitrate': '128'},
      );
      final bitrate = qari['bitrate'] ?? '128';
      final String ayahUrl = 'https://cdn.islamic.network/quran/audio/$bitrate/$qariId/${ayah.number}.mp3';

      Get.log("Playing Ayah: $ayahUrl");

      AudioSource source;
      if (!kIsWeb) {
        final docDir = await getApplicationDocumentsDirectory();

        // ── 1. Check for fully downloaded file (from Download screen) ──────
        final downloadedFile = File('${docDir.path}/audio/$qariId/${ayah.number}.mp3');
        final cacheFile = File('${docDir.path}/audio_cache/${qariId}_${ayah.number}.mp3');

        if (await downloadedFile.exists() && await downloadedFile.length() > 0) {
          // Play from fully downloaded file (offline-safe)
          Get.log("Playing from local file: ${downloadedFile.path}");
          source = AudioSource.file(
            downloadedFile.path,
            tag: MediaItem(
              id: '${ayah.number}',
              album: _currentContextLabel,
              title: 'Ayah ${ayah.numberInSurah}',
              artist: qari['name'] ?? qariId,
              artUri: Uri.parse('asset:///assets/icons/icon_android.png'),
            ),
          );
        } else if (await cacheFile.exists() && await cacheFile.length() > 0) {
          // Play from audio cache file
          Get.log("Playing from cache file: ${cacheFile.path}");
          source = AudioSource.file(
            cacheFile.path,
            tag: MediaItem(
              id: '${ayah.number}',
              album: _currentContextLabel,
              title: 'Ayah ${ayah.numberInSurah}',
              artist: qari['name'] ?? qariId,
              artUri: Uri.parse('asset:///assets/icons/icon_android.png'),
            ),
          );
        } else {
          // Stream from network
          if (!await cacheFile.parent.exists()) await cacheFile.parent.create(recursive: true);
          source = AudioSource.uri(
            Uri.parse(ayahUrl),
            tag: MediaItem(
              id: '${ayah.number}',
              album: _currentContextLabel,
              title: 'Ayah ${ayah.numberInSurah}',
              artist: qari['name'] ?? qariId,
              artUri: Uri.parse('asset:///assets/icons/icon_android.png'),
            ),
          );
        }
      } else {
        source = AudioSource.uri(
          Uri.parse(ayahUrl),
          tag: MediaItem(
            id: '${ayah.number}',
            album: _currentContextLabel,
            title: 'Ayah ${ayah.numberInSurah}',
            artist: qari['name'] ?? qariId,
            artUri: Uri.parse('asset:///assets/icons/icon_android.png'),
          ),
        );
      }
      await _player.setAudioSource(source);
      await _player.play();

      // Track the play
      _trackPlay(ayah, qari['name'] ?? qariId);
    } catch (e) {
      isPlayerLoading.value = false;
      playingAyahNumber.value = null;
      Get.log("Audio play error: $e");
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('socket') || errStr.contains('network') || errStr.contains('connection') || errStr.contains('failed host')) {
        Get.snackbar(
          'No Internet',
          'Download this Surah for offline listening via the Download screen.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Playback Error', 'Could not play audio. Check your internet connection.');
      }
    }
  }


  void _trackPlay(AyahModel ayah, String qariName) async {
    try {
      final auth = Get.find<AuthController>();
      final uid = auth.user.value?.uid ?? 'anonymous';
      
      await FirebaseFirestore.instance.collection('play_logs').add({
        'uid': uid,
        'ayahNumber': ayah.number,
        'surahNumber': ayah.surahNumber,
        'ayahNumberInSurah': ayah.numberInSurah,
        'qari': qariName,
        'context': _currentContextLabel,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.log("Tracking error: $e");
    }
  }

  void _playNext() {
    if (_currentIndex != -1 && _currentIndex < _playlist.length - 1) {
      playAyah(_playlist[_currentIndex + 1], qariId: Get.find<SettingsController>().selectedQari.value);
    } else {
      stopAudio();
    }
  }

  Future<void> playAudioUrl(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      Get.log("Error playing URL: $e");
    }
  }

  Future<void> togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> stopAudio() async {
    await _player.stop();
    playingAyahNumber.value = null;
    _currentIndex = -1;
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
