import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/bookmark_model.dart';
import '../../data/models/surah_model.dart';
import '../../data/repositories/quran_repository.dart';
import '../../modules/settings/settings_controller.dart';
import '../../data/providers/quran_api_provider.dart';
import '../../core/constants/app_urls.dart';

class ParaDetailsController extends GetxController {
  final QuranRepository _repository = Get.find<QuranRepository>();
  final SettingsController _settings = Get.find<SettingsController>();
  final QuranApiProvider _api = Get.find<QuranApiProvider>();

  late final AudioPlayer audioPlayer;
  
  final RxBool isLoading = true.obs;
  final RxList<AyahModel> ayahs = <AyahModel>[].obs;
  final List<SurahModel> _surahs = [];
  
  late final int paraNumber;
  late final String paraName;

  final RxnInt playingAyahNumber = RxnInt(); // Global ayah number
  final RxBool isPlaying = false.obs;
  final RxBool isPlayerLoading = false.obs;
  final RxBool autoPlayNext = true.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    paraNumber = args['paraNumber'] ?? 1;
    paraName = args['paraName'] ?? 'Alif Lam Meem';

    _loadAyahsAndSurahs();
    _setupAudioListeners();
  }

  Future<void> _loadAyahsAndSurahs() async {
    isLoading.value = true;
    try {
      final surahList = await _repository.getSurahList();
      _surahs.assignAll(surahList);

      final list = await _repository.getParaAyahs(paraNumber);
      ayahs.assignAll(list);
    } catch (e) {
      Get.log('Error loading para data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupAudioListeners() {
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _onAudioCompleted();
      }
    });
  }

  void scrollToAyah(int globalAyahNum) {
    final index = ayahs.indexWhere((element) => element.number == globalAyahNum);
    if (index != -1) {
      final targetOffset = index * 220.0;
      if (scrollController.hasClients) {
        scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> playAyah(AyahModel ayah) async {
    if (playingAyahNumber.value == ayah.number && isPlaying.value) {
      await audioPlayer.pause();
      return;
    }

    if (playingAyahNumber.value == ayah.number) {
      await audioPlayer.play();
      return;
    }

    try {
      isPlayerLoading.value = true;
      playingAyahNumber.value = ayah.number;
      
      final qariId = _settings.selectedQari.value;
      final hasLocal = await _repository.isAyahAudioDownloaded(ayah.number, qariId);
      final localPath = await _repository.getLocalAudioPath(ayah.number, qariId);
      
      final qariName = AppUrls.qariList.firstWhere(
        (element) => element['id'] == qariId,
        orElse: () => {'id': qariId, 'name': 'Reciter'},
      )['name'] ?? 'Reciter';
      
      final surahName = getSurahNameForAyah(ayah);

      final AudioSource source;
      if (hasLocal) {
        source = AudioSource.file(
          localPath,
          tag: MediaItem(
            id: 'ayah_${ayah.number}',
            album: surahName,
            title: 'Ayah ${ayah.numberInSurah}',
            artist: qariName,
          ),
        );
      } else {
        final url = _api.getAyahAudioUrl(ayah.number, qariId: qariId);
        source = AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: 'ayah_${ayah.number}',
            album: surahName,
            title: 'Ayah ${ayah.numberInSurah}',
            artist: qariName,
          ),
        );
      }

      await audioPlayer.setAudioSource(source);
      isPlayerLoading.value = false;
      await audioPlayer.play();
    } catch (e) {
      isPlayerLoading.value = false;
      Get.log('Error playing para ayah: $e');
      Get.snackbar(
        'Audio Error',
        'Could not load audio recitation. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    playingAyahNumber.value = null;
  }

  void _onAudioCompleted() {
    if (!autoPlayNext.value || playingAyahNumber.value == null) return;

    final currentIndex = ayahs.indexWhere((element) => element.number == playingAyahNumber.value);
    if (currentIndex != -1 && currentIndex < ayahs.length - 1) {
      final nextAyah = ayahs[currentIndex + 1];
      scrollToAyah(nextAyah.number);
      playAyah(nextAyah);
    } else {
      playingAyahNumber.value = null;
    }
  }

  // Bookmarks
  bool isBookmarked(AyahModel ayah) {
    if (ayah.surahNumber == null) return false;
    return _repository.isBookmarked(ayah.surahNumber!, ayah.numberInSurah);
  }

  Future<void> toggleBookmark(AyahModel ayah) async {
    if (ayah.surahNumber == null) return;

    if (isBookmarked(ayah)) {
      await _repository.removeBookmark(ayah.surahNumber!, ayah.numberInSurah);
    } else {
      // Find surah name
      final surah = _surahs.firstWhereOrNull((s) => s.number == ayah.surahNumber);
      final sName = surah?.englishName ?? 'Surah ${ayah.surahNumber}';
      
      final bookmark = BookmarkModel(
        surahNumber: ayah.surahNumber!,
        ayahNumber: ayah.numberInSurah,
        surahName: sName,
        ayahText: ayah.text,
        savedAt: DateTime.now(),
      );
      await _repository.addBookmark(bookmark);
    }
    ayahs.refresh();
  }

  String getSurahNameForAyah(AyahModel ayah) {
    if (ayah.surahNumber == null) return '';
    final surah = _surahs.firstWhereOrNull((s) => s.number == ayah.surahNumber);
    return surah?.englishName ?? 'Surah ${ayah.surahNumber}';
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
