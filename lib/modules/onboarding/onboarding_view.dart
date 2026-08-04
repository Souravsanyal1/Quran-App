import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'onboarding_controller.dart';

class _OnboardingTheme {
  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color darkBg = Color(0xFF141420);
  static const Color lightBg = Color(0xFFFAF8F5);
}

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isBn = settings.isBangla;
    final isDark = settings.isDark;

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
                  gradient: const LinearGradient(
                    colors: [
                      _OnboardingTheme.emerald,
                      _OnboardingTheme.emeraldLight
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: _OnboardingTheme.gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _OnboardingTheme.emerald.withValues(alpha: 0.3),
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
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 28.0,
                fontWeight: FontWeight.w800,
                color: _OnboardingTheme.emerald,
              ),
              bodyTextStyle: GoogleFonts.poppins(
                fontSize: 16.0,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
              pageColor:
                  isDark ? _OnboardingTheme.darkBg : _OnboardingTheme.lightBg,
              imagePadding: const EdgeInsets.only(top: 100),
            ),
          );
        }).toList(),
        onDone: () => controller.completeOnboarding(),
        onSkip: () => controller.skipOnboarding(),
        showSkipButton: true,
        skip: Text(
          isBn ? 'এড়িয়ে যান' : 'Skip',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: _OnboardingTheme.gold),
        ),
        next: const Icon(Icons.arrow_forward_rounded,
            color: _OnboardingTheme.emerald),
        done: Text(
          isBn ? 'শুরু করুন' : 'Get Started',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, color: _OnboardingTheme.emerald),
        ),
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: _OnboardingTheme.emerald,
          color: Colors.grey.withValues(alpha: 0.3),
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }
}
