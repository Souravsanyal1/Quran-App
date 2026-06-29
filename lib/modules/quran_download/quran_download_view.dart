import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/percentage_loading_widget.dart';
import 'quran_download_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _DownloadTheme {
  _DownloadTheme._();
  static const Color emerald      = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark  = Color(0xFF0D3B1E);
  static const Color gold         = Color(0xFFC9A84C);
  static const Color goldLight    = Color(0xFFE8C97A);
  static const Color goldSoft     = Color(0xFFFFF8E7);
  static const Color darkSurface  = Color(0xFF141420);
  static const Color darkCard     = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard    = Color(0xFFFFFFFF);
}

class QuranDownloadView extends GetView<QuranDownloadController> {
  const QuranDownloadView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final isBn = settings.isBangla;

      return Scaffold(
        backgroundColor: isDark ? _DownloadTheme.darkSurface : _DownloadTheme.lightSurface,
        appBar: AppBar(
          leading: const AppBackButton(color: Colors.white),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_DownloadTheme.emeraldDark, _DownloadTheme.emerald, _DownloadTheme.emeraldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: _DownloadTheme.gold, width: 1.5)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
              ],
            ),
          ),
          title: Text(
            isBn ? 'অফলাইন কুরআন ডাউনলোড' : 'Offline Quran Download',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: PercentageLoadingWidget(
                message: isBn ? 'সূরা তালিকা লোড হচ্ছে...' : 'Loading Surah List...',
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: isDark ? _DownloadTheme.darkCard : _DownloadTheme.lightCard,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? _DownloadTheme.emerald.withOpacity(0.15) : _DownloadTheme.emerald.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: _DownloadTheme.emerald, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isBn
                                ? 'আপনার পছন্দের সূরাগুলো ডাউনলোড করে রাখুন যাতে ইন্টারনেট ছাড়াই যেকোনো সময় পড়তে পারেন।'
                                : 'Download your favorite Surahs to read offline anytime without internet connection.',
                            style: GoogleFonts.poppins(
                              fontSize: 13, 
                              color: isDark ? Colors.white70 : AppColors.textDark,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.surahs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final surah = controller.surahs[index];
                    return Obx(() {
                      final state = controller.downloadStates[surah.number] ?? 0;
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? _DownloadTheme.darkCard : _DownloadTheme.lightCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? _DownloadTheme.emerald.withOpacity(0.15) : _DownloadTheme.emerald.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? _DownloadTheme.emerald.withOpacity(0.15) : _DownloadTheme.goldSoft,
                              shape: BoxShape.circle,
                              border: Border.all(color: _DownloadTheme.gold, width: 1.5),
                            ),
                            child: Text(
                              surah.number.toString(),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: _DownloadTheme.emerald,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            surah.englishName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          subtitle: Text(
                            '${surah.revelationType} • ${surah.numberOfAyahs} ${isBn ? "আয়াত" : "Ayahs"}',
                            style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                surah.name,
                                style: GoogleFonts.amiri(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _DownloadTheme.gold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              if (state == 2)
                                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24)
                              else if (state == 1)
                                SizedBox(
                                  width: 60,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${((controller.downloadProgress[surah.number] ?? 0.0) * 100).toInt()}%',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _DownloadTheme.emerald,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: controller.downloadProgress[surah.number],
                                          minHeight: 4,
                                          backgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.1),
                                          valueColor: const AlwaysStoppedAnimation<Color>(_DownloadTheme.emerald),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.cloud_download_outlined, color: _DownloadTheme.emerald),
                                  onPressed: () => controller.downloadSurah(surah.number),
                                ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          );
        }),
      );
    });
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
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
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
