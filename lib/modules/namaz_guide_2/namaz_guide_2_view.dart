import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import '../namaz_guide/namaz_guide_model.dart';

import 'namaz_guide_2_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _Theme {
  _Theme._();
  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color goldSoft = Color(0xFFFFF8E7);
  static const Color maleBlue = Color(0xFF1565C0);
  static const Color maleBlueDark = Color(0xFF0D47A1);
  static const Color maleBlueLight = Color(0xFF1E88E5);
  static const Color femalePink = Color(0xFF880E4F);
  static const Color femalePinkDark = Color(0xFF6A0035);
  static const Color femalePinkLight = Color(0xFFAD1457);
  static const Color darkSurface = Color(0xFF141420);
  static const Color darkCard = Color(0xFF1E1E2E);
  static const Color darkCardAlt = Color(0xFF252538);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard = Color(0xFFFFFFFF);
}

class NamazGuide2View extends GetView<NamazGuide2Controller> {
  const NamazGuide2View({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isBn = settings.isBangla;
    final isDark = settings.isDark;

    return Obx(() {
      final gender = controller.selectedGender.value;
      if (gender == null) {
        return _GenderSelectionScreen(
            isBn: isBn, isDark: isDark, controller: controller);
      }
      return _GuideScreen(
          isBn: isBn, isDark: isDark, controller: controller, gender: gender);
    });
  }
}

// ── Gender Selection Screen ──────────────────────────────────────────────────
class _GenderSelectionScreen extends StatelessWidget {
  final bool isBn;
  final bool isDark;
  final NamazGuide2Controller controller;

