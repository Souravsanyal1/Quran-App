import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_urls.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/word_model.dart';
import '../../data/models/bookmark_model.dart';
import '../../data/models/last_read_model.dart';
import '../../data/repositories/quran_repository.dart';
import '../../modules/settings/settings_controller.dart';
import '../../services/audio_player_service.dart';

class SurahDetailsController extends GetxController {
  final QuranRepository _repository = Get.find<QuranRepository>();
  final SettingsController _settings = Get.find<SettingsController>();
  final AudioPlayerService _audio = Get.find<AudioPlayerService>();

  final RxBool isLoading = true.obs;
  final RxBool isOffline = false.obs;
  final RxBool hasError = false.obs;
  final RxList<AyahModel> ayahs = <AyahModel>[].obs;
  final RxMap<int, List<WordModel>> ayahWords = <int, List<WordModel>>{}.obs;
  final RxBool isWordByWord = false.obs;
  final RxBool showTranslation = true.obs;
  final RxBool showPronunciation = true.obs;

  String get currentSurahName => _settings.isBangla
      ? (AppUrls.surahNamesBn[surahNumber] ?? surahName)
      : surahName;

  late final int surahNumber;
  late final String surahName;
  late final String surahMeaning;
  int? initialAyah;

  /// Expose audio state from the service (read-only delegates)
  RxnInt get playingAyahNumber => _audio.playingAyahNumber;
  RxBool get isPlaying => _audio.isPlaying;
  RxBool get isPlayerLoading => _audio.isPlayerLoading;
  RxBool get autoPlayNext => _audio.isPlaying; // kept for Switch binding

  /// Separate observable for the auto-play toggle
  final RxBool autoPlayNextToggle = true.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    surahNumber = args['surahNumber'] ?? 1;
    surahName = args['surahName'] ?? 'Al-Fatihah';
    surahMeaning = args['surahMeaning'] ?? '';
    initialAyah = args['initialAyah'];

    _loadAyahs();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    ever(playingAyahNumber, (int? ayahNum) {
      if (ayahNum != null && autoPlayNextToggle.value) {
        scrollToAyah(ayahs.firstWhere((a) => a.number == ayahNum).numberInSurah);
      }
    });
  }

  Future<void> toggleWordByWord() async {
    isWordByWord.toggle();
    if (isWordByWord.value && ayahWords.isEmpty) {
      isLoading.value = true;
      try {
        final words = await _repository.getSurahWords(surahNumber);
        ayahWords.assignAll(words);
      } catch (e) {
        Get.log('Error loading words: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> _loadAyahs() async {
    isLoading.value = true;
    isOffline.value = false;
    hasError.value = false;
    try {
      final list = await _repository.getSurahAyahs(surahNumber);

      if (list.isEmpty) {
        // Network failed — try serving from cache
        final cached = _repository.getSurahAyahsCached(surahNumber);
        if (cached.isNotEmpty) {
          ayahs.assignAll(cached);
          isOffline.value = true; // Show offline badge but content is available
          _audio.setPlaylist(
            ayahs: cached,
            contextLabel: 'Surah $surahName',
            autoPlayNext: autoPlayNextToggle.value,
          );
          saveLastRead(initialAyah ?? 1);
          if (initialAyah != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollToAyah(initialAyah!);
            });
          }
        } else {
          hasError.value = true; // No cache, no internet
        }
        return;
      }

      ayahs.assignAll(list);

      // Tell the audio service about this playlist
      _audio.setPlaylist(
        ayahs: list,
        contextLabel: 'Surah $surahName',
        autoPlayNext: autoPlayNextToggle.value,
      );

      // Save last read for this surah
      saveLastRead(initialAyah ?? 1);

      // Scroll to initialAyah if provided
      if (initialAyah != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToAyah(initialAyah!);
        });
      }
    } catch (e) {
      Get.log('Error loading ayahs: $e');
      // Try cache fallback on exception
      final cached = _repository.getSurahAyahsCached(surahNumber);
      if (cached.isNotEmpty) {
        ayahs.assignAll(cached);
        isOffline.value = true;
        _audio.setPlaylist(
          ayahs: cached,
          contextLabel: 'Surah $surahName',
          autoPlayNext: autoPlayNextToggle.value,
        );
      } else {
        hasError.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setAutoPlay(bool value) {
    autoPlayNextToggle.value = value;
    _audio.setAutoPlayNext(value);
  }

  /// Retry loading after an error (e.g. user tapped Retry button)
  Future<void> retryLoad() => _loadAyahs();

  void scrollToAyah(int ayahNumInSurah) {
    final index =
        ayahs.indexWhere((a) => a.numberInSurah == ayahNumInSurah);
    if (index != -1 && scrollController.hasClients) {
      scrollController.animateTo(
        index * 220.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> playAyah(AyahModel ayah) async {
    await _audio.playAyah(
      ayah,
      qariId: _settings.selectedQari.value,
    );
    saveLastRead(ayah.numberInSurah);
  }

  Future<void> togglePlayback() => _audio.togglePlayback();

  Future<void> playWordAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) return;
    try {
      await _audio.playAudioUrl(audioUrl);
    } catch (e) {
      Get.log('Error playing word audio: $e');
    }
  }

  Future<void> stopAudio() => _audio.stopAudio();

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  bool isBookmarked(AyahModel ayah) =>
      _repository.isBookmarked(surahNumber, ayah.numberInSurah);

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
    ayahs.refresh();
  }

  // ── Last Read ─────────────────────────────────────────────────────────────

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
    // Do NOT dispose the audio player — it lives in AudioPlayerService
    // Only clean up UI-only resources
    scrollController.dispose();
    super.onClose();
  }
}
