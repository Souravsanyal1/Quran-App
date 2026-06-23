import 'package:flutter/material.dart';
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

  // Advanced Search Controller & States
  final searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedTypeFilter = 'All'.obs; // 'All', 'Meccan', 'Medinan'

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

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
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

  // Advanced phonetic & multilingual search
  void filterSurahs() {
    final query = searchQuery.value.trim();
    final filter = selectedTypeFilter.value;

    if (query.isEmpty && filter == 'All') {
      filteredSurahList.assignAll(surahList);
      return;
    }

    final cleanQuery = query.toLowerCase();

    // Helper to normalize text (removes hyphens, spaces, apostrophes, double letters, etc.)
    String normalize(String text) {
      return text
          .toLowerCase()
          .replaceAll(RegExp(r"[^a-zA-Z0-9\u0980-\u09ff]"), "")
          .replaceAll("aa", "a")
          .replaceAll("ee", "i")
          .replaceAll("oo", "u")
          .replaceAll("uu", "u")
          .replaceAll("al", "");
    }

    final normalizedQuery = normalize(cleanQuery);

    filteredSurahList.assignAll(
      surahList.where((surah) {
        // 1. Revelation Type Filter
        if (filter == 'Meccan' && !surah.revelationType.toLowerCase().contains('meccan')) {
          return false;
        }
        if (filter == 'Medinan' && !surah.revelationType.toLowerCase().contains('medinan')) {
          return false;
        }

        // If no query exists, type filter match is sufficient
        if (cleanQuery.isEmpty) return true;

        // 2. Direct Surah Number Match
        if (surah.number.toString() == cleanQuery) {
          return true;
        }

        // 3. Normalised phonetic name match
        final normEnglishName = normalize(surah.englishName);
        final normTranslation = normalize(surah.englishNameTranslation);

        if (normEnglishName.contains(normalizedQuery) ||
            normTranslation.contains(normalizedQuery)) {
          return true;
        }

        // 4. Arabic name match
        if (surah.name.contains(cleanQuery)) {
          return true;
        }

        // 5. Special phonetic matches for common Bangla surah searches
        final Map<String, List<int>> banglaMap = {
          'ফাতিহা': [1],
          'বাকারা': [2],
          'ইমরান': [3],
          'নিসা': [4],
          'মায়েদা': [5],
          'আনআম': [6],
          'আরাফ': [7],
          'আনফাল': [8],
          'তাওবা': [9],
          'ইউনুস': [10],
          'হুদ': [11],
          'ইউসুফ': [12],
          'রাদ': [13],
          'ইব্রাহিম': [14],
          'হিজর': [15],
          'নাহল': [16],
          'ইসরা': [17],
          'কাহফ': [18],
          'মারইয়াম': [19],
          'ত্বহা': [20],
          'আম্বিয়া': [21],
          'হজ্জ': [22],
          'মুমিনুন': [23],
          'নূর': [24],
          'ফুরকান': [25],
          'শুয়ারা': [26],
          'নামল': [27],
          'কাসাস': [28],
          'আনকাবুত': [29],
          'রুম': [30],
          'লোকমান': [31],
          'সাজদাহ': [32],
          'আহযাব': [33],
          'সাবা': [34],
          'ফাতির': [35],
          'ইয়াসীন': [36],
          'সাফফাত': [37],
          'সোয়াদ': [38],
          'যুমার': [39],
          'গাফির': [40],
          'ফুসসিলাত': [41],
          'শুরা': [42],
          'যুখরুফ': [43],
          'দুখান': [44],
          'জাসিয়াহ': [45],
          'আহকাফ': [46],
          'মুহাম্মদ': [47],
          'ফাতহ': [48],
          'হুজুরাত': [49],
          'কাফ': [50],
          'যারিয়াত': [51],
          'তূর': [52],
          'নাজম': [53],
          'কামার': [54],
          'রাহমান': [55],
          'ওয়াকিয়াহ': [56],
          'হাদীদ': [57],
          'মুজাদালাহ': [58],
          'হাশর': [59],
          'মুমতাহিনাহ': [60],
          'সাফ': [61],
          'জুমুআহ': [62],
          'মুনাফিকুন': [63],
          'তাগাবুন': [64],
          'তালাক': [65],
          'তাহরীম': [66],
          'মুলক': [67],
          'কলম': [68],
          'হাক্কাহ': [69],
          'মাআরিজ': [70],
          'নূহ': [71],
          'জ্বীন': [72],
          'মুযযামমিল': [73],
          'মুদ্দাসসির': [74],
          'কিয়ামাহ': [75],
          'ইনসান': [76],
          'মুরসালাত': [77],
          'নাবা': [78],
          'নাযিয়াত': [79],
          'আবাসা': [80],
          'তাকবীর': [81],
          'ইনফিতার': [82],
          'মুতাফফিফীন': [83],
          'ইনশিকাক': [84],
          'বুরুজ': [85],
          'তারিক': [86],
          'আলা': [87],
          'গাশিয়াহ': [88],
          'ফজর': [89],
          'বালাদ': [90],
          'শামস': [91],
          'লাইল': [92],
          'দুহা': [93],
          'ইনশিরাহ': [94],
          'তীন': [95],
          'আলাক': [96],
          'কদর': [97],
          'বাইয়্যিনাহ': [98],
          'যিলযাল': [99],
          'আদিয়াত': [100],
          'কারিআহ': [101],
          'তাকাসুর': [102],
          'আসর': [103],
          'হুমাযাহ': [104],
          'ফীল': [105],
          'কুরাইশ': [106],
          'মাউন': [107],
          'কাওসার': [108],
          'কাফিরুন': [109],
          'নাসর': [110],
          'লাহাব': [111],
          'ইখলাস': [112],
          'ফালাক': [113],
          'নাস': [114],
        };

        for (final entry in banglaMap.entries) {
          if (entry.key.contains(cleanQuery) || cleanQuery.contains(entry.key)) {
            if (entry.value.contains(surah.number)) {
              return true;
            }
          }
        }

        return false;
      }).toList(),
    );
  }

  void searchSurah(String query) {
    searchQuery.value = query;
    filterSurahs();
  }

  void setTypeFilter(String filter) {
    selectedTypeFilter.value = filter;
    filterSurahs();
  }

  void clearSearch() {
    searchQuery.value = '';
    searchTextController.clear();
    filterSurahs();
  }

  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    await _repository.removeBookmark(surahNumber, ayahNumber);
    loadBookmarksAndLastRead();
  }
}
