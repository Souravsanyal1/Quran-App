import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'package:quran_app/widgets/shimmer_loading.dart';
import '../../widgets/app_back_button.dart';
import 'tasbih_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _TasbihTheme {
  _TasbihTheme._();
  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color goldSoft = Color(0xFFFFF8E7);
  static const Color darkSurface = Color(0xFF141420);
  static const Color darkCard = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard = Color(0xFFFFFFFF);
}

class TasbihView extends GetView<TasbihController> {
  const TasbihView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    return Scaffold(
      backgroundColor:
          isDark ? _TasbihTheme.darkSurface : _TasbihTheme.lightSurface,
      appBar: AppBar(
        leading: const AppBackButton(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _TasbihTheme.emeraldDark,
                _TasbihTheme.emerald,
                _TasbihTheme.emeraldLight
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
                bottom: BorderSide(color: _TasbihTheme.gold, width: 1.5)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                  opacity: 0.05,
                  child: CustomPaint(painter: _StarPatternPainter())),
            ],
          ),
        ),
        title: Text(
          isBn ? 'ডিজিটাল তসবীহ' : 'Digital Tasbih',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  ShimmerLoading.rounded(height: 80, borderRadius: 20),
                  const SizedBox(height: 60),
                  Center(
                      child: ShimmerLoading.circular(height: 240, width: 240)),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(child: ShimmerLoading.rounded(height: 48)),
                      const SizedBox(width: 12),
                      Expanded(child: ShimmerLoading.rounded(height: 48)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // ─── Dhikr Card ────────────────────────────────────
                      _buildDhikrCard(context, settings, isDark),

                      const SizedBox(height: 24),

                      // ─── Circular Counter ──────────────────────────────
                      Expanded(
                          child:
                              _buildCircularCounter(context, settings, isDark)),

                      const SizedBox(height: 24),

                      // ─── Target Selector ───────────────────────────────
                      _buildTargetRow(isDark),

                      const SizedBox(height: 20),

                      // ─── Action Row ────────────────────────────────────
                      _buildActionRow(context, settings, isDark),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDhikrCard(
      BuildContext context, SettingsController settings, bool isDark) {
    return Obx(() {
      final dhikr = controller.currentDhikr;
      return GestureDetector(
        onTap: () => _showDhikrSelector(settings),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? _TasbihTheme.darkCard : _TasbihTheme.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _TasbihTheme.emerald.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _TasbihTheme.emerald
                    .withValues(alpha: isDark ? 0.08 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _TasbihTheme.emerald.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _TasbihTheme.gold.withValues(alpha: 0.5),
                      width: 1),
                ),
                child: const Icon(Icons.my_library_books_rounded,
                    color: _TasbihTheme.emerald, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dhikr.arabic,
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _TasbihTheme.emerald,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.isBangla
                          ? '${dhikr.transliterationBn} — ${dhikr.meaningBn}'
                          : '${dhikr.transliterationEn} — ${dhikr.meaningEn}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textGrey
                            : AppColors.textDark.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: _TasbihTheme.emerald),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCircularCounter(
      BuildContext context, SettingsController settings, bool isDark) {
    return Center(
      child: Obx(() {
        final count = controller.count.value;
        final target = controller.target.value;
        final progress =
            target == 9999 ? 0.0 : (count / target).clamp(0.0, 1.0);

        return GestureDetector(
          onTap: () => controller.increment(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            child: CustomPaint(
              painter: _ArcPainter(
                progress: progress,
                isDark: isDark,
                primaryColor: _TasbihTheme.gold,
              ),
              child: SizedBox(
                width: 240,
                height: 240,
                child: Center(
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          isDark ? const Color(0xFF232335) : Colors.white,
                          isDark
                              ? const Color(0xFF141420)
                              : const Color(0xFFF9F7F2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _TasbihTheme.emerald.withValues(alpha: 0.25),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.4 : 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          settings.isBangla ? 'স্পর্শ করুন' : 'TAP',
                          style: GoogleFonts.poppins(
                            color: _TasbihTheme.emerald,
                            fontSize: 12,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<int>(
                          key: ValueKey(count),
                          tween: IntTween(
                              begin: count - 1 < 0 ? 0 : count - 1, end: count),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, val, child) => Text(
                            val.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.textDark,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() {
                          final t = controller.target.value;
                          return Text(
                            '/ ${t == 9999 ? "∞" : t}',
                            style: GoogleFonts.poppins(
                              color: _TasbihTheme.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTargetRow(bool isDark) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _targetChip(33, '33', isDark),
            const SizedBox(width: 8),
            _targetChip(99, '99', isDark),
            const SizedBox(width: 8),
            _targetChip(100, '100', isDark),
            const SizedBox(width: 8),
            _targetChip(9999, '∞', isDark),
          ],
        ));
  }

  Widget _targetChip(int value, String label, bool isDark) {
    final isSelected = controller.target.value == value;
    return GestureDetector(
      onTap: () => controller.setTarget(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [_TasbihTheme.emerald, _TasbihTheme.emeraldLight],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? _TasbihTheme.darkCard : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected
                ? _TasbihTheme.gold
                : (isDark
                    ? _TasbihTheme.emerald.withValues(alpha: 0.2)
                    : Colors.grey.shade300),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _TasbihTheme.emerald.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : AppColors.textGrey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(
      BuildContext context, SettingsController settings, bool isDark) {
    return Row(
      children: [
        // Reset button
        Expanded(
          child: GestureDetector(
            onTap: () => _confirmReset(context, settings),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    settings.isBangla ? 'রিসেট' : 'Reset',
                    style: GoogleFonts.poppins(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Rounds counter
        Expanded(
          child: Obx(() => Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _TasbihTheme.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _TasbihTheme.emerald.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.loop_rounded,
                        color: _TasbihTheme.emerald, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${settings.isBangla ? "চক্র" : "Rounds"}: ${controller.totalSaves.value}',
                      style: GoogleFonts.poppins(
                        color: _TasbihTheme.emerald,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  void _showDhikrSelector(SettingsController settings) {
    final isDark = settings.isDark;
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? _TasbihTheme.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
              top: BorderSide(
                  color: _TasbihTheme.emerald.withValues(alpha: 0.2))),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              settings.isBangla ? 'জিকির বেছে নিন' : 'Choose Dhikr',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: Get.height * 0.55,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.dhikrList.length,
                separatorBuilder: (context, i) => Divider(
                  height: 1,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                itemBuilder: (context, index) {
                  final dhikr = controller.dhikrList[index];
                  return Obx(() {
                    final isSelected =
                        controller.selectedDhikrIndex.value == index;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      onTap: () {
                        controller.selectDhikr(index);
                        Get.back();
                      },
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? _TasbihTheme.emerald.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                        child: Text(
                          '${dhikr.defaultTarget}',
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? _TasbihTheme.emerald
                                : AppColors.textGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        dhikr.arabic,
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? _TasbihTheme.gold
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Text(
                        settings.isBangla
                            ? '${dhikr.transliterationBn} — ${dhikr.meaningBn}'
                            : '${dhikr.transliterationEn} — ${dhikr.meaningEn}',
                        style: GoogleFonts.poppins(fontSize: 11.5),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: _TasbihTheme.emerald)
                          : null,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmReset(BuildContext context, SettingsController settings) {
    Get.dialog(
      AlertDialog(
        backgroundColor:
            settings.isDark ? _TasbihTheme.darkCard : _TasbihTheme.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(settings.isBangla ? 'রিসেট নিশ্চিত করুন' : 'Confirm Reset',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          settings.isBangla
              ? 'গণনা ও চক্র শূন্য হয়ে যাবে। এগিয়ে যাবেন?'
              : 'Count and rounds will be reset. Proceed?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(settings.isBangla ? 'বাতিল' : 'Cancel',
                style: TextStyle(color: _TasbihTheme.emerald)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              controller.reset();
              Get.back();
            },
            child: Text(settings.isBangla ? 'রিসেট' : 'Reset'),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color primaryColor;

  _ArcPainter({
    required this.progress,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final trackPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFF1B5E35).withValues(alpha: 0.1)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * pi * progress;

      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + 2 * pi,
          colors: const [
            Color(0xFF1B5E35),
            Color(0xFFC9A84C),
            Color(0xFF1B5E35),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      final angle = -pi / 2 + sweepAngle;
      final dotX = center.dx + radius * cos(angle);
      final dotY = center.dy + radius * sin(angle);
      final dotPaint = Paint()
        ..color = primaryColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);
      canvas.drawCircle(
        Offset(dotX, dotY),
        5,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.isDark != isDark;
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
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
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
