import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_model.dart';

class NotificationsController extends GetxController {
  static const String _storageKey = 'app_notifications';

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;

  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getStringList(_storageKey) ?? [];
    final loaded = raw.map((s) {
      try {
        return AppNotification.fromMap(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<AppNotification>().toList();

    // Sort by most recent first
    loaded.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    notifications.assignAll(loaded);
    _updateUnreadCount();
  }

  Future<void> _saveNotifications() async {
    final raw = notifications
        .map((n) => jsonEncode(n.toMap()))
        .toList();
    await _prefs?.setStringList(_storageKey, raw);
  }

  /// Add a new notification (called from NotificationService)
  Future<void> addNotification(AppNotification notification) async {
    notifications.insert(0, notification);
    _updateUnreadCount();
    await _saveNotifications();
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifications.refresh();
      _updateUnreadCount();
      await _saveNotifications();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    await _saveNotifications();
  }

  /// Delete a single notification
  Future<void> deleteNotification(String id) async {
    notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
    await _saveNotifications();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    notifications.clear();
    unreadCount.value = 0;
    await _saveNotifications();
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