  const _GenderSelectionScreen(
      {required this.isBn, required this.isDark, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? _Theme.darkSurface : _Theme.lightSurface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: const AppBackButton(),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_Theme.emeraldDark, _Theme.emerald, _Theme.emeraldLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(color: _Theme.gold, width: 1.5),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPainter())),
            ],
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isBn ? 'নামাজ শিক্ষা' : 'Namaz Guide',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
            Container(
              height: 2, width: 32,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: _Theme.goldLight,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Subtitle
              Text(
                isBn
                    ? 'আপনার নামাজের ধরন বাছাই করুন'
                    : 'Select your prayer style',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.textDark.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                isBn
                    ? 'পুরুষ ও মহিলার নামাজে কিছু পার্থক্য রয়েছে'
                    : 'Men and women have some differences in prayer postures',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : AppColors.textDark.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 36),

              // Male Card
              _GenderCard(
                icon: Icons.man_rounded,
                labelBn: 'পুরুষ',
                labelEn: 'Male',
                descBn: 'পুরুষের নামাজের নিয়ম\nঅনুযায়ী গাইড',
                descEn: 'Prayer guide following\nmen\'s method',
                gradientColors: const [_Theme.maleBlueDark, _Theme.maleBlueLight],
                glowColor: _Theme.maleBlue,
                isDark: isDark,
                isBn: isBn,
                onTap: () => controller.selectGender(NamazGender.male),
                badge: '♂',
                delay: 150,
              ),
              const SizedBox(height: 16),

              // Female Card
              _GenderCard(
                icon: Icons.woman_rounded,
                labelBn: 'মহিলা',
                labelEn: 'Female',
                descBn: 'মহিলার নামাজের নিয়ম\nঅনুযায়ী গাইড',
                descEn: 'Prayer guide following\nwomen\'s method',
                gradientColors: const [_Theme.femalePinkDark, _Theme.femalePinkLight],
                glowColor: _Theme.femalePink,
                isDark: isDark,
                isBn: isBn,
                onTap: () => controller.selectGender(NamazGender.female),
                badge: '♀',
                delay: 250,
              ),

              const Spacer(),

              // Bottom note
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   decoration: BoxDecoration(
              //     color: _Theme.gold.withValues(alpha: isDark ? 0.08 : 0.06),
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(
              //       color: _Theme.gold.withValues(alpha: isDark ? 0.15 : 0.12),
              //     ),
              //   ),
                // child: Row(
                //   children: [
                //     Icon(Icons.info_outline_rounded,
                //         size: 16, color: _Theme.gold.withValues(alpha: 0.7)),
                //     const SizedBox(width: 8),
                //     // Expanded(
                //     //   child: Text(
                //     //     isBn
                //     //         ? 'এই গাইডটি হানাফি মাযহাব অনুসারে তৈরি'
                //     //         : 'This guide is based on the Hanafi school of thought',
                //     //     style: GoogleFonts.poppins(
                //     //       fontSize: 11.5,
                //     //       color: isDark
                //     //           ? Colors.white.withValues(alpha: 0.5)
                //     //           : AppColors.textDark.withValues(alpha: 0.5),
                //     //       height: 1.4,
                //     //     ),
                //     //   ),
                //     // ),
                //   ],
                // ),
              // // ).animate(delay: 350.ms).fadeIn(),
              // ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String labelBn;
  final String labelEn;
  final String descBn;
  final String descEn;
  final List<Color> gradientColors;
  final Color glowColor;
  final bool isDark;
  final bool isBn;
  final VoidCallback onTap;
  final String badge;
  final int delay;

  const _GenderCard({
    required this.icon,
    required this.labelBn,
    required this.labelEn,
    required this.descBn,
    required this.descEn,
    required this.gradientColors,
    required this.glowColor,
    required this.isDark,
    required this.isBn,
    required this.onTap,
    required this.badge,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isBn ? labelBn : labelEn,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBn ? descBn : descEn,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay.ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.05, curve: Curves.easeOutCubic);
  }
}

// ── Guide Screen ─────────────────────────────────────────────────────────────
class _GuideScreen extends StatelessWidget {
  final bool isBn;
  final bool isDark;
  final NamazGuide2Controller controller;
  final NamazGender gender;

  const _GuideScreen({
    required this.isBn,
    required this.isDark,
    required this.controller,
    required this.gender,
  });

  bool get isMale => gender == NamazGender.male;

  Color get accentColor => isMale ? _Theme.maleBlue : _Theme.femalePink;
  Color get accentLight => isMale ? _Theme.maleBlueLight : _Theme.femalePinkLight;
  Color get accentDark => isMale ? _Theme.maleBlueDark : _Theme.femalePinkDark;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Scaffold(
      backgroundColor: isDark ? _Theme.darkSurface : _Theme.lightSurface,
      appBar: _buildAppBar(),
      body: Obx(() {
        return Column(
          children: [
            _ProgressBar(
              controller: controller,
              isBn: isBn,
              isDark: isDark,
              accentColor: accentColor,
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.steps.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.steps.length) {
                    return _CompletionPage(
                      isBn: isBn,
                      isDark: isDark,
                      isMale: isMale,
                      onRestart: controller.restart,
                      onBack: controller.backToGenderSelection,
                    );
                  }
                  final step = controller.steps[index];
                  return _StepPage(
                    step: step,
                    isBn: isBn,
                    isDark: isDark,
                    isMale: isMale,
                    accentColor: accentColor,
                    settings: settings,
                  );
                },
              ),
            ),
            _BottomNav(
              controller: controller,
              isBn: isBn,
              isDark: isDark,
              accentColor: accentColor,
            ),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        ),
        onPressed: controller.backToGenderSelection,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentDark, accentColor, accentLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: const Border(bottom: BorderSide(color: _Theme.gold, width: 1.5)),
        ),
        child: Stack(fit: StackFit.expand, children: [
          Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPainter())),
        ]),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMale ? Icons.man_rounded : Icons.woman_rounded,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isBn
                    ? (isMale ? 'পুরুষের নামাজ' : 'মহিলার নামাজ')
                    : (isMale ? 'Men\'s Prayer' : 'Women\'s Prayer'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          Container(
            height: 2, width: 32,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: _Theme.goldLight,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded, color: _Theme.goldLight, size: 18),
            ),
            tooltip: isBn ? 'পুনরায় শুরু' : 'Restart',
            onPressed: controller.restart,
          ),
        ),
      ],
    );
  }
}

