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

  /// Get audio URL for a single Ayah
  String getAyahAudioUrl(int globalAyahNumber,
      {String qariId = AppUrls.defaultQariId}) {
    final qari = AppUrls.qariList.firstWhere(
      (q) => q['id'] == qariId,
      orElse: () => {'id': qariId, 'bitrate': '128'},
    );
    final bitrate = qari['bitrate'] ?? '128';
    return 'https://cdn.islamic.network/quran/audio/$bitrate/$qariId/$globalAyahNumber.mp3';
  }

  /// Prayer times by latitude/longitude and date
  Future<Response> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    required String date, // format: DD-MM-YYYY
    int method = 2,
  }) async {
    final url = AppUrls.prayerByLocation.replaceFirst('{date}', date);
    return await _dio.get(url, queryParameters: {
      'latitude': latitude,
      'longitude': longitude,
      'method': method,
      'adjustment': -1, // Bangladesh observes Hijri date 1 day behind astronomical calculation
    });
  }

  /// Monthly calendar of prayer times by latitude/longitude, year and month
  Future<Response> fetchMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    int method = 2,
  }) async {
    final url = AppUrls.prayerMonthly
        .replaceFirst('{year}', year.toString())
        .replaceFirst('{month}', month.toString());
    return await _dio.get(url, queryParameters: {
      'latitude': latitude,
      'longitude': longitude,
      'method': method,
      'adjustment': -1, // Bangladesh observes Hijri date 1 day behind astronomical calculation
    });
  }

}
