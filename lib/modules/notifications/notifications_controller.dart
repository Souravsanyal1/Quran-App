import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NotificationsController(this._repository);

  final RxList<AppNotification> allNotifications = <AppNotification>[].obs;
  final RxList<AppNotification> filteredNotifications = <AppNotification>[].obs;
  
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final Rx<NotificationCategory?> selectedCategory = Rx<NotificationCategory?>(null);
  final RxBool showOnlyUnread = false.obs;
  final RxString sortBy = 'latest'.obs; // latest, oldest
  final RxList<String> selectedIds = <String>[].obs;
  final RxBool isSelectionMode = false.obs;

  Timer? _searchTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _listenToPersonalNotifications();
  }

  void _listenToPersonalNotifications() {
    final user = _auth.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            // Avoid adding duplicates if already fetched via API
            final exists = allNotifications.any((n) => n.id == change.doc.id);
            if (!exists) {
              final newNotif = AppNotification(
                id: change.doc.id,
                title: data['title'] ?? 'Notification',
                body: data['body'] ?? '',
                imageUrl: data['imageUrl'],
                createdAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                category: _parseCategory(data['type']),
                isRead: data['isRead'] ?? false,
              );
              allNotifications.insert(0, newNotif);
              _applyFilters();
              _updateUnreadCount();
            }
          }
        }
      }
    });
  }

  NotificationCategory _parseCategory(String? type) {
    switch (type) {
      case 'support_reply': return NotificationCategory.support;
      case 'prayer': return NotificationCategory.prayer;
      case 'quran': return NotificationCategory.quran;
      default: return NotificationCategory.general;
    }
  }

  Future<void> fetchNotifications() async {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final results = await _repository.getNotifications(user.uid);
      allNotifications.assignAll(results);
      _applyFilters();
      _updateUnreadCount();
      
      // Precache images for faster loading in background
      _precacheNotificationImages(results);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch notifications');
    } finally {
      isLoading.value = false;
    }
  }

  void _precacheNotificationImages(List<AppNotification> notifications) {
    for (var n in notifications) {
      final imageUrl = n.imageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
        // Use the image provider with an error listener if supported, 
        // or wrap the precache in a safe way.
        try {
          precacheImage(
            CachedNetworkImageProvider(imageUrl), 
            Get.context!,
          ).catchError((e) {
            Get.log('Failed to precache notification image: $imageUrl - $e');
          });
        } catch (e) {
          // Catch synchronous errors during provider creation
          Get.log('Error creating image provider: $e');
        }
      }
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = allNotifications.where((n) => !n.isRead).length;
  }

  void _applyFilters() {
    var temp = List<AppNotification>.from(allNotifications);

    // Filter by Category
    if (selectedCategory.value != null) {
      temp = temp.where((n) => n.category == selectedCategory.value).toList();
    }

    // Filter by Unread
    if (showOnlyUnread.value) {
      temp = temp.where((n) => !n.isRead).toList();
    }

    // Search Query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      temp = temp.where((n) => 
        n.title.toLowerCase().contains(query) || 
        n.body.toLowerCase().contains(query)
      ).toList();
    }

    // Sorting
    if (sortBy.value == 'latest') {
      temp.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      temp.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    filteredNotifications.assignAll(temp);
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }

  void setCategory(NotificationCategory? category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void toggleUnreadOnly() {
    showOnlyUnread.value = !showOnlyUnread.value;
    _applyFilters();
  }

  void setSortBy(String sort) {
    sortBy.value = sort;
    _applyFilters();
  }

  String timeAgo(DateTime date, bool isBangla) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (isBangla) {
      if (diff.inMinutes < 1) return 'এইমাত্র';
      if (diff.inMinutes < 60) return '${diff.inMinutes} মিনিট আগে';
      if (diff.inHours < 24) return '${diff.inHours} ঘণ্টা আগে';
      if (diff.inDays < 7) return '${diff.inDays} দিন আগে';
      return DateFormat('dd MMM, hh:mm a').format(date);
    }
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd, hh:mm a').format(date);
  }

  Future<void> addNotification(AppNotification notification) async {
    allNotifications.insert(0, notification);
    _applyFilters();
    _updateUnreadCount();
  }

  Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final index = allNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        allNotifications[index].isRead = true;
        allNotifications.refresh();
        _applyFilters();
        _updateUnreadCount();
        await _repository.markAsRead(user.uid, notificationId);
      }
    } catch (e) {
      // Revert on error if necessary
    }
  }

  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      for (var n in allNotifications) {
        n.isRead = true;
      }
      allNotifications.refresh();
      _applyFilters();
      _updateUnreadCount();
      await _repository.markAllAsRead(user.uid);
    } catch (e) {
      fetchNotifications(); // Reload on error
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final index = allNotifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final deletedItem = allNotifications[index];
    
    // Optimistic delete
    allNotifications.removeAt(index);
    _applyFilters();
    _updateUnreadCount();

    Get.snackbar(
      'Notification Deleted',
      'The notification has been removed',
      mainButton: TextButton(
        onPressed: () {
          allNotifications.insert(index, deletedItem);
          _applyFilters();
          _updateUnreadCount();
          Get.back();
        },
        child: const Text('UNDO', style: TextStyle(color: Colors.amber)),
      ),
      duration: const Duration(seconds: 5),
    );

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _repository.deleteNotification(user.uid, notificationId);
      }
    } catch (e) {
      // Revert if API fails? Usually, for deletion, we just try our best.
    }
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
      if (selectedIds.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      selectedIds.add(id);
      isSelectionMode.value = true;
    }
  }

  void clearSelection() {
    selectedIds.clear();
    isSelectionMode.value = false;
  }

  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final idsToDelete = List<String>.from(selectedIds);
    
    // Optimistic delete from UI
    allNotifications.removeWhere((n) => idsToDelete.contains(n.id));
    _applyFilters();
    _updateUnreadCount();
    clearSelection();

    try {
      await _repository.deleteBulk(user.uid, idsToDelete);
      Get.snackbar('Deleted', '${idsToDelete.length} notifications removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete some notifications');
      fetchNotifications(); // Reload to sync with server
    }
  }

  Future<void> deleteAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Confirm before delete is handled in UI
    allNotifications.clear();
    _applyFilters();
    _updateUnreadCount();
    clearSelection();

    try {
      await _repository.deleteAll(user.uid);
      Get.snackbar('Success', 'All notifications cleared');
    } catch (e) {
      fetchNotifications();
    }
  }
}
