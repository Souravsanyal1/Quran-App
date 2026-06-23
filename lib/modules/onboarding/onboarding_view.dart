import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final pageController = PageController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.nightGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: controller.skipOnboarding,
                    child: Obx(() => Text(
                          settings.isBangla ? 'এড়িয়ে যান' : 'Skip',
                          style: const TextStyle(color: AppColors.textGrey),
                        )),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.slides.length,
                  itemBuilder: (context, index) {
                    final slide = controller.slides[index];
                    return _OnboardingSlide(
                      slide: slide,
                      isBangla: settings.isBangla,
                    );
                  },
                ),
              ),

              // Indicators + Button
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Page indicator
                    Obx(() {
                      return AnimatedSmoothIndicator(
                        activeIndex: controller.currentPage.value,
                        count: controller.slides.length,
                        effect: const WormEffect(
                          dotColor: AppColors.borderDark,
                          activeDotColor: AppColors.primary,
                          dotHeight: 8,
                          dotWidth: 8,
                        ),
                      );
                    }),

                    const SizedBox(height: 32),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Obx(() {
                        final isLast = controller.currentPage.value ==
                            controller.slides.length - 1;
                        return ElevatedButton(
                          onPressed: () {
                            if (isLast) {
                              controller.completeOnboarding();
                            } else {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              controller.nextPage();
                            }
                          },
                          child: Text(
                            isLast
                                ? (settings.isBangla ? 'শুরু করুন' : 'Get Started')
                                : (settings.isBangla ? 'পরবর্তী' : 'Next'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
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
}

class _OnboardingSlide extends StatelessWidget {
  final Map<String, String> slide;
  final bool isBangla;

  const _OnboardingSlide({required this.slide, required this.isBangla});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                slide['icon'] ?? '',
                style: const TextStyle(fontSize: 56),
              ),
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 48),

          Text(
            isBangla ? (slide['titleBn'] ?? '') : (slide['title'] ?? ''),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textWhite,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3, end: 0),

          const SizedBox(height: 16),

          Text(
            isBangla ? (slide['descBn'] ?? '') : (slide['desc'] ?? ''),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textGrey,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}
