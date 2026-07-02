import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/percentage_loading_widget.dart';
import 'para_details_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _ParaTheme {
  _ParaTheme._();
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

class ParaDetailsView extends GetView<ParaDetailsController> {
  const ParaDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      return Scaffold(
        backgroundColor: isDark ? _ParaTheme.darkSurface : _ParaTheme.lightSurface,
        appBar: AppBar(
          leading: const AppBackButton(color: Colors.white),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_ParaTheme.emeraldDark, _ParaTheme.emerald, _ParaTheme.emeraldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: _ParaTheme.gold, width: 1.5)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
              ],
            ),
          ),
          title: Obx(() => Text(
            '${settings.isBangla ? "পারা" : "Juz"} ${controller.paraNumber} - ${controller.currentParaName}',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          )),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onSelected: (value) {
                if (value == 'translation') controller.showTranslation.toggle();
                if (value == 'pronunciation') controller.showPronunciation.toggle();
                if (value == 'autoplay') controller.setAutoPlay(!controller.autoPlayNext.value);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'autoplay',
                  child: Obx(() => Row(
                    children: [
                      Icon(
                        controller.autoPlayNext.value ? Icons.check_box : Icons.check_box_outline_blank,
                        color: _ParaTheme.emerald,
                      ),
                      const SizedBox(width: 8),
                      Text(settings.isBangla ? 'অটো-প্লে' : 'Auto Play'),
                    ],
                  )),
                ),
                PopupMenuItem(
                  value: 'translation',
                  child: Obx(() => Row(
                    children: [
                      Icon(
                        controller.showTranslation.value ? Icons.check_box : Icons.check_box_outline_blank,
                        color: _ParaTheme.emerald,
                      ),
                      const SizedBox(width: 8),
                      Text(settings.isBangla ? 'অর্থ দেখান' : 'Show Translation'),
                    ],
                  )),
                ),
                PopupMenuItem(
                  value: 'pronunciation',
                  child: Obx(() => Row(
                    children: [
                      Icon(
                        controller.showPronunciation.value ? Icons.check_box : Icons.check_box_outline_blank,
                        color: _ParaTheme.emerald,
                      ),
                      const SizedBox(width: 8),
                      Text(settings.isBangla ? 'উচ্চারণ দেখান' : 'Show Pronunciation'),
                    ],
                  )),
                ),
              ],
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: PercentageLoadingWidget(
                message: settings.isBangla ? 'পারা লোড হচ্ছে...' : 'Loading Juz/Para...',
              ),
            );
          }

          if (controller.ayahs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 48),
                  const SizedBox(height: 24),
                  Text(settings.isBangla ? 'কোনো আয়াত পাওয়া যায়নি' : 'No Ayahs found', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.retryLoadData(),
                    style: ElevatedButton.styleFrom(backgroundColor: _ParaTheme.emerald, foregroundColor: Colors.white),
                    child: Text(settings.isBangla ? 'আবার চেষ্টা করুন' : 'Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.ayahs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildHeaderCard(settings);
                    final ayah = controller.ayahs[index - 1];
                    final surahName = controller.getSurahNameForAyah(ayah);
                    
                    return Obx(() {
                      final isCurrentPlaying = controller.playingAyahNumber.value == ayah.number;
                      final isBookmarked = controller.isBookmarked(ayah);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCurrentPlaying 
                              ? _ParaTheme.emerald.withOpacity(isDark ? 0.08 : 0.05) 
                              : (isDark ? _ParaTheme.darkCard : _ParaTheme.lightCard),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrentPlaying 
                                ? _ParaTheme.emerald.withOpacity(0.5) 
                                : (isDark ? _ParaTheme.emerald.withOpacity(0.12) : _ParaTheme.emerald.withOpacity(0.06)), 
                            width: isCurrentPlaying ? 1.5 : 1,
                          ),
                          boxShadow: isCurrentPlaying ? [
                            BoxShadow(
                              color: _ParaTheme.emerald.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ] : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                                  decoration: BoxDecoration(
                                    color: _ParaTheme.emerald.withOpacity(0.1), 
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _ParaTheme.gold.withOpacity(0.3), width: 0.5),
                                  ), 
                                  child: Text(
                                    '$surahName [${ayah.surahNumber}:${ayah.numberInSurah}]', 
                                    style: const TextStyle(color: _ParaTheme.emerald, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(isCurrentPlaying && controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_fill, color: _ParaTheme.emerald, size: 26), 
                                      onPressed: () => controller.playAyah(ayah),
                                    ),
                                    IconButton(
                                      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: _ParaTheme.emerald), 
                                      onPressed: () => controller.toggleBookmark(ayah),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share_outlined, color: AppColors.textGrey), 
                                      onPressed: () => Share.share('${ayah.text}\n\n[$surahName, ${ayah.numberInSurah}]'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              ayah.text, 
                              textAlign: TextAlign.right, 
                              textDirection: TextDirection.rtl, 
                              style: GoogleFonts.amiri(
                                fontSize: settings.arabicFontSize.value, 
                                height: 1.8, 
                                color: _ParaTheme.emerald,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Bengali Transliteration (Pronunciation)
                            if (ayah.textBanglaTranslit != null && controller.showPronunciation.value)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _ParaTheme.emerald.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _ParaTheme.emerald.withOpacity(0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      settings.isBangla ? 'উচ্চারণ:' : 'Pronunciation:',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _ParaTheme.emerald),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ayah.textBanglaTranslit!,
                                      style: TextStyle(
                                        fontSize: settings.translationFontSize.value - 1,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            if (controller.showTranslation.value) ...[
                              const SizedBox(height: 12),
                              Text(
                                ayah.textBangla ?? '', 
                                style: TextStyle(
                                  fontSize: settings.translationFontSize.value, 
                                  color: isDark ? AppColors.textGrey : AppColors.textDark, 
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    });
                  },
                ),
              ),
              Obx(() {
                if (controller.playingAyahNumber.value == null) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.nowPlaying),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? _ParaTheme.darkCard : Colors.white, 
                      border: Border(top: BorderSide(color: _ParaTheme.emerald.withOpacity(0.1))),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          const Icon(Icons.music_note_rounded, color: _ParaTheme.emerald),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              mainAxisSize: MainAxisSize.min, 
                              children: [
                                Text('${settings.isBangla ? "তিলওয়াত হচ্ছে" : "Reciting"} - ${settings.isBangla ? "পারা" : "Juz"} ${controller.paraNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${settings.isBangla ? "আয়াত নং" : "Ayah No"}: ${controller.ayahs.firstWhereOrNull((element) => element.number == controller.playingAyahNumber.value)?.numberInSurah ?? ""}', style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled, color: _ParaTheme.emerald, size: 36), 
                            onPressed: () => controller.togglePlayback(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.stop_circle_rounded, color: AppColors.error, size: 36), 
                            onPressed: () => controller.stopAudio(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      );
    });
  }

  Widget _buildHeaderCard(SettingsController settings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_ParaTheme.emeraldDark, _ParaTheme.emerald],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _ParaTheme.gold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _ParaTheme.emerald.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              controller.currentParaName, 
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${settings.isBangla ? "পারা নং" : "Juz No"}: ${controller.paraNumber}', 
              style: GoogleFonts.poppins(color: _ParaTheme.goldSoft, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
              children: [
                _buildHeaderStatItem(settings.isBangla ? 'মোট আয়াত' : 'Ayahs', '${controller.ayahs.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: _ParaTheme.goldSoft, fontSize: 12)),
      ],
    );
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
