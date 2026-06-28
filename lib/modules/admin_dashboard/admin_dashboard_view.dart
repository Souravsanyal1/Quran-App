import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/support_chat_model.dart';
import '../auth/auth_controller.dart';
import '../home/banner_controller.dart';
import 'admin_chat_controller.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff09090b),
        cardColor: const Color(0xff121214),
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(primary: AppColors.primary),
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: const Duration(seconds: 2)),
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
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: const Duration(seconds: 1)).fadeOut(delay: const Duration(seconds: 1)),
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
            color: Color(0xff121214),
            border: Border(right: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildSidebarItem(0, Icons.grid_view_rounded, 'Dashboard Overview'),
              _buildSidebarItem(7, Icons.forum_rounded, 'Support Inbox'),
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
            color: Color(0xff121214),
            border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Obx(() => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMobileTabItem(0, 'Overview'),
                  _buildMobileTabItem(7, 'Inbox'),
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
            color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
            border: Border.all(
                color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
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

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0: return _buildOverviewTab();
      case 2: return _buildBannersTab();
      case 3: return _buildStaticBannersTab();
      case 4: return _buildNotificationsTab();
      case 5: return _buildPrayerSettingsTab();
      case 6: return _buildCustomAdsTab();
      case 7: return _buildSupportInboxTab();
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
                _buildModernStatsCard('Support Inbox', controller.totalTicketsCount, Icons.forum_rounded, AppColors.primary),
                _buildModernStatsCard('Visual Banners', controller.totalBannersCount, Icons.collections_rounded, Colors.blueAccent),
                _buildModernStatsCard('Active Campaigns', controller.totalAdsCount, Icons.campaign_rounded, Colors.purpleAccent),
                _buildModernStatsCard('Administrators', controller.totalAdminsCount, Icons.admin_panel_settings_rounded, AppColors.emerald),
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
        color: const Color(0xff121214),
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
        _buildTicketFilters(),
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
              fillColor: const Color(0xff121214),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Obx(() => DropdownButton<TicketStatus?>(
          value: controller.ticketStatusFilter.value,
          hint: const Text('All Status'),
          dropdownColor: const Color(0xff121214),
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
        color: const Color(0xff121214),
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
        backgroundColor: const Color(0xff09090b),
        insetPadding: const EdgeInsets.all(40),
        child: Container(
          width: 500, height: 700,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xff121214), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                decoration: const BoxDecoration(color: Color(0xff121214), borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      if (chatController.selectedImage.value != null) {
                        return Container(
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: (kIsWeb
                                      ? NetworkImage(chatController.selectedImage.value!.path)
                                      : FileImage(File(chatController.selectedImage.value!.path)))
                                  as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () => chatController.selectedImage.value = null,
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
                          icon: const Icon(Icons.image_rounded, color: AppColors.primary),
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
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                            : const Icon(Icons.send_rounded, color: AppColors.primary),
                          style: IconButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1)),
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
    ).then((_) => Get.delete<AdminChatController>(tag: userId));
  }

  Widget _buildBannersTab() {
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
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCustomAdsTab() {
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
          const SizedBox(height: 24),
          Obx(() => _buildActionButton(
            'Publish Campaign Ad',
            controller.addCustomAd,
            isLoading: controller.isAdSubmitting.value,
          )),
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
                  () => controller.toggleAdStatus(id, status),
                  () => controller.deleteCustomAd(id),
                  trailing: Switch(
                    value: status == 'active',
                    onChanged: (_) => controller.toggleAdStatus(id, status),
                    activeColor: AppColors.primary,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStaticBannersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Static Banners', 'Manage the thin banners directly below the AppBar.'),
        const SizedBox(height: 32),
        const Center(child: Text('Coming Soon: Static Banner Management')),
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
          _buildActionButton('Save Configuration', controller.savePrayerSettings, isLoading: controller.isSettingsSaving.value),
        ]),
      ],
    );
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
        color: const Color(0xff121214),
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
        prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.5), size: 18),
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
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
          backgroundColor: AppColors.primary,
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

  Widget _buildItemCard(String? imageUrl, String title, String subtitle, VoidCallback onEdit, VoidCallback onDelete, {Widget? trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff121214),
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
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
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
          color: Color(0xff1A1A24),
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
              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.primary.withOpacity(0.3)),
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
              color: isMe ? AppColors.primary : const Color(0xff1A1A24),
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
