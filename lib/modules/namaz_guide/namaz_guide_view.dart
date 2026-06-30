import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'package:quran_app/widgets/shimmer_loading.dart';
import 'namaz_guide_controller.dart';
import 'widgets/posture_illustration.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _NamazTheme {
  _NamazTheme._();

  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color goldSoft = Color(0xFFFFF8E7);

  // Dark mode
  static const Color darkSurface = Color(0xFF141420);
  static const Color darkCard = Color(0xFF1E1E2E);
  static const Color darkCardAlt = Color(0xFF252538);

  // Light mode
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard = Color(0xFFFFFFFF);
}

class NamazGuideView extends GetView<NamazGuideController> {
  const NamazGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isBn = settings.isBangla;
    final isDark = settings.isDark;

    return Scaffold(
      backgroundColor: isDark ? _NamazTheme.darkSurface : _NamazTheme.lightSurface,
      appBar: _buildAppBar(isBn, isDark),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmer();
        }
        return Column(
          children: [
            // ── Progress Section ──────────────────────────────────────
            _ProgressSection(controller: controller, isBn: isBn, isDark: isDark),

            // ── Swipeable Step Pages ──────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.steps.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.steps.length) {
                    return _CompletionPage(isBn: isBn, isDark: isDark, onRestart: controller.restart);
                  }
                  final step = controller.steps[index];
                  return _StepPage(
                    step: step,
                    isBn: isBn,
                    isDark: isDark,
                    settings: settings,
                  );
                },
              ),
            ),

            // ── Bottom Navigation ─────────────────────────────────────
            _BottomNavigation(controller: controller, isBn: isBn, isDark: isDark),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isBn, bool isDark) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading: const AppBackButton(),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_NamazTheme.emeraldDark, _NamazTheme.emerald, _NamazTheme.emeraldLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: const Border(
            bottom: BorderSide(color: _NamazTheme.gold, width: 1.5),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _StarPatternPainter()),
            ),
          ],
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isBn ? 'নামাজ শিক্ষা' : 'Namaz Guide',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            height: 2,
            width: 32,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: _NamazTheme.goldLight,
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
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded, color: _NamazTheme.goldLight, size: 18),
            ),
            tooltip: isBn ? 'পুনরায় শুরু করুন' : 'Restart',
            onPressed: controller.restart,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ShimmerLoading.rounded(height: 40),
          const SizedBox(height: 20),
          ShimmerLoading.rounded(height: 200, borderRadius: 20),
          const SizedBox(height: 20),
          ShimmerLoading.rounded(height: 30, width: 200),
          const SizedBox(height: 20),
          ShimmerLoading.rounded(height: 100, borderRadius: 14),
        ],
      ),
    );
  }
}

// ── Progress Section ─────────────────────────────────────────────────────────
class _ProgressSection extends StatelessWidget {
  final NamazGuideController controller;
  final bool isBn;
  final bool isDark;

  const _ProgressSection({
    required this.controller,
    required this.isBn,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: isDark ? _NamazTheme.darkCard : _NamazTheme.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? _NamazTheme.gold.withValues(alpha: 0.1)
              : _NamazTheme.emerald.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : _NamazTheme.emerald).withValues(alpha: 0.06),
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
            // Step counter & percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_NamazTheme.emerald, _NamazTheme.emeraldLight],
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
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _NamazTheme.emerald.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _NamazTheme.emeraldLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segmented progress bar
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
                              ? const LinearGradient(
                                  colors: [_NamazTheme.emerald, _NamazTheme.emeraldLight],
                                )
                              : null,
                          color: isCompleted
                              ? null
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : _NamazTheme.emerald.withValues(alpha: 0.08)),
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

// ── Step Page ────────────────────────────────────────────────────────────────
class _StepPage extends StatelessWidget {
  final dynamic step;
  final bool isBn;
  final bool isDark;
  final SettingsController settings;

