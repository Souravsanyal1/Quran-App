import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_urls.dart';
import '../../data/models/notification_model.dart' as app_notification_model;

class NotificationApiProvider {
  final Dio _dio;
  final Logger _logger = Logger();

  NotificationApiProvider() : _dio = Dio(BaseOptions(
    baseUrl: AppUrls.backendBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'User-Agent': 'QuranApp/1.0.0 (Flutter Mobile)',
    },
  )) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => _logger.d(o.toString()),
    ));
  }

  /// Fetches notifications for a specific user.
  Future<List<app_notification_model.AppNotification>> getNotifications(String userId) async {
    if (AppUrls.backendBaseUrl.contains('your-backend-api.com')) {
      _logger.w('⚠️ API URL not configured! Please update backendBaseUrl in app_urls.dart');
      return []; // Return empty list instead of crashing
    }

    try {
      final response = await _dio.get(
        AppUrls.notifications,
        queryParameters: {'userId': userId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => app_notification_model.AppNotification.fromJson(json)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _logger.w('Notifications endpoint not found (404). Returning empty list.');
        return [];
      }
      _logger.e('Error fetching notifications: $e');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error: $e');
      return [];
    }
  }

  /// Marks a specific notification as read.
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final url = AppUrls.notificationsRead.replaceFirst('{notificationId}', notificationId);
      final response = await _dio.patch(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Marks all notifications for a user as read.
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final response = await _dio.patch(
        AppUrls.notificationsMarkAllRead,
        data: {'userId': userId},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Deletes a specific notification.
  Future<void> deleteNotification(String notificationId) async {
    try {
      final url = AppUrls.notificationsDelete.replaceFirst('{notificationId}', notificationId);
      final response = await _dio.delete(url);
      if (response.statusCode != 204) { // 204 No Content for successful deletion
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Sends a broadcast notification (Admin specific).
  Future<void> sendBroadcastNotification(String title, String body, {String? imageUrl}) async {
    try {
      final response = await _dio.post(
        AppUrls.notificationsBroadcast,
        data: {
          'title': title,
          'body': body,
          'imageUrl': imageUrl,
          'target': 'all', // Or specific user IDs
          'status': 'queued',
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to send broadcast notification: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error sending broadcast notification: $e');
      rethrow;
    }
  }
}
