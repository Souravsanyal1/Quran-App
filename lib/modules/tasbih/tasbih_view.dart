import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'package:quran_app/widgets/shimmer_loading.dart';
import 'tasbih_controller.dart';

class TasbihView extends GetView<TasbihController> {
  const TasbihView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isBn ? 'ডিজিটাল তসবীহ' : 'Digital Tasbih',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          const SizedBox(width: 48), // Balancing the leading back button
        ],
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
                  Center(child: ShimmerLoading.circular(height: 240, width: 240)),
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
                      const SizedBox(height: 12),

                      // ─── Dhikr Card ────────────────────────────────────
                      _buildDhikrCard(context, settings, isDark),

                      const SizedBox(height: 24),

                      // ─── Circular Counter ──────────────────────────────
                      Expanded(child: _buildCircularCounter(context, settings, isDark)),

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

  // ────────────────────────────────────────────────────────────────
  // Dhikr Info Card
  // ────────────────────────────────────────────────────────────────
  Widget _buildDhikrCard(BuildContext context, SettingsController settings, bool isDark) {
    return Obx(() {
      final dhikr = controller.currentDhikr;
      return GestureDetector(
        onTap: () => _showDhikrSelector(settings),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.06),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.my_library_books_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dhikr.arabic,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.isBangla
                          ? '${dhikr.transliterationBn} — ${dhikr.meaningBn}'
                          : '${dhikr.transliterationEn} — ${dhikr.meaningEn}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textGrey : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      );
    });
  }

  // ────────────────────────────────────────────────────────────────
  // Circular Counter Button
  // ────────────────────────────────────────────────────────────────
  Widget _buildCircularCounter(BuildContext context, SettingsController settings, bool isDark) {
    return Center(
      child: Obx(() {
        final count = controller.count.value;
        final target = controller.target.value;
        final progress = target == 9999 ? 0.0 : (count / target).clamp(0.0, 1.0);

        return GestureDetector(
          onTap: () => controller.increment(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            child: CustomPaint(
              painter: _ArcPainter(
                progress: progress,
                isDark: isDark,
                primaryColor: AppColors.primary,
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
                          isDark
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                          isDark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF5F5F5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
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
                          style: TextStyle(
                            color: AppColors.textGrey.withValues(alpha: 0.7),
                            fontSize: 11,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Large animated count
                        TweenAnimationBuilder<int>(
                          key: ValueKey(count),
                          tween: IntTween(begin: count - 1 < 0 ? 0 : count - 1, end: count),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, val, child) => Text(
                            val.toString(),
                            style: TextStyle(
                              fontSize: 72,
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
                            style: const TextStyle(
                              color: AppColors.primary,
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

  // ────────────────────────────────────────────────────────────────
  // Target Selector
  // ────────────────────────────────────────────────────────────────
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
                  colors: [AppColors.primary, Color(0xFFFF6A00)],
                )
              : null,
          color: isSelected ? null : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textGrey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Action Row: reset | rounds badge
  // ────────────────────────────────────────────────────────────────
  Widget _buildActionRow(BuildContext context, SettingsController settings, bool isDark) {
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
                  const Icon(Icons.refresh_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    settings.isBangla ? 'রিসেট' : 'Reset',
                    style: const TextStyle(
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.loop_rounded, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${settings.isBangla ? "চক্র" : "Rounds"}: ${controller.totalSaves.value}',
                      style: const TextStyle(
                        color: AppColors.success,
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

  // ────────────────────────────────────────────────────────────────
  // Dhikr Selector Bottom Sheet
  // ────────────────────────────────────────────────────────────────
  void _showDhikrSelector(SettingsController settings) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: settings.isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
                    final isSelected = controller.selectedDhikrIndex.value == index;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      onTap: () {
                        controller.selectDhikr(index);
                        Get.back();
                      },
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                        child: Text(
                          '${dhikr.defaultTarget}',
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        dhikr.arabic,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Text(
                        settings.isBangla
                            ? '${dhikr.transliterationBn} — ${dhikr.meaningBn}'
                            : '${dhikr.transliterationEn} — ${dhikr.meaningEn}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
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

  // ────────────────────────────────────────────────────────────────
  // Reset Confirm Dialog
  // ────────────────────────────────────────────────────────────────
  void _confirmReset(BuildContext context, SettingsController settings) {
    Get.dialog(
      AlertDialog(
        title: Text(settings.isBangla ? 'রিসেট নিশ্চিত করুন' : 'Confirm Reset'),
        content: Text(
          settings.isBangla
              ? 'গণনা ও চক্র শূন্য হয়ে যাবে। এগিয়ে যাবেন?'
              : 'Count and rounds will be reset. Proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(settings.isBangla ? 'বাতিল' : 'Cancel'),
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

// ──────────────────────────────────────────────────────────────────
// Custom Arc Painter for progress ring
// ──────────────────────────────────────────────────────────────────
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

    // Background track
    final trackPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Progress arc (gradient simulation via shader)
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * pi * progress;

      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + 2 * pi,
          colors: const [
            Color(0xFFFF8A00),
            Color(0xFFFF4500),
            Color(0xFFFF8A00),
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

      // Glow dot at tip
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
