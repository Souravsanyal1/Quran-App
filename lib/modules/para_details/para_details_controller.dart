import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/bookmark_model.dart';
import '../../data/models/surah_model.dart';
import '../../data/repositories/quran_repository.dart';
import '../../modules/settings/settings_controller.dart';
import '../../services/audio_player_service.dart';

class ParaDetailsController extends GetxController {
  final QuranRepository _repository = Get.find<QuranRepository>();
  final SettingsController _settings = Get.find<SettingsController>();
  final AudioPlayerService _audio = Get.find<AudioPlayerService>();

  final RxBool isLoading = true.obs;
  final RxList<AyahModel> ayahs = <AyahModel>[].obs;
  final List<SurahModel> _surahs = [];

  late final int paraNumber;
  late final String paraName;

  /// Delegates to the shared audio service
  RxnInt get playingAyahNumber => _audio.playingAyahNumber;
  RxBool get isPlaying => _audio.isPlaying;
  RxBool get isPlayerLoading => _audio.isPlayerLoading;

  final RxBool autoPlayNext = true.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    paraNumber = args['paraNumber'] ?? 1;
    paraName = args['paraName'] ?? 'Alif Lam Meem';

    _loadAyahsAndSurahs();
  }

  Future<void> _loadAyahsAndSurahs() async {
    isLoading.value = true;
    try {
      final surahList = await _repository.getSurahList();
      _surahs.assignAll(surahList);

      final list = await _repository.getParaAyahs(paraNumber);
      ayahs.assignAll(list);

      // Tell audio service about this playlist
      _audio.setPlaylist(
        ayahs: list,
        contextLabel: 'Juz $paraNumber - $paraName',
        autoPlayNext: autoPlayNext.value,
      );
    } catch (e) {
      Get.log('Error loading para data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retryLoadData() async {
    await _loadAyahsAndSurahs();
  }

  void setAutoPlay(bool value) {
    autoPlayNext.value = value;
    _audio.setAutoPlayNext(value);
  }

  void scrollToAyah(int globalAyahNum) {
    final index = ayahs.indexWhere((a) => a.number == globalAyahNum);
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
  }

  Future<void> stopAudio() => _audio.stopAudio();

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  bool isBookmarked(AyahModel ayah) {
    if (ayah.surahNumber == null) return false;
    return _repository.isBookmarked(ayah.surahNumber!, ayah.numberInSurah);
  }

  Future<void> toggleBookmark(AyahModel ayah) async {
    if (ayah.surahNumber == null) return;

    if (isBookmarked(ayah)) {
      await _repository.removeBookmark(ayah.surahNumber!, ayah.numberInSurah);
    } else {
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
    // Do NOT dispose audio player — it lives in AudioPlayerService
    scrollController.dispose();
    super.onClose();
  }
}
