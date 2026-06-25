import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'notification_model.dart';

class NotificationsController extends GetxController {
  static const String _storageKey = 'app_notifications';

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;

  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() {
    final List<dynamic>? raw = _storage.read(_storageKey);
    if (raw == null) return;

    final loaded = raw.map((item) {
      try {
        return AppNotification.fromMap(Map<String, dynamic>.from(item));
      } catch (_) {
        return null;
      }
    }).whereType<AppNotification>().toList();

    // Sort by most recent first
    loaded.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    notifications.assignAll(loaded);
    _updateUnreadCount();
  }

  void _saveNotifications() {
    final raw = notifications
        .map((n) => n.toMap())
        .toList();
    _storage.write(_storageKey, raw);
  }

  /// Add a new notification (called from NotificationService)
  void addNotification(AppNotification notification) {
    notifications.insert(0, notification);
    _updateUnreadCount();
    _saveNotifications();
  }

  /// Mark a single notification as read
  void markAsRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifications.refresh();
      _updateUnreadCount();
      _saveNotifications();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    _saveNotifications();
  }

  /// Delete a single notification
  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
    _saveNotifications();
  }

  /// Clear all notifications
  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
    _saveNotifications();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
