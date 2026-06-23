import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../providers/quran_api_provider.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';
import '../models/bookmark_model.dart';
import '../models/last_read_model.dart';

class QuranRepository {
  static const String _surahListBox = 'surah_list_v2';
  static const String _surahDataBox = 'surah_data_v2';
  static const String _paraDataBox  = 'para_data_v2';
  static const String _bookmarksBox = 'bookmarks_v2';
  static const String _lastReadBox  = 'last_read_v2';

  late Box _surahListCache;
  late Box _surahDataCache;
  late Box _paraDataCache;
  late Box _bookmarksCache;
  late Box _lastReadCache;

  final Logger _logger = Logger();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _surahListCache = await Hive.openBox(_surahListBox);
    _surahDataCache = await Hive.openBox(_surahDataBox);
    _paraDataCache  = await Hive.openBox(_paraDataBox);
    _bookmarksCache = await Hive.openBox(_bookmarksBox);
    _lastReadCache  = await Hive.openBox(_lastReadBox);
    _initialized = true;
  }

  QuranApiProvider get _api => Get.find<QuranApiProvider>();

  // ── Surah List ────────────────────────────────────────────────────────────

  Future<List<SurahModel>> getSurahList() async {
    await init();
    try {
      final cached = _surahListCache.get('list');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached as String);
        return decoded.map((e) => SurahModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      final response = await _api.fetchSurahList();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        await _surahListCache.put('list', jsonEncode(data));
        return data.map((e) => SurahModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      _logger.e('getSurahList: $e');
    }
    return [];
  }

  // ── Surah Detail ──────────────────────────────────────────────────────────

  /// Returns list of ayahs merged from editions:
  ///   [0] = quran-uthmani (Arabic)
  ///   [1] = bn.bengali     (Bangla)
  ///   [2] = en.asad        (English)
  Future<List<AyahModel>> getSurahAyahs(int surahNumber) async {
    await init();
    try {
      final cacheKey = 'surah_$surahNumber';
      final cached = _surahDataCache.get(cacheKey);
      if (cached != null) {
        return _parseAyahsFromCache(jsonDecode(cached as String));
      }
      final response = await _api.fetchSurah(surahNumber);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _surahDataCache.put(cacheKey, jsonEncode(data));
        return _parseAyahsFromCache(data);
      }
    } catch (e) {
      _logger.e('getSurahAyahs($surahNumber): $e');
    }
    return [];
  }

  List<AyahModel> _parseAyahsFromCache(Map<String, dynamic> data) {
    final List<dynamic> editions = data['data'] ?? [];
    if (editions.isEmpty) return [];

    final int surahNum = editions[0]['number'] ?? 0;
    final arabicAyahs = List<Map<String, dynamic>>.from(editions[0]['ayahs'] ?? []);
    final banglaAyahs = editions.length > 1
        ? List<Map<String, dynamic>>.from(editions[1]['ayahs'] ?? [])
        : <Map<String, dynamic>>[];
    final englishAyahs = editions.length > 2
        ? List<Map<String, dynamic>>.from(editions[2]['ayahs'] ?? [])
        : <Map<String, dynamic>>[];

    return arabicAyahs.asMap().entries.map((entry) {
      final i = entry.key;
      final arabic = entry.value;
      return AyahModel(
        number: arabic['number'] ?? 0,
        numberInSurah: arabic['numberInSurah'] ?? i + 1,
        surahNumber: surahNum,
        text: arabic['text'] ?? '',
        textBangla: i < banglaAyahs.length ? banglaAyahs[i]['text'] : null,
        textEnglish: i < englishAyahs.length ? englishAyahs[i]['text'] : null,
        page: arabic['page'] ?? 0,
        juz: arabic['juz'] ?? 0,
      );
    }).toList();
  }

  // ── Para / Juz ────────────────────────────────────────────────────────────

  Future<List<AyahModel>> getParaAyahs(int paraNumber) async {
    await init();
    try {
      final cacheKey = 'para_$paraNumber';
      final cached = _paraDataCache.get(cacheKey);
      if (cached != null) {
        return _parseParaAyahs(jsonDecode(cached as String));
      }
      final response = await _api.fetchPara(paraNumber);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _paraDataCache.put(cacheKey, jsonEncode(data));
        return _parseParaAyahs(data);
      }
    } catch (e) {
      _logger.e('getParaAyahs($paraNumber): $e');
    }
    return [];
  }

  List<AyahModel> _parseParaAyahs(Map<String, dynamic> data) {
    final List<dynamic> editions = data['data'] ?? [];
    if (editions.isEmpty) return [];

    final arabicAyahs = List<Map<String, dynamic>>.from(editions[0]['ayahs'] ?? []);
    final banglaAyahs = editions.length > 1
        ? List<Map<String, dynamic>>.from(editions[1]['ayahs'] ?? [])
        : <Map<String, dynamic>>[];

    return arabicAyahs.asMap().entries.map((entry) {
      final i = entry.key;
      final arabic = entry.value;
      final surahNum = arabic['surah'] != null ? (arabic['surah']['number'] as int?) : null;
      return AyahModel(
        number: arabic['number'] ?? 0,
        numberInSurah: arabic['numberInSurah'] ?? i + 1,
        surahNumber: surahNum,
        text: arabic['text'] ?? '',
        textBangla: i < banglaAyahs.length ? banglaAyahs[i]['text'] : null,
        page: arabic['page'] ?? 0,
        juz: arabic['juz'] ?? 0,
      );
    }).toList();
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<void> addBookmark(BookmarkModel bookmark) async {
    await init();
    await _bookmarksCache.put(bookmark.key, bookmark.toMap());
  }

  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    await init();
    await _bookmarksCache.delete('${surahNumber}_$ayahNumber');
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    if (!_initialized) return false;
    return _bookmarksCache.containsKey('${surahNumber}_$ayahNumber');
  }

  List<BookmarkModel> getBookmarks() {
    if (!_initialized) return [];
    return _bookmarksCache.values
        .map((e) => BookmarkModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  // ── Last Read ─────────────────────────────────────────────────────────────

  Future<void> saveLastRead(LastReadModel lastRead) async {
    await init();
    await _lastReadCache.put('last', lastRead.toMap());
  }

  LastReadModel? getLastRead() {
    if (!_initialized) return null;
    final data = _lastReadCache.get('last');
    if (data == null) return null;
    return LastReadModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  // ── Cache management ──────────────────────────────────────────────────────

  bool isSurahCached(int surahNumber) {
    if (!_initialized) return false;
    return _surahDataCache.containsKey('surah_$surahNumber');
  }

  bool isParaCached(int paraNumber) {
    if (!_initialized) return false;
    return _paraDataCache.containsKey('para_$paraNumber');
  }

  Future<void> clearCache() async {
    await init();
    await _surahDataCache.clear();
    await _paraDataCache.clear();
  }
}
