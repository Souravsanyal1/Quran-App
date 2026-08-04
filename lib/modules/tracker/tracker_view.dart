import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'package:quran_app/widgets/shimmer_loading.dart';
import 'tracker_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _TrackerTheme {
  _TrackerTheme._();
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

class TrackerView extends GetView<TrackerController> {
  const TrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final isBn = settings.isBangla;

      return Scaffold(
        backgroundColor:
            isDark ? _TrackerTheme.darkSurface : _TrackerTheme.lightSurface,
        appBar: AppBar(
          leading: const AppBackButton(color: Colors.white),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _TrackerTheme.emeraldDark,
                  _TrackerTheme.emerald,
                  _TrackerTheme.emeraldLight
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                  bottom: BorderSide(color: _TrackerTheme.gold, width: 1.5)),
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
            isBn ? 'ইবাদত ট্র্যাকার' : 'Deen Tracker',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ShimmerLoading.rounded(height: 140, borderRadius: 24),
                  const SizedBox(height: 32),
                  ShimmerLoading.rounded(height: 20, width: 150),
                  const SizedBox(height: 16),
                  ShimmerList(
                      itemCount: 6, height: 70, padding: EdgeInsets.zero),
                ],
              ),
            );
          }

          final rate = controller.todayCompletionRate;
          final completedCount =
              controller.todayRecords.values.where((v) => v).length;
          final totalCount = controller.todayRecords.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Today's Progress Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        _TrackerTheme.emeraldDark,
                        _TrackerTheme.emerald
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: _TrackerTheme.gold.withValues(alpha: 0.5),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _TrackerTheme.emerald.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 50.0,
                        lineWidth: 8.0,
                        percent: rate,
                        center: Text(
                          '${(rate * 100).round()}%',
                          style: GoogleFonts.poppins(
                            color: _TrackerTheme.goldLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        progressColor: _TrackerTheme.gold,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'আজকের অগ্রগতি' : "Today's Progress",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isBn
                                  ? '$completedCount / $totalCount ইবাদত সম্পন্ন হয়েছে'
                                  : '$completedCount / $totalCount activities completed',
                              style: GoogleFonts.poppins(
                                  color: _TrackerTheme.goldSoft,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Checklist Section Title
                Text(
                  isBn ? 'দৈনিক ইবাদত তালিকা' : 'Daily Checklist',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDark),
                ),
                const SizedBox(height: 16),

                // Checklist Items
                ...controller.todayRecords.keys.map((activity) {
                  final isDone = controller.todayRecords[activity] ?? false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? _TrackerTheme.darkCard
                          : _TrackerTheme.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDone
                            ? _TrackerTheme.emerald
                            : (isDark
                                ? _TrackerTheme.emerald.withValues(alpha: 0.15)
                                : _TrackerTheme.emerald
                                    .withValues(alpha: 0.06)),
                        width: isDone ? 1.5 : 1,
                      ),
                    ),
                    child: CheckboxListTile(
                      value: isDone,
                      onChanged: (val) => controller.toggleRecord(activity),
                      activeColor: _TrackerTheme.emerald,
                      checkColor: Colors.white,
                      title: Text(
                        _getActivityName(activity, isBn),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      subtitle: Text(
                        _getActivitySubtitle(activity, isBn),
                        style: GoogleFonts.poppins(
                            color: AppColors.textGrey, fontSize: 12),
                      ),
                      secondary: Icon(
                        activity == 'Quran'
                            ? Icons.menu_book_rounded
                            : Icons.nights_stay_outlined,
                        color: isDone ? _TrackerTheme.gold : AppColors.textGrey,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      );
    });
  }

  String _getActivityName(String key, bool isBangla) {
    if (!isBangla) return key == 'Quran' ? 'Quran Reading' : '$key Salah';
    switch (key) {
      case 'Fajr':
        return 'ফজর সালাত';
      case 'Dhuhr':
        return 'যোহর সালাত';
      case 'Asr':
        return 'আসর সালাত';
      case 'Maghrib':
        return 'মাগরিব সালাত';
      case 'Isha':
        return 'এশা সালাত';
      case 'Quran':
        return 'আল-কুরআন তিলাওয়াত';
      default:
        return key;
    }
  }

  String _getActivitySubtitle(String key, bool isBangla) {
    if (!isBangla)
      return key == 'Quran' ? 'Read or listen today' : 'Perform daily prayer';
    switch (key) {
      case 'Quran':
        return 'আজকে কুরআন পাঠ বা শ্রবণ করুন';
      default:
        return 'দৈনিক ফরজ নামাজ আদায় করুন';
    }
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
