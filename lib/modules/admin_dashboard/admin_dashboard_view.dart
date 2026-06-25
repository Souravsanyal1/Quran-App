import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_controller.dart';
import '../home/banner_controller.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff09090b),
        cardColor: const Color(0xff121214),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xff09090b),
        appBar: _buildAppBar(),
        body: Obx(() {
          if (controller.isInitialLoading.value) {
            return _buildLoadingState();
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 950;
              return isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context);
            },
          );
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ).animate(onPlay: (c) => controller.isEditMode.value ? null : c.repeat()).rotate(duration: 2.seconds),
          ),
          const SizedBox(height: 24),
          const Text(
            'Initializing Cloud Engine...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 1.seconds).fadeOut(delay: 1.seconds),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xff121214),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_mosaic_rounded, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Quran App Cloud Engine',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5),
          ),
          const SizedBox(width: 12),
          _buildStatusBadge('LIVE', Colors.green),
        ],
      ),
      actions: [
        _buildUserBadge(),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
          tooltip: 'Sign Out Admin',
          onPressed: () => Get.find<AuthController>().logout(),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBadge() {
    final auth = Get.find<AuthController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_circle_outlined, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Text(
            auth.user.value?.email?.split('@').first ?? 'Admin',
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 260,
          decoration: const BoxDecoration(
            color: Color(0xff121214),
            border: Border(right: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildSidebarItem(0, Icons.grid_view_rounded, 'Dashboard Overview'),
              _buildSidebarItem(1, Icons.mark_email_unread_rounded, 'User Support'),
              _buildSidebarItem(2, Icons.collections_rounded, 'Visual Banners'),
              _buildSidebarItem(3, Icons.horizontal_distribute_rounded, 'Static Banners'),
              _buildSidebarItem(4, Icons.notifications_active_rounded, 'Push Broadcast'),
              _buildSidebarItem(5, Icons.tune_rounded, 'Prayer Config'),
              _buildSidebarItem(6, Icons.ads_click_rounded, 'Ad Campaigns'),
              const Spacer(),
              _buildSidebarFooter(),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xff09090b),
            child: Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    key: ValueKey(controller.activeTabIndex.value),
                    padding: const EdgeInsets.all(40.0),
                    child: _buildTabContent(controller.activeTabIndex.value),
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarFooter() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.shield_rounded, color: Colors.green, size: 14),
                const SizedBox(width: 8),
                Text('Secure Access',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.white10,
              color: Colors.green,
              minHeight: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xff121214),
            border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Obx(() => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMobileTabItem(0, 'Overview'),
                  _buildMobileTabItem(1, 'Support'),
                  _buildMobileTabItem(2, 'Banners'),
                  _buildMobileTabItem(3, 'Static'),
                  _buildMobileTabItem(4, 'Push'),
                  _buildMobileTabItem(5, 'Prayers'),
                  _buildMobileTabItem(6, 'Ads'),
                ],
              )),
        ),
        Expanded(
          child: Obx(() => SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: _buildTabContent(controller.activeTabIndex.value),
              )),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    return Obx(() {
      final isSelected = controller.activeTabIndex.value == index;
      return GestureDetector(
        onTap: () => controller.activeTabIndex.value = index,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
            border: Border.all(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                width: 1),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.4),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMobileTabItem(int index, String label) {
    final isSelected = controller.activeTabIndex.value == index;
    return GestureDetector(
      onTap: () => controller.activeTabIndex.value = index,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildSupportTab();
      case 2:
        return _buildBannersTab();
      case 3:
        return _buildStaticBannersTab();
      case 4:
        return _buildNotificationsTab();
      case 5:
        return _buildPrayerSettingsTab();
      case 6:
        return _buildCustomAdsTab();
      default:
        return const SizedBox();
    }
  }

  // ── Tab 1: Overview ────────────────────────────────────────────────────────
  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('System Overview', 'Control center for real-time application metrics.'),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
            return GridView.count(
              crossAxisCount: crossCount,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: [
                _buildModernStatsCard('Support Requests', controller.totalTicketsCount,
                    Icons.contact_support_rounded, AppColors.primary),
                _buildModernStatsCard('Visual Banners', controller.totalBannersCount,
                    Icons.collections_rounded, Colors.blueAccent),
                _buildModernStatsCard('Active Campaigns', controller.totalAdsCount,
                    Icons.campaign_rounded, Colors.purpleAccent),
                _buildModernStatsCard('Static Banners', controller.totalStaticBannersCount,
                    Icons.horizontal_distribute_rounded, Colors.orangeAccent),
                _buildModernStatsCard('Push Broadcasts', controller.totalBroadcastsCount,
                    Icons.notifications_active_rounded, Colors.blueAccent),
                _buildModernStatsCard('Administrators', controller.totalAdminsCount,
                    Icons.admin_panel_settings_rounded, AppColors.emerald),
              ],
            );
          },
        ),
        const SizedBox(height: 40),
        _buildQuickInfoCard(),
      ],
    );
  }

  Widget _buildModernStatsCard(String title, RxInt count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff121214),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Icon(icon, color: color.withValues(alpha: 0.5), size: 20),
            ],
          ),
          Obx(() => Text(
                count.value.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1),
              )),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.15), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Console Notice',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'This dashboard directly interacts with the Quran App production database. Any changes made to Banners or Ad Campaigns will reflect on user devices within minutes due to real-time sync listeners. Please verify URLs before publishing.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Support ─────────────────────────────────────────────────────────
  Widget _buildSupportTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('User Feedback', 'Manage and respond to real-time support inquiries.'),
            ElevatedButton.icon(
              onPressed: controller.clearResolvedTickets,
              icon: const Icon(Icons.cleaning_services_rounded, size: 16),
              label: const Text('Clear Resolved'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: controller.supportTicketsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState(Icons.inbox_rounded, 'No active tickets');
              }

              return ListView.separated(
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'open';
                  final isResolved = status == 'resolved';

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff121214),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isResolved ? Colors.white.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(data['name']?[0]?.toUpperCase() ?? 'U',
                              style: const TextStyle(color: AppColors.primary)),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(data['name'] ?? 'Guest User',
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  _buildSmallBadge(
                                      status.toUpperCase(), isResolved ? Colors.grey : Colors.green),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(data['message'] ?? '',
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 14,
                                      height: 1.5)),
                              const SizedBox(height: 12),
                              Text(
                                _formatTimestamp(data['createdAt']),
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.reply_rounded, color: Colors.blueAccent),
                              onPressed: () {
                                controller.notificationTitleController.text = 'Reply to your support request';
                                controller.notificationBodyController.text = 'Assalamu Alaikum, ${data['name'] ?? 'User'}...';
                                controller.activeTabIndex.value = 4; // Switch to Push Broadcast tab
                              },
                              tooltip: 'Reply via Push',
                            ),
                            IconButton(
                              icon: Icon(
                                isResolved ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                                color: isResolved ? Colors.white38 : Colors.green,
                              ),
                              onPressed: () => controller.toggleTicketStatus(doc.id, status),
                              tooltip: isResolved ? 'Re-open' : 'Mark Resolved',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                              onPressed: () => _showDeleteConfirmation(context, () {
                                controller.deleteTicket(doc.id);
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Tab 3: Banners ─────────────────────────────────────────────────────────
  Widget _buildBannersTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Visual Banners', 'Visual cues and informational slider content.'),
              const SizedBox(height: 32),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: controller.bannersStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState(Icons.photo_library_rounded, 'No banners found');
                    }
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildResourceCard(
                          doc.id,
                          data,
                          () => controller.enterBannerEditMode(doc.id, data),
                          () => controller.deleteBanner(doc.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(
          width: 380,
          child: Obx(() => _buildEditorCard(
                title: controller.editingBannerId.value != null ? 'Edit Banner' : 'Create Banner',
                isEditing: controller.editingBannerId.value != null,
                isSubmitting: controller.isBannerSubmitting.value,
                onCancel: controller.cancelBannerEdit,
                onSave: controller.addBanner,
                inputs: [
                  _buildManagedInput(controller.bannerTitleController, 'Display Title'),
                  _buildManagedInput(controller.bannerImageController, 'Banner Image URL'),
                  _buildManagedInput(controller.bannerTargetController, 'Target Link (HTTPS)'),
                ],
              )),
        ),
      ],
    );
  }

  // ── Tab 3: Static Banners ──────────────────────────────────────────────────
  Widget _buildStaticBannersTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Static Top Banners (970x90)',
                  'Manage the thin informational banners shown at the top of Home.'),
              const SizedBox(height: 32),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: controller.staticBannersStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState(
                          Icons.horizontal_distribute_rounded, 'No static banners found');
                    }

                    return ListView.separated(
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xff121214),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(data['imageUrl'] ?? '',
                                    width: 150,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                        width: 150, height: 40, color: Colors.white10)),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['title'] ?? 'Untitled',
                                        style: const TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(data['linkUrl'] ?? 'No target URL',
                                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                                onPressed: () => _showDeleteConfirmation(context, () {
                                  controller.deleteStaticBanner(doc.id);
                                }),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(
          width: 380,
          child: _buildEditorCard(
            title: 'Publish Static Banner',
            isEditing: false,
            isSubmitting: false,
            onCancel: () {},
            onSave: () {
              final title = controller.bannerTitleController.text;
              final img = controller.bannerImageController.text;
              final link = controller.bannerTargetController.text;
              if (img.isNotEmpty) {
                Get.find<BannerController>().addStaticTopBanner(img, link, title);
                controller.bannerTitleController.clear();
                controller.bannerImageController.clear();
                controller.bannerTargetController.clear();
              }
            },
            inputs: [
              _buildManagedInput(controller.bannerTitleController, 'Display Title'),
              _buildManagedInput(controller.bannerImageController, 'Banner Image URL (970x90)'),
              _buildManagedInput(controller.bannerTargetController, 'Target Link (HTTPS)'),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab 4: Push Notifications ──────────────────────────────────────────────
  Widget _buildNotificationsTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Broadcast History', 'Manage and view previously sent push notifications.'),
              const SizedBox(height: 32),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: controller.broadcastsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState(Icons.notifications_none_rounded, 'No broadcasts found');
                    }

                    return ListView.separated(
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xff121214),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.send_rounded, color: Colors.blue, size: 20),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['title'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(data['body'] ?? '',
                                        style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                                    const SizedBox(height: 8),
                                    Text(_formatTimestamp(data['sentAt']),
                                        style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                onPressed: () => controller.deleteBroadcast(doc.id),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(
          width: 380,
          child: Obx(() => _buildEditorCard(
                title: 'Send New Broadcast',
                isEditing: false,
                isSubmitting: controller.isNotificationSending.value,
                onCancel: () {},
                onSave: controller.sendBroadcastNotification,
                inputs: [
                  const Text('Send to: ALL USERS (Topic: "all")', 
                    style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildManagedInput(controller.notificationTitleController, 'Notification Title'),
                  _buildManagedInput(controller.notificationBodyController, 'Notification Message / Body'),
                  _buildManagedInput(controller.notificationImageController, 'Image URL (Optional)'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Note: Notification will be sent to all users who have notifications enabled.',
                            style: TextStyle(color: Colors.orange.withValues(alpha: 0.8), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildPrayerSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Prayer Configuration', 'Dynamic calculation standards for prayer alerts.'),
        const SizedBox(height: 32),
        Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xff121214),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownSection(
                'Asr Calculation (Madhab)',
                'Defines how Asr time is calculated based on shadow length.',
                controller.selectedSchool,
                {
                  'hanafi': 'Hanafi (Shadow x2)',
                  'shafi': 'Standard/Shafi (Shadow x1)',
                },
              ),
              const SizedBox(height: 32),
              _buildDropdownSection(
                'Calculation Method',
                'Astronomical parameters for prayer time windows.',
                controller.selectedMethod,
                {
                  'karachi': 'University of Karachi',
                  'mwl': 'Muslim World League',
                  'egypt': 'Egyptian Authority',
                },
              ),
              const SizedBox(height: 32),
              const Text('Global App Message',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: controller.prayerMessageController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _buildModernInputDecoration('Enter message for all users...'),
              ),
              const SizedBox(height: 40),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          controller.isSettingsSaving.value ? null : controller.savePrayerSettings,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: controller.isSettingsSaving.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Sync Configurations',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAdsTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Ad Campaigns', 'Direct custom monetization or awareness banners.'),
              const SizedBox(height: 32),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: controller.customAdsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState(Icons.campaign_rounded, 'No ads found');
                    }
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildResourceCard(
                          doc.id,
                          data,
                          () => controller.enterAdEditMode(doc.id, data),
                          () => controller.deleteCustomAd(doc.id),
                          extraActions: [
                            IconButton(
                              icon: Icon(
                                (data['status'] ?? 'active') == 'active'
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.orangeAccent,
                                size: 18,
                              ),
                              onPressed: () =>
                                  controller.toggleAdStatus(doc.id, data['status'] ?? 'active'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(
          width: 380,
          child: Obx(() => _buildEditorCard(
                title: controller.editingAdId.value != null ? 'Edit Campaign' : 'Create Campaign',
                isEditing: controller.editingAdId.value != null,
                isSubmitting: controller.isAdSubmitting.value,
                onCancel: controller.cancelAdEdit,
                onSave: controller.addCustomAd,
                inputs: [
                  _buildManagedInput(controller.adTitleController, 'Ad Label / Internal Name'),
                  _buildManagedInput(controller.adImageController, 'Creative Image URL'),
                  _buildManagedInput(controller.adTargetController, 'Click-through Link'),
                  const SizedBox(height: 16),
                  const Text('Placement Type',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  _buildRadioSelect(controller.selectedAdType, {'banner': 'Banner', 'interstitial': 'Full Screen'}),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2)),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 15)),
      ],
    );
  }

  Widget _buildResourceCard(
      String id, Map<String, dynamic> data, VoidCallback onEdit, VoidCallback onDelete,
      {List<Widget>? extraActions}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff121214),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
              child: Opacity(
                  opacity: 0.4, child: Image.network(data['imageUrl'] ?? '', fit: BoxFit.cover))),
          Positioned.fill(
              child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter)))),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(data['title'] ?? 'Untitled',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(data['linkUrl'] ?? data['targetUrl'] ?? 'No link',
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                if (extraActions != null) ...extraActions,
                _buildRoundAction(Icons.edit_rounded, Colors.white70, onEdit),
                const SizedBox(width: 8),
                _buildRoundAction(Icons.delete_rounded, Colors.redAccent, onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _buildEditorCard({
    required String title,
    required bool isEditing,
    required bool isSubmitting,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    required List<Widget> inputs,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xff121214),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              if (isEditing)
                IconButton(
                    onPressed: onCancel, icon: const Icon(Icons.close, color: Colors.white30)),
            ],
          ),
          const SizedBox(height: 24),
          ...inputs.map((i) => Padding(padding: const EdgeInsets.only(bottom: 16), child: i)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSave,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text(isEditing ? 'Update Resource' : 'Publish Resource',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagedInput(TextEditingController ctrl, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: _buildModernInputDecoration('Type here...'),
        ),
      ],
    );
  }

  Widget _buildRadioSelect(RxString groupValue, Map<String, String> options) {
    return Obx(() => Row(
          children: options.entries.map((e) {
            final isSelected = groupValue.value == e.key;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(e.value),
                selected: isSelected,
                onSelected: (_) => groupValue.value = e.key,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildDropdownSection(String title, String desc, RxString value, Map<String, String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 12),
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value.value,
                  dropdownColor: const Color(0xff121214),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white),
                  items: items.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) => value.value = v!,
                ),
              ),
            )),
      ],
    );
  }

  InputDecoration _buildModernInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Recent';
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp.toDate());
    }
    return timestamp.toString();
  }

  void _showDeleteConfirmation(BuildContext context, VoidCallback onConfirm) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xff121214),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
        content: const Text('This record will be permanently removed from the production database.',
            style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
