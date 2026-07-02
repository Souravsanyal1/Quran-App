import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../settings/settings_controller.dart';
import '../../auth/auth_controller.dart';

// ── Drawer Design Tokens ─────────────────────────────────────────────────────
class _DrawerTheme {
  _DrawerTheme._();

  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);

  // Dark mode
  static const Color darkSurface = Color(0xFF141420);

  // Light mode
  static const Color lightSurface = Color(0xFFFAF8F5);

  static LinearGradient get headerGradient => const LinearGradient(
        colors: [emeraldDark, emerald, emeraldLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final auth = Get.find<AuthController>();

    return Obx(() {
      final isDark = settings.isDark;
      final bn = settings.isBangla;

      return Drawer(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? _DrawerTheme.darkSurface : _DrawerTheme.lightSurface,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              _DrawerHeader(settings: settings, auth: auth),

              // ── Navigation Items ────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    // Main section
                    _DrawerSectionLabel(
                      label: bn ? 'প্রধান' : 'Main',
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.home_rounded,
                      title: bn ? 'হোম' : 'Home',
                      gradientColors: const [Color(0xFF1B5E35), Color(0xFF2E7D52)],
                      onTap: () => Get.back(),
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.menu_book_rounded,
                      title: bn ? 'আল-কুরআন' : 'Al-Quran',
                      gradientColors: const [Color(0xFF1B5E35), Color(0xFF2E7D52)],
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.quran);
                      },
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.access_time_filled_rounded,
                      title: bn ? 'নামাজের সময়' : 'Prayer Times',
                      gradientColors: const [Color(0xFF5C6BC0), Color(0xFF7986CB)],
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.prayerTime);
                      },
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.explore_rounded,
                      title: bn ? 'কিবলা কম্পাস' : 'Qibla Finder',
                      gradientColors: const [Color(0xFF00897B), Color(0xFF26A69A)],
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.qibla);
                      },
                      isDark: isDark,
                    ),

                    // Admin (conditional)
                    Obx(() {
                      if (auth.isAdmin.value) {
                        return _DrawerItem(
                          icon: Icons.admin_panel_settings_rounded,
                          title: bn ? 'অ্যাডমিন ড্যাশবোর্ড' : 'Admin Dashboard',
                          gradientColors: const [Color(0xFFE65100), Color(0xFFFF8A00)],
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoutes.adminDashboard);
                          },
                          isDark: isDark,
                          isHighlight: true,
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: 8),

                    // Learning section
                    _DrawerSectionLabel(
                      label: bn ? 'শিক্ষা' : 'Learning',
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.auto_stories_rounded,
                      title: bn ? 'শিক্ষা ও গাইড' : 'Learning & Guide',
                      gradientColors: const [Color(0xFF0288D1), Color(0xFF29B6F6)],
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.newMuslimGuide);
                      },
                      isDark: isDark,
                    ),
                    // _DrawerItem(
                    //   icon: Icons.menu_book_outlined,
                    //   title: bn ? 'নামাজ শিক্ষা' : 'Namaz Guide',
                    //   gradientColors: const [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                    //   onTap: () {
                    //     Get.back();
                    //     settings.checkNamazGuideAccessAndNavigate(AppRoutes.salahGuide);
                    //   },
                    //   isDark: isDark,
                    // ),
                    _DrawerItem(
                      icon: Icons.menu_book_rounded,
                      title: bn ? 'নামাজ শিক্ষা' : 'Namaz Guide',
                      gradientColors: const [Color(0xFF00796B), Color(0xFF009688)],
                      onTap: () {
                        Get.back();
                        settings.checkNamazGuideAccessAndNavigate(AppRoutes.salahGuide2);
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: 8),

                    // Ornamental divider
                    _DrawerDivider(isDark: isDark),

                    const SizedBox(height: 8),

                    // Settings section
                    _DrawerSectionLabel(
                      label: bn ? 'অন্যান্য' : 'More',
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.settings_rounded,
                      title: bn ? 'সেটিংস' : 'Settings',
                      gradientColors: const [Color(0xFF455A64), Color(0xFF78909C)],
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.settings);
                      },
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.info_outline_rounded,
                      title: bn ? 'ডেভেলপার তথ্য' : 'Developer Info',
                      gradientColors: const [Color(0xFF455A64), Color(0xFF78909C)],
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.developerInfo);
                      },
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.contact_support_rounded,
                      title: bn ? 'সাপোর্ট' : 'Support',
                      gradientColors: const [_DrawerTheme.gold, _DrawerTheme.goldLight],
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.support);
                      },
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.favorite_rounded,
                      title: bn ? 'অনুদান ও সদকা' : 'Donation & Sadakah',
                      gradientColors: const [Color(0xFFD32F2F), Color(0xFFEF5350)],
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.donation);
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // ── Footer ─────────────────────────────────────────────────
              _DrawerFooter(isDark: isDark),
            ],
          ),
        ),
      );
    });
  }
}

