import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/bookmark_model.dart';
import '../../data/models/last_read_model.dart';
import '../../data/repositories/quran_repository.dart';
import '../../modules/settings/settings_controller.dart';
import '../../data/providers/quran_api_provider.dart';
import '../../core/constants/app_urls.dart';

class SurahDetailsController extends GetxController {
  final QuranRepository _repository = Get.find<QuranRepository>();
  final SettingsController _settings = Get.find<SettingsController>();
  final QuranApiProvider _api = Get.find<QuranApiProvider>();

  late final AudioPlayer audioPlayer;
  
  final RxBool isLoading = true.obs;
  final RxList<AyahModel> ayahs = <AyahModel>[].obs;
  
  late final int surahNumber;
  late final String surahName;
  int? initialAyah;

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
    surahNumber = args['surahNumber'] ?? 1;
    surahName = args['surahName'] ?? 'Al-Fatihah';
    initialAyah = args['initialAyah'];

    _loadAyahs();
    _setupAudioListeners();
  }

  Future<void> _loadAyahs() async {
    isLoading.value = true;
    try {
      final list = await _repository.getSurahAyahs(surahNumber);
      ayahs.assignAll(list);
      
      // Save last read initially for this surah
      saveLastRead(initialAyah ?? 1);

      // If initialAyah is provided, scroll to it after rendering
      if (initialAyah != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToAyah(initialAyah!);
        });
      }
    } catch (e) {
      Get.log('Error loading ayahs: $e');
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

  void scrollToAyah(int ayahNumInSurah) {
    final index = ayahs.indexWhere((element) => element.numberInSurah == ayahNumInSurah);
    if (index != -1) {
      // Estimate height of each card: ~220px
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
    // If it's already playing, pause it
    if (playingAyahNumber.value == ayah.number && isPlaying.value) {
      await audioPlayer.pause();
      return;
    }

    // If it's paused, resume
    if (playingAyahNumber.value == ayah.number) {
      await audioPlayer.play();
      return;
    }

    // Load and play new ayah audio
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

      final AudioSource source;
      if (hasLocal) {
        source = AudioSource.file(
          localPath,
          tag: MediaItem(
            id: 'ayah_${ayah.number}',
            album: 'Surah $surahName',
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
            album: 'Surah $surahName',
            title: 'Ayah ${ayah.numberInSurah}',
            artist: qariName,
          ),
        );
      }

      await audioPlayer.setAudioSource(source);
      isPlayerLoading.value = false;
      await audioPlayer.play();
      
      // Update last read when playing
      saveLastRead(ayah.numberInSurah);
    } catch (e) {
      isPlayerLoading.value = false;
      Get.log('Error playing ayah: $e');
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
      scrollToAyah(nextAyah.numberInSurah);
      playAyah(nextAyah);
    } else {
      playingAyahNumber.value = null;
    }
  }

  // Bookmarks
  bool isBookmarked(AyahModel ayah) {
    return _repository.isBookmarked(surahNumber, ayah.numberInSurah);
  }

  Future<void> toggleBookmark(AyahModel ayah) async {
    if (isBookmarked(ayah)) {
      await _repository.removeBookmark(surahNumber, ayah.numberInSurah);
    } else {
      final bookmark = BookmarkModel(
        surahNumber: surahNumber,
        ayahNumber: ayah.numberInSurah,
        surahName: surahName,
        ayahText: ayah.text,
        savedAt: DateTime.now(),
      );
      await _repository.addBookmark(bookmark);
    }
    ayahs.refresh(); // Triggers rebuild of ayah list items
  }

  // Last Read
  Future<void> saveLastRead(int ayahNumInSurah) async {
    final lastRead = LastReadModel(
      surahNumber: surahNumber,
      ayahNumber: ayahNumInSurah,
      surahName: surahName,
      readAt: DateTime.now(),
    );
    await _repository.saveLastRead(lastRead);
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
