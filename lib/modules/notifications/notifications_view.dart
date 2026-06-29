import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../../widgets/app_back_button.dart';
import '../settings/settings_controller.dart';
import 'notifications_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _NotifTheme {
  _NotifTheme._();
  static const Color emerald      = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark  = Color(0xFF0D3B1E);
  static const Color gold         = Color(0xFFC9A84C);
  static const Color goldLight    = Color(0xFFE8C97A);
  static const Color goldSoft     = Color(0xFFFFF8E7);
  static const Color darkSurface  = Color(0xFF141420);
  static const Color darkCard     = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard    = Color(0xFFFFFFFF);
}

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isBn = settings.isBangla;
      final isDark = settings.isDark;
      final scaffoldBg = isDark ? _NotifTheme.darkSurface : _NotifTheme.lightSurface;

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          elevation: 0,
          leading: AppBackButton(
            color: Colors.white,
            onPressed: () => controller.isSelectionMode.value ? controller.clearSelection() : Get.back(),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_NotifTheme.emeraldDark, _NotifTheme.emerald, _NotifTheme.emeraldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: _NotifTheme.gold, width: 1.5)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
              ],
            ),
          ),
          title: Text(
            controller.isSelectionMode.value 
              ? (isBn ? '${controller.selectedIds.length}টি নির্বাচিত' : '${controller.selectedIds.length} selected')
              : (isBn ? 'নোটিফিকেশন' : 'Notifications'),
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
          actions: [
            if (controller.isSelectionMode.value) ...[
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                tooltip: isBn ? 'নির্বাচিতগুলো মুছুন' : 'Delete selected',
                onPressed: () => _confirmBulkDelete(context, isBn, false, isDark),
              ),
            ] else ...[
              if (controller.unreadCount.value > 0)
                IconButton(
                  icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                  tooltip: isBn ? 'সবগুলো পঠিত হিসেবে চিহ্নিত করুন' : 'Mark all as read',
                  onPressed: controller.markAllAsRead,
                ),
              IconButton(
                icon: const Icon(Icons.sort_rounded, color: Colors.white),
                onPressed: () => _showSortOptions(context, isBn, isDark),
              ),
            ],
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            _buildFilterSection(context, isBn, isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: _NotifTheme.emerald));
                }

                if (controller.filteredNotifications.isEmpty) {
                  return _buildEmptyState(context, isBn, isDark);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: controller.filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.filteredNotifications[index];
                    return _buildNotificationCard(context, notification, isBn, isDark)
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .slideY(begin: 0.05, curve: Curves.easeOutQuad);
                  },
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterSection(BuildContext context, bool isBn, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? _NotifTheme.darkCard : _NotifTheme.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? _NotifTheme.emerald.withOpacity(0.15) : _NotifTheme.emerald.withOpacity(0.06),
              ),
            ),
            child: TextField(
              onChanged: controller.setSearchQuery,
              style: GoogleFonts.poppins(color: isDark ? Colors.white : AppColors.textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: isBn ? 'নোটিফিকেশন খুঁজুন...' : 'Search notifications...',
                hintStyle: GoogleFonts.poppins(color: isDark ? Colors.white30 : Colors.black38, fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 20, color: _NotifTheme.emerald),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip(
                label: isBn ? 'সব' : 'All',
                isSelected: controller.selectedCategory.value == null,
                onSelected: () => controller.setCategory(null),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              ...NotificationCategory.values.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: _getCategoryLabel(cat, isBn),
                      isSelected: controller.selectedCategory.value == cat,
                      onSelected: () => controller.setCategory(cat),
                      isDark: isDark,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [_NotifTheme.emerald, _NotifTheme.emeraldLight],
                )
              : null,
          color: isSelected ? null : (isDark ? _NotifTheme.darkCard : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? _NotifTheme.gold
                : (isDark ? _NotifTheme.emerald.withOpacity(0.15) : _NotifTheme.emerald.withOpacity(0.06)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _NotifTheme.emerald.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark),
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
      ),
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

  Widget _buildNotificationCard(BuildContext context, AppNotification notification, bool isBn, bool isDark) {
    return Obx(() {
      final isSelected = controller.selectedIds.contains(notification.id);
      
      return Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => controller.deleteNotification(notification.id),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
        ),
        child: InkWell(
          onTap: () {
            if (controller.isSelectionMode.value) {
              controller.toggleSelection(notification.id);
            } else {
              if (!notification.isRead) {
                controller.markAsRead(notification.id);
              }
              _openNotificationDetails(notification);
            }
          },
          onLongPress: () {
            controller.toggleSelection(notification.id);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? _NotifTheme.emerald.withOpacity(0.08)
                  : (notification.isRead 
                      ? (isDark ? _NotifTheme.darkCard.withOpacity(0.6) : _NotifTheme.lightCard)
                      : (isDark ? _NotifTheme.darkCard : _NotifTheme.lightCard)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? _NotifTheme.gold
                    : (notification.isRead 
                        ? (isDark ? _NotifTheme.emerald.withOpacity(0.1) : _NotifTheme.emerald.withOpacity(0.04)) 
                        : _NotifTheme.emerald.withOpacity(0.18)),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: notification.isRead
                  ? null
                  : [
                      BoxShadow(
                        color: _NotifTheme.emerald.withOpacity(isDark ? 0.03 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: notification.imageUrl!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      maxWidthDiskCache: 1000,
                      memCacheHeight: 300,
                      placeholder: (context, url) => Container(
                        height: 140,
                        color: Colors.grey.withOpacity(0.05),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _NotifTheme.emerald)),
                      ),
                      errorWidget: (context, url, error) => const SizedBox.shrink(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryIcon(notification.category, isDark),
                      const SizedBox(width: 14),
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
                                  style: GoogleFonts.poppins(
                                    color: isDark ? Colors.white38 : Colors.black38,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.title,
                              style: GoogleFonts.poppins(
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 12.5,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!notification.isRead && !isSelected)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          decoration: const BoxDecoration(
                            color: _NotifTheme.emerald,
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
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(left: 8, top: 4),
                          child: Icon(Icons.check_circle_rounded, color: _NotifTheme.gold, size: 20),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCategoryIcon(NotificationCategory category, bool isDark) {
    IconData icon;
    Color color;

    switch (category) {
      case NotificationCategory.prayer:
        icon = Icons.access_time_filled_rounded;
        color = Colors.blue;
        break;
      case NotificationCategory.quran:
        icon = Icons.menu_book_rounded;
        color = _NotifTheme.emerald;
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
        color = _NotifTheme.emerald;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 18),
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
        style: GoogleFonts.poppins(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isBn, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, 
               size: 80, 
               color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          const SizedBox(height: 20),
          Text(
            isBn ? 'কোনো নোটিফিকেশন পাওয়া যায়নি' : 'No notifications found',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white30 : Colors.black38,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, bool isBn, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? _NotifTheme.darkCard : _NotifTheme.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: _NotifTheme.gold.withOpacity(0.5), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBn ? 'সাজানোর অপশন' : 'Sort Notifications', 
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.arrow_downward_rounded, color: _NotifTheme.emerald),
              title: Text(
                isBn ? 'নতুনগুলো আগে' : 'Latest First',
                style: GoogleFonts.poppins(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textDark, fontWeight: FontWeight.w500),
              ),
              trailing: controller.sortBy.value == 'latest' ? const Icon(Icons.check_rounded, color: _NotifTheme.gold) : null,
              onTap: () {
                controller.setSortBy('latest');
                Get.back();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
              title: Text(
                isBn ? 'সবগুলো মুছে ফেলুন' : 'Clear All Notifications', 
                style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Get.back();
                _confirmBulkDelete(context, isBn, true, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBulkDelete(BuildContext context, bool isBn, bool all, bool isDark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? _NotifTheme.darkCard : _NotifTheme.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isBn ? 'নিশ্চিত করুন' : 'Confirm Delete',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark),
        ),
        content: Text(
          all 
              ? (isBn ? 'আপনি কি সব নোটিফিকেশন মুছে ফেলতে চান?' : 'Are you sure you want to clear all notifications?')
              : (isBn ? 'নির্বাচিত নোটিফিকেশনগুলো মুছে ফেলতে চান?' : 'Are you sure you want to delete selected notifications?'),
          style: GoogleFonts.poppins(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: Text(isBn ? 'না' : 'Cancel', style: GoogleFonts.poppins(color: _NotifTheme.emerald, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              if (all) {
                controller.deleteAll();
              } else {
                controller.deleteSelected();
              }
              Get.back();
            },
            child: Text(isBn ? 'হ্যাঁ, মুছুন' : 'Yes, Delete', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openNotificationDetails(AppNotification notification) {
    // Navigate to NotificationDetailsView
    // Get.to(() => NotificationDetailsView(notification: notification));
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
