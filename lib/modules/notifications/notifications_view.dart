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
import 'notification_details_view.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _NotifTheme {
  _NotifTheme._();
  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color goldSoft = Color(0xFFFFF8E7);
  static const Color darkSurface = Color(0xFF0A0A0F);
  static const Color darkCard = Color(0xFF121218);
  static const Color lightSurface = Color(0xFFFFF9E6);
  static const Color lightCard = Color(0xFFFFFBF0);
}

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isBn = settings.isBangla;
      final isDark = settings.isDark;
      final scaffoldBg =
          isDark ? _NotifTheme.darkSurface : _NotifTheme.lightSurface;

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: _buildAppBar(isBn, isDark),
        body: Column(
          children: [
            _buildFilterSection(context, isBn, isDark),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: _NotifTheme.emerald,
                            strokeWidth: 3,
                            backgroundColor:
                                _NotifTheme.emerald.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isBn ? 'লোড হচ্ছে...' : 'Loading...',
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white30 : Colors.black38,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.filteredNotifications.isEmpty) {
                  return _buildEmptyState(context, isBn, isDark);
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        controller.filteredNotifications[index];
                    return _buildNotificationCard(
                            context, notification, isBn, isDark)
                        .animate()
                        .fadeIn(delay: (index * 40).ms, duration: 300.ms)
                        .slideY(begin: 0.04, end: 0, curve: Curves.easeOutQuad);
                  },
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isBn, bool isDark) {
    return AppBar(
      elevation: 0,
      leading: AppBackButton(
        color: Colors.white,
        onPressed: () => controller.isSelectionMode.value
            ? controller.clearSelection()
            : Get.back(),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _NotifTheme.emeraldDark,
              _NotifTheme.emerald,
              _NotifTheme.emeraldLight
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border:
              Border(bottom: BorderSide(color: _NotifTheme.gold, width: 1.5)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
                opacity: 0.05,
                child: CustomPaint(painter: _StarPatternPainter())),
          ],
        ),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                    .animate(animation),
            child: child,
          ),
        ),
        child: controller.isSelectionMode.value
            ? Row(
                key: const ValueKey('selection'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _NotifTheme.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.selectedIds.length}',
                      style: GoogleFonts.poppins(
                        color: _NotifTheme.goldLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'নির্বাচিত' : 'selected',
                    style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                ],
              )
            : Row(
                key: const ValueKey('title'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_rounded,
                      color: _NotifTheme.goldLight, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'নোটিফিকেশন' : 'Notifications',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  if (controller.unreadCount.value > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _NotifTheme.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _NotifTheme.gold.withOpacity(0.4),
                            width: 0.5),
                      ),
                      child: Text(
                        '${controller.unreadCount.value}',
                        style: GoogleFonts.poppins(
                          color: _NotifTheme.goldLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
      centerTitle: true,
      actions: [
        if (controller.isSelectionMode.value) ...[
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            tooltip: isBn ? 'নির্বাচিতগুলো মুছুন' : 'Delete selected',
            onPressed: () =>
                _confirmBulkDelete(Get.context!, isBn, false, isDark),
          ),
        ] else ...[
          if (controller.unreadCount.value > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: Colors.white),
              tooltip:
                  isBn ? 'সবগুলো পঠিত হিসেবে চিহ্নিত করুন' : 'Mark all as read',
              onPressed: controller.markAllAsRead,
            ),
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            onPressed: () => _showSortOptions(Get.context!, isBn, isDark),
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Filter Section ──────────────────────────────────────────────────────────
  Widget _buildFilterSection(BuildContext context, bool isBn, bool isDark) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? _NotifTheme.darkCard : _NotifTheme.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? _NotifTheme.emerald.withOpacity(0.12)
                    : _NotifTheme.emerald.withOpacity(0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: controller.setSearchQuery,
              style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    isBn ? 'নোটিফিকেশন খুঁজুন...' : 'Search notifications...',
                hintStyle: GoogleFonts.poppins(
                    color: isDark ? Colors.white30 : Colors.black38,
                    fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 20,
                    color: isDark ? Colors.white38 : _NotifTheme.emerald),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        // Category Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip(
                label: isBn ? 'সব' : 'All',
                icon: Icons.apps_rounded,
                isSelected: controller.selectedCategory.value == null,
                onSelected: () => controller.setCategory(null),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              ...NotificationCategory.values.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: _getCategoryLabel(cat, isBn),
                      icon: _getCategoryIcon(cat),
                      isSelected: controller.selectedCategory.value == cat,
                      onSelected: () => controller.setCategory(cat),
                      isDark: isDark,
                      accentColor: _getCategoryColor(cat),
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
    required IconData icon,
    required bool isSelected,
    required VoidCallback onSelected,
    required bool isDark,
    Color? accentColor,
  }) {
    final chipColor = accentColor ?? _NotifTheme.emerald;
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [chipColor, chipColor.withOpacity(0.8)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? _NotifTheme.darkCard : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? _NotifTheme.gold.withOpacity(0.6)
                : (isDark
                    ? _NotifTheme.emerald.withOpacity(0.12)
                    : _NotifTheme.emerald.withOpacity(0.06)),
            width: isSelected ? 1.2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white54 : chipColor.withOpacity(0.7)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColors.textDark),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Notification Card ───────────────────────────────────────────────────────
  Widget _buildNotificationCard(BuildContext context,
      AppNotification notification, bool isBn, bool isDark) {
    return Obx(() {
      final isSelected = controller.selectedIds.contains(notification.id);
      final catColor = _getCategoryColor(notification.category);

      return Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => controller.deleteNotification(notification.id),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.redAccent.withOpacity(0.08),
                Colors.redAccent.withOpacity(0.15)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 22),
              const SizedBox(height: 4),
              Text(
                isBn ? 'মুছুন' : 'Delete',
                style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
                  ? catColor.withOpacity(isDark ? 0.06 : 0.04)
                  : (notification.isRead
                      ? (isDark
                          ? _NotifTheme.darkCard.withOpacity(0.6)
                          : _NotifTheme.lightCard)
                      : (isDark
                          ? _NotifTheme.darkCard
                          : _NotifTheme.lightCard)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? _NotifTheme.gold
                    : (notification.isRead
                        ? (isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.black.withOpacity(0.04))
                        : catColor.withOpacity(0.15)),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: notification.isRead
                  ? null
                  : [
                      BoxShadow(
                        color: catColor.withOpacity(isDark ? 0.05 : 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Image
                if (notification.imageUrl != null)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: notification.imageUrl!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          maxWidthDiskCache: 1000,
                          memCacheHeight: 300,
                          placeholder: (context, url) => Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: catColor.withOpacity(0.03),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: catColor.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                        ),
                        // Subtle bottom gradient overlay
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 40,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  (isDark
                                          ? _NotifTheme.darkCard
                                          : _NotifTheme.lightCard)
                                      .withOpacity(0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Card Content
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
                                Flexible(
                                    child: _buildPriorityBadge(
                                        notification.priority, isBn)),
                                Text(
                                  controller.timeAgo(
                                      notification.createdAt, isBn),
                                  style: GoogleFonts.poppins(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.title,
                              style: GoogleFonts.poppins(
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                fontSize: 14.5,
                                color:
                                    isDark ? Colors.white : AppColors.textDark,
                                height: 1.3,
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
                      const SizedBox(width: 4),
                      // Unread dot or Selection checkmark
                      if (!notification.isRead && !isSelected)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(left: 4, top: 4),
                          decoration: BoxDecoration(
                            color: catColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: catColor.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scaleXY(
                                begin: 0.85,
                                end: 1.15,
                                duration: 900.ms,
                                curve: Curves.easeInOut),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(left: 4, top: 2),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: _NotifTheme.gold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _NotifTheme.gold.withOpacity(0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14),
                        ).animate().scaleXY(
                            begin: 0,
                            end: 1,
                            duration: 200.ms,
                            curve: Curves.easeOutBack),
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
    final icon = _getCategoryIcon(category);
    final color = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.1), width: 0.5),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildPriorityBadge(NotificationPriority priority, bool isBn) {
    if (priority == NotificationPriority.low ||
        priority == NotificationPriority.medium) {
      return const SizedBox.shrink();
    }

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, bool isBn, bool isDark) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle geometric background
          Opacity(
            opacity: isDark ? 0.03 : 0.04,
            child: CustomPaint(
              painter: _StarPatternPainter(),
              size: const Size(250, 250),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (isDark ? _NotifTheme.emerald : _NotifTheme.emerald)
                      .withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 56,
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isBn
                    ? 'কোনো নোটিফিকেশন পাওয়া যায়নি'
                    : 'No notifications found',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white30 : Colors.black38,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isBn
                    ? 'আপনার নতুন নোটিফিকেশন এখানে দেখা যাবে'
                    : 'New notifications will appear here',
                style: GoogleFonts.poppins(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black26,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  // ── Sort Options Bottom Sheet ───────────────────────────────────────────────
  void _showSortOptions(BuildContext context, bool isBn, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? _NotifTheme.darkCard : _NotifTheme.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
              top: BorderSide(
                  color: _NotifTheme.gold.withOpacity(0.4), width: 1.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              isBn ? 'সাজানোর অপশন' : 'Sort Notifications',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption(
              icon: Icons.arrow_downward_rounded,
              iconColor: _NotifTheme.emerald,
              label: isBn ? 'নতুনগুলো আগে' : 'Latest First',
              isSelected: controller.sortBy.value == 'latest',
              isDark: isDark,
              onTap: () {
                controller.setSortBy('latest');
                Get.back();
              },
            ),
            const SizedBox(height: 8),
            _buildSortOption(
              icon: Icons.delete_forever_rounded,
              iconColor: Colors.redAccent,
              label: isBn ? 'সবগুলো মুছে ফেলুন' : 'Clear All Notifications',
              isSelected: false,
              isDark: isDark,
              isDestructive: true,
              onTap: () {
                Get.back();
                _confirmBulkDelete(context, isBn, true, isDark);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? _NotifTheme.emerald.withOpacity(0.06)
              : (isDark
                  ? Colors.white.withOpacity(0.02)
                  : Colors.black.withOpacity(0.02)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? _NotifTheme.gold.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDestructive
                      ? Colors.redAccent
                      : (isDark ? Colors.white70 : AppColors.textDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded,
                  color: _NotifTheme.gold, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Delete Confirmation Dialog ──────────────────────────────────────────────
  void _confirmBulkDelete(
      BuildContext context, bool isBn, bool all, bool isDark) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? _NotifTheme.darkCard : _NotifTheme.lightCard,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                isBn ? 'নিশ্চিত করুন' : 'Confirm Delete',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                all
                    ? (isBn
                        ? 'আপনি কি সব নোটিফিকেশন মুছে ফেলতে চান?'
                        : 'Are you sure you want to clear all notifications?')
                    : (isBn
                        ? 'নির্বাচিত নোটিফিকেশনগুলো মুছে ফেলতে চান?'
                        : 'Delete selected notifications?'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isBn ? 'না' : 'Cancel',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white70 : AppColors.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (all) {
                          controller.deleteAll();
                        } else {
                          controller.deleteSelected();
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        isBn ? 'মুছুন' : 'Delete',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────────
  void _openNotificationDetails(AppNotification notification) {
    Get.to(
      () => NotificationDetailsView(notification: notification),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 350),
    );
  }

  // ── Category Helpers ────────────────────────────────────────────────────────
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

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.general:
        return Icons.notifications_none_rounded;
      case NotificationCategory.prayer:
        return Icons.mosque_rounded;
      case NotificationCategory.quran:
        return Icons.menu_book_rounded;
      case NotificationCategory.announcement:
        return Icons.campaign_rounded;
      case NotificationCategory.event:
        return Icons.event_available_rounded;
      case NotificationCategory.donation:
        return Icons.volunteer_activism_rounded;
      case NotificationCategory.update:
        return Icons.system_update_alt_rounded;
      case NotificationCategory.support:
        return Icons.support_agent_rounded;
    }
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.general:
        return Colors.blue;
      case NotificationCategory.prayer:
        return AppColors.primary;
      case NotificationCategory.quran:
        return AppColors.islamic;
      case NotificationCategory.announcement:
        return Colors.orange;
      case NotificationCategory.event:
        return Colors.teal;
      case NotificationCategory.donation:
        return Colors.redAccent;
      case NotificationCategory.update:
        return Colors.purple;
      case NotificationCategory.support:
        return Colors.indigo;
    }
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
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
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
