import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_urls.dart';

class AdminApiProvider {
  final Dio _dio;
  final Logger _logger = Logger();

  AdminApiProvider() : _dio = Dio(BaseOptions(
    baseUrl: AppUrls.backendBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'User-Agent': 'QuranAppAdmin/1.0.0 (Flutter Mobile)',
    },
  )) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => _logger.d(o.toString()),
    ));
  }

  // ── Banners Management ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final response = await _dio.get('banners');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to fetch banners: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching banners: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addBanner(Map<String, dynamic> bannerData) async {
    try {
      final response = await _dio.post('banners', data: bannerData);
      if (response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to add banner: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error adding banner: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBanner(String bannerId, Map<String, dynamic> bannerData) async {
    try {
      final response = await _dio.patch('banners/$bannerId', data: bannerData);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to update banner: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error updating banner: $e');
      rethrow;
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      final response = await _dio.delete('banners/$bannerId');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete banner: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error deleting banner: $e');
      rethrow;
    }
  }

  // ── Custom Ads Management ───────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCustomAds() async {
    try {
      final response = await _dio.get('custom-ads');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to fetch custom ads: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching custom ads: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addCustomAd(Map<String, dynamic> adData) async {
    try {
      final response = await _dio.post('custom-ads', data: adData);
      if (response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to add custom ad: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error adding custom ad: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCustomAd(String adId, Map<String, dynamic> adData) async {
    try {
      final response = await _dio.patch('custom-ads/$adId', data: adData);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to update custom ad: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error updating custom ad: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomAd(String adId) async {
    try {
      final response = await _dio.delete('custom-ads/$adId');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete custom ad: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error deleting custom ad: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> toggleCustomAdStatus(String adId, String status) async {
    try {
      final response = await _dio.patch('custom-ads/$adId/status', data: {'status': status});
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to toggle custom ad status: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error toggling custom ad status: $e');
      rethrow;
    }
  }

  // ── Static Banners Management ───────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getStaticBanners() async {
    try {
      final response = await _dio.get('static-banners');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to fetch static banners: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching static banners: $e');
      rethrow;
    }
  }

  Future<void> deleteStaticBanner(String bannerId) async {
    try {
      final response = await _dio.delete('static-banners/$bannerId');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete static banner: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error deleting static banner: $e');
      rethrow;
    }
  }

  // ── Prayer Settings Management ──────────────────────────────────────────

  Future<Map<String, dynamic>> getPrayerSettings() async {
    try {
      final response = await _dio.get('settings/prayer');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'] ?? {};
        return data;
      } else {
        throw Exception('Failed to fetch prayer settings: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching prayer settings: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> savePrayerSettings(Map<String, dynamic> settingsData) async {
    try {
      final response = await _dio.patch('settings/prayer', data: settingsData);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to save prayer settings: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error saving prayer settings: $e');
      rethrow;
    }
  }

  // ── Admin Users Management ──────────────────────────────────────────────
  Future<int> getAdminsCount() async {
    try {
      final response = await _dio.get('admins/count');
      if (response.statusCode == 200) {
        return (response.data['count'] as num?)?.toInt() ?? 0;
      } else {
        throw Exception('Failed to fetch admins count: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching admins count: $e');
      return 0;
    }
  }
}
