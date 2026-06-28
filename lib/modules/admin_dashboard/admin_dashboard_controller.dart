import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/support_chat_model.dart';
import '../../data/repositories/support_repository.dart';
import '../../data/repositories/notification_repository.dart';

class AdminDashboardController extends GetxController {
  final SupportRepository _supportRepository;
  final NotificationRepository _notificationRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminDashboardController(this._supportRepository, this._notificationRepository);

  // Active Tab Index
  final RxInt activeTabIndex = 0.obs;

  // Loading States
  final RxBool isInitialLoading = true.obs;
  final RxBool isBannerSubmitting = false.obs;
  final RxBool isAdSubmitting = false.obs;
  final RxBool isSettingsSaving = false.obs;

  // Form Controllers
  final bannerTitleController = TextEditingController();
  final bannerImageController = TextEditingController();
  final bannerTargetController = TextEditingController();

  final adTitleController = TextEditingController();
  final adImageController = TextEditingController();
  final adTargetController = TextEditingController();

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

  // Data Lists for UI
  final RxList<Map<String, dynamic>> banners = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> customAds = <Map<String, dynamic>>[].obs;

  // Streams for compatibility with some view parts
  Stream<QuerySnapshot> get staticBannersStream => _firestore.collection('static_top_banners').snapshots();
  Stream<QuerySnapshot> get broadcastsStream => _firestore.collection('broadcast_notifications').snapshots();

  @override
  void onInit() {
    super.onInit();
    _loadAllData();
    _listenToTickets();
  }

  void _listenToTickets() {
    _supportRepository.streamAllTickets().listen((tickets) {
      // Check for new tickets to show admin notification
      if (allTickets.isNotEmpty && tickets.length > allTickets.length) {
        final newTicket = tickets.first;
        Get.snackbar(
          'New Support Ticket',
          '${newTicket.userName}: ${newTicket.subject}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary,
          colorText: Colors.black,
          duration: const Duration(seconds: 5),
        );
      }

      allTickets.assignAll(tickets);
      _applyTicketFilters();
      totalTicketsCount.value = allTickets.where((t) => t.status != TicketStatus.closed).length;
    });
  }

  Future<void> _loadAllData() async {
    isInitialLoading.value = true;
    await Future.wait([
      _loadBanners(),
      _loadAds(),
    ]);
    isInitialLoading.value = false;
  }

  Future<void> _loadBanners() async {
    _firestore.collection('banners').snapshots().listen((snapshot) {
      banners.assignAll(snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
      totalBannersCount.value = banners.length;
    });
  }

  Future<void> _loadAds() async {
    _firestore.collection('custom_ads').snapshots().listen((snapshot) {
      customAds.assignAll(snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
      totalAdsCount.value = customAds.length;
    });
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

  void enterBannerEditMode(String id, Map<String, dynamic> data) {
    bannerTitleController.text = data['title'] ?? '';
    bannerImageController.text = data['imageUrl'] ?? '';
    bannerTargetController.text = data['linkUrl'] ?? '';
    isEditMode.value = true;
  }

  void cancelBannerEdit() {
    bannerTitleController.clear();
    bannerImageController.clear();
    bannerTargetController.clear();
    isEditMode.value = false;
  }

  Future<void> addBanner() async {
    isBannerSubmitting.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Mock
    Get.snackbar('Success', 'Banner added');
    isBannerSubmitting.value = false;
  }

  Future<void> deleteBanner(String id) async {
    Get.snackbar('Success', 'Banner deleted');
  }

  Future<void> addCustomAd() async {
    isAdSubmitting.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Mock
    Get.snackbar('Success', 'Ad added');
    isAdSubmitting.value = false;
  }

  Future<void> toggleAdStatus(String id, String status) async {
    Get.snackbar('Success', 'Status updated');
  }

  Future<void> deleteCustomAd(String id) async {
    Get.snackbar('Success', 'Ad deleted');
  }

  Future<void> savePrayerSettings() async {
    isSettingsSaving.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Mock
    Get.snackbar('Success', 'Settings saved');
    isSettingsSaving.value = false;
  }
  Stream<void>? get supportChatsStream => null;
  Stream<void>? get bannersStream => null;
  Stream<void>? get customAdsStream => null;
  RxBool isEditMode = false.obs;

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