// ── Drawer Header ────────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  final SettingsController settings;
  final AuthController auth;

  const _DrawerHeader({required this.settings, required this.auth});

  @override
  Widget build(BuildContext context) {
    final bn = settings.isBangla;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 22,
        right: 14,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: _DrawerTheme.headerGradient,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Geometric pattern overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(painter: _DrawerPatternPainter()),
              ),
            ),

            // Decorative circles
            Positioned(
              right: -15,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 30,
              top: -10,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _DrawerTheme.goldLight.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: _DrawerTheme.goldLight,
                        size: 28,
                      ),
                    ),
                    // Close button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Get.back(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // App name
                Text(
                  bn ? 'কুরানিয়া' : 'Qurania',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                // Gold accent underline
                Container(
                  height: 2,
                  width: 40,
                  margin: const EdgeInsets.only(top: 6, bottom: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_DrawerTheme.goldLight, _DrawerTheme.gold],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                // User email
                Obx(() => Text(
                      auth.user.value?.email ??
                          (bn ? 'মেহমান ইউজার' : 'Guest User'),
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Drawer Section Label ─────────────────────────────────────────────────────
class _DrawerSectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _DrawerSectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_DrawerTheme.gold, _DrawerTheme.goldLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? _DrawerTheme.goldLight.withValues(alpha: 0.6)
                  : _DrawerTheme.emerald.withValues(alpha: 0.5),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Item ──────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isDark;
  final bool isHighlight;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.gradientColors,
    required this.onTap,
    required this.isDark,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: gradientColors.first.withValues(alpha: 0.08),
          highlightColor: gradientColors.first.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: isHighlight
                ? BoxDecoration(
                    color: gradientColors.first.withValues(alpha: isDark ? 0.1 : 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: gradientColors.first.withValues(alpha: 0.15),
                    ),
                  )
                : null,
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientColors.first.withValues(alpha: isDark ? 0.2 : 0.12),
                        gradientColors.last.withValues(alpha: isDark ? 0.1 : 0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: gradientColors.first,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.textDark,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.textDark.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ornamental Divider ───────────────────────────────────────────────────────
class _DrawerDivider extends StatelessWidget {
  final bool isDark;
  const _DrawerDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = _DrawerTheme.gold.withValues(alpha: isDark ? 0.15 : 0.25);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, color],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.star_rounded,
              size: 8,
              color: _DrawerTheme.gold.withValues(alpha: isDark ? 0.3 : 0.4),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Footer ────────────────────────────────────────────────────────────
class _DrawerFooter extends StatelessWidget {
  final bool isDark;
  const _DrawerFooter({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          // Divider
          _DrawerDivider(isDark: isDark),
          const SizedBox(height: 12),
          // Version info with subtle styling
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _DrawerTheme.emeraldLight.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Version 1.0.0',
                style: GoogleFonts.poppins(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.textDark.withValues(alpha: 0.35),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _DrawerTheme.emeraldLight.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Geometric Pattern Painter for Header ─────────────────────────────────────
class _DrawerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const step = 30.0;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar(canvas, paint, Offset(x, y), 8);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * (math.pi / 180);
      final radius = i.isEven ? r : r * 0.4;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DrawerPatternPainter old) => false;
}