// ── Progress Bar ──────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final NamazGuide2Controller controller;
  final bool isBn;
  final bool isDark;
  final Color accentColor;

  const _ProgressBar({
    required this.controller,
    required this.isBn,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: isDark ? _Theme.darkCard : _Theme.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.12 : 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final current = controller.currentIndex.value;
        final total = controller.steps.length;
        final progress = controller.progress;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${current + 1}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isBn
                          ? 'ধাপ ${current + 1} / $total'
                          : 'Step ${current + 1} of $total',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: List.generate(total, (i) {
                    final isCompleted = i <= current;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < total - 1 ? 3 : 0),
                        decoration: BoxDecoration(
                          gradient: isCompleted
                              ? LinearGradient(colors: [accentColor, accentColor.withValues(alpha: 0.7)])
                              : null,
                          color: isCompleted
                              ? null
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : accentColor.withValues(alpha: 0.08)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      }),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05);
  }
}

// ── Step Page ─────────────────────────────────────────────────────────────────
class _StepPage extends StatelessWidget {
  final NamazStep step;
  final bool isBn;
  final bool isDark;
  final bool isMale;
  final Color accentColor;
  final SettingsController settings;

  const _StepPage({
    required this.step,
    required this.isBn,
    required this.isDark,
    required this.isMale,
    required this.accentColor,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Illustration
          _IllustrationCard(
              step: step,
              isDark: isDark,
              accentColor: accentColor,
              isMale: isMale),
          const SizedBox(height: 20),
          // Title
          _StepTitle(step: step, isBn: isBn, isDark: isDark, accentColor: accentColor),
          const SizedBox(height: 14),
          // Rakah completed badge
          if (step.stepNumber == 8) ...[
            _RakahCompletedBadge(isBn: isBn, isDark: isDark),
            const SizedBox(height: 14),
          ],
          // Instruction
          _InstructionCard(step: step, isBn: isBn, isDark: isDark, accentColor: accentColor),
          // Arabic
          if (step.arabic != null) ...[
            const SizedBox(height: 16),
            _ArabicSection(step: step, isBn: isBn, isDark: isDark, settings: settings),
          ],
        ],
      ),
    );
  }
}

// ── Rakah Completed Badge ──────────────────────────────────────────────────
class _RakahCompletedBadge extends StatelessWidget {
  final bool isBn;
  final bool isDark;
  const _RakahCompletedBadge({required this.isBn, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFFC9A84C).withValues(alpha: 0.15), const Color(0xFF1E1E2E)]
              : [const Color(0xFFFFF8E7), const Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC9A84C).withValues(alpha: isDark ? 0.3 : 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC9A84C).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            color: Color(0xFFC9A84C),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isBn ? '১ রাকাত সম্পন্ন হলো' : '1 Rakah Completed',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFC9A84C),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

// ── Illustration Card ─────────────────────────────────────────────────────────
class _IllustrationCard extends StatelessWidget {
  final NamazStep step;
  final bool isDark;
  final Color accentColor;
  final bool isMale;

  const _IllustrationCard({
    required this.step,
    required this.isDark,
    required this.accentColor,
    required this.isMale,
  });

