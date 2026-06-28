import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isBn = settings.isBangla;

    return Scaffold(
      body: IntroductionScreen(
        pages: controller.slides.map((slide) {
          return PageViewModel(
            title: isBn ? slide['titleBn'] : slide['title'],
            body: isBn ? slide['descBn'] : slide['desc'],
            image: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    slide['icon'] ?? '',
                    style: const TextStyle(fontSize: 70),
                  ),
                ),
              ),
            ),
            decoration: PageDecoration(
              titleTextStyle: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
              bodyTextStyle: TextStyle(
                fontSize: 16.0,
                color: settings.isDark ? Colors.white70 : Colors.black87,
              ),
              pageColor: settings.isDark ? AppColors.bgDark : Colors.white,
              imagePadding: const EdgeInsets.only(top: 100),
            ),
          );
        }).toList(),
        onDone: () => controller.completeOnboarding(),
        onSkip: () => controller.skipOnboarding(),
        showSkipButton: true,
        skip: Text(isBn ? 'এড়িয়ে যান' : 'Skip', 
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
        next: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
        done: Text(isBn ? 'শুরু করুন' : 'Get Started', 
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: AppColors.primary,
          color: Colors.grey.withOpacity(0.3),
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }
}
