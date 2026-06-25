import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Active Tab Index
  final RxInt activeTabIndex = 0.obs;

  // Loading States
  final RxBool isInitialLoading = true.obs;
  final RxBool isBannerSubmitting = false.obs;
  final RxBool isAdSubmitting = false.obs;
  final RxBool isSettingsSaving = false.obs;

  // Form Controllers - Banners
  final bannerTitleController = TextEditingController();
  final bannerImageController = TextEditingController();
  final bannerTargetController = TextEditingController();

  // Form Controllers - Custom Ads
  final adTitleController = TextEditingController();
  final adImageController = TextEditingController();
  final adTargetController = TextEditingController();
  final RxString selectedAdType = 'banner'.obs; // banner, interstitial
  final RxString selectedAdStatus = 'active'.obs; // active, inactive

  // Form Controllers - Push Notifications
  final notificationTitleController = TextEditingController();
  final notificationBodyController = TextEditingController();
  final notificationImageController = TextEditingController();
  final RxBool isNotificationSending = false.obs;

  // Editing States
  final RxnString editingBannerId = RxnString();
  final RxnString editingAdId = RxnString();
  final RxBool isEditMode = false.obs;

  // Form Controllers - Prayer Settings
  final prayerMessageController = TextEditingController();
  final RxString selectedSchool = 'hanafi'.obs; // hanafi or shafi
  final RxString selectedMethod = 'karachi'.obs; // karachi or mwl

  // Streams for Real-time Data
  Stream<QuerySnapshot> get supportTicketsStream => _firestore
      .collection('support_tickets')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Stream<QuerySnapshot> get bannersStream =>
      _firestore.collection('banners').orderBy('createdAt', descending: true).snapshots();

  Stream<QuerySnapshot> get customAdsStream => _firestore
      .collection('custom_ads')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Stream<QuerySnapshot> get staticBannersStream => _firestore
      .collection('static_top_banners')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Stream<QuerySnapshot> get broadcastsStream => _firestore
      .collection('broadcast_notifications')
      .orderBy('createdAt', descending: true)
      .snapshots();

  // Stats Counters
  final RxInt totalTicketsCount = 0.obs;
  final RxInt totalBannersCount = 0.obs;
  final RxInt totalStaticBannersCount = 0.obs;
  final RxInt totalAdsCount = 0.obs;
  final RxInt totalBroadcastsCount = 0.obs;
  final RxInt totalAdminsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStats();
    _loadPrayerSettings();
    
    // Simulate a short delay to ensure UI transition is smooth
    Future.delayed(const Duration(milliseconds: 1200), () {
      isInitialLoading.value = false;
    });
  }

  void _loadStats() {
    // Watch support tickets count
    supportTicketsStream.listen((snapshot) {
      totalTicketsCount.value = snapshot.docs.length;
    });

    // Watch banners count
    bannersStream.listen((snapshot) {
      totalBannersCount.value = snapshot.docs.length;
    });

    // Watch custom ads count
    customAdsStream.listen((snapshot) {
      totalAdsCount.value = snapshot.docs.length;
    });

    // Watch static banners count
    staticBannersStream.listen((snapshot) {
      totalStaticBannersCount.value = snapshot.docs.length;
    });

    // Watch broadcasts count
    broadcastsStream.listen((snapshot) {
      totalBroadcastsCount.value = snapshot.docs.length;
    });

    // Watch admins count
    _firestore.collection('admins').snapshots().listen((snapshot) {
      totalAdminsCount.value = snapshot.docs.length;
    });
  }

  Future<void> _loadPrayerSettings() async {
    try {
      final doc = await _firestore.collection('settings').doc('prayer_settings').get();
      if (doc.exists) {
        final data = doc.data()!;
        prayerMessageController.text = data['customMessage'] ?? '';
        selectedSchool.value = data['school'] ?? 'hanafi';
        selectedMethod.value = data['method'] ?? 'karachi';
      }
    } catch (e) {
      Get.log('Error loading prayer settings: $e');
    }
  }

  // --- Support Tickets Management ---
  Future<void> toggleTicketStatus(String ticketId, String currentStatus) async {
    final newStatus = currentStatus == 'resolved' ? 'open' : 'resolved';
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'status': newStatus,
        'resolvedAt': newStatus == 'resolved' ? FieldValue.serverTimestamp() : null,
      });
      Get.snackbar(
        'Success',
        'Ticket marked as $newStatus.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Action failed: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).delete();
      Get.snackbar('Success', 'Ticket deleted.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> clearResolvedTickets() async {
    try {
      final snapshot = await _firestore
          .collection('support_tickets')
          .where('status', isEqualTo: 'resolved')
          .get();
      
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      Get.snackbar('Success', 'Cleared ${snapshot.docs.length} resolved tickets.', 
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // --- Banners Management ---
  void enterBannerEditMode(String id, Map<String, dynamic> data) {
    editingBannerId.value = id;
    bannerTitleController.text = data['title'] ?? '';
    bannerImageController.text = data['imageUrl'] ?? '';
    bannerTargetController.text = data['linkUrl'] ?? data['targetUrl'] ?? ''; // Handle both for safety
    isEditMode.value = true;
  }

  void cancelBannerEdit() {
    editingBannerId.value = null;
    bannerTitleController.clear();
    bannerImageController.clear();
    bannerTargetController.clear();
    isEditMode.value = false;
  }

  Future<void> addBanner() async {
    final title = bannerTitleController.text.trim();
    final imageUrl = bannerImageController.text.trim();
    final targetUrl = bannerTargetController.text.trim();

    if (title.isEmpty || imageUrl.isEmpty) {
      Get.snackbar(
        'Input Error',
        'Please provide a title and an image URL.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isBannerSubmitting.value = true;
      
      final data = {
        'title': title,
        'imageUrl': imageUrl,
        'linkUrl': targetUrl, // Standardized field name
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (editingBannerId.value != null) {
        await _firestore.collection('banners').doc(editingBannerId.value).update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('banners').add(data);
      }

      cancelBannerEdit();

      Get.snackbar(
        'Success',
        editingBannerId.value != null ? 'Banner updated successfully.' : 'Banner added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Action failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isBannerSubmitting.value = false;
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      await _firestore.collection('banners').doc(bannerId).delete();
      Get.snackbar(
        'Success',
        'Banner deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete banner: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  // --- Custom Ads Management ---
  void enterAdEditMode(String id, Map<String, dynamic> data) {
    editingAdId.value = id;
    adTitleController.text = data['title'] ?? '';
    adImageController.text = data['imageUrl'] ?? '';
    adTargetController.text = data['targetUrl'] ?? '';
    selectedAdType.value = data['type'] ?? 'banner';
    selectedAdStatus.value = data['status'] ?? 'active';
    isEditMode.value = true;
  }

  void cancelAdEdit() {
    editingAdId.value = null;
    adTitleController.clear();
    adImageController.clear();
    adTargetController.clear();
    isEditMode.value = false;
  }

  Future<void> addCustomAd() async {
    final title = adTitleController.text.trim();
    final imageUrl = adImageController.text.trim();
    final targetUrl = adTargetController.text.trim();

    if (title.isEmpty || imageUrl.isEmpty) {
      Get.snackbar(
        'Input Error',
        'Please provide a title and an image URL.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isAdSubmitting.value = true;
      
      final data = {
        'title': title,
        'imageUrl': imageUrl,
        'targetUrl': targetUrl,
        'type': selectedAdType.value,
        'status': selectedAdStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (editingAdId.value != null) {
        // Update existing
        await _firestore.collection('custom_ads').doc(editingAdId.value).update(data);
      } else {
        // Add new
        data['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('custom_ads').add(data);
      }

      cancelAdEdit();

      Get.snackbar(
        'Success',
        editingAdId.value != null ? 'Custom Ad updated successfully.' : 'Custom Ad added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Action failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isAdSubmitting.value = false;
    }
  }

  Future<void> deleteCustomAd(String adId) async {
    try {
      await _firestore.collection('custom_ads').doc(adId).delete();
      Get.snackbar(
        'Success',
        'Custom Ad deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete custom ad: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteStaticBanner(String bannerId) async {
    try {
      await _firestore.collection('static_top_banners').doc(bannerId).delete();
      Get.snackbar('Success', 'Static banner deleted.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }

  Future<void> toggleAdStatus(String adId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    try {
      await _firestore.collection('custom_ads').doc(adId).update({
        'status': newStatus,
      });
      Get.snackbar(
        'Success',
        'Ad status updated to $newStatus.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update ad status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  // --- Push Notifications Management ---
  Future<void> sendBroadcastNotification() async {
    final title = notificationTitleController.text.trim();
    final body = notificationBodyController.text.trim();
    final imageUrl = notificationImageController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      Get.snackbar('Input Error', 'Title and Body are required.');
      return;
    }

    try {
      isNotificationSending.value = true;
      
      await _firestore.collection('broadcast_notifications').add({
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'sentAt': FieldValue.serverTimestamp(),
        'target': 'all',
        'status': 'sent_to_queue',
      });

      notificationTitleController.clear();
      notificationBodyController.clear();
      notificationImageController.clear();

      Get.snackbar(
        'Success',
        'Notification queued for delivery to all users.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to queue notification: $e');
    } finally {
      isNotificationSending.value = false;
    }
  }

  Future<void> deleteBroadcast(String id) async {
    try {
      await _firestore.collection('broadcast_notifications').doc(id).delete();
      Get.snackbar('Deleted', 'Notification record removed.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }

  // --- Prayer Settings Management ---
  Future<void> savePrayerSettings() async {
    try {
      isSettingsSaving.value = true;
      await _firestore.collection('settings').doc('prayer_settings').set({
        'customMessage': prayerMessageController.text.trim(),
        'school': selectedSchool.value,
        'method': selectedMethod.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar(
        'Success',
        'Prayer settings updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save settings: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isSettingsSaving.value = false;
    }
  }

  @override
  void onClose() {
    bannerTitleController.dispose();
    bannerImageController.dispose();
    bannerTargetController.dispose();
    adTitleController.dispose();
    adImageController.dispose();
    adTargetController.dispose();
    notificationTitleController.dispose();
    notificationBodyController.dispose();
    notificationImageController.dispose();
    prayerMessageController.dispose();
    super.onClose();
  }
}