  int? _getImageNumber(int stepNumber) {
    if (stepNumber == 1) return 0; // 0.png (niyat chele)
    if (stepNumber == 2) return 1; // 1.png (takbir)
    if (stepNumber == 3) return 2; // 2.png (qiyam)
    if (stepNumber >= 4 && stepNumber <= 10) return stepNumber;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final int stepNum = step.stepNumber;
    final int? imgNum = isMale ? _getImageNumber(stepNum) : null;
    final bool hasImage = isMale ? (imgNum != null) : (stepNum >= 1 && stepNum <= 10);
    final String imagePath = isMale
        ? 'assets/images/$imgNum.png'
        : 'assets/images/namaj woman/$stepNum.png';

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [accentColor.withValues(alpha: 0.08), _Theme.darkCardAlt]
              : [accentColor.withValues(alpha: 0.05), _Theme.goldSoft.withValues(alpha: 0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.15 : 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: hasImage
          ? Stack(
              children: [
                Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _FallbackIllustration(step: step, color: accentColor),
                  frameBuilder: (ctx, child, frame, wasSynced) {
                    if (wasSynced || frame != null) return child;
                    return Container(
                      height: 260,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: accentColor,
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isDark ? _Theme.darkCardAlt : Colors.white).withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          (isDark ? _Theme.darkCardAlt : Colors.white).withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _FallbackIllustration(step: step, color: accentColor),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutCubic);
  }
}

class _FallbackIllustration extends StatelessWidget {
  final NamazStep step;
  final Color color;
  const _FallbackIllustration({required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Icon(
        Icons.accessibility_new_rounded,
        color: color.withValues(alpha: 0.1),
        size: 120,
      ),
    );
  }
}

// ── Step Title ────────────────────────────────────────────────────────────────
class _StepTitle extends StatelessWidget {
  final NamazStep step;
  final bool isBn;
  final bool isDark;
  final Color accentColor;

  const _StepTitle(
      {required this.step,
      required this.isBn,
      required this.isDark,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_Theme.gold, _Theme.goldLight],
            ),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: _Theme.gold.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${step.stepNumber}',
              style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            isBn ? step.titleBn : step.titleEn,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textDark,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.03);
  }
}

// ── Instruction Card ──────────────────────────────────────────────────────────
class _InstructionCard extends StatelessWidget {
  final NamazStep step;
  final bool isBn;
  final bool isDark;
  final Color accentColor;

  const _InstructionCard(
      {required this.step,
      required this.isBn,
      required this.isDark,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _Theme.darkCard : _Theme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : accentColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 80,
            margin: const EdgeInsets.only(top: 16, left: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 14,
                          color: accentColor.withValues(alpha: 0.6)),
                      const SizedBox(width: 6),
                      Text(
                        isBn ? 'নির্দেশনা' : 'Instructions',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: accentColor.withValues(alpha: 0.6),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn ? step.instructionBn : step.instructionEn,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      height: 1.7,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textDark.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.03);
  }
}

// ── Arabic Section ────────────────────────────────────────────────────────────
class _ArabicSection extends StatelessWidget {
  final NamazStep step;
  final bool isBn;
  final bool isDark;
  final SettingsController settings;

  const _ArabicSection(
      {required this.step,
      required this.isBn,
      required this.isDark,
      required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? _Theme.darkCard : _Theme.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _Theme.gold.withValues(alpha: isDark ? 0.15 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: _Theme.gold.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [_Theme.gold.withValues(alpha: 0.08), Colors.transparent]
                    : [_Theme.goldSoft, _Theme.lightCard],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_Theme.gold, _Theme.goldLight]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_stories_rounded,
                      color: Colors.white, size: 14),
                ),
                const SizedBox(width: 10),
                Text(
                  isBn ? 'আরবি পাঠ' : 'Arabic Recitation',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? _Theme.goldLight : _Theme.emerald,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Arabic text
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? _Theme.gold.withValues(alpha: 0.04)
                    : _Theme.goldSoft.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _Theme.gold.withValues(alpha: isDark ? 0.08 : 0.12),
                ),
              ),
              child: Obx(() => Text(
                    step.arabic!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: settings.arabicFontSize.value,
                      color: isDark ? _Theme.goldLight : _Theme.gold,
                      height: 1.8,
                      fontWeight: FontWeight.w700,
                    ),
                  )),
            ),
          ),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _Divider(isDark: isDark),
          ),
          // Transliteration
          if (step.translit != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.record_voice_over_rounded,
                      size: 14,
                      color: _Theme.emeraldLight.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'উচ্চারণ: ${step.translitBn ?? step.translit}'
                          : 'Transliteration: ${step.translit}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          // Meaning
          if (step.meaningBn != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.translate_rounded,
                      size: 14,
                      color: _Theme.emeraldLight.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'অর্থ: ${step.meaningBn}'
                          : 'Meaning: ${step.meaningEn}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.75)
                            : AppColors.textDark.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.04);
  }
}