  const _StepPage({
    required this.step,
    required this.isBn,
    required this.isDark,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Illustration Card ─────────────────────────────────────
          _IllustrationCard(step: step, isDark: isDark),
          const SizedBox(height: 20),

          // ── Step Title ────────────────────────────────────────────
          _StepTitle(step: step, isBn: isBn, isDark: isDark),
          const SizedBox(height: 14),

          // ── Rakah Completion Badge ────────────────────────────────
          if (step.stepNumber == 9) ...[
            _RakahCompletedBadge(isBn: isBn, isDark: isDark),
            const SizedBox(height: 14),
          ],

          // ── Instruction Card ──────────────────────────────────────
          _InstructionCard(step: step, isBn: isBn, isDark: isDark),

          // ── Arabic Section ────────────────────────────────────────
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

// ── Completion Page ──────────────────────────────────────────────────────────
class _CompletionPage extends StatelessWidget {
  final bool isBn;
  final bool isDark;
  final VoidCallback onRestart;

  const _CompletionPage({
    required this.isBn,
    required this.isDark,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Celebration Icon ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [_NamazTheme.emerald.withValues(alpha: 0.12), _NamazTheme.darkCardAlt]
                    : [_NamazTheme.emerald.withValues(alpha: 0.06), _NamazTheme.goldSoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _NamazTheme.gold.withValues(alpha: isDark ? 0.2 : 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _NamazTheme.emerald.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Checkmark badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_NamazTheme.emerald, _NamazTheme.emeraldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _NamazTheme.emerald.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 42),
                ),
                const SizedBox(height: 20),
                // Gold star row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(Icons.star_rounded, color: _NamazTheme.gold, size: 20),
                  )),
                ),
                const SizedBox(height: 18),
                Text(
                  isBn ? 'মাশাআল্লাহ! 🎉' : 'MashaAllah! 🎉',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : _NamazTheme.emeraldDark,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isBn
                      ? 'আপনি নামাজ শিক্ষার সব ধাপ সম্পন্ন করেছেন!'
                      : 'You have completed all steps of the Namaz Guide!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.65)
                        : _NamazTheme.emerald.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOutCubic),

          const SizedBox(height: 24),

          // ── Dua Card ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? _NamazTheme.darkCard : _NamazTheme.lightCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _NamazTheme.gold.withValues(alpha: isDark ? 0.15 : 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
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
                    color: isDark ? _NamazTheme.goldLight : _NamazTheme.gold,
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

          const SizedBox(height: 24),

          // ── Restart Button ───────────────────────────────────────────
          GestureDetector(
            onTap: onRestart,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_NamazTheme.emerald, _NamazTheme.emeraldLight],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _NamazTheme.emerald.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.replay_rounded, color: _NamazTheme.goldLight, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    isBn ? 'আবার শুরু করুন' : 'Restart Guide',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.06),
        ],
      ),
    );
  }
}

// ── Illustration Card ────────────────────────────────────────────────────────
class _IllustrationCard extends StatelessWidget {
  final dynamic step;
  final bool isDark;

  const _IllustrationCard({required this.step, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final int stepNum = step.stepNumber as int;
    // Step 1 (Niyat) has no image. Steps 2–11 map to 1.png–10.png.
    final bool hasImage = stepNum >= 2 && stepNum <= 11;
    final String imagePath = 'assets/images/${stepNum - 1}.png';

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [_NamazTheme.emerald.withValues(alpha: 0.08), _NamazTheme.darkCardAlt]
              : [_NamazTheme.emerald.withValues(alpha: 0.04), _NamazTheme.goldSoft.withValues(alpha: 0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? _NamazTheme.emerald.withValues(alpha: 0.15)
              : _NamazTheme.emerald.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _NamazTheme.emerald.withValues(alpha: isDark ? 0.05 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: hasImage
          ? Stack(
              children: [
                // Step image — full width, fixed height
                Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _FallbackIllustration(step: step),
                  frameBuilder: (ctx, child, frame, wasSynced) {
                    if (wasSynced || frame != null) return child;
                    return Container(
                      height: 260,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: _NamazTheme.emerald,
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
                // Subtle top gradient overlay so image blends with card
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isDark ? _NamazTheme.darkCardAlt : Colors.white).withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Subtle bottom gradient overlay
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          (isDark ? _NamazTheme.darkCardAlt : Colors.white).withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _FallbackIllustration(step: step),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutCubic);
  }
}

// Fallback when no image is available
class _FallbackIllustration extends StatelessWidget {
  final dynamic step;
  const _FallbackIllustration({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -10, right: -10,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _NamazTheme.emerald.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -8, left: -8,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _NamazTheme.gold.withValues(alpha: 0.05),
              ),
            ),
          ),
          PostureIllustration(
            posture: step.posture,
            color: _NamazTheme.emerald,
            size: 150,
          ),
        ],
      ),
    );
  }
}

// ── Step Title ───────────────────────────────────────────────────────────────
class _StepTitle extends StatelessWidget {
  final dynamic step;
  final bool isBn;
  final bool isDark;

  const _StepTitle({required this.step, required this.isBn, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Step number badge
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_NamazTheme.gold, _NamazTheme.goldLight],
            ),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: _NamazTheme.gold.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${step.stepNumber}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            isBn ? step.titleBn : step.titleEn,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
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

// ── Instruction Card ─────────────────────────────────────────────────────────
class _InstructionCard extends StatelessWidget {
  final dynamic step;
  final bool isBn;
  final bool isDark;

