import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../notifications/notifications_controller.dart';
import 'home_controller.dart';
import 'banner_controller.dart';
import 'widgets/app_drawer.dart';
import 'widgets/home_dashboard.dart';
import 'widgets/floating_support_button.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/banner_ad_widget.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _QTheme {
  // Palette
  static const Color emerald      = Color(0xFF1B5E35); // deep Islamic green
  static const Color emeraldLight = Color(0xFF2E7D52); // lighter green for gradients
  static const Color gold         = Color(0xFFC9A84C); // warm gold accent
  static const Color goldLight    = Color(0xFFE8C97A); // soft gold highlight
  static const Color cream        = Color(0xFFF8F4EF); // warm off-white surface
  static const Color inkDark      = Color(0xFF1A1A2E); // near-black for dark mode
  static const Color inkMid       = Color(0xFF2D3561); // secondary dark
  static const Color shadow       = Color(0x26000000); // 15% black

  // Typography helpers
  static TextStyle appBarTitle(bool isBangla) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.8,
  );

  static TextStyle badgeText() => const TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );
}

// ─── HomeView ─────────────────────────────────────────────────────────────────
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final bannerController = Get.put(BannerController());
    final notificationsController = Get.find<NotificationsController>();

    return ShowCaseWidget(
      onStart: (index, key) => debugPrint('onStart: $index, $key'),
      onComplete: (index, key) => debugPrint('onComplete: $index, $key'),
      blurValue: 1,
      builder: (context) {
        controller.startShowcase(context);

        return Obx(() {
          final isDark = settings.isDark;
          final bool bn = settings.isBangla;

          return Scaffold(
            backgroundColor: isDark ? _QTheme.inkDark : _QTheme.cream,
            drawer: const AppDrawer(),

            // ── AppBar with gradient + geometric overlay ──────────────────────
            appBar: _IslamicAppBar(
              isBangla: bn,
              isDark: isDark,
              notificationsController: notificationsController,
            ),

            body: Column(
              children: [
                // ── Thin promo strip ─────────────────────────────────────────
                _StaticTopBannerArea(controller: bannerController),

                // ── Scrollable content ────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Photo slider with dot indicator
                        _BannerSlider(controller: bannerController),

                        // Main dashboard
                        const HomeDashboard(),
                      ],
                    ),
                  ),
                ),

                // ── Bottom ad strip ───────────────────────────────────────────
                const BannerAdWidget(),
              ],
            ),

            floatingActionButton: const FloatingSupportButton(),
          );
        });
      },
    );
  }
}

// ─── Islamic AppBar ────────────────────────────────────────────────────────────
class _IslamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isBangla;
  final bool isDark;
  final NotificationsController notificationsController;

  const _IslamicAppBar({
    required this.isBangla,
    required this.isDark,
    required this.notificationsController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_QTheme.emerald, _QTheme.emeraldLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // Subtle bottom gold line
          border: const Border(
            bottom: BorderSide(color: _QTheme.gold, width: 1.5),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Geometric star pattern overlay (opacity)
            Opacity(
              opacity: 0.07,
              child: CustomPaint(painter: _StarPatternPainter()),
            ),
          ],
        ),
      ),

      // ── Hamburger menu ───────────────────────────────────────────────────
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          tooltip: 'Menu',
        ),
      ),

      // ── Title ────────────────────────────────────────────────────────────
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isBangla ? 'কুরআন অ্যাপ' : 'Quran App',
            style: _QTheme.appBarTitle(isBangla),
          ),
          // Gold accent underline
          Container(
            height: 2,
            width: 36,
            decoration: BoxDecoration(
              color: _QTheme.goldLight,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),

      // ── Notification bell ─────────────────────────────────────────────────
      actions: [
        Obx(() {
          final count = notificationsController.unreadCount.value;
          return badges.Badge(
            position: badges.BadgePosition.topEnd(top: 8, end: 8),
            showBadge: count > 0,
            badgeContent: Text(count.toString(), style: _QTheme.badgeText()),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Color(0xFFE53935),
              padding: EdgeInsets.all(4),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () => Get.toNamed(AppRoutes.notifications),
              tooltip: isBangla ? 'বিজ্ঞপ্তি' : 'Notifications',
            )
                .animate(
              onPlay: (c) => count > 0 ? c.repeat() : null,
            )
                .shake(duration: 1500.ms, hz: 4),
          );
        }),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ─── Banner Slider ─────────────────────────────────────────────────────────────
class _BannerSlider extends StatelessWidget {
  final BannerController controller;
  const _BannerSlider({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.banners.isEmpty) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: ShimmerLoading.rounded(height: 168, borderRadius: 20),
        );
      }
      if (controller.banners.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          // ── Slide area ────────────────────────────────────────────────────
          Container(
            height: 168,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _QTheme.emerald.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Page slides
                  PageView.builder(
                    itemCount: controller.banners.length,
                    onPageChanged: (i) =>
                    controller.currentBannerIndex.value = i,
                    itemBuilder: (context, index) {
                      final banner = controller.banners[index];
                      return GestureDetector(
                        onTap: () => controller.openLink(banner.linkUrl),
                        child: CachedNetworkImage(
                          imageUrl: banner.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              ShimmerLoading.rectangular(height: 168),
                          errorWidget: (_, __, ___) => Container(
                            color: _QTheme.emerald.withValues(alpha: 0.08),
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),

                  // Bottom gold gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.35),
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
          ),

          // ── Dot indicator ─────────────────────────────────────────────────
          Obx(() {
            final current = controller.currentBannerIndex.value;
            final count = controller.banners.length;
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(count, (i) {
                  final isActive = i == current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive ? _QTheme.gold : _QTheme.emerald.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      );
    });
  }
}

// ─── Static Top Banner ─────────────────────────────────────────────────────────
class _StaticTopBannerArea extends StatelessWidget {
  final BannerController controller;
  const _StaticTopBannerArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.staticTopBanners.isEmpty) return const SizedBox.shrink();

      // Show the latest static banner with a more prominent size
      final banner = controller.staticTopBanners.first;
      return GestureDetector(
        onTap: () => controller.openLink(banner.linkUrl),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // Elegant gold border
            border: Border.all(color: _QTheme.gold.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _QTheme.emerald.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: AspectRatio(
              aspectRatio: 4.8, // Much more prominent and clear size
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => ShimmerLoading.rectangular(height: 75),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, curve: Curves.easeOut),
      );
    });
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