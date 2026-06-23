import 'package:get/get.dart';
import '../../data/models/surah_model.dart';
import '../../data/models/para_model.dart';
import '../../data/models/bookmark_model.dart';
import '../../data/models/last_read_model.dart';
import '../../data/repositories/quran_repository.dart';

class QuranController extends GetxController {
  final QuranRepository _repository = Get.find<QuranRepository>();

  final RxBool isLoading = true.obs;
  final RxList<SurahModel> surahList = <SurahModel>[].obs;
  final RxList<SurahModel> filteredSurahList = <SurahModel>[].obs;
  final RxList<ParaModel> paraList = <ParaModel>[].obs;
  final RxList<BookmarkModel> bookmarkList = <BookmarkModel>[].obs;
  final Rxn<LastReadModel> lastRead = Rxn<LastReadModel>();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    paraList.addAll(ParaModel.allParas);
    loadQuranData();
  }

  @override
  void onReady() {
    super.onReady();
    loadBookmarksAndLastRead();
  }

  Future<void> loadQuranData() async {
    isLoading.value = true;
    try {
      final surahs = await _repository.getSurahList();
      surahList.assignAll(surahs);
      filteredSurahList.assignAll(surahs);
      loadBookmarksAndLastRead();
    } catch (e) {
      Get.log('Error loading Quran data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadBookmarksAndLastRead() {
    bookmarkList.assignAll(_repository.getBookmarks());
    lastRead.value = _repository.getLastRead();
  }

  void searchSurah(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredSurahList.assignAll(surahList);
    } else {
      filteredSurahList.assignAll(
        surahList.where((surah) =>
            surah.englishName.toLowerCase().contains(query.toLowerCase()) ||
            surah.englishNameTranslation.toLowerCase().contains(query.toLowerCase()) ||
            surah.number.toString() == query),
      );
    }
  }

  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    await _repository.removeBookmark(surahNumber, ayahNumber);
    loadBookmarksAndLastRead();
  }
}
