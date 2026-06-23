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
      headers: {'Content-Type': 'application/json'},
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

  /// Fetch a Para (Juz) with Arabic + Bangla translation
  Future<Response> fetchPara(int number) async {
    final url = AppUrls.quranPara.replaceFirst('{number}', number.toString());
    return await _dio.get(url);
  }

  /// Get audio URL for a Surah by Qari ID
  String getSurahAudioUrl(int surahNumber, {String qariId = AppUrls.defaultQariId}) {
    final paddedNumber = surahNumber.toString().padLeft(3, '0');
    return '${AppUrls.audioBase}/$qariId/$paddedNumber.mp3';
  }

  /// Get audio URL for a single Ayah
  String getAyahAudioUrl(int globalAyahNumber,
      {String qariId = AppUrls.defaultQariId}) {
    return '${AppUrls.ayahAudioBase}/$qariId/$globalAyahNumber.mp3';
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
    });
  }

}