  const _InstructionCard({required this.step, required this.isBn, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _NamazTheme.darkCard : _NamazTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : _NamazTheme.emerald.withValues(alpha: 0.08),
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
          // Emerald accent bar
          Container(
            width: 4,
            height: 80,
            margin: const EdgeInsets.only(top: 16, left: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_NamazTheme.emerald, _NamazTheme.emeraldLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Instruction text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: _NamazTheme.emeraldLight.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBn ? 'নির্দেশনা' : 'Instructions',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _NamazTheme.emeraldLight.withValues(alpha: 0.6),
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
                      color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textDark.withValues(alpha: 0.85),
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

// ── Arabic Section ───────────────────────────────────────────────────────────
class _ArabicSection extends StatelessWidget {
  final dynamic step;
  final bool isBn;
  final bool isDark;
  final SettingsController settings;

  const _ArabicSection({
    required this.step,
    required this.isBn,
    required this.isDark,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? _NamazTheme.darkCard : _NamazTheme.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _NamazTheme.gold.withValues(alpha: isDark ? 0.15 : 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _NamazTheme.gold.withValues(alpha: 0.05),
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
                    ? [_NamazTheme.gold.withValues(alpha: 0.08), Colors.transparent]
                    : [_NamazTheme.goldSoft, _NamazTheme.lightCard],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_NamazTheme.gold, _NamazTheme.goldLight],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 10),
                Text(
                  isBn ? 'আরবি পাঠ' : 'Arabic Recitation',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? _NamazTheme.goldLight : _NamazTheme.emerald,
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
                    ? _NamazTheme.gold.withValues(alpha: 0.04)
                    : _NamazTheme.goldSoft.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _NamazTheme.gold.withValues(alpha: isDark ? 0.08 : 0.12),
                ),
              ),
              child: Obx(() => Text(
                    step.arabic!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: settings.arabicFontSize.value,
                      color: isDark ? _NamazTheme.goldLight : _NamazTheme.gold,
                      height: 1.8,
                      fontWeight: FontWeight.w700,
                    ),
                  )),
            ),
          ),

          // Ornamental divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _OrnamentalDivider(isDark: isDark),
          ),

          // Transliteration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.record_voice_over_rounded,
                  size: 14,
                  color: _NamazTheme.emeraldLight.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn
                        ? 'উচ্চারণ: ${step.translitBn ?? step.translit}'
                        : 'Transliteration: ${step.translit}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Meaning
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: 14,
                  color: _NamazTheme.emeraldLight.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn ? 'অর্থ: ${step.meaningBn}' : 'Meaning: ${step.meaningEn}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? Colors.white.withValues(alpha: 0.75) : AppColors.textDark.withValues(alpha: 0.8),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
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

// ── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNavigation extends StatelessWidget {
  final NamazGuideController controller;
  final bool isBn;
  final bool isDark;

  const _BottomNavigation({
    required this.controller,
    required this.isBn,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? _NamazTheme.darkCard : _NamazTheme.lightCard,
        border: Border(
          top: BorderSide(
            color: isDark
                ? _NamazTheme.gold.withValues(alpha: 0.08)
                : _NamazTheme.emerald.withValues(alpha: 0.06),
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
                // Previous button
                if (!controller.isFirstStep) ...[
                  Expanded(
                    child: _NavButton(
                      label: isBn ? 'আগের ধাপ' : 'Previous',
                      icon: Icons.arrow_back_rounded,
                      onTap: controller.previousStep,
                      isPrimary: false,
                      isDark: isDark,
                    ),
                  ),
                  if (!controller.isLastStep) const SizedBox(width: 12),
                ],
                // Next button – hidden on completion page
                if (!controller.isLastStep)
                  Expanded(
                    child: _NavButton(
                      label: isBn ? 'পরের ধাপ' : 'Next Step',
                      icon: Icons.arrow_forward_rounded,
                      onTap: controller.nextStep,
                      isPrimary: true,
                      isDark: isDark,
                    ),
                  ),
              ],
            )),
      ),
    );
  }
}

// ── Nav Button ───────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDark;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_NamazTheme.emerald, _NamazTheme.emeraldLight],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _NamazTheme.emerald.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: _NamazTheme.goldLight, size: 18),
            ],
          ),
        ),
      );
    }

    // Secondary (outline) button
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? _NamazTheme.emerald.withValues(alpha: 0.08)
              : _NamazTheme.emerald.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _NamazTheme.emerald.withValues(alpha: isDark ? 0.25 : 0.2),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _NamazTheme.emeraldLight, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: _NamazTheme.emeraldLight,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ornamental Divider ───────────────────────────────────────────────────────
class _OrnamentalDivider extends StatelessWidget {
  final bool isDark;
  const _OrnamentalDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = _NamazTheme.gold.withValues(alpha: isDark ? 0.2 : 0.3);
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
            child: Icon(
              Icons.star_rounded,
              size: 8,
              color: _NamazTheme.gold.withValues(alpha: isDark ? 0.3 : 0.4),
            ),
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

// ── Star Pattern Painter ─────────────────────────────────────────────────────
class _StarPatternPainter extends CustomPainter {
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
  bool shouldRepaint(_StarPatternPainter old) => false;
}
