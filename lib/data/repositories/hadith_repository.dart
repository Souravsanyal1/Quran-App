import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../providers/hadith_api_provider.dart';
import '../models/hadith_model.dart';

class HadithRepository {
  static const String _hadithBooksBox = 'hadith_books';
  static const String _hadithDataBox = 'hadith_data';

  late Box _booksCache;
  late Box _hadithCache;

  final Logger _logger = Logger();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _booksCache = await Hive.openBox(_hadithBooksBox);
    _hadithCache = await Hive.openBox(_hadithDataBox);
    _initialized = true;
  }

  HadithApiProvider get _api => Get.find<HadithApiProvider>();

  Future<List<HadithBook>> getBooks() async {
    await init();
    try {
      final cached = _booksCache.get('list');
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached as String);
        return decoded.map((e) => HadithBook.fromJson(Map<String, dynamic>.from(e))).toList();
      }

      final response = await _api.fetchBooks();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        await _booksCache.put('list', jsonEncode(data));
        return data.map((e) => HadithBook.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      _logger.e('getBooks: $e');
    }
    return [];
  }

  Future<List<Hadith>> getHadiths(String bookId, {int start = 1, int end = 50}) async {
    await init();
    try {
      final cacheKey = '${bookId}_${start}_$end';
      final cached = _hadithCache.get(cacheKey);
      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached as String);
        return decoded.map((e) => Hadith.fromJson(Map<String, dynamic>.from(e))).toList();
      }

      final response = await _api.fetchHadiths(bookId, start: start, end: end);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['hadiths'];
        await _hadithCache.put(cacheKey, jsonEncode(data));
        return data.map((e) => Hadith.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      _logger.e('getHadiths($bookId): $e');
    }
    return [];
  }

  Future<Hadith?> getHadithDetail(String bookId, int number) async {
    await init();
    try {
      final response = await _api.fetchHadithDetail(bookId, number);
      if (response.statusCode == 200) {
        final data = response.data['data']['contents'];
        return Hadith.fromJson(data);
      }
    } catch (e) {
      _logger.e('getHadithDetail($bookId, $number): $e');
    }
    return null;
  }
}
