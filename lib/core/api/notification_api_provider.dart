import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../data/models/notification_model.dart' as app_notification_model;

class NotificationApiProvider {
  // Use a getter to ensure we always use the initialized instance
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final Logger _logger = Logger();

  NotificationApiProvider();

  /// Fetches notifications for a specific user.
  Future<List<app_notification_model.AppNotification>> getNotifications(
      String userId,
      {DateTime? creationTime}) async {
    try {
      // 1. Get personal notifications
      final personalQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();

      final personal = personalQuery.docs
          .map((doc) => app_notification_model.AppNotification.fromJson(
              {...doc.data(), 'id': doc.id}))
          .toList();

      // 2. Get broadcast notifications (Filter by creation time so new users don't see old ones)
      Query broadcastBase = _firestore.collection('broadcast_notifications');

      if (creationTime != null) {
        broadcastBase = broadcastBase.where('sentAt',
            isGreaterThan: Timestamp.fromDate(creationTime));
      }

      final broadcastQuery = await broadcastBase
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();

      final broadcast = broadcastQuery.docs
          .map((doc) => app_notification_model.AppNotification.fromJson(
              {...(doc.data() as Map<String, dynamic>), 'id': doc.id}))
          .toList();

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
  Future<void> markNotificationAsRead(
      String userId, String notificationId) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({'isRead': true});
      }
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
    }
  }

  /// Marks all notifications for a user as read.
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
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
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      _logger.e('Error deleting notification: $e');
    }
  }

  /// Deletes multiple notifications.
  Future<void> deleteNotificationsBulk(
      String userId, List<String> notificationIds) async {
    try {
      final batch = _firestore.batch();
      for (var id in notificationIds) {
        final ref = _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(id);
        batch.delete(ref);
      }
      await batch.commit();
    } catch (e) {
      _logger.e('Error bulk deleting notifications: $e');
    }
  }

  /// Deletes all personal notifications for a user.
  Future<void> deleteAllPersonalNotifications(String userId) async {
    try {
      final personal = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .get();
      final batch = _firestore.batch();
      for (var doc in personal.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      _logger.e('Error deleting all personal notifications: $e');
    }
  }

  /// Sends a broadcast notification (Admin specific).
  Future<void> sendBroadcastNotification(String title, String body,
      {String? imageUrl}) async {
    try {
      await _firestore.collection('broadcast_notifications').add({
        'title': title,
        'body': body,
        'imageUrl': imageUrl ?? '',
        'type': 'broadcast',
        'status': 'sent_to_queue',
        'target': 'all',
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      _logger.e('Error sending broadcast notification via Firestore: $e');
      rethrow;
    }
  }
}
