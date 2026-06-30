import '../models/notification_model.dart';
import '../../core/api/notification_api_provider.dart';

class NotificationRepository {
  final NotificationApiProvider _apiProvider;

  NotificationRepository(this._apiProvider);

  Future<List<AppNotification>> getNotifications(String userId, [DateTime? creationTime]) {
    return _apiProvider.getNotifications(userId, creationTime: creationTime);
  }

  Future<void> markAsRead(String userId, String notificationId) {
    return _apiProvider.markNotificationAsRead(userId, notificationId);
  }

  Future<void> markAllAsRead(String userId) {
    return _apiProvider.markAllNotificationsAsRead(userId);
  }

  Future<void> deleteNotification(String userId, String notificationId) {
    return _apiProvider.deleteNotification(userId, notificationId);
  }

  Future<void> deleteBulk(String userId, List<String> ids) {
    return _apiProvider.deleteNotificationsBulk(userId, ids);
  }

  Future<void> deleteAll(String userId) {
    return _apiProvider.deleteAllPersonalNotifications(userId);
  }

  Future<void> sendBroadcast(String title, String body, {String? imageUrl}) {
    return _apiProvider.sendBroadcastNotification(title, body, imageUrl: imageUrl);
  }
}
