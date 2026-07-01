import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'developer_info_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _DevTheme {
  _DevTheme._();
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

class DeveloperInfoView extends GetView<DeveloperInfoController> {
  const DeveloperInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final bn = settings.isBangla;

      final scaffoldBg = isDark ? _DevTheme.darkSurface : _DevTheme.lightSurface;
      final cardColor = isDark ? _DevTheme.darkCard : _DevTheme.lightCard;
      final textColor = isDark ? Colors.white : AppColors.textDark;
      final subtitleColor = isDark ? AppColors.textGrey : Colors.black54;
      final borderColor = isDark ? _DevTheme.emerald.withOpacity(0.15) : _DevTheme.emerald.withOpacity(0.06);

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          leading: const AppBackButton(color: Colors.white),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_DevTheme.emeraldDark, _DevTheme.emerald, _DevTheme.emeraldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: _DevTheme.gold, width: 1.5)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
              ],
            ),
          ),
          title: Text(
            bn ? 'ডেভেলপার তথ্য' : 'Developer Information',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                
                // Avatar with premium gradient border
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_DevTheme.emerald, _DevTheme.gold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: isDark ? _DevTheme.darkSurface : Colors.white,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(52),
                        child: CachedNetworkImage(
                          imageUrl: 'https://i.postimg.cc/t45rDD8J/Whats-App-Image-2026-06-20-at-11-47-11-AM-(1).jpg',
                          width: 104,
                          height: 104,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const SizedBox(
                            width: 32,
                            height: 6,
                            child: Center(
                              child: LinearProgressIndicator(
                                color: _DevTheme.emerald,
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person_rounded,
                            size: 64,
                            color: _DevTheme.emerald,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Name & Publisher
                Text(
                  'Sourav Sanyal Joy',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bn ? 'প্রকাশক: Nexora Labs' : 'Publisher: Nexora Labs',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: _DevTheme.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 28),

                // Section Title: Contact & Socials
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _DevTheme.gold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        bn ? 'যোগাযোগ ও সোশ্যাল মিডিয়া' : 'Contact & Social Links',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _DevTheme.emerald,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Social Grid/List Cards
                _buildSocialTile(
                  title: 'Email',
                  subtitle: 'joysanyal1999@gmail.com',
                  svgString: AppIcons.gmail,
                  color: Colors.redAccent,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchEmail(),
                ),
                const SizedBox(height: 12),
                
                _buildSocialTile(
                  title: bn ? 'পোর্টফোলিও' : 'Portfolio',
                  subtitle: 'souravs-portfollio.vercel.app',
                  svgString: AppIcons.portfolio,
                  color: Colors.blueAccent,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchURL('https://souravs-portfollio.vercel.app/'),
                ),
                const SizedBox(height: 12),

                _buildSocialTile(
                  title: 'GitHub',
                  subtitle: 'github.com/Souravsanyal1',
                  svgString: AppIcons.github,
                  color: isDark ? Colors.white : Colors.black87,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchURL('https://github.com/Souravsanyal1'),
                ),
                const SizedBox(height: 12),

                _buildSocialTile(
                  title: 'LinkedIn',
                  subtitle: 'linkedin.com/in/sourav-sanyal-joy',
                  svgString: AppIcons.linkedin,
                  color: const Color(0xFF0077B5),
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchURL('https://www.linkedin.com/in/sourav-sanyal-joy/'),
                ),
                const SizedBox(height: 12),

                _buildSocialTile(
                  title: 'X / Twitter',
                  subtitle: 'x.com/Souravisms',
                  svgString: AppIcons.twitterX,
                  color: isDark ? Colors.white : Colors.black,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchURL('https://x.com/Souravisms'),
                ),
                const SizedBox(height: 12),

                _buildSocialTile(
                  title: 'Facebook',
                  subtitle: 'facebook.com/sourav.sanyal.developer',
                  svgString: AppIcons.facebook,
                  color: const Color(0xFF1877F2),
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                  onTap: () => controller.launchURL('https://www.facebook.com/sourav.sanyal.developer/'),
                ),
                
                const SizedBox(height: 36),
                
                // Footer
                Text(
                  bn ? 'Qurania এর সাথে থাকার জন্য ধন্যবাদ।' : 'Thank you for supporting Qurania.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: subtitleColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSocialTile({
    required String title,
    required String subtitle,
    required String svgString,
    required Color color,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: _DevTheme.emerald.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.string(
                svgString,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: _DevTheme.emerald,
            ),
          ],
        ),
      ),
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
