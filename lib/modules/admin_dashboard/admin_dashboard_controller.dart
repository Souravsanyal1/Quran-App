import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/support_chat_model.dart';
import '../../data/repositories/support_repository.dart';
import '../../data/repositories/notification_repository.dart';

class AdminDashboardController extends GetxController {
  final SupportRepository _supportRepository;
  final NotificationRepository _notificationRepository;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  AdminDashboardController(this._supportRepository, this._notificationRepository);

  // Active Tab Index
  final RxInt activeTabIndex = 0.obs;

  // Loading States
  final RxBool isInitialLoading = true.obs;
  final RxBool isBannerSubmitting = false.obs;
  final RxBool isAdSubmitting = false.obs;
  final RxBool isSettingsSaving = false.obs;
  final RxBool isStaticBannerSubmitting = false.obs;

  // Live Support Settings
  final Dio _dio = Dio();
  final RxBool liveSupportEnabled = true.obs;
  final RxBool isLiveSupportLoading = false.obs;

  // Form Controllers
  final bannerTitleController = TextEditingController();
  final bannerImageController = TextEditingController();
  final bannerTargetController = TextEditingController();

  final adTitleController = TextEditingController();
  final adImageController = TextEditingController();
  final adTargetController = TextEditingController();

  final staticBannerTitleController = TextEditingController();
  final staticBannerImageController = TextEditingController();
  final staticBannerTargetController = TextEditingController();

  final Rxn<DateTime> bannerExpiresAt = Rxn<DateTime>();
  final Rxn<DateTime> staticBannerExpiresAt = Rxn<DateTime>();
  final Rxn<DateTime> adExpiresAt = Rxn<DateTime>();

  final notificationTitleController = TextEditingController();
  final notificationBodyController = TextEditingController();
  final notificationImageController = TextEditingController();
  final RxBool isNotificationSending = false.obs;

  final prayerMessageController = TextEditingController();

  // Support Tickets
  final RxList<SupportTicket> allTickets = <SupportTicket>[].obs;
  final RxList<SupportTicket> filteredTickets = <SupportTicket>[].obs;
  final RxString ticketSearchQuery = ''.obs;
  final Rx<TicketStatus?> ticketStatusFilter = Rx<TicketStatus?>(null);

  // Stats
  final RxInt totalTicketsCount = 0.obs;
  final RxInt totalBannersCount = 0.obs;
  final RxInt totalAdsCount = 0.obs;
  final RxInt totalAdminsCount = 0.obs;
  final RxInt totalUsersCount = 0.obs;

  // Data Lists for UI
  final RxList<Map<String, dynamic>> banners = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> customAds = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> staticBanners = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> usersList = <Map<String, dynamic>>[].obs;

  // App Update Config
  final versionController = TextEditingController();
  final buildNumberController = TextEditingController();
  final RxBool forceUpdateEnabled = false.obs;
  final RxBool maintenanceModeEnabled = false.obs;
  final Rxn<DateTime> maintenanceEndTime = Rxn<DateTime>();
  final RxBool isUpdateConfigSaving = false.obs;

  // Streams for compatibility with some view parts
  Stream<QuerySnapshot> get staticBannersStream => _firestore.collection('static_top_banners').snapshots();
  Stream<QuerySnapshot> get broadcastsStream => _firestore.collection('broadcast_notifications').snapshots();

  @override
  void onInit() {
    super.onInit();
    _loadAllData();
    _listenToTickets();
    _loadLiveSupportConfig();
  }

