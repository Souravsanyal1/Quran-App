import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/word_model.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/percentage_loading_widget.dart';
import 'surah_details_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _SurahTheme {
  _SurahTheme._();
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

class SurahDetailsView extends GetView<SurahDetailsController> {
  const SurahDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      return Scaffold(
        backgroundColor: isDark ? _SurahTheme.darkSurface : _SurahTheme.lightSurface,
        appBar: AppBar(
          leading: const AppBackButton(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_SurahTheme.emeraldDark, _SurahTheme.emerald, _SurahTheme.emeraldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: _SurahTheme.gold, width: 1.5)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
              ],
            ),
          ),
          title: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.currentSurahName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (settings.isBangla)
                const Text(
                  'উচ্চারণ ও শব্দার্থসহ',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.normal),
                ),
            ],
          )),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onSelected: (value) {
                if (value == 'translation') controller.showTranslation.toggle();
                if (value == 'pronunciation') controller.showPronunciation.toggle();
                if (value == 'wordbyword') controller.toggleWordByWord();
                if (value == 'autoplay') controller.setAutoPlay(!controller.autoPlayNextToggle.value);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'autoplay',
                  child: Obx(() => Row(
                    children: [
                      Icon(
                        controller.autoPlayNextToggle.value ? Icons.check_box : Icons.check_box_outline_blank,
                        color: _SurahTheme.emerald,
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
                        color: _SurahTheme.emerald,
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
                        color: _SurahTheme.emerald,
                      ),
                      const SizedBox(width: 8),
                      Text(settings.isBangla ? 'উচ্চারণ দেখান' : 'Show Pronunciation'),
                    ],
                  )),
                ),
                PopupMenuItem(
                  value: 'wordbyword',
                  child: Obx(() => Row(
                    children: [
                      Icon(
                        controller.isWordByWord.value ? Icons.check_box : Icons.check_box_outline_blank,
                        color: _SurahTheme.emerald,
                      ),
                      const SizedBox(width: 8),
                      Text(settings.isBangla ? 'শব্দে শব্দে অর্থ' : 'Word-by-Word'),
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
                message: settings.isBangla ? 'সূরা লোড হচ্ছে...' : 'Loading Surah...',
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.ayahs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeaderCard(settings);
                    }

                    final ayah = controller.ayahs[index - 1];
                    return _buildAyahItem(ayah, settings);
                  },
                ),
              ),
              
              // Bottom Audio Controller
              Obx(() {
                if (controller.playingAyahNumber.value == null) return const SizedBox.shrink();
                return _buildBottomAudioPlayer(settings);
              }),
            ],
          );
        }),
      );
    });
  }

  Widget _buildHeaderCard(SettingsController settings) {
    return Obx(() {
      final isDark = settings.isDark;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16, bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_SurahTheme.emeraldDark, _SurahTheme.emerald],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _SurahTheme.gold.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _SurahTheme.emerald.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Text(
                  controller.currentSurahName,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${settings.isBangla ? "অর্থ" : "The Opener"} • ${controller.ayahs.length} ${settings.isBangla ? "আয়াত" : "Ayahs"}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _SurahTheme.goldSoft,
                  ),
                ),
                const SizedBox(height: 20),
                // Bismillah text in calligraphy style
                if (controller.surahNumber != 9)
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: GoogleFonts.amiri(
                      fontSize: 28,
                      color: _SurahTheme.goldLight,
                    ),
                  ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.mosque,
                  size: 60,
                  color: _SurahTheme.goldLight,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAyahItem(AyahModel ayah, SettingsController settings) {
    return Obx(() {
      final isPlaying = controller.playingAyahNumber.value == ayah.number;
      final isBookmarked = controller.isBookmarked(ayah);
      final isDark = settings.isDark;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isPlaying 
              ? _SurahTheme.emerald.withOpacity(isDark ? 0.08 : 0.05) 
              : (isDark ? _SurahTheme.darkCard : _SurahTheme.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPlaying 
                ? _SurahTheme.emerald.withOpacity(0.5)
                : (isDark ? _SurahTheme.emerald.withOpacity(0.12) : _SurahTheme.emerald.withOpacity(0.06)),
            width: isPlaying ? 1.5 : 1,
          ),
          boxShadow: isPlaying ? [
            BoxShadow(
              color: _SurahTheme.emerald.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ayah Header (1:1 and Menu)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPlaying 
                        ? _SurahTheme.emerald 
                        : (isDark ? _SurahTheme.darkSurface : _SurahTheme.goldSoft),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _SurahTheme.gold.withOpacity(0.5), width: 1),
                  ),
                  child: Text(
                    '${controller.surahNumber}:${ayah.numberInSurah}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPlaying ? Colors.white : _SurahTheme.emerald,
                    ),
                  ),
                ),
                if (isPlaying)
                  const Icon(Icons.volume_up_rounded, color: _SurahTheme.gold, size: 20)
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(duration: 600.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1))
                      .then()
                      .scale(duration: 600.ms)
                else
                  Icon(
                    Icons.bookmark_outline_rounded,
                    color: isDark ? Colors.white30 : Colors.grey,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Arabic Text
            controller.isWordByWord.value
                ? _buildWordByWordView(ayah, settings)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        ayah.text,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: settings.arabicFontSize.value + 4,
                          height: 2.0,
                          fontWeight: FontWeight.w500,
                          color: _SurahTheme.emerald,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Bengali Transliteration (Pronunciation)
                      if (ayah.textBanglaTranslit != null && controller.showPronunciation.value)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: _SurahTheme.emerald.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _SurahTheme.emerald.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                settings.isBangla ? 'উচ্চারণ:' : 'Pronunciation:',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _SurahTheme.emerald),
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
                    ],
                  ),

            if (controller.showTranslation.value) ...[
              const SizedBox(height: 12),
              Text(
                settings.isBangla ? (ayah.textBangla ?? '') : (ayah.textEnglish ?? ''),
                style: TextStyle(
                  fontSize: settings.translationFontSize.value,
                  height: 1.5,
                  color: isPlaying 
                      ? (isDark ? Colors.white : AppColors.textDark) 
                      : (isDark ? AppColors.textGrey : AppColors.textDark),
                  fontWeight: isPlaying ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action Buttons Row
            Row(
              children: [
                _buildPlayButton(ayah, isPlaying, controller.isPlaying.value, isDark),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  onTap: () => controller.toggleBookmark(ayah),
                  isDark: isDark,
                  color: isBookmarked ? _SurahTheme.emerald : null,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  onTap: () {
                    final text = settings.isBangla
                        ? '${ayah.text}\n\nঅনুবাদ: ${ayah.textBangla ?? ""}\n\n[সূরা ${controller.surahName}, আয়াত ${ayah.numberInSurah}]'
                        : '${ayah.text}\n\nTranslation: ${ayah.textEnglish ?? ""}\n\n[Surah ${controller.surahName}, Ayah ${ayah.numberInSurah}]';
                    Share.share(text);
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPlayButton(AyahModel ayah, bool isCurrentPlaying, bool isActuallyPlaying, bool isDark) {
    final showPause = isCurrentPlaying && isActuallyPlaying;
    
    return InkWell(
      onTap: () => controller.playAyah(ayah),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: showPause ? Colors.black : _SurahTheme.emerald,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _SurahTheme.gold.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: (showPause ? Colors.black : _SurahTheme.emerald).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showPause ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: showPause ? _SurahTheme.gold : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              showPause ? 'PAUSE' : 'PLAY',
              style: GoogleFonts.poppins(
                color: showPause ? _SurahTheme.gold : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap, required bool isDark, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 22,
          color: color ?? (isDark ? Colors.white70 : Colors.black54),
        ),
      ),
    );
  }

  Widget _buildBottomAudioPlayer(SettingsController settings) {
    final isDark = settings.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? _SurahTheme.darkCard : Colors.white,
        border: Border(top: BorderSide(color: _SurahTheme.emerald.withOpacity(0.1), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _SurahTheme.emerald.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.music_note_rounded, color: _SurahTheme.emerald, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${settings.isBangla ? "তিলওয়াত হচ্ছে" : "Reciting"} - ${controller.currentSurahName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    '${settings.isBangla ? "আয়াত নং" : "Ayah No"}: ${controller.ayahs.firstWhereOrNull((element) => element.number == controller.playingAyahNumber.value)?.numberInSurah ?? ""}',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: _SurahTheme.emerald,
                size: 38,
              ),
              onPressed: () => controller.togglePlayback(),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
              onPressed: () => controller.stopAudio(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordByWordView(AyahModel ayah, SettingsController settings) {
    final words = controller.ayahWords[ayah.numberInSurah] ?? [];
    if (words.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: _SurahTheme.emerald)),
      );
    }

    return Wrap(
      alignment: WrapAlignment.end,
      direction: Axis.horizontal,
      textDirection: TextDirection.rtl,
      spacing: 12,
      runSpacing: 20,
      children: words.map((word) {
        return GestureDetector(
          onTap: () => controller.playWordAudio(word.audioUrl),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _SurahTheme.emerald.withOpacity(0.04),
              border: Border.all(color: _SurahTheme.emerald.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  word.text,
                  style: GoogleFonts.amiri(
                    fontSize: settings.arabicFontSize.value,
                    color: _SurahTheme.emerald,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  settings.isBangla ? (word.translationBn ?? word.translationEn ?? '') : (word.translationEn ?? ''),
                  style: const TextStyle(
                    fontSize: 10,
                    color: _SurahTheme.gold,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
