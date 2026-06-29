import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'package:quran_app/widgets/shimmer_loading.dart';
import 'duas_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _DuaTheme {
  _DuaTheme._();
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

class DuasView extends GetView<DuasController> {
  const DuasView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final bn = settings.isBangla;
      final scaffoldBg = isDark ? _DuaTheme.darkSurface : _DuaTheme.lightSurface;

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          leading: const AppBackButton(color: Colors.white),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_DuaTheme.emeraldDark, _DuaTheme.emerald, _DuaTheme.emeraldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: _DuaTheme.gold, width: 1.5)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
              ],
            ),
          ),
          title: Text(
            bn ? 'দোয়া ও যিকর' : 'Duas & Azkar',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Categories list horizontal scroll
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: controller.categoriesEn.length,
                itemBuilder: (context, index) {
                  final catEn = controller.categoriesEn[index];
                  final catBn = controller.categoriesBn[index];
                  
                  return Obx(() {
                    final isSelected = controller.selectedCategoryEn.value == catEn;
                    return GestureDetector(
                      onTap: () => controller.selectCategory(catEn),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [_DuaTheme.emerald, _DuaTheme.emeraldLight],
                                )
                              : null,
                          color: isSelected ? null : (isDark ? _DuaTheme.darkCard : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? _DuaTheme.gold
                                : (isDark ? _DuaTheme.emerald.withOpacity(0.15) : _DuaTheme.emerald.withOpacity(0.06)),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _DuaTheme.emerald.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          bn ? catBn : catEn,
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : AppColors.textDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            // List of Duas
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return ShimmerList(itemCount: 4, height: 180);
                }

                final list = controller.filteredDuas;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      bn ? 'কোনো দোয়া পাওয়া যায়নি' : 'No Duas found',
                      style: GoogleFonts.poppins(color: AppColors.textGrey, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final dua = list[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? _DuaTheme.darkCard : _DuaTheme.lightCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? _DuaTheme.emerald.withOpacity(0.15) : _DuaTheme.emerald.withOpacity(0.06),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _DuaTheme.emerald.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    bn ? dua.titleBn : dua.titleEn,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark ? Colors.white : AppColors.textDark,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share_outlined, color: _DuaTheme.emerald, size: 20),
                                  onPressed: () {
                                    final text = bn
                                        ? '${dua.arabic}\n\nউচ্চারণ: ${dua.pronunciationBn}\n\nঅনুবাদ: ${dua.translationBn}\n\n[উৎস: দোয়া ও যিকর]'
                                        : '${dua.arabic}\n\nTranslation: ${dua.translationEn}\n\n[Source: Duas & Azkar]';
                                    Share.share(text);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Arabic
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? _DuaTheme.darkSurface : _DuaTheme.goldSoft,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _DuaTheme.emerald.withOpacity(0.1)),
                              ),
                              child: Text(
                                dua.arabic,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Uthmanic',
                                  fontSize: settings.arabicFontSize.value,
                                  color: isDark ? _DuaTheme.goldLight : _DuaTheme.emerald,
                                  height: 1.65,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Pronunciation
                            Text(
                              bn ? 'উচ্চারণ:' : 'Pronunciation:',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _DuaTheme.emerald,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bn ? dua.pronunciationBn : dua.pronunciationEn,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: isDark ? Colors.white70 : AppColors.textDark,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Translation
                            Text(
                              bn ? 'অনুবাদ:' : 'Translation:',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _DuaTheme.emerald,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bn ? dua.translationBn : dua.translationEn,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isDark ? AppColors.textGrey : AppColors.textDark.withOpacity(0.85),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
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
