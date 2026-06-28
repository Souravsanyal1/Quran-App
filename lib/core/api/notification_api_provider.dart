import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../data/models/notification_model.dart' as app_notification_model;

class NotificationApiProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  NotificationApiProvider();

  /// Fetches notifications for a specific user.
  Future<List<app_notification_model.AppNotification>> getNotifications(String userId) async {
    try {
      // 1. Get personal notifications
      final personalQuery = await _firestore.collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();
      
      final personal = personalQuery.docs.map((doc) => 
        app_notification_model.AppNotification.fromJson({...doc.data(), 'id': doc.id})).toList();

      // 2. Get broadcast notifications
      final broadcastQuery = await _firestore.collection('broadcast_notifications')
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();
      
      final broadcast = broadcastQuery.docs.map((doc) => 
        app_notification_model.AppNotification.fromJson({...doc.data(), 'id': doc.id})).toList();

      // Combine and sort
      final all = [...personal, ...broadcast];
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return all;
    } catch (e) {
      _logger.e('Error fetching notifications from Firestore: $e');
      return [];
    }
  }

  /// Marks a specific notification as read.
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      // Check personal collection first
      final docRef = _firestore.collection('users').doc(userId).collection('notifications').doc(notificationId);
      final doc = await docRef.get();
      
      if (doc.exists) {
        await docRef.update({'isRead': true});
      } else {
        // Broadcast notifications marking as read is more complex (usually per-user state)
        // For simplicity, we just ignore for now or handle locally in the app
      }
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
    }
  }

  /// Marks all notifications for a user as read.
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore.collection('users').doc(userId).collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();
      
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
    } catch (e) {
      _logger.e('Error marking all notifications as read: $e');
    }
  }

  /// Deletes a specific notification.
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('notifications').doc(notificationId).delete();
    } catch (e) {
      _logger.e('Error deleting notification: $e');
    }
  }

  /// Sends a broadcast notification (Admin specific).
  Future<void> sendBroadcastNotification(String title, String body, {String? imageUrl}) async {
    try {
      await _firestore.collection('broadcast_notifications').add({
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'type': 'broadcast',
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      _logger.e('Error sending broadcast notification via Firestore: $e');
      rethrow;
    }
  }
}
