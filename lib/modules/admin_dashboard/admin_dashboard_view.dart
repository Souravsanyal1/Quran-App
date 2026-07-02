import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/support_chat_model.dart';
import '../auth/auth_controller.dart';
import '../home/banner_controller.dart';
import '../settings/settings_controller.dart';
import '../settings/n8n_config_controller.dart';
import 'admin_chat_controller.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141420),
        cardColor: const Color(0xFF1E1E2E),
        primaryColor: const Color(0xFF1B5E35),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1B5E35),
          secondary: Color(0xFFC9A84C),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF141420),
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
              color: const Color(0xFF1B5E35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: const Color(0xFF1B5E35),
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: const Duration(seconds: 2)),
          ),
          const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

          const Text(
            'Initializing Cloud Engine...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: const Duration(seconds: 1)).fadeOut(delay: const Duration(seconds: 1)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E2E),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1B5E35), Color(0xFFC9A84C)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_mosaic_rounded, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Qurania Cloud Engine',
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
            color: Color(0xFF1E1E2E),
            border: Border(right: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSidebarItem(0, Icons.grid_view_rounded, 'Dashboard Overview'),
                      _buildSidebarItem(7, Icons.forum_rounded, 'Support Inbox'),
                      _buildSidebarItem(8, Icons.people_rounded, 'User Management'),
                      _buildSidebarItem(2, Icons.collections_rounded, 'Visual Banners'),
                      _buildSidebarItem(3, Icons.horizontal_distribute_rounded, 'Static Banners'),
                      _buildSidebarItem(4, Icons.notifications_active_rounded, 'Push Broadcast'),
                      _buildSidebarItem(5, Icons.tune_rounded, 'Prayer Config'),
                      _buildSidebarItem(6, Icons.ads_click_rounded, 'Ad Campaigns'),
                      _buildSidebarItem(9, Icons.build_circle_rounded, 'App Maintenance'),
                      _buildSidebarItem(10, Icons.settings_suggest_rounded, 'n8n Webhook'),
                    ],
                  ),
                ),
              ),
              _buildSidebarFooter(),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFF141420),
            child: Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: SingleChildScrollView(
                    key: ValueKey(controller.activeTabIndex.value),
                    padding: const EdgeInsets.all(40.0),
                    child: _buildTabContent(context, controller.activeTabIndex.value),
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
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.shield_rounded, color: Colors.green, size: 14),
                const SizedBox(width: 8),
                Text('Secure Access',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
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
            color: Color(0xFF1E1E2E),
            border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Obx(() => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMobileTabItem(0, 'Overview'),
                  _buildMobileTabItem(7, 'Inbox'),
                  _buildMobileTabItem(8, 'Users'),
                  _buildMobileTabItem(2, 'Banners'),
                  _buildMobileTabItem(3, 'Static'),
                  _buildMobileTabItem(4, 'Push'),
                  _buildMobileTabItem(5, 'Prayers'),
                  _buildMobileTabItem(6, 'Ads'),
                  _buildMobileTabItem(9, 'Maint'),
                  _buildMobileTabItem(10, 'n8n'),
                ],
              )),
        ),
        Expanded(
          child: Obx(() => SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: _buildTabContent(context, controller.activeTabIndex.value),
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
            color: isSelected ? const Color(0xFF1B5E35).withOpacity(0.08) : Colors.transparent,
            border: Border.all(
                color: isSelected ? const Color(0xFF1B5E35).withOpacity(0.2) : Colors.transparent,
                width: 1),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
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
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, int index) {
    switch (index) {
      case 0: return _buildOverviewTab();
      case 2: return _buildBannersTab(context);
      case 3: return _buildStaticBannersTab(context);
      case 4: return _buildNotificationsTab();
      case 5: return _buildPrayerSettingsTab();
      case 6: return _buildCustomAdsTab(context);
      case 7: return _buildSupportInboxTab();
      case 8: return _buildUsersTab();
      case 9: return _buildMaintenanceTab(context);
      case 10: return _buildN8nConfigTab(context);
      default: return const SizedBox();
    }
  }

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
                _buildModernStatsCard('Support Inbox', controller.totalTicketsCount, Icons.forum_rounded, const Color(0xFF1B5E35)),
                _buildModernStatsCard('Total Users', controller.totalUsersCount, Icons.people_rounded, Colors.orangeAccent),
                _buildModernStatsCard('Visual Banners', controller.totalBannersCount, Icons.collections_rounded, Colors.blueAccent),
                _buildModernStatsCard('Active Campaigns', controller.totalAdsCount, Icons.campaign_rounded, Colors.purpleAccent),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildModernStatsCard(String title, RxInt count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w600)),
              Icon(icon, color: color.withOpacity(0.5), size: 20),
            ],
          ),
          Obx(() => Text(
            count.value.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
          )),
        ],
      ),
    );
  }

  Widget _buildSupportInboxTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Support Tickets', 'Manage and respond to user requests.'),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

        _buildTicketFilters(),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

        Expanded(
          child: Obx(() {
            if (controller.filteredTickets.isEmpty) {
              return _buildEmptyState(Icons.confirmation_number_outlined, 'No tickets found matching filters');
            }
            return ListView.separated(
              itemCount: controller.filteredTickets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = controller.filteredTickets[index];
                return _buildTicketCard(ticket);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTicketFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.setTicketSearch,
            decoration: InputDecoration(
              hintText: 'Search by user, email or subject...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFF1E1E2E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Obx(() => DropdownButton<TicketStatus?>(
          value: controller.ticketStatusFilter.value,
          hint: const Text('All Status'),
          dropdownColor: const Color(0xFF1E1E2E),
          underline: const SizedBox(),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Status')),
            ...TicketStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.capitalizeFirst!))),
          ],
          onChanged: controller.setTicketStatusFilter,
        )),
      ],
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        onTap: () => _openAdminChat(ticket.id, ticket.userName),
        title: Row(
          children: [
            Text(ticket.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            _buildStatusBadge(ticket.status.name.toUpperCase(), _getStatusColor(ticket.status)),
            const Spacer(),
            _buildPriorityBadge(ticket.priority),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(ticket.subject, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(ticket.lastMessage ?? 'No messages', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'delete') {
              // controller.deleteTicket(ticket.id);
            } else if (val.startsWith('status_')) {
              final status = TicketStatus.values.firstWhere((e) => e.name == val.split('_')[1]);
              controller.updateTicketStatus(ticket.id, status);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'status_open', child: Text('Mark Open')),
            const PopupMenuItem(value: 'status_inProgress', child: Text('Mark In Progress')),
            const PopupMenuItem(value: 'status_resolved', child: Text('Mark Resolved')),
            const PopupMenuItem(value: 'status_closed', child: Text('Mark Closed')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'delete', child: Text('Delete Ticket', style: TextStyle(color: Colors.redAccent))),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    Color color;
    switch (priority) {
      case TicketPriority.urgent: color = Colors.red; break;
      case TicketPriority.high: color = Colors.orange; break;
      case TicketPriority.medium: color = Colors.blue; break;
      case TicketPriority.low: color = Colors.grey; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(priority.name.toUpperCase(), style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open: return Colors.green;
      case TicketStatus.pending: return Colors.orange;
      case TicketStatus.resolved: return Colors.blue;
      case TicketStatus.closed: return Colors.grey;
      case TicketStatus.inProgress: return Colors.purple;
    }
  }

  void _openAdminChat(String userId, String userName) {
    final chatController = Get.put(AdminChatController(Get.find()), tag: userId);
    chatController.setupChat(userId, userName);
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF141420),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF141420),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFF1E1E2E), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(
                  children: [
                    IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.white54)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const Text('Live Support Channel', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ])),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() => chatController.isLoading.value 
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: chatController.scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: chatController.messages.length + (chatController.isUserTyping.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatController.messages.length) {
                          return _buildUserTypingIndicator();
                        }
                        return _AdminMessageBubble(message: chatController.messages[index], isMe: chatController.messages[index].senderType == 'admin');
                      },
                    )),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFF1E1E2E), borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      if (chatController.selectedImageBytes.value != null) {
                        return Container(
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: MemoryImage(chatController.selectedImageBytes.value!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    chatController.selectedImage.value = null;
                                    chatController.selectedImageBytes.value = null;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    Row(
                      children: [
                        IconButton(
                          onPressed: chatController.pickImage,
                          icon: const Icon(Icons.image_rounded, color: const Color(0xFF1B5E35)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(
                          controller: chatController.messageController,
                          onSubmitted: (_) => chatController.sendMessage(),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: 'Type your reply...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)), filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                        )),
                        const SizedBox(width: 12),
                        Obx(() => IconButton(
                          onPressed: chatController.isSubmitting.value ? null : chatController.sendMessage,
                          icon: chatController.isSubmitting.value 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF1B5E35)))
                            : const Icon(Icons.send_rounded, color: const Color(0xFF1B5E35)),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFF1B5E35).withOpacity(0.1)),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )).then((_) => Get.delete<AdminChatController>(tag: userId));
  }

  Widget _buildBannersTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Visual Banners', 'Manage the top carousel of the mobile app.'),
        const SizedBox(height: 32),
        _buildFormCard([
          _buildTextField(controller.bannerTitleController, 'Banner Title', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.bannerImageController, 'Image URL', Icons.image_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.bannerTargetController, 'Target URL / Route', Icons.link_rounded),
          const SizedBox(height: 16),
          const Text('Display Duration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          const Text('Banner will auto-hide after this time.', style: TextStyle(color: Colors.white24, fontSize: 11)),
          const SizedBox(height: 12),
          Obx(() => Wrap(
            spacing: 8,
            children: [
              _buildExpiryChip(context, controller, 24, '24h', isSlider: true),
              _buildExpiryChip(context, controller, 48, '2 days', isSlider: true),
              _buildExpiryChip(context, controller, 168, '7 days', isSlider: true),
              _buildExpiryChip(context, controller, 720, '30 days', isSlider: true),
              _buildExpiryChip(context, controller, 0, 'No Expiry', isSlider: true),
              ActionChip(
                label: const Text('Custom'),
                avatar: const Icon(Icons.calendar_month_rounded, size: 14),
                onPressed: () => _pickCustomDateTime(context, (dt) => controller.bannerExpiresAt.value = dt),
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ],
          )),
          if (controller.bannerExpiresAt.value != null) ...[
            const SizedBox(height: 8),
            Obx(() => Text(
              'Expires on: ${DateFormat('dd MMM, hh:mm a').format(controller.bannerExpiresAt.value!)}',
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
            )),
          ],
          const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

          Obx(() => _buildActionButton(
            controller.isEditMode.value ? 'Update Banner' : 'Publish Banner',
            controller.addBanner,
            isLoading: controller.isBannerSubmitting.value,
          )),
          if (controller.isEditMode.value)
            TextButton(onPressed: controller.cancelBannerEdit, child: const Text('Cancel Edit', style: TextStyle(color: Colors.grey))),
        ]),
        const SizedBox(height: 40),
        const Text('Active Banners', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.banners.isEmpty) return const Center(child: Text('No banners found', style: TextStyle(color: Colors.white24)));
            return ListView.separated(
              itemCount: controller.banners.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = controller.banners[index];
                final id = data['id'] ?? '';
                return _buildItemCard(
                  data['imageUrl'],
                  data['title'] ?? 'No Title',
                  data['linkUrl'] ?? 'No Link',
                  () => controller.enterBannerEditMode(id, data),
                  () => controller.deleteBanner(id),
                  data: data,
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCustomAdsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Ad Campaigns', 'Manage the rotating campaign banners.'),
        const SizedBox(height: 32),
        _buildFormCard([
          _buildTextField(controller.adTitleController, 'Ad Title', Icons.campaign_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.adImageController, 'Ad Image URL', Icons.image_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.adTargetController, 'Ad Target URL', Icons.link_rounded),
          const SizedBox(height: 16),
          const Text('Campaign Duration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          const Text('Ad will automatically pause after this time.', style: TextStyle(color: Colors.white24, fontSize: 11)),
          const SizedBox(height: 12),
          Obx(() => Wrap(
            spacing: 8,
            children: [
              _buildExpiryChip(context, controller, 24, '24h', isAd: true),
              _buildExpiryChip(context, controller, 48, '2 days', isAd: true),
              _buildExpiryChip(context, controller, 168, '7 days', isAd: true),
              _buildExpiryChip(context, controller, 0, 'No Expiry', isAd: true),
              ActionChip(
                label: const Text('Custom'),
                avatar: const Icon(Icons.calendar_month_rounded, size: 14),
                onPressed: () => _pickCustomDateTime(context, (dt) => controller.adExpiresAt.value = dt),
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ],
          )),
          if (controller.adExpiresAt.value != null) ...[
            const SizedBox(height: 8),
            Obx(() => Text(
              'Expires on: ${DateFormat('dd MMM, hh:mm a').format(controller.adExpiresAt.value!)}',
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
            )),
          ],
          const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

          Obx(() => _buildActionButton(
            controller.isAdEditMode.value ? 'Update Campaign Ad' : 'Publish Campaign Ad',
            controller.addCustomAd,
            isLoading: controller.isAdSubmitting.value,
          )),
          Obx(() => controller.isAdEditMode.value 
            ? TextButton(onPressed: controller.cancelAdEdit, child: const Text('Cancel Edit', style: TextStyle(color: Colors.grey)))
            : const SizedBox.shrink()),
        ]),
        const SizedBox(height: 40),
        const Text('Active Campaigns', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.customAds.isEmpty) return const Center(child: Text('No ads found', style: TextStyle(color: Colors.white24)));
            return ListView.separated(
              itemCount: controller.customAds.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = controller.customAds[index];
                final id = data['id'] ?? '';
                final status = data['status'] ?? 'active';
                return _buildItemCard(
                  data['imageUrl'],
                  data['title'] ?? 'No Title',
                  data['targetUrl'] ?? 'No Link',
                  () => controller.enterAdEditMode(id, data),
                  () => controller.deleteCustomAd(id),
                  data: data,
                  trailing: Switch(
                    value: status == 'active',
                    onChanged: (_) => controller.toggleAdStatus(id, status),
                    activeColor: const Color(0xFF1B5E35),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStaticBannersTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Static Banners', 'Manage the prominent banners directly below the AppBar.'),
        const SizedBox(height: 32),
        _buildFormCard([
          _buildTextField(controller.staticBannerTitleController, 'Banner Title', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.staticBannerImageController, 'Image URL', Icons.image_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.staticBannerTargetController, 'Target URL / Route', Icons.link_rounded),
          const SizedBox(height: 16),
          const Text('Display Duration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          const Text('Static banner will auto-hide after this time.', style: TextStyle(color: Colors.white24, fontSize: 11)),
          const SizedBox(height: 12),
          Obx(() => Wrap(
            spacing: 8,
            children: [
              _buildExpiryChip(context, controller, 24, '24h', isStatic: true),
              _buildExpiryChip(context, controller, 48, '2 days', isStatic: true),
              _buildExpiryChip(context, controller, 168, '7 days', isStatic: true),
              _buildExpiryChip(context, controller, 0, 'No Expiry', isStatic: true),
              ActionChip(
                label: const Text('Custom'),
                avatar: const Icon(Icons.calendar_month_rounded, size: 14),
                onPressed: () => _pickCustomDateTime(context, (dt) => controller.staticBannerExpiresAt.value = dt),
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ],
          )),
          if (controller.staticBannerExpiresAt.value != null) ...[
            const SizedBox(height: 8),
            Obx(() => Text(
              'Expires on: ${DateFormat('dd MMM, hh:mm a').format(controller.staticBannerExpiresAt.value!)}',
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
            )),
          ],
          const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

          Obx(() => _buildActionButton(
                controller.isStaticEditMode.value ? 'Update Static Banner' : 'Publish Static Banner',
                controller.addStaticBanner,
                isLoading: controller.isStaticBannerSubmitting.value,
              )),
          Obx(() => controller.isStaticEditMode.value 
            ? TextButton(onPressed: controller.cancelStaticBannerEdit, child: const Text('Cancel Edit', style: TextStyle(color: Colors.grey)))
            : const SizedBox.shrink()),
        ]),
        const SizedBox(height: 40),
        const Text('Active Static Banners', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.staticBanners.isEmpty) return const Center(child: Text('No static banners found', style: TextStyle(color: Colors.white24)));
            return ListView.separated(
              itemCount: controller.staticBanners.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = controller.staticBanners[index];
                final id = data['id'] ?? '';
                return _buildItemCard(
                  data['imageUrl'],
                  data['title'] ?? 'No Title',
                  data['linkUrl'] ?? 'No Link',
                  () => controller.enterStaticBannerEditMode(id, data),
                  () => controller.deleteStaticBanner(id),
                  data: data,
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNotificationsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Push Broadcast', 'Send real-time alerts to all app users.'),
        const SizedBox(height: 32),
        _buildFormCard([
          _buildTextField(controller.notificationTitleController, 'Title', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.notificationBodyController, 'Body', Icons.text_snippet_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.notificationImageController, 'Image URL (Optional)', Icons.image_rounded),
          const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

          Obx(() => _buildActionButton(
            'Broadcast Now',
            controller.sendBroadcastNotification,
            isLoading: controller.isNotificationSending.value,
          )),
        ]),
      ],
    );
  }

  Widget _buildPrayerSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Prayer Config', 'Configure global prayer time rules.'),
        const SizedBox(height: 32),
        _buildFormCard([
          _buildTextField(controller.prayerMessageController, 'Global Prayer Message', Icons.message_rounded),
          const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

          _buildActionButton('Save Configuration', controller.savePrayerSettings, isLoading: controller.isSettingsSaving.value),
        ]),
      ],
    );
  }

  Widget _buildUsersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('User Management', 'Monitor user growth and manage permissions.'),
        const SizedBox(height: 32),
        Expanded(
          child: Obx(() {
            if (controller.usersList.isEmpty) return _buildEmptyState(Icons.people_outline, 'No users registered yet');
            return ListView.separated(
              itemCount: controller.usersList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = controller.usersList[index];
                final role = user['role'] ?? 'user';
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: role == 'admin' ? const Color(0xFF1B5E35) : Colors.white10,
                      child: Text((user['displayName'] ?? user['email'] ?? 'U')[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(user['displayName'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user['email'] ?? 'No Email', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatusBadge(role.toUpperCase(), role == 'admin' ? Colors.green : Colors.blue),
                        if (role != 'admin') ...[
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Namaz Access', style: TextStyle(color: Colors.white30, fontSize: 8)),
                              SizedBox(
                                height: 28,
                                child: Switch(
                                  value: user['hasNamazGuideAccess'] == true,
                                  activeColor: const Color(0xFF1B5E35),
                                  onChanged: (val) {
                                    controller.toggleUserNamazAccess(user['id'], val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMaintenanceTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('App Maintenance', 'Control app versioning and force update behavior.'),
        const SizedBox(height: 32),
        _buildFormCard([
          const Text('Live Support Bot (n8n Integration)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Live Support Bot / Agent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          controller.liveSupportEnabled.value
                              ? 'Users will chat with the n8n AI Agent when support is opened.'
                              : 'Live Support is currently disabled. Users will see "Live Support is currently unavailable."',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  controller.isLiveSupportLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B5E35)),
                        )
                      : Switch(
                          value: controller.liveSupportEnabled.value,
                          onChanged: (val) => controller.toggleLiveSupport(val),
                          activeColor: const Color(0xFF1B5E35),
                        ),
                ],
              )),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

        _buildFormCard([
          const Text('Version Control', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildTextField(controller.versionController, 'Current Version (e.g. 1.2.0)', Icons.vibration_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.buildNumberController, 'Build Number (e.g. 12)', Icons.format_list_numbered_rounded),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Force Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Users will be blocked until they update the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.forceUpdateEnabled.value,
                    onChanged: (val) => controller.forceUpdateEnabled.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Maintenance Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Block all user access for server maintenance.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.maintenanceModeEnabled.value,
                    onChanged: (val) => controller.maintenanceModeEnabled.value = val,
                    activeColor: Colors.orangeAccent,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (!controller.maintenanceModeEnabled.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Maintenance Duration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const Text('App will automatically reopen after this time.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDurationChip(15, '15m'),
                    _buildDurationChip(30, '30m'),
                    _buildDurationChip(60, '1h'),
                    _buildDurationChip(120, '2h'),
                    _buildDurationChip(360, '6h'),
                    _buildDurationChip(0, 'Manual'),
                    ActionChip(
                      label: const Text('Set Custom'),
                      avatar: const Icon(Icons.more_time_rounded, size: 14),
                      onPressed: () => _pickCustomDateTime(context, (dt) => controller.maintenanceEndTime.value = dt),
                      backgroundColor: Colors.orangeAccent.withOpacity(0.1),
                    ),
                  ],
                ),
                if (controller.maintenanceEndTime.value != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Will end at: ${DateFormat('hh:mm:ss a, dd MMM').format(controller.maintenanceEndTime.value!)}',
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            );
          }),
          const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

          Obx(() => _buildActionButton(
                'Save Update Config',
                controller.saveUpdateConfig,
                isLoading: controller.isUpdateConfigSaving.value,
              )),
        ]),
      ],
    );
  }

  Future<void> _pickCustomDateTime(BuildContext context, Function(DateTime) onPicked) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 5)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1B5E35),
            onPrimary: Colors.white,
            surface: Color(0xFF1E1E2E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onPicked(finalDateTime);
      }
    }
  }

  Widget _buildExpiryChip(BuildContext context, AdminDashboardController controller, int hours, String label, {bool isSlider = false, bool isStatic = false, bool isAd = false}) {
    DateTime? expiry;
    if (isSlider) expiry = controller.bannerExpiresAt.value;
    else if (isStatic) expiry = controller.staticBannerExpiresAt.value;
    else if (isAd) expiry = controller.adExpiresAt.value;
    
    bool isSelected = false;
    
    if (hours == 0) {
      isSelected = expiry == null;
    } else if (expiry != null) {
      final diff = expiry.difference(DateTime.now()).inHours;
      isSelected = (diff - hours).abs() <= 1;
    }

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          if (hours <= 0) {
            if (isSlider) controller.bannerExpiresAt.value = null;
            else if (isStatic) controller.staticBannerExpiresAt.value = null;
            else if (isAd) controller.adExpiresAt.value = null;
          } else {
            final newExpiry = DateTime.now().add(Duration(hours: hours));
            if (isSlider) controller.bannerExpiresAt.value = newExpiry;
            else if (isStatic) controller.staticBannerExpiresAt.value = newExpiry;
            else if (isAd) controller.adExpiresAt.value = newExpiry;
          }
        }
      },
      selectedColor: const Color(0xFF1B5E35).withOpacity(0.3),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 12),
    );
  }

  Widget _buildDurationChip(int minutes, String label) {
    return Obx(() {
      bool isSelected = false;
      if (minutes == 0) {
        isSelected = controller.maintenanceEndTime.value == null;
      } else if (controller.maintenanceEndTime.value != null) {
        // Approximate check
        final diff = controller.maintenanceEndTime.value!.difference(DateTime.now()).inMinutes;
        isSelected = (diff - minutes).abs() < 2; 
      }

      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) controller.setMaintenanceDuration(minutes);
        },
        selectedColor: Colors.orangeAccent.withOpacity(0.2),
        labelStyle: TextStyle(color: isSelected ? Colors.orangeAccent : Colors.white60, fontSize: 12),
      );
    });
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
      ],
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF1B5E35).withOpacity(0.5), size: 18),
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: const Color(0xFF1B5E35), width: 1)),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, {bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B5E35),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      ),
    );
  }

  Widget _buildItemCard(String? imageUrl, String title, String subtitle, VoidCallback onEdit, VoidCallback onDelete, {Widget? trailing, Map<String, dynamic>? data}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: imageUrl != null && imageUrl.isNotEmpty ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imageUrl, 
            width: 60, 
            height: 40, 
            fit: BoxFit.cover, 
            errorWidget: (_,__,___) => const Icon(Icons.broken_image, size: 20),
          ),
        ) : const Icon(Icons.image_not_supported_rounded),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
            if (data != null && data['expiresAt'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.orangeAccent, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${DateFormat('dd MMM, hh:mm a').format((data['expiresAt'] as Timestamp).toDate())}',
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 10),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null) trailing,
            IconButton(icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20), onPressed: onDelete),
          ],
        ),
      ),
    );
  }

  Widget _buildN8nConfigTab(BuildContext context) {
    final n8nController = Get.find<N8nConfigController>();
    final settings = Get.find<SettingsController>();
    final bn = settings.isBangla;

    final borderColor = const Color(0xFF1B5E35).withOpacity(0.2);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('n8n Webhook Config', 'Configure your n8n Live Chat Support webhook and test connection.'),
          const SizedBox(height: 32),
          _buildFormCard([
            const Text('Endpoint Configuration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildTextField(n8nController.urlController, 'Webhook / MCP Server URL', Icons.link_rounded),
            const SizedBox(height: 16),
            _buildTextField(n8nController.apiKeyController, 'API Key (Optional)', Icons.vpn_key_rounded),
            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Model Context Protocol (MCP) Mode',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    bn
                        ? 'অন করলে JSON-RPC ফরম্যাটে ডাটা যাবে, অফ থাকলে সরাসরি POST রিকোয়েস্ট যাবে'
                        : 'Enable JSON-RPC wrapping for MCP servers, or disable for standard webhooks',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  value: n8nController.useMcp.value,
                  activeColor: const Color(0xFFC9A84C),
                  activeTrackColor: const Color(0xFF1B5E35),
                  onChanged: (val) => n8nController.useMcp.value = val,
                )),
            Obx(() {
              if (!n8nController.useMcp.value) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildTextField(
                  n8nController.toolNameController,
                  'MCP Tool Name',
                  Icons.build_circle_rounded,
                ),
              );
            }),
            const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

            _buildActionButton(
              'Save Configuration',
              () async {
                final success = await n8nController.saveConfig();
                if (success) {
                  Get.snackbar(
                    bn ? 'সংরক্ষিত হয়েছে' : 'Settings Saved',
                    bn
                        ? 'লাইভ চ্যাট সেটিংস সফলভাবে আপডেট করা হয়েছে'
                        : 'Live chat configurations updated successfully',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: const Color(0xFF1B5E35),
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ]),
          const SizedBox(height: 28),
          _buildFormCard([
            const Text('Connection Testing Console', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildTextField(n8nController.testMessageController, 'Test Message', Icons.chat_bubble_outline_rounded),
            const SizedBox(height: 24),
        _buildFormCard([
          const Text('In-App Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Show Announcement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('Displays a popup dialog when user opens the app.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.showAnnouncement.value,
                    onChanged: (val) => controller.showAnnouncement.value = val,
                    activeColor: const Color(0xFFC9A84C),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementTitleController, 'Title (e.g. 📢 Important Update)', Icons.title_rounded),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementBodyController, 'Message Body', Icons.message_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(controller.announcementImageController, 'Image URL (Optional)', Icons.image_rounded),
        ]),
        const SizedBox(height: 24),
        _buildFormCard([
          const Text('Feature Toggles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Namaz Guide Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('If off, users will see "Coming Soon". If on, page is available.', style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              Obx(() => Switch(
                    value: controller.isNamazGuideActive.value,
                    onChanged: (val) => controller.isNamazGuideActive.value = val,
                    activeColor: const Color(0xFF1B5E35),
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 24),

            Obx(() => _buildActionButton(
                  n8nController.isTesting.value ? 'Testing...' : 'Test Connection',
                  () => n8nController.testConnection(),
                  isLoading: n8nController.isTesting.value,
                )),
            Obx(() {
              if (n8nController.testResultText.value.isEmpty &&
                  n8nController.testResultStatus.value == null) {
                return const SizedBox.shrink();
              }

              final status = n8nController.testResultStatus.value;
              final isSuccess = status == 200;
              final badgeColor = isSuccess ? Colors.green : Colors.redAccent;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Test Result:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (status != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: badgeColor, width: 1),
                          ),
                          child: Text(
                            'HTTP $status',
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      n8nController.testResultText.value,
                      style: TextStyle(
                        color: isSuccess ? Colors.white : Colors.redAccent,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Theme(
                    data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      leading: const Icon(Icons.terminal_rounded, color: Color(0xFFC9A84C), size: 20),
                      title: Text(
                        bn ? 'র-পেলোড ও ডাটা ডিটেইলস' : 'Raw Payload & Log Details',
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                n8nController.testResultDetails.value,
                                style: GoogleFonts.sourceCodePro(
                                  color: Colors.greenAccent,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ]),
        ],
      ),
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

  Widget _buildUserTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4, right: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('User is typing', style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: const Color(0xFF1B5E35).withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMessageBubble extends StatelessWidget {
  final SupportMessage message;
  final bool isMe;

  const _AdminMessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8, bottom: 4, left: isMe ? 60 : 0, right: isMe ? 0 : 60),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: message.imageUrl!,
                      placeholder: (context, url) => const SizedBox(
                        height: 150, width: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 100,
                        width: 150,
                        color: Colors.black26,
                        child: const Icon(Icons.broken_image, color: Colors.white24),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (message.message.isNotEmpty)
                  Text(message.message, style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 14)),
              ],
            ),
          ),
          Text(
            DateFormat('hh:mm a').format(message.timestamp), 
            style: const TextStyle(fontSize: 10, color: Colors.white30),
          ),
        ],
      ).animate().fadeIn(duration: 200.ms),
    );
  }
}


// ─── Islamic Star / Geometric Pattern Painter ──────────────────────────────────
class _StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const step = 32.0;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar6(canvas, paint, Offset(x, y), 9);
      }
    }
  }

  void _drawStar6(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * (3.14159 / 180);
      final radius = i.isEven ? r : r * 0.45;
      final point = Offset(
        center.dx + radius * _cos(angle),
        center.dy + radius * _sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double rad) => rad == 0
      ? 1
      : (rad - (rad * rad * rad) / 6 + (rad * rad * rad * rad * rad) / 120);
  double _sin(double rad) =>
      rad - (rad * rad * rad) / 6 + (rad * rad * rad * rad * rad) / 120;

  @override
  bool shouldRepaint(_StarPatternPainter old) => false;
}
