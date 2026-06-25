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

class SurahDetailsView extends GetView<SurahDetailsController> {
  const SurahDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: settings.isDark ? AppColors.bgDark : const Color(0xFFFCF8F2),
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: settings.isDark ? AppColors.bgDark : AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Obx(() => Column(
          children: [
            Text(
              controller.currentSurahName,
              style: const TextStyle(
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
            icon: Icon(Icons.settings_outlined, color: settings.isDark ? Colors.white : AppColors.textDark),
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
                      color: AppColors.primary,
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
                      color: AppColors.primary,
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
                      color: AppColors.primary,
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
                      color: AppColors.primary,
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
  }

  Widget _buildHeaderCard(SettingsController settings) {
    return Obx(() => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: settings.isDark 
            ? [const Color(0xFF2D241E), const Color(0xFF1A1A24)]
            : [const Color(0xFFFDECDD), const Color(0xFFF7D9C4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Text(
                controller.currentSurahName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: settings.isDark ? Colors.white : const Color(0xFF4A3428),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${settings.isBangla ? "অর্থ" : "The Opener"} • ${controller.ayahs.length} ${settings.isBangla ? "আয়াত" : "Ayahs"}',
                style: TextStyle(
                  fontSize: 14,
                  color: settings.isDark ? Colors.white70 : const Color(0xFF7A5C4F),
                ),
              ),
              const SizedBox(height: 20),
              // Bismillah text in calligraphy style
              if (controller.surahNumber != 9)
                Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: GoogleFonts.amiri(
                    fontSize: 26,
                    color: settings.isDark ? AppColors.primary : const Color(0xFF4A3428),
                  ),
                ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.mosque,
                size: 60,
                color: settings.isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildAyahItem(AyahModel ayah, SettingsController settings) {
    return Obx(() {
      final isPlaying = controller.playingAyahNumber.value == ayah.number;
      final isBookmarked = controller.isBookmarked(ayah);
      final isDark = settings.isDark;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isPlaying 
              ? AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.05) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isPlaying 
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1)
              : Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.borderDark : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
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
                        ? AppColors.primary 
                        : (isDark ? AppColors.surfaceDark : const Color(0xFFF3E9DF)),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isPlaying ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ] : null,
                  ),
                  child: Text(
                    '${controller.surahNumber}:${ayah.numberInSurah}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPlaying 
                          ? Colors.black 
                          : (isDark ? AppColors.primary : const Color(0xFF4A3428)),
                    ),
                  ),
                ),
                if (isPlaying)
                  const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 20)
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(duration: 600.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1))
                      .then()
                      .scale(duration: 600.ms)
                else
                  Icon(
                    Icons.more_horiz,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Arabic Text
            controller.isWordByWord.value
                ? _buildWordByWordView(ayah, settings)
                : Text(
                    ayah.text,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: settings.arabicFontSize.value,
                      height: 1.8,
                      fontWeight: FontWeight.w500,
                      color: isPlaying 
                          ? AppColors.primary 
                          : (isDark ? AppColors.textWhite : const Color(0xFF1A1A1A)),
                    ),
                  ),

            if (controller.showPronunciation.value && ayah.textBanglaTranslit != null) ...[
              const SizedBox(height: 16),
              Text(
                ayah.textBanglaTranslit!,
                style: TextStyle(
                  fontSize: settings.translationFontSize.value - 2,
                  color: isPlaying ? AppColors.primary : AppColors.primary.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                  fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],

            if (controller.showTranslation.value) ...[
              const SizedBox(height: 12),
              Text(
                settings.isBangla ? (ayah.textBangla ?? '') : (ayah.textEnglish ?? ''),
                style: TextStyle(
                  fontSize: settings.translationFontSize.value,
                  height: 1.5,
                  color: isPlaying 
                      ? (isDark ? Colors.white : AppColors.textDark) 
                      : (isDark ? AppColors.textGrey : const Color(0xFF4A3428)),
                  fontWeight: isPlaying ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons Row
            Row(
              children: [
                _buildPlayButton(ayah, isPlaying, controller.isPlaying.value, isDark),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  onTap: () => controller.toggleBookmark(ayah),
                  isDark: isDark,
                  color: isBookmarked ? AppColors.primary : null,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: showPause ? Colors.black : AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (showPause ? Colors.black : AppColors.primary).withValues(alpha: 0.3),
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
              color: showPause ? AppColors.primary : Colors.black,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              showPause ? 'PAUSE' : 'PLAY',
              style: TextStyle(
                color: showPause ? AppColors.primary : Colors.black,
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
          size: 24,
          color: color ?? (isDark ? Colors.white70 : Colors.black54),
        ),
      ),
    );
  }

  Widget _buildBottomAudioPlayer(SettingsController settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: settings.isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.music_note, color: AppColors.primary, size: 20),
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
                color: AppColors.primary,
                size: 36,
              ),
              onPressed: () {
                final current = controller.ayahs.firstWhereOrNull((element) => element.number == controller.playingAyahNumber.value);
                if (current != null) controller.playAyah(current);
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textGrey),
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
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primary.withValues(alpha: 0.03),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  word.text,
                  style: GoogleFonts.amiri(
                    fontSize: settings.arabicFontSize.value,
                    color: settings.isDark ? AppColors.textWhite : const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  settings.isBangla ? (word.translationBn ?? word.translationEn ?? '') : (word.translationEn ?? ''),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
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
