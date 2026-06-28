import '../models/notification_model.dart';
import '../../core/api/notification_api_provider.dart';

class NotificationRepository {
  final NotificationApiProvider _apiProvider;

  NotificationRepository(this._apiProvider);

  Future<List<AppNotification>> getNotifications(String userId) {
    return _apiProvider.getNotifications(userId);
  }

  Future<void> markAsRead(String notificationId) {
    return _apiProvider.markNotificationAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) {
    return _apiProvider.markAllNotificationsAsRead(userId);
  }

  Future<void> deleteNotification(String notificationId) {
    return _apiProvider.deleteNotification(notificationId);
  }

  Future<void> sendBroadcast(String title, String body, {String? imageUrl}) {
    return _apiProvider.sendBroadcastNotification(title, body, imageUrl: imageUrl);
  }
}
