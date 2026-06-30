import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../data/models/notification_model.dart';
import '../../widgets/app_back_button.dart';
import '../settings/settings_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _DetailTheme {
  _DetailTheme._();
  static const Color emerald      = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark  = Color(0xFF0D3B1E);
  static const Color gold         = Color(0xFFC9A84C);
  static const Color goldLight    = Color(0xFFE8C97A);
  static const Color goldSoft     = Color(0xFFFFF8E7);
  static const Color darkSurface  = Color(0xFF0A0A0F); // Matching AppColors.bgDark
  static const Color darkCard     = Color(0xFF121218); // Matching AppColors.bgDark2
  static const Color lightSurface = Color(0xFFFFF9E6); // Matching AppColors.bgLight
  static const Color lightCard    = Color(0xFFFFFBF0); // Matching AppColors.surfaceLight
}

class NotificationDetailsView extends StatefulWidget {
  final AppNotification notification;

  const NotificationDetailsView({super.key, required this.notification});

  @override
  State<NotificationDetailsView> createState() => _NotificationDetailsViewState();
}

class _NotificationDetailsViewState extends State<NotificationDetailsView> {
  double _fontSize = 15.0;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    final scaffoldBg = isDark ? _DetailTheme.darkSurface : _DetailTheme.lightSurface;
    final cardColor = isDark ? _DetailTheme.darkCard : _DetailTheme.lightCard;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subtitleColor = isDark ? Colors.white54 : Colors.black54;
    final borderColor = isDark ? _DetailTheme.emerald.withOpacity(0.15) : _DetailTheme.emerald.withOpacity(0.06);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -32),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges and Font Size Controller Row
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _buildCategoryBadge(widget.notification.category, isBn),
                                _buildPriorityBadge(widget.notification.priority, isBn),
                              ],
                            ),
                          ),
                          _buildFontSizeControls(isDark),
                        ],
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
                      
                      const SizedBox(height: 16),
                      
                      // Creation Date Time Row
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: subtitleColor),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMMM dd, yyyy • hh:mm a').format(widget.notification.createdAt),
                            style: GoogleFonts.poppins(color: subtitleColor, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ).animate().fadeIn(delay: 150.ms),
                      
                      const SizedBox(height: 16),
                      
                      // Notification Title
                      Text(
                        widget.notification.title,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          height: 1.3,
                          color: textColor,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                      
                      const SizedBox(height: 16),
                      
                      // Decorative Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.white10 : Colors.black12,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(
                              Icons.brightness_3_rounded, // Crescent moon
                              size: 14,
                              color: _DetailTheme.gold,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.white10 : Colors.black12,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 250.ms),
                      
                      const SizedBox(height: 16),
                      
                      // Selectable Notification Body
                      SelectableText(
                        widget.notification.body,
                        style: GoogleFonts.poppins(
                          fontSize: _fontSize,
                          color: isDark ? Colors.white70 : AppColors.textDark.withOpacity(0.85),
                          height: 1.6,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      
                      const SizedBox(height: 24),
                      
                      // Subtle dot decorative separator
                      Center(
                        child: Opacity(
                          opacity: 0.25,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(3, (index) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(Icons.circle, size: 6, color: _DetailTheme.gold),
                            )),
                          ),
                        ),
                      ).animate().fadeIn(delay: 350.ms),
                      
                      const SizedBox(height: 12),
                      
                      // Call To Action (if deep link exists)
                      if (widget.notification.deepLink != null && widget.notification.deepLink!.isNotEmpty) ...[
                        _buildCallToAction(isBn),
                        const SizedBox(height: 16),
                      ],
                      
                      // Copy & Share buttons
                      _buildActions(context, isDark, cardColor, textColor, subtitleColor, borderColor, isBn)
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    final scaffoldBg = isDark ? _DetailTheme.darkSurface : _DetailTheme.lightSurface;
    return SliverAppBar(
      expandedHeight: widget.notification.imageUrl != null ? 300 : 200,
      pinned: true,
      backgroundColor: scaffoldBg,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: AppBackButton(
          color: Colors.white,
          onPressed: () => Get.back(),
        ),
      ),
      flexibleSpace: widget.notification.imageUrl != null
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () => _openFullscreenImage(context, widget.notification.imageUrl!),
                    child: Hero(
                      tag: 'notif_img_${widget.notification.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.notification.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            scaffoldBg,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_DetailTheme.emeraldDark, _DetailTheme.emerald, _DetailTheme.emeraldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border(bottom: BorderSide(color: _DetailTheme.gold, width: 1.5)),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.08,
                      child: CustomPaint(painter: _StarPatternPainter()),
                    ),
                    Center(
                      child: Hero(
                        tag: 'notif_icon_${widget.notification.id}',
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(widget.notification.category).withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _getCategoryColor(widget.notification.category).withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getCategoryColor(widget.notification.category).withOpacity(0.2),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCategoryIcon(widget.notification.category),
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFontSizeControls(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (_fontSize > 12.0) {
                setState(() => _fontSize -= 1.0);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.remove, size: 16, color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${_fontSize.toInt()}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              if (_fontSize < 24.0) {
                setState(() => _fontSize += 1.0);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.add, size: 16, color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(NotificationCategory category, bool isBn) {
    final catColor = _getCategoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: catColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: catColor.withOpacity(0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getCategoryIcon(category), size: 12, color: catColor),
          const SizedBox(width: 6),
          Text(
            _getCategoryName(category, isBn).toUpperCase(),
            style: GoogleFonts.poppins(
              color: catColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(NotificationPriority priority, bool isBn) {
    if (priority == NotificationPriority.low || priority == NotificationPriority.medium) {
      return const SizedBox.shrink();
    }
    
    final color = _getPriorityColor(priority);
    final label = _getPriorityLabel(priority, isBn);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scaleXY(begin: 0.8, end: 1.3, duration: 800.ms),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction(bool isBn) {
    final categoryColor = _getCategoryColor(widget.notification.category);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            categoryColor,
            categoryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleDeepLink(widget.notification.deepLink!),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isBn ? 'বিস্তারিত দেখুন' : 'Explore Now',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .shimmer(delay: NumDurationExtensions(2).seconds, duration: NumDurationExtensions(1.5).seconds, color: Colors.white24);
  }

  Widget _buildActions(
    BuildContext context, 
    bool isDark, 
    Color cardColor, 
    Color textColor, 
    Color subtitleColor, 
    Color borderColor,
    bool isBn,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.share_rounded,
            label: isBn ? 'শেয়ার' : 'Share',
            onTap: () => Share.share('${widget.notification.title}\n\n${widget.notification.body}'),
            isDark: isDark,
            cardColor: cardColor,
            textColor: textColor,
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.copy_rounded,
            label: isBn ? 'কপি' : 'Copy',
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.notification.body));
              Get.snackbar(
                isBn ? 'অনুলিপি করা হয়েছে' : 'Copied', 
                isBn ? 'নোটিফিকেশনের লেখা সফলভাবে কপি করা হয়েছে!' : 'Notification content copied to clipboard!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: _getCategoryColor(widget.notification.category),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                boxShadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  )
                ],
              );
            },
            isDark: isDark,
            cardColor: cardColor,
            textColor: textColor,
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: _getCategoryColor(widget.notification.category)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: subtitleColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreenImage(BuildContext context, String imageUrl) {
    Get.to(() => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            heroAttributes: PhotoViewHeroAttributes(tag: 'notif_img_${widget.notification.id}'),
          ),
        ));
  }

  void _handleDeepLink(String deepLink) {
    final route = deepLink.trim().toLowerCase();
    
    if (route.contains('tasbih')) {
      Get.toNamed(AppRoutes.tasbih);
    } else if (route.contains('qibla')) {
      Get.toNamed(AppRoutes.qibla);
    } else if (route.contains('prayer') || route.contains('namaz')) {
      Get.toNamed(AppRoutes.prayerTime);
    } else if (route.contains('quran')) {
      Get.toNamed(AppRoutes.quran);
    } else if (route.contains('dua')) {
      Get.toNamed(AppRoutes.duas);
    } else if (route.contains('donation') || route.contains('donat')) {
      Get.toNamed(AppRoutes.donation);
    } else if (route.contains('support')) {
      Get.toNamed(AppRoutes.support);
    } else if (route.contains('settings')) {
      Get.toNamed(AppRoutes.settings);
    } else if (route.contains('tracker')) {
      Get.toNamed(AppRoutes.tracker);
    } else if (route.contains('salah') || route.contains('guide')) {
      Get.toNamed(AppRoutes.salahGuide);
    } else if (route.contains('developer')) {
      Get.toNamed(AppRoutes.developerInfo);
    } else {
      if (deepLink.startsWith('/')) {
        Get.toNamed(deepLink);
      } else {
        Get.toNamed('/$deepLink');
      }
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
        return AppColors.primary; // Gold/Primary
      case NotificationCategory.quran:
        return AppColors.islamic; // Green
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

  String _getCategoryName(NotificationCategory category, bool isBn) {
    switch (category) {
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

  String _getPriorityLabel(NotificationPriority priority, bool isBn) {
    switch (priority) {
      case NotificationPriority.low:
        return isBn ? 'কম' : 'Low';
      case NotificationPriority.medium:
        return isBn ? 'মাঝারি' : 'Medium';
      case NotificationPriority.high:
        return isBn ? 'উচ্চ' : 'High';
      case NotificationPriority.urgent:
        return isBn ? 'জরুরি' : 'Urgent';
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.green;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
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
