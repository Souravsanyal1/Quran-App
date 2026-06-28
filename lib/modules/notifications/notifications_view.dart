import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../settings/settings_controller.dart';
import 'notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isBn = settings.isBangla;

      return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
          ),
          title: Text(
            isBn ? 'নোটিফিকেশন' : 'Notifications',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            if (controller.unreadCount.value > 0)
              IconButton(
                icon: const Icon(Icons.done_all_rounded),
                tooltip: isBn ? 'সবগুলো পঠিত হিসেবে চিহ্নিত করুন' : 'Mark all as read',
                onPressed: controller.markAllAsRead,
              ),
            IconButton(
              icon: const Icon(Icons.sort_rounded),
              onPressed: () => _showSortOptions(context, isBn),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            _buildFilterSection(context, isBn),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredNotifications.isEmpty) {
                  return _buildEmptyState(context, isBn);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.filteredNotifications[index];
                    return _buildNotificationCard(context, notification, isBn)
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .slideX(begin: 0.1, curve: Curves.easeOutQuad);
                  },
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterSection(BuildContext context, bool isBn) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              hintText: isBn ? 'নোটিফিকেশন খুঁজুন...' : 'Search notifications...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: context.theme.cardColor.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: Text(isBn ? 'সব' : 'All'),
                selected: controller.selectedCategory.value == null,
                onSelected: (_) => controller.setCategory(null),
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              ...NotificationCategory.values.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getCategoryLabel(cat, isBn)),
                      selected: controller.selectedCategory.value == cat,
                      onSelected: (_) => controller.setCategory(cat),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  String _getCategoryLabel(NotificationCategory cat, bool isBn) {
    switch (cat) {
      case NotificationCategory.general:
        return isBn ? 'সাধারণ' : 'General';
      case NotificationCategory.prayer:
        return isBn ? 'নামাজ' : 'Prayer';
      case NotificationCategory.quran:
        return isBn ? 'কুরআন' : 'Quran';
      case NotificationCategory.announcement:
        return isBn ? 'ঘোষণা' : 'Announcement';
      case NotificationCategory.event:
        return isBn ? 'ইভেন্ট' : 'Event';
      case NotificationCategory.donation:
        return isBn ? 'দান' : 'Donation';
      case NotificationCategory.update:
        return isBn ? 'আপডেট' : 'Update';
      case NotificationCategory.support:
        return isBn ? 'সাপোর্ট' : 'Support';
    }
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification notification, bool isBn) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deleteNotification(notification.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            controller.markAsRead(notification.id);
          }
          _openNotificationDetails(notification);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notification.isRead ? context.theme.cardColor.withOpacity(0.4) : context.theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: notification.isRead ? Colors.white.withOpacity(0.05) : AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: notification.isRead
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: CachedNetworkImage(
                    imageUrl: notification.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    maxWidthDiskCache: 1000, // Optimize disk cache
                    memCacheHeight: 300, // Pre-resize in memory for faster rendering
                    placeholder: (context, url) => Container(
                      height: 150,
                      color: Colors.grey.withOpacity(0.05),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryIcon(notification.category),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildPriorityBadge(notification.priority, isBn),
                              Text(
                                controller.timeAgo(notification.createdAt, isBn),
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notification.title,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8, top: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .scale(
                            duration: const Duration(seconds: 1),
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                          )
                          .then()
                          .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(NotificationCategory category) {
    IconData icon;
    Color color;

    switch (category) {
      case NotificationCategory.prayer:
        icon = Icons.access_time_filled_rounded;
        color = Colors.blue;
        break;
      case NotificationCategory.quran:
        icon = Icons.menu_book_rounded;
        color = AppColors.emerald;
        break;
      case NotificationCategory.announcement:
        icon = Icons.campaign_rounded;
        color = Colors.orange;
        break;
      case NotificationCategory.donation:
        icon = Icons.volunteer_activism_rounded;
        color = Colors.pink;
        break;
      case NotificationCategory.support:
        icon = Icons.support_agent_rounded;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildPriorityBadge(NotificationPriority priority, bool isBn) {
    if (priority == NotificationPriority.low) return const SizedBox.shrink();

    Color color;
    String label;

    switch (priority) {
      case NotificationPriority.urgent:
        color = Colors.red;
        label = isBn ? 'জরুরী' : 'Urgent';
        break;
      case NotificationPriority.high:
        color = Colors.orange;
        label = isBn ? 'উচ্চ' : 'High';
        break;
      default:
        color = Colors.grey;
        label = '';
    }

    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isBn) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 20),
          Text(
            isBn ? 'কোনো নোটিফিকেশন পাওয়া যায়নি' : 'No notifications found',
            style: context.textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, bool isBn) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isBn ? 'সাজানোর অপশন' : 'Sort Notifications', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.arrow_downward_rounded),
              title: Text(isBn ? 'নতুনগুলো আগে' : 'Latest First'),
              trailing: controller.sortBy.value == 'latest' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                controller.setSortBy('latest');
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward_rounded),
              title: Text(isBn ? 'পুরানো গুলো আগে' : 'Oldest First'),
              trailing: controller.sortBy.value == 'oldest' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                controller.setSortBy('oldest');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openNotificationDetails(AppNotification notification) {
    // Navigate to NotificationDetailsView
    // Get.to(() => NotificationDetailsView(notification: notification));
  }
}
