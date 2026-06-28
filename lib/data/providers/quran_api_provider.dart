import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_urls.dart';

class QuranApiProvider {
  late final Dio _dio;
  final Logger _logger = Logger();

  QuranApiProvider() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (o) => _logger.d(o.toString()),
    ));
  }

  /// Fetch all 114 Surahs metadata
  Future<Response> fetchSurahList() async {
    return await _dio.get(AppUrls.quranSurahList);
  }

  /// Fetch a single Surah with Arabic + Bangla translation + pronunciation
  Future<Response> fetchSurah(int number) async {
    final url = AppUrls.quranSurah.replaceFirst('{number}', number.toString());
    return await _dio.get(url);
  }

  /// Fetch a Para (Juz) Arabic text (quran-uthmani)
  Future<Response> fetchParaArabic(int number) async {
    final url = AppUrls.quranParaArabic.replaceFirst('{number}', number.toString());
    return await _dio.get(url);
  }

  /// Fetch a Para (Juz) Bangla translation
  Future<Response> fetchParaBangla(int number) async {
    final url = AppUrls.quranParaBangla.replaceFirst('{number}', number.toString());
    return await _dio.get(url);
  }

  /// Get audio URL for a Surah by Qari ID
  String getSurahAudioUrl(int surahNumber, {String qariId = AppUrls.defaultQariId}) {
    final paddedNumber = surahNumber.toString().padLeft(3, '0');
    final qari = AppUrls.qariList.firstWhere(
          (q) => q['id'] == qariId,
      orElse: () => {'id': qariId, 'bitrate': '128'},
    );
    final bitrate = qari['bitrate'] ?? '128';
    return 'https://cdn.islamic.network/quran/audio-surah/$bitrate/$qariId/$paddedNumber.mp3';
  }

  /// Get audio URL for a single Ayah from EveryAyah (More Stable)
  String getEveryAyahAudioUrl(int globalAyahNumber, String qariId) {
    return '${AppUrls.everyAyahBase}/$qariId/$globalAyahNumber.mp3';
  }

  /// Get audio URL for a single Ayah (Islamic Network CDN)
  String getAyahAudioUrl(int globalAyahNumber, {String qariId = AppUrls.defaultQariId}) {
    final qari = AppUrls.qariList.firstWhere(
          (q) => q['id'] == qariId,
      orElse: () => {'id': qariId, 'bitrate': '128'},
    );
    final bitrate = qari['bitrate'] ?? '128';
    return 'https://cdn.islamic.network/quran/audio/$bitrate/$qariId/$globalAyahNumber.mp3';
  }

  /// Get Qibla direction from Aladhan API
  Future<Response> fetchQiblaDirection(double latitude, double longitude) async {
    final url = AppUrls.qiblaApi
        .replaceFirst('{latitude}', latitude.toString())
        .replaceFirst('{longitude}', longitude.toString());
    return await _dio.get(url);
  }

  /// Fetch Tafsir list from Quran.com
  Future<Response> fetchTafsirList() async {
    return await _dio.get(AppUrls.tafsirList);
  }

  /// Fetch Tafsir content for a specific ayah
  Future<Response> fetchAyahTafsir(int tafsirId, int surahNum, int ayahNum) async {
    final url = '${AppUrls.quranComBaseV4}/quran/tafsirs/$tafsirId/by_ayah/$surahNum:$ayahNum';
    return await _dio.get(url);
  }

  /// Fetch Dua categories from Hisn-ul-Muslim
  Future<Response> fetchDuaCategories() async {
    return await _dio.get('${AppUrls.hisnMuslimBase}/index.json');
  }

  /// Fetch Dua details by category ID
  Future<Response> fetchDuaDetails(int categoryId) async {
    return await _dio.get('${AppUrls.hisnMuslimBase}/$categoryId.json');
  }

  /// Prayer times by latitude/longitude and date
  Future<Response> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    required String date,
    int method = 2,
    int school = 1,
  }) async {
    final url = AppUrls.prayerByLocation.replaceFirst('{date}', date);
    return await _dio.get(url, queryParameters: {
      'latitude': latitude,
      'longitude': longitude,
      'method': method,
      'school': school,
      'adjustment': -1,
    });
  }

  /// Fetch word-by-word data for a Surah from Quran.com
  Future<Response> fetchWordsBySurah(int surahNumber) async {
    final url = AppUrls.wordsBySurah.replaceFirst('{number}', surahNumber.toString());
    return await _dio.get(url, queryParameters: {
      'words': 'true',
      'word_fields': 'text_uthmani,location,audio_url',
      'translation_fields': '131,161',
      'per_page': 300,
    });
  }

  /// Monthly calendar of prayer times
  Future<Response> fetchMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    int method = 2,
    int school = 1,
  }) async {
    final url = AppUrls.prayerMonthly
        .replaceFirst('{year}', year.toString())
        .replaceFirst('{month}', month.toString());
    return await _dio.get(url, queryParameters: {
      'latitude': latitude,
      'longitude': longitude,
      'method': method,
      'school': school,
      'adjustment': -1,
    });
  }

  /// Fetch Hadith books list
  Future<Response> fetchHadithBooks() async {
    return await _dio.get(AppUrls.hadithBooks);
  }

  /// Fetch Hadith from a specific book with range
  Future<Response> fetchHadithByBook(String bookId, {int start = 1, int end = 10}) async {
    final url = AppUrls.hadithByBook.replaceFirst('{book}', bookId);
    return await _dio.get(url, queryParameters: {'range': '$start-$end'});
  }

  /// Convert Gregorian date to Hijri
  Future<Response> fetchHijriDate(String date) async {
    final url = AppUrls.hijriDate.replaceFirst('{date}', date);
    return await _dio.get(url);
  }

  /// Fetch prayer times by city name
  Future<Response> fetchPrayerByCity({
    required String city,
    required String country,
    required String date,
    int method = 2,
  }) async {
    final url = AppUrls.prayerByCity.replaceFirst('{date}', date);
    return await _dio.get(url, queryParameters: {
      'city': city,
      'country': country,
      'method': method,
    });
  }

  /// Get location info by IP
  Future<Response> fetchLocationByIp() async {
    return await _dio.get(AppUrls.ipLocation);
  }

  /// Fetch a random Islamic quote
  Future<Response> fetchRandomQuote() async {
    return await _dio.get(AppUrls.randomQuote);
  }
}