// ── Completion Page ───────────────────────────────────────────────────────────
class _CompletionPage extends StatelessWidget {
  final bool isBn;
  final bool isDark;
  final bool isMale;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const _CompletionPage({
    required this.isBn,
    required this.isDark,
    required this.isMale,
    required this.onRestart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isMale ? _Theme.maleBlue : _Theme.femalePink;
    final accentLight = isMale ? _Theme.maleBlueLight : _Theme.femalePinkLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Celebration card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [accent.withValues(alpha: 0.12), _Theme.darkCardAlt]
                    : [accent.withValues(alpha: 0.06), _Theme.goldSoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: _Theme.gold.withValues(alpha: isDark ? 0.2 : 0.25),
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent, accentLight]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    isMale ? Icons.man_rounded : Icons.woman_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      5,
                      (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(Icons.star_rounded,
                                color: _Theme.gold, size: 20),
                          )),
                ),
                const SizedBox(height: 18),
                Text(
                  isBn ? 'মাশাআল্লাহ! 🎉' : 'MashaAllah! 🎉',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : accent,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isBn
                      ? 'আপনি ${isMale ? "পুরুষের" : "মহিলার"} নামাজ শিক্ষার সব ধাপ সম্পন্ন করেছেন!'
                      : 'You have completed all steps of the ${isMale ? "Men's" : "Women's"} Namaz Guide!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.65)
                        : accent.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).scale(
              begin: const Offset(0.92, 0.92), curve: Curves.easeOutCubic),

          const SizedBox(height: 20),

          // Dua card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? _Theme.darkCard : _Theme.lightCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: _Theme.gold.withValues(alpha: isDark ? 0.15 : 0.2)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    color: isDark ? _Theme.goldLight : _Theme.gold,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isBn
                      ? 'হে আমার প্রতিপালক! আমাকে নামাজ কায়েমকারী বানিয়ে দিন।\n(সূরা ইব্রাহিম: ৪০)'
                      : 'O my Lord! Make me one who establishes prayer.\n(Surah Ibrahim: 40)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.textDark.withValues(alpha: 0.7),
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.04),

          const SizedBox(height: 16),

          // Restart button
          GestureDetector(
            onTap: onRestart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accent, accentLight]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.replay_rounded, color: Colors.white70, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    isBn ? 'আবার শুরু করুন' : 'Restart Guide',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.05),

          const SizedBox(height: 12),

          // Back to gender selection
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? accent.withValues(alpha: 0.08)
                    : accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: accent.withValues(alpha: isDark ? 0.2 : 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swap_horiz_rounded, color: accent, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    isBn ? 'অন্য ধরন বাছাই করুন' : 'Switch Gender Guide',
                    style: GoogleFonts.poppins(
                      color: accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final NamazGuide2Controller controller;
  final bool isBn;
  final bool isDark;
  final Color accentColor;

  const _BottomNav({
    required this.controller,
    required this.isBn,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? _Theme.darkCard : _Theme.lightCard,
        border: Border(
          top: BorderSide(
            color: accentColor.withValues(alpha: isDark ? 0.1 : 0.08),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() => Row(
              children: [
                if (!controller.isFirstStep) ...[
                  Expanded(
                    child: _NavBtn(
                      label: isBn ? 'আগের ধাপ' : 'Previous',
                      icon: Icons.arrow_back_rounded,
                      onTap: controller.previousStep,
                      isPrimary: false,
                      isDark: isDark,
                      accentColor: accentColor,
                    ),
                  ),
                  if (!controller.isLastStep) const SizedBox(width: 12),
                ],
                if (!controller.isLastStep)
                  Expanded(
                    child: _NavBtn(
                      label: isBn ? 'পরের ধাপ' : 'Next Step',
                      icon: Icons.arrow_forward_rounded,
                      onTap: controller.nextStep,
                      isPrimary: true,
                      isDark: isDark,
                      accentColor: accentColor,
                    ),
                  ),
              ],
            )),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDark;
  final Color accentColor;

  const _NavBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.75)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3)),
              const SizedBox(width: 8),
              Icon(icon, color: Colors.white70, size: 18),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? accentColor.withValues(alpha: 0.08)
              : accentColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.25 : 0.2),
              width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accentColor, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    color: accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }
}

// ── Ornamental Divider ────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = _Theme.gold.withValues(alpha: isDark ? 0.2 : 0.3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.transparent, color]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.star_rounded,
                size: 8,
                color: _Theme.gold.withValues(alpha: isDark ? 0.3 : 0.4)),
          ),
          Expanded(
            child: Container(
              height: 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, Colors.transparent]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Star Painter ──────────────────────────────────────────────────────────────
class _StarPainter extends CustomPainter {
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
  bool shouldRepaint(_StarPainter old) => false;
}