  void _listenToTickets() {
    _supportRepository.streamAllTickets().listen((tickets) {
      // 1. Check for NEW tickets (tickets created since last load)
      if (allTickets.isNotEmpty && tickets.length > allTickets.length) {
        final newTicket = tickets.first;
        _showAdminNotification('New Support Ticket', '${newTicket.userName}: ${newTicket.subject}');
      } 
      // 2. Check for NEW MESSAGES in existing tickets
      else if (allTickets.isNotEmpty) {
        for (var updatedTicket in tickets) {
          final oldTicket = allTickets.firstWhereOrNull((t) => t.id == updatedTicket.id);
          if (oldTicket != null && 
              updatedTicket.lastMessage != oldTicket.lastMessage && 
              updatedTicket.updatedAt.isAfter(oldTicket.updatedAt)) {
            
            // Only notify if the last change was from user (faint check via updatedAt)
            // In a real app, we'd check 'lastSenderType' field in Firestore
            _showAdminNotification('New Message from ${updatedTicket.userName}', updatedTicket.lastMessage ?? '...');
          }
        }
      }

      allTickets.assignAll(tickets);
      _applyTicketFilters();
      totalTicketsCount.value = allTickets.where((t) => t.status != TicketStatus.closed).length;
    });
  }

  void _showAdminNotification(String title, String body) {
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1B5E35),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(15),
      icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
      boxShadows: [
        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
      ],
    );
    // Future: Add sound logic here if needed
  }

  Future<void> _loadAllData() async {
    isInitialLoading.value = true;
    await Future.wait([
      _loadBanners(),
      _loadAds(),
      _loadStaticBanners(),
      _loadPrayerSettings(),
      _loadUsersStats(),
      _loadAppUpdateConfig(),
      _loadLiveSupportConfig(),
    ]);
    isInitialLoading.value = false;
  }

  Future<void> _loadUsersStats() async {
    _firestore.collection('users').snapshots().listen((snapshot) {
      totalUsersCount.value = snapshot.size;
      totalAdminsCount.value = snapshot.docs.where((doc) => doc.data()['role'] == 'admin').length;
      usersList.assignAll(snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
    });
  }

  Future<void> toggleUserNamazAccess(String userId, bool hasAccess) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'hasNamazGuideAccess': hasAccess,
      });
      final index = usersList.indexWhere((u) => u['id'] == userId);
      if (index != -1) {
        final updatedUser = Map<String, dynamic>.from(usersList[index]);
        updatedUser['hasNamazGuideAccess'] = hasAccess;
        usersList[index] = updatedUser;
      }
      Get.snackbar('Success', 'User Namaz Guide access updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user access: $e');
    }
  }

  Future<void> _loadAppUpdateConfig() async {
    final doc = await _firestore.collection('app_settings').doc('update_config').get();
    if (doc.exists) {
      final data = doc.data();
      versionController.text = data?['version'] ?? '1.0.0';
      buildNumberController.text = (data?['buildNumber'] ?? 1).toString();
      forceUpdateEnabled.value = data?['forceUpdate'] ?? false;
      maintenanceModeEnabled.value = data?['maintenanceMode'] ?? false;
      if (data?['maintenanceEndTime'] != null) {
        maintenanceEndTime.value = (data?['maintenanceEndTime'] as Timestamp).toDate();
      }
    }
  }

  Future<void> saveUpdateConfig() async {
    try {
      isUpdateConfigSaving.value = true;
      await _firestore.collection('app_settings').doc('update_config').set({
        'version': versionController.text.trim(),
        'buildNumber': int.tryParse(buildNumberController.text.trim()) ?? 1,
        'forceUpdate': forceUpdateEnabled.value,
        'maintenanceMode': maintenanceModeEnabled.value,
        'maintenanceEndTime': maintenanceEndTime.value != null ? Timestamp.fromDate(maintenanceEndTime.value!) : null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'App update configuration saved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save update config');
    } finally {
      isUpdateConfigSaving.value = false;
    }
  }

  void setMaintenanceDuration(int minutes) {
    if (minutes <= 0) {
      maintenanceEndTime.value = null;
    } else {
      maintenanceEndTime.value = DateTime.now().add(Duration(minutes: minutes));
    }
  }

  Future<void> _loadBanners() async {
    _firestore.collection('banners').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      banners.assignAll(snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
      totalBannersCount.value = banners.length;
    });
  }

  Future<void> _loadAds() async {
    _firestore.collection('custom_ads').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      customAds.assignAll(snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
      totalAdsCount.value = customAds.length;
    });
  }

  Future<void> _loadStaticBanners() async {
    _firestore.collection('static_top_banners').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      staticBanners.assignAll(snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
    });
  }

  Future<void> _loadPrayerSettings() async {
    final doc = await _firestore.collection('app_settings').doc('prayer_config').get();
    if (doc.exists) {
      prayerMessageController.text = doc.data()?['globalMessage'] ?? '';
    }
  }

  Future<void> fetchTickets() async {
    try {
      final tickets = await _supportRepository.getAllTickets();
      allTickets.assignAll(tickets);
      _applyTicketFilters();
      totalTicketsCount.value = allTickets.where((t) => t.status != TicketStatus.closed).length;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tickets');
    }
  }

  void _applyTicketFilters() {
    var temp = List<SupportTicket>.from(allTickets);
    if (ticketStatusFilter.value != null) {
      temp = temp.where((t) => t.status == ticketStatusFilter.value).toList();
    }
    if (ticketSearchQuery.value.isNotEmpty) {
      final query = ticketSearchQuery.value.toLowerCase();
      temp = temp.where((t) => 
        t.userName.toLowerCase().contains(query) || 
        t.subject.toLowerCase().contains(query) ||
        t.email.toLowerCase().contains(query)
      ).toList();
    }
    filteredTickets.assignAll(temp);
  }

  void setTicketSearch(String query) {
    ticketSearchQuery.value = query;
    _applyTicketFilters();
  }

  void setTicketStatusFilter(TicketStatus? status) {
    ticketStatusFilter.value = status;
    _applyTicketFilters();
  }

  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    try {
      await _supportRepository.updateStatus(ticketId, status);
      fetchTickets();
      Get.snackbar('Success', 'Ticket marked as ${status.name}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    }
  }

  Future<void> updateTicketPriority(String ticketId, TicketPriority priority) async {
    try {
      await _supportRepository.updatePriority(ticketId, priority);
      fetchTickets();
      Get.snackbar('Success', 'Priority set to ${priority.name}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update priority');
    }
  }

  Future<void> sendBroadcastNotification() async {
    final title = notificationTitleController.text.trim();
    final body = notificationBodyController.text.trim();
    final imageUrl = notificationImageController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      Get.snackbar('Error', 'Title and body are required');
      return;
    }

    try {
      isNotificationSending.value = true;
      await _notificationRepository.sendBroadcast(title, body, imageUrl: imageUrl.isNotEmpty ? imageUrl : null);
      Get.snackbar('Success', 'Broadcast notification sent');
      notificationTitleController.clear();
      notificationBodyController.clear();
      notificationImageController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send broadcast');
    } finally {
      isNotificationSending.value = false;
    }
  }

  Future<void> deleteStaticBanner(String id) async {
    try {
      await _firestore.collection('static_top_banners').doc(id).delete();
      Get.snackbar('Success', 'Static banner deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete');
    }
  }

  Future<void> deleteBroadcast(String id) async {
    try {
      await _firestore.collection('broadcast_notifications').doc(id).delete();
      Get.snackbar('Success', 'Broadcast record deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete');
    }
  }

  final RxString editingBannerId = ''.obs;
  final RxString editingStaticBannerId = ''.obs;
  final RxString editingAdId = ''.obs;
  final RxBool isEditMode = false.obs;
  final RxBool isStaticEditMode = false.obs;
  final RxBool isAdEditMode = false.obs;

  void enterBannerEditMode(String id, Map<String, dynamic> data) {
    editingBannerId.value = id;
    bannerTitleController.text = data['title'] ?? '';
    bannerImageController.text = data['imageUrl'] ?? '';
    bannerTargetController.text = data['linkUrl'] ?? '';
    if (data['expiresAt'] != null) {
      bannerExpiresAt.value = (data['expiresAt'] as Timestamp).toDate();
    } else {
      bannerExpiresAt.value = null;
    }
    isEditMode.value = true;
  }

  void cancelBannerEdit() {
    editingBannerId.value = '';
    bannerTitleController.clear();
    bannerImageController.clear();
    bannerTargetController.clear();
    bannerExpiresAt.value = null;
    isEditMode.value = false;
  }

  void enterStaticBannerEditMode(String id, Map<String, dynamic> data) {
    editingStaticBannerId.value = id;
    staticBannerTitleController.text = data['title'] ?? '';
    staticBannerImageController.text = data['imageUrl'] ?? '';
    staticBannerTargetController.text = data['linkUrl'] ?? '';
    if (data['expiresAt'] != null) {
      staticBannerExpiresAt.value = (data['expiresAt'] as Timestamp).toDate();
    } else {
      staticBannerExpiresAt.value = null;
    }
    isStaticEditMode.value = true;
  }

  void cancelStaticBannerEdit() {
    editingStaticBannerId.value = '';
    staticBannerTitleController.clear();
    staticBannerImageController.clear();
    staticBannerTargetController.clear();
    staticBannerExpiresAt.value = null;
    isStaticEditMode.value = false;
  }

  void enterAdEditMode(String id, Map<String, dynamic> data) {
    editingAdId.value = id;
    adTitleController.text = data['title'] ?? '';
    adImageController.text = data['imageUrl'] ?? '';
    adTargetController.text = data['targetUrl'] ?? '';
    if (data['expiresAt'] != null) {
      adExpiresAt.value = (data['expiresAt'] as Timestamp).toDate();
    } else {
      adExpiresAt.value = null;
    }
    isAdEditMode.value = true;
  }

  void cancelAdEdit() {
    editingAdId.value = '';
    adTitleController.clear();
    adImageController.clear();
    adTargetController.clear();
    adExpiresAt.value = null;
    isAdEditMode.value = false;
  }

  Future<void> addBanner() async {
    final title = bannerTitleController.text.trim();
    final imageUrl = bannerImageController.text.trim();
    final linkUrl = bannerTargetController.text.trim();

    if (imageUrl.isEmpty) {
      Get.snackbar('Error', 'Image URL is required');
      return;
    }

    try {
      isBannerSubmitting.value = true;
      if (isEditMode.value) {
        await _firestore.collection('banners').doc(editingBannerId.value).update({
          'title': title,
          'imageUrl': imageUrl,
          'linkUrl': linkUrl,
          'expiresAt': bannerExpiresAt.value != null ? Timestamp.fromDate(bannerExpiresAt.value!) : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar('Success', 'Banner updated');
      } else {
        await _firestore.collection('banners').add({
          'title': title,
          'imageUrl': imageUrl,
          'linkUrl': linkUrl,
          'isActive': true,
          'expiresAt': bannerExpiresAt.value != null ? Timestamp.fromDate(bannerExpiresAt.value!) : null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar('Success', 'Banner published');
      }
      cancelBannerEdit();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save banner: $e');
    } finally {
      isBannerSubmitting.value = false;
    }
  }

  void setBannerExpiry(int hours) {
    if (hours <= 0) {
      bannerExpiresAt.value = null;
    } else {
      bannerExpiresAt.value = DateTime.now().add(Duration(hours: hours));
    }
  }

  void setStaticBannerExpiry(int hours) {
    if (hours <= 0) {
      staticBannerExpiresAt.value = null;
    } else {
      staticBannerExpiresAt.value = DateTime.now().add(Duration(hours: hours));
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _firestore.collection('banners').doc(id).delete();
      Get.snackbar('Success', 'Banner deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete banner');
    }
  }

  Future<void> addCustomAd() async {
    final title = adTitleController.text.trim();
    final imageUrl = adImageController.text.trim();
    final targetUrl = adTargetController.text.trim();

    if (imageUrl.isEmpty) {
      Get.snackbar('Error', 'Image URL is required');
      return;
    }

    try {
      isAdSubmitting.value = true;
      if (isAdEditMode.value) {
        await _firestore.collection('custom_ads').doc(editingAdId.value).update({
          'title': title,
          'imageUrl': imageUrl,
          'targetUrl': targetUrl,
          'expiresAt': adExpiresAt.value != null ? Timestamp.fromDate(adExpiresAt.value!) : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar('Success', 'Ad campaign updated');
      } else {
        await _firestore.collection('custom_ads').add({
          'title': title,
          'imageUrl': imageUrl,
          'targetUrl': targetUrl,
          'status': 'active',
          'type': 'banner',
          'expiresAt': adExpiresAt.value != null ? Timestamp.fromDate(adExpiresAt.value!) : null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar('Success', 'Ad campaign published');
      }
      cancelAdEdit();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save ad');
    } finally {
      isAdSubmitting.value = false;
    }
  }

  Future<void> toggleAdStatus(String id, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'active' ? 'paused' : 'active';
      await _firestore.collection('custom_ads').doc(id).update({'status': newStatus});
      Get.snackbar('Success', 'Ad is now $newStatus');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    }
  }

  Future<void> deleteCustomAd(String id) async {
    try {
      await _firestore.collection('custom_ads').doc(id).delete();
      Get.snackbar('Success', 'Ad campaign deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete ad');
    }
  }

  Future<void> addStaticBanner() async {
    final title = staticBannerTitleController.text.trim();
    final imageUrl = staticBannerImageController.text.trim();
    final linkUrl = staticBannerTargetController.text.trim();

    if (imageUrl.isEmpty) {
      Get.snackbar('Error', 'Image URL is required');
      return;
    }

    try {
      isStaticBannerSubmitting.value = true;
      if (isStaticEditMode.value) {
        await _firestore.collection('static_top_banners').doc(editingStaticBannerId.value).update({
          'title': title,
          'imageUrl': imageUrl,
          'linkUrl': linkUrl,
          'expiresAt': staticBannerExpiresAt.value != null ? Timestamp.fromDate(staticBannerExpiresAt.value!) : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar('Success', 'Static banner updated');
      } else {
        await _firestore.collection('static_top_banners').add({
          'title': title,
          'imageUrl': imageUrl,
          'linkUrl': linkUrl,
          'isActive': true,
          'expiresAt': staticBannerExpiresAt.value != null ? Timestamp.fromDate(staticBannerExpiresAt.value!) : null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        Get.snackbar('Success', 'Static banner published');
      }
      cancelStaticBannerEdit();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save static banner');
    } finally {
      isStaticBannerSubmitting.value = false;
    }
  }

  Future<void> savePrayerSettings() async {
    try {
      isSettingsSaving.value = true;
      await _firestore.collection('app_settings').doc('prayer_config').set({
        'globalMessage': prayerMessageController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      Get.snackbar('Success', 'Prayer configuration updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings');
    } finally {
      isSettingsSaving.value = false;
    }
  }

  Future<void> _loadLiveSupportConfig() async {
    try {
      isLiveSupportLoading.value = true;
      final response = await _dio.get('https://quran-205d8-default-rtdb.firebaseio.com/liveSupport.json');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map) {
          liveSupportEnabled.value = data['enabled'] ?? true;
        } else if (data is bool) {
          liveSupportEnabled.value = data;
        }
      }
    } catch (e) {
      debugPrint('Failed to load Live Support config: $e');
    } finally {
      isLiveSupportLoading.value = false;
    }
  }

  Future<void> toggleLiveSupport(bool enabled) async {
    try {
      isLiveSupportLoading.value = true;
      final response = await _dio.put(
        'https://quran-205d8-default-rtdb.firebaseio.com/liveSupport.json',
        data: {'enabled': enabled},
      );
      if (response.statusCode == 200) {
        liveSupportEnabled.value = enabled;
        Get.snackbar(
          'Success', 
          'Live Support ${enabled ? "Enabled" : "Disabled"} successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1B5E35),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Failed to update Live Support status');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network Error: $e');
    } finally {
      isLiveSupportLoading.value = false;
    }
  }
  Stream<void>? get supportChatsStream => null;
  Stream<void>? get bannersStream => null;
  Stream<void>? get customAdsStream => null;

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
    staticBannerTitleController.dispose();
    staticBannerImageController.dispose();
    staticBannerTargetController.dispose();
    versionController.dispose();
    buildNumberController.dispose();
    super.onClose();
  }
}
