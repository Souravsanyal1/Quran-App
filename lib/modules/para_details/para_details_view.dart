import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/percentage_loading_widget.dart';
import 'para_details_controller.dart';

class ParaDetailsView extends GetView<ParaDetailsController> {
  const ParaDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('${settings.isBangla ? "পারা" : "Juz"} ${controller.paraNumber} - ${controller.paraName}'),
        actions: [
          Obx(() => Row(
                children: [
                  Text(
                    settings.isBangla ? 'অটো-প্লে' : 'Auto Play',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Switch(
                    value: controller.autoPlayNext.value,
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
              message: settings.isBangla ? 'পারা লোড হচ্ছে...' : 'Loading Juz/Para...',
            ),
          );
        }

        if (controller.ayahs.isEmpty) {
          final isDark = settings.isDark;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.error,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    settings.isBangla
                        ? 'কোনো আয়াত পাওয়া যায়নি'
                        : 'No Ayahs found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    settings.isBangla
                        ? 'পারার আয়াতগুলো লোড করা যায়নি। অনুগ্রহ করে আপনার ইন্টারনেট সংযোগ পরীক্ষা করে পুনরায় চেষ্টা করুন।'
                        : 'Could not load the Juz/Para ayahs. Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.retryLoadData(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      settings.isBangla ? 'আবার চেষ্টা করুন' : 'Retry',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.ayahs.length + 1, // 1 for header card
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHeaderCard(settings);
                  }

                  final ayahIndex = index - 1;
                  final ayah = controller.ayahs[ayahIndex];
                  final surahName = controller.getSurahNameForAyah(ayah);
                  
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
                                  '$surahName [${ayah.surahNumber}:${ayah.numberInSurah}]',
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
                                          ? '${ayah.text}\n\nঅনুবাদ: ${ayah.textBangla ?? ""}\n\n[$surahName, আয়াত ${ayah.numberInSurah}]'
                                          : '${ayah.text}\n\nTranslation: ${ayah.textBangla ?? ""}\n\n[$surahName, Ayah ${ayah.numberInSurah}]'; // Fallback to Bangla since Para only retrieves Uthmani + Bangla
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
                            ayah.textBangla ?? '',
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
                              '${settings.isBangla ? "তিলওয়াত হচ্ছে" : "Reciting"} - ${settings.isBangla ? "পারা" : "Juz"} ${controller.paraNumber}',
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
              controller.paraName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${settings.isBangla ? "পারা নং" : "Juz No"}: ${controller.paraNumber}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
}
