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
        // Trigger showcase on start
        controller.startShowcase(context);
        
        return Obx(() {
          final isDark = settings.isDark;
          final bool bn = settings.isBangla;

          return Scaffold(
            backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            drawer: const AppDrawer(),
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              centerTitle: true,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              title: Text(
                bn ? 'কুরআন অ্যাপ' : 'Quran App',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              actions: [
                Obx(() => badges.Badge(
                      position: badges.BadgePosition.topEnd(top: 8, end: 8),
                      showBadge: notificationsController.unreadCount.value > 0,
                      badgeContent: Text(
                        notificationsController.unreadCount.value.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: Colors.red,
                        padding: EdgeInsets.all(4),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                        onPressed: () => Get.toNamed(AppRoutes.notifications),
                      ).animate(
                        onPlay: (c) => notificationsController.unreadCount.value > 0 ? c.repeat() : null,
                      ).shake(duration: 1500.ms, hz: 4),
                    )),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                // 1. Thin Static Banner (Immediately below AppBar)
                _StaticTopBannerArea(controller: bannerController),
                
                // Dashboard Scrollable Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // 2. Photo Slider
                        _BannerSlider(controller: bannerController),
                        
                        // 3. Main Dashboard Content
                        const HomeDashboard(),
                      ],
                    ),
                  ),
                ),
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

class _BannerSlider extends StatelessWidget {
  final BannerController controller;
  const _BannerSlider({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.banners.isEmpty) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: ShimmerLoading.rounded(height: 160, borderRadius: 20),
        );
      }
      if (controller.banners.isEmpty) return const SizedBox.shrink();

      return Container(
        height: 160,
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: PageView.builder(
            itemCount: controller.banners.length,
            onPageChanged: (index) => controller.currentBannerIndex.value = index,
            itemBuilder: (context, index) {
              final banner = controller.banners[index];
              return GestureDetector(
                onTap: () => controller.openLink(banner.linkUrl),
                child: CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => ShimmerLoading.rectangular(height: 160),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class _StaticTopBannerArea extends StatelessWidget {
  final BannerController controller;
  const _StaticTopBannerArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.staticTopBanners.isEmpty) return const SizedBox.shrink();

      final banner = controller.staticTopBanners.first;
      return GestureDetector(
        onTap: () => controller.openLink(banner.linkUrl),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 970 / 40,
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (c, e, s) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
    });
  }
}
