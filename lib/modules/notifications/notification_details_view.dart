import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
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
  static const Color darkSurface  = Color(0xFF141420);
  static const Color darkCard     = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard    = Color(0xFFFFFFFF);
}

class NotificationDetailsView extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailsView({super.key, required this.notification});

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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDark, textColor, subtitleColor),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                  const SizedBox(height: 24),
                  _buildContent(context, isDark, textColor),
                  const SizedBox(height: 40),
                  _buildActions(context, isDark, cardColor, textColor, subtitleColor, borderColor, isBn),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: notification.imageUrl != null ? 300 : 0,
      pinned: true,
      backgroundColor: isDark ? _DetailTheme.darkSurface : _DetailTheme.lightSurface,
      leading: AppBackButton(
        color: Colors.white,
        onPressed: () => Get.back(),
      ),
      flexibleSpace: notification.imageUrl != null
          ? FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () => _openFullscreenImage(context, notification.imageUrl!),
                child: Hero(
                  tag: 'notif_img_${notification.id}',
                  child: CachedNetworkImage(
                    imageUrl: notification.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_DetailTheme.emeraldDark, _DetailTheme.emerald, _DetailTheme.emeraldLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(bottom: BorderSide(color: _DetailTheme.gold, width: 1.5)),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildCategoryBadge(notification.category),
            const SizedBox(width: 12),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(notification.createdAt),
              style: GoogleFonts.poppins(color: subtitleColor, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          notification.title,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.25,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(NotificationCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _DetailTheme.emerald.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _DetailTheme.gold.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        category.name.toUpperCase(),
        style: GoogleFonts.poppins(color: _DetailTheme.emerald, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, Color textColor) {
    return Text(
      notification.body,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: isDark ? Colors.white70 : AppColors.textDark.withOpacity(0.85),
        height: 1.6,
      ),
    );
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
        _buildActionButton(
          context,
          icon: Icons.share_rounded,
          label: isBn ? 'শেয়ার' : 'Share',
          onTap: () => Share.share('${notification.title}\n\n${notification.body}'),
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          context,
          icon: Icons.copy_rounded,
          label: isBn ? 'কপি' : 'Copy',
          onTap: () {
            Clipboard.setData(ClipboardData(text: notification.body));
            Get.snackbar(
              isBn ? 'অনুলিপি করা হয়েছে' : 'Copied', 
              isBn ? 'নোটিফিকেশনের লেখা সফলভাবে কপি করা হয়েছে!' : 'Notification content copied to clipboard!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: _DetailTheme.emerald.withOpacity(0.9),
              colorText: Colors.white,
            );
          },
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: _DetailTheme.emerald),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
            heroAttributes: PhotoViewHeroAttributes(tag: 'notif_img_${notification.id}'),
          ),
        ));
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
