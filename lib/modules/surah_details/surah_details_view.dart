import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
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
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(controller.surahName),
        actions: [
          Obx(() => Row(
                children: [
                  Text(
                    settings.isBangla ? 'অটো-প্লে' : 'Auto Play',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Switch(
                    value: controller.autoPlayNextToggle.value,
                    onChanged: (val) => controller.setAutoPlay(val),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              )),
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

        if (controller.ayahs.isEmpty) {
          return Center(
            child: Text(
              settings.isBangla ? 'কোনো আয়াত পাওয়া যায়নি' : 'No Ayahs found',
              style: const TextStyle(color: AppColors.textGrey),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.ayahs.length + 2, // 1 for header card, 1 for Bismillah (if needed), plus ayahs
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHeaderCard(settings);
                  }

                  // Determine if Bismillah is needed
                  final needsBismillah = controller.surahNumber != 1 && controller.surahNumber != 9;
                  
                  if (index == 1) {
                    if (needsBismillah) {
                      return _buildBismillahCard(settings);
                    } else {
                      return const SizedBox.shrink();
                    }
                  }

                  // Ayah index starts at index - 2
                  final ayahIndex = index - 2;
                  final ayah = controller.ayahs[ayahIndex];
                  
                  return Obx(() {
                    final isCurrentPlaying = controller.playingAyahNumber.value == ayah.number;
                    final isBookmarked = controller.isBookmarked(ayah);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCurrentPlaying
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : (settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrentPlaying
                              ? AppColors.primary
                              : (settings.isDark ? AppColors.borderDark : AppColors.borderLight),
                          width: isCurrentPlaying ? 1.5 : 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ayah Info & Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${controller.surahNumber}:${ayah.numberInSurah}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  // Play/Pause
                                  IconButton(
                                    icon: isCurrentPlaying && controller.isPlayerLoading.value
                                        ? const SizedBox(
                                            width: 24,
                                            height: 8,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(4)),
                                              child: LinearProgressIndicator(
                                                color: AppColors.primary,
                                                backgroundColor: Colors.transparent,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            isCurrentPlaying && controller.isPlaying.value
                                                ? Icons.pause_circle_filled
                                                : Icons.play_circle_fill,
                                            color: AppColors.primary,
                                            size: 26,
                                          ),
                                    onPressed: () => controller.playAyah(ayah),
                                  ),
                                  // Bookmark
                                  IconButton(
                                    icon: Icon(
                                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () => controller.toggleBookmark(ayah),
                                  ),
                                  // Share
                                  IconButton(
                                    icon: const Icon(Icons.share_outlined, color: AppColors.textGrey),
                                    onPressed: () {
                                      final text = settings.isBangla
                                          ? '${ayah.text}\n\nঅনুবাদ: ${ayah.textBangla ?? ""}\n\n[সূরা ${controller.surahName}, আয়াত ${ayah.numberInSurah}]'
                                          : '${ayah.text}\n\nTranslation: ${ayah.textEnglish ?? ""}\n\n[Surah ${controller.surahName}, Ayah ${ayah.numberInSurah}]';
                                      Share.share(text);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Arabic text
                          Text(
                            ayah.text,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Uthmanic',
                              fontSize: settings.arabicFontSize.value,
                              height: 1.8,
                              color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Translation
                          Text(
                            settings.isBangla
                                ? (ayah.textBangla ?? '')
                                : (ayah.textEnglish ?? ''),
                            style: TextStyle(
                              fontSize: settings.translationFontSize.value,
                              color: settings.isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
            
            // Mini Bottom Audio Controller if playing
            Obx(() {
              if (controller.playingAyahNumber.value == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: Border(
                    top: BorderSide(
                      color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      const Icon(Icons.music_note, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${settings.isBangla ? "তিলওয়াত হচ্ছে" : "Reciting"} - ${controller.surahName}',
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
                          controller.isPlaying.value ? Icons.pause_circle : Icons.play_circle,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        onPressed: () {
                          final current = controller.ayahs.firstWhereOrNull((element) => element.number == controller.playingAyahNumber.value);
                          if (current != null) {
                            controller.playAyah(current);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop_circle, color: AppColors.error, size: 32),
                        onPressed: () => controller.stopAudio(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderCard(SettingsController settings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.islamicGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              controller.surahName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              settings.isBangla ? 'মক্কী/মাদানী • আয়াত সংখ্যা' : 'Revelation • Verses',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHeaderStatItem(
                  settings.isBangla ? 'পড়া শুরু' : 'Start',
                  '${controller.surahNumber}:1',
                ),
                _buildHeaderStatItem(
                  settings.isBangla ? 'মোট আয়াত' : 'Ayahs',
                  '${controller.ayahs.length}',
                ),
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
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBismillahCard(SettingsController settings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      alignment: Alignment.center,
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Uthmanic',
          fontSize: settings.arabicFontSize.value * 1.1,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
