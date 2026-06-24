import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'notification_model.dart';
import 'notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final isBn = settings.isBangla;

      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: _buildAppBar(isDark, isBn),
        body: _buildBody(isDark, isBn),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(bool isDark, bool isBn) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Text(isBn ? 'নোটিফিকেশন' : 'Notifications'),
      actions: [
        Obx(() {
          if (controller.notifications.isEmpty) return const SizedBox.shrink();
          return TextButton.icon(
            onPressed: () => _showClearDialog(isBn),
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: Text(isBn ? 'সব পড়া' : 'Mark All'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          );
        }),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody(bool isDark, bool isBn) {
    return Obx(() {
      if (controller.notifications.isEmpty) {
        return _buildEmptyState(isDark, isBn);
      }

      return Column(
        children: [
          // Summary bar
          _buildSummaryBar(isDark, isBn),
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                return _buildNotificationCard(notification, isDark, isBn);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryBar(bool isDark, bool isBn) {
    return Obx(() {
      final unread = controller.unreadCount.value;
      final total = controller.notifications.length;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isBn
                    ? '$total টি নোটিফিকেশন • $unread টি অপঠিত'
                    : '$total notifications • $unread unread',
                style: TextStyle(
                  color: isDark ? AppColors.textGrey : AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildNotificationCard(AppNotification notif, bool isDark, bool isBn) {
    final iconData = _getTypeIcon(notif.type);
    final iconColor = _getTypeColor(notif.type);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deleteNotification(notif.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_rounded, color: AppColors.error, size: 24),
            const SizedBox(height: 4),
            Text(
              isBn ? 'মুছুন' : 'Delete',
              style: const TextStyle(color: AppColors.error, fontSize: 11),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => controller.markAsRead(notif.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead
                ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                : (isDark
                    ? AppColors.primary.withValues(alpha: 0.07)
                    : AppColors.primary.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notif.isRead
                  ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                  : AppColors.primary.withValues(alpha: 0.3),
              width: notif.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              color: isDark ? AppColors.textWhite : AppColors.textDark,
                              fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: TextStyle(
                        color: isDark ? AppColors.textGrey : AppColors.textMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: isDark ? AppColors.textMuted : AppColors.textGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.timeAgo(notif.receivedAt),
                          style: TextStyle(
                            color: isDark ? AppColors.textMuted : AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTypeLabel(notif.type, isBn),
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isBn) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isBn ? 'কোনো নোটিফিকেশন নেই' : 'No Notifications Yet',
            style: TextStyle(
              color: isDark ? AppColors.textWhite : AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isBn
                ? 'নামাজের সময়, দৈনিক হাদিস ও\nনতুন বার্তা এখানে দেখা যাবে'
                : 'Prayer alerts, daily hadith, and\napp updates will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.textGrey : AppColors.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(isBn ? 'ফিরে যান' : 'Go Back'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(bool isBn) {
    Get.dialog(
      AlertDialog(
        title: Text(isBn ? 'সব পড়া হিসেবে চিহ্নিত করুন' : 'Mark All as Read'),
        content: Text(
          isBn
              ? 'সব নোটিফিকেশন পড়া হিসেবে চিহ্নিত করবেন?'
              : 'Mark all notifications as read?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.markAllAsRead();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              isBn ? 'হ্যাঁ' : 'Yes',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'prayer':
        return Icons.access_time_rounded;
      case 'hadith':
        return Icons.menu_book_rounded;
      case 'quran':
        return Icons.auto_stories_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'prayer':
        return AppColors.islamicLight;
      case 'hadith':
        return AppColors.gold;
      case 'quran':
        return AppColors.primary;
      default:
        return AppColors.info;
    }
  }

  String _getTypeLabel(String type, bool isBn) {
    switch (type) {
      case 'prayer':
        return isBn ? 'নামাজ' : 'Prayer';
      case 'hadith':
        return isBn ? 'হাদিস' : 'Hadith';
      case 'quran':
        return isBn ? 'কুরআন' : 'Quran';
      default:
        return isBn ? 'সাধারণ' : 'General';
    }
  }
}
