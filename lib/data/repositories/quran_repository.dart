import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/quran_api_provider.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';
import '../models/word_model.dart';
import '../models/bookmark_model.dart';
import '../models/last_read_model.dart';

class QuranRepository {
  static const String _surahListBox = 'surah_list_v2';
  static const String _surahDataBox = 'surah_data_v2';
  static const String _paraDataBox  = 'para_data_v2';
  static const String _wordsDataBox = 'words_data_v2';
  static const String _bookmarksBox = 'bookmarks_v2';
  static const String _lastReadBox  = 'last_read_v2';

  late Box _surahListCache;
  late Box _surahDataCache;
  late Box _paraDataCache;
  late Box _wordsDataCache;
  late Box _bookmarksCache;
  late Box _lastReadCache;

  final Logger _logger = Logger();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _surahListCache = await Hive.openBox(_surahListBox);
    _surahDataCache = await Hive.openBox(_surahDataBox);
    _paraDataCache  = await Hive.openBox(_paraDataBox);
    _wordsDataCache = await Hive.openBox(_wordsDataBox);
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
  ///   [3] = en.transliteration (Pronunciation)
  Future<List<AyahModel>> getSurahAyahs(int surahNumber) async {
    await init();
    try {
      final cacheKey = 'surah_v4_$surahNumber';
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

  /// Returns a map of Ayah number -> List of WordModel
  Future<Map<int, List<WordModel>>> getSurahWords(int surahNumber) async {
    await init();
    try {
      final cacheKey = 'words_$surahNumber';
      final cached = _wordsDataCache.get(cacheKey);
      if (cached != null) {
        return _parseWordsFromCache(jsonDecode(cached as String));
      }

      final response = await _api.fetchWordsBySurah(surahNumber);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _wordsDataCache.put(cacheKey, jsonEncode(data));
        return _parseWordsFromCache(data);
      }
    } catch (e) {
      _logger.e('getSurahWords($surahNumber): $e');
    }
    return {};
  }

  Map<int, List<WordModel>> _parseWordsFromCache(Map<String, dynamic> data) {
    final Map<int, List<WordModel>> result = {};
    final List<dynamic> verses = data['verses'] ?? [];

    for (var verse in verses) {
      final int verseNum = verse['verse_number'] ?? 0;
      final List<dynamic> wordsJson = verse['words'] ?? [];
      final List<WordModel> words = wordsJson
          .map((w) => WordModel.fromJson(Map<String, dynamic>.from(w)))
          .toList();
      result[verseNum] = words;
    }
    return result;
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
    final translitAyahs = editions.length > 3
        ? List<Map<String, dynamic>>.from(editions[3]['ayahs'] ?? [])
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
        textBanglaTranslit: i < translitAyahs.length ? translitAyahs[i]['text'] : null,
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
      // Use v3 cache key — previous versions stored broken 404 responses
      final cacheKey = 'para_v3_$paraNumber';
      final cached = _paraDataCache.get(cacheKey);
      if (cached != null) {
        final decoded = jsonDecode(cached as String) as Map<String, dynamic>;
        return _parseParaAyahsMerged(
          decoded['arabic'] as Map<String, dynamic>,
          decoded['bangla']  as Map<String, dynamic>,
        );
      }

      // Fetch Arabic and Bangla in parallel
      final results = await Future.wait([
        _api.fetchParaArabic(paraNumber),
        _api.fetchParaBangla(paraNumber),
      ]);

      final arabicResp = results[0];
      final banglaResp = results[1];

      if (arabicResp.statusCode == 200 && banglaResp.statusCode == 200) {
        final arabicData = arabicResp.data as Map<String, dynamic>;
        final banglaData  = banglaResp.data  as Map<String, dynamic>;
        // Cache both together
        await _paraDataCache.put(
          cacheKey,
          jsonEncode({'arabic': arabicData, 'bangla': banglaData}),
        );
        return _parseParaAyahsMerged(arabicData, banglaData);
      }
    } catch (e) {
      _logger.e('getParaAyahs($paraNumber): $e');
    }
    return [];
  }

  List<AyahModel> _parseParaAyahsMerged(
    Map<String, dynamic> arabicData,
    Map<String, dynamic> banglaData,
  ) {
    // Each single-edition response has shape: {data: {ayahs: [...], edition: {...}, surahs: {...}}}
    final arabicWrapper = arabicData['data'];
    final banglaWrapper  = banglaData['data'];

    final arabicAyahs = arabicWrapper is Map
        ? List<Map<String, dynamic>>.from((arabicWrapper['ayahs'] as List?) ?? [])
        : <Map<String, dynamic>>[];
    final banglaAyahs  = banglaWrapper  is Map
        ? List<Map<String, dynamic>>.from((banglaWrapper['ayahs']  as List?) ?? [])
        : <Map<String, dynamic>>[];

    // Build a fast lookup: global ayah number -> bangla text
    final banglaMap = <int, String>{
      for (final b in banglaAyahs)
        if (b['number'] != null) (b['number'] as int): (b['text'] as String? ?? '')
    };

    return arabicAyahs.map((arabic) {
      final num = arabic['number'] as int? ?? 0;
      final surahNum = arabic['surah'] is Map
          ? (arabic['surah']['number'] as int?)
          : null;
      return AyahModel(
        number: num,
        numberInSurah: arabic['numberInSurah'] as int? ?? 0,
        surahNumber: surahNum,
        text: arabic['text'] as String? ?? '',
        textBangla: banglaMap[num],
        page: arabic['page'] as int? ?? 0,
        juz: arabic['juz'] as int? ?? 0,
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
    return _paraDataCache.containsKey('para_v3_$paraNumber');
  }

  Future<String> getLocalAudioPath(int globalAyahNumber, String qariId) async {
    final docDir = await getApplicationDocumentsDirectory();
    return '${docDir.path}/audio/$qariId/$globalAyahNumber.mp3';
  }

  Future<bool> isAyahAudioDownloaded(int globalAyahNumber, String qariId) async {
    final path = await getLocalAudioPath(globalAyahNumber, qariId);
    final file = File(path);
    return await file.exists() && await file.length() > 0;
  }

  Future<bool> isSurahAudioDownloaded(int surahNumber, String qariId) async {
    final ayahs = await getSurahAyahs(surahNumber);
    if (ayahs.isEmpty) return false;
    for (var ayah in ayahs) {
      if (!await isAyahAudioDownloaded(ayah.number, qariId)) {
        return false;
      }
    }
    return true;
  }

  Future<void> clearCache() async {
    await init();
    await _surahDataCache.clear();
    await _paraDataCache.clear();
  }
}
