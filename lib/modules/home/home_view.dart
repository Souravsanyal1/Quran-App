import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'home_controller.dart';
import 'banner_controller.dart';
import 'widgets/app_drawer.dart';
import 'widgets/home_dashboard.dart';
import 'widgets/floating_support_button.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final bannerController = Get.put(BannerController());

    return Obx(() {
      final isDark = settings.isDark;
      final bool bn = settings.isBangla;

      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        drawer: const AppDrawer(),
        body: Column(
          children: [
            // 1. App Bar at the top (with SafeArea)
            SafeArea(
              bottom: false,
              child: _buildCustomAppBar(context, settings, isDark, bn),
            ),
            
            // 2. Static Banner (Zero gap with AppBar)
            _StaticTopBannerArea(controller: bannerController),
            
            // Dashboard Scrollable Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 3. Photo Slider
                    _BannerSlider(controller: bannerController),
                    
                    // 4. Main Dashboard Content
                    const HomeDashboard(),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: const FloatingSupportButton(),
      );
    });
  }

  Widget _buildCustomAppBar(BuildContext context, SettingsController settings, bool isDark, bool bn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              bn ? 'কুরআন অ্যাপ' : 'Quran App',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: Colors.white, size: 20),
            onPressed: settings.toggleTheme,
          ),
        ],
      ),
    );
  }
}

class _BannerSlider extends StatelessWidget {
  final BannerController controller;
  const _BannerSlider({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.banners.isEmpty) return const SizedBox.shrink();
      if (controller.banners.isEmpty) return const SizedBox.shrink();

      return Container(
        height: 160,
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
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
                child: Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
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
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 970 / 40,
              child: Image.network(
                banner.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
    });
  }
}
