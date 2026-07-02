import '../models/notification_model.dart';
import '../models/notification_config_model.dart';
import '../../core/api/notification_api_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  final NotificationApiProvider _apiProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationRepository(this._apiProvider);

  // --- Remote Config Methods ---

  Future<Map<String, NotificationCategoryConfig>> getGlobalConfigs() async {
    final doc = await _firestore.collection('app_settings').doc('notification_configs').get();
    if (!doc.exists) return {};
    
    final categories = doc.data()?['categories'] as Map<String, dynamic>? ?? {};
    return categories.map((key, value) => MapEntry(
      key, 
      NotificationCategoryConfig.fromJson(value as Map<String, dynamic>)
    ));
  }

  Future<void> updateGlobalConfigs(Map<String, NotificationCategoryConfig> configs) async {
    final data = configs.map((key, value) => MapEntry(key, value.toJson()));
    await _firestore.collection('app_settings').doc('notification_configs').set({
      'categories': data,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, NotificationCategoryConfig>> streamGlobalConfigs() {
    return _firestore.collection('app_settings').doc('notification_configs').snapshots().map((doc) {
      if (!doc.exists) return {};
      final categories = doc.data()?['categories'] as Map<String, dynamic>? ?? {};
      return categories.map((key, value) => MapEntry(
        key, 
        NotificationCategoryConfig.fromJson(value as Map<String, dynamic>)
      ));
    });
  }

  // --- Custom Notifications Methods ---

  Stream<List<CustomNotificationConfig>> streamCustomNotifications() {
    return _firestore.collection('custom_notifications')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomNotificationConfig.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> addCustomNotification(CustomNotificationConfig config) async {
    await _firestore.collection('custom_notifications').add(config.toJson());
  }

  Future<void> updateCustomNotification(CustomNotificationConfig config) async {
    await _firestore.collection('custom_notifications').doc(config.id).update(config.toJson());
  }

  Future<void> deleteCustomNotification(String id) async {
    await _firestore.collection('custom_notifications').doc(id).delete();
  }

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
