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
        title: Obx(() => Text('${settings.isBangla ? "পারা" : "Juz"} ${controller.paraNumber} - ${controller.currentParaName}')),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 48),
                const SizedBox(height: 24),
                Text(settings.isBangla ? 'কোনো আয়াত পাওয়া যায়নি' : 'No Ayahs found', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => controller.retryLoadData(), child: Text(settings.isBangla ? 'আবার চেষ্টা করুন' : 'Retry')),
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
                        color: isCurrentPlaying ? AppColors.primary.withValues(alpha: 0.08) : (settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isCurrentPlaying ? AppColors.primary : (settings.isDark ? AppColors.borderDark : AppColors.borderLight), width: isCurrentPlaying ? 1.5 : 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text('$surahName [${ayah.surahNumber}:${ayah.numberInSurah}]', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))),
                              Row(children: [
                                IconButton(icon: Icon(isCurrentPlaying && controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_fill, color: AppColors.primary, size: 26), onPressed: () => controller.playAyah(ayah)),
                                IconButton(icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: AppColors.primary), onPressed: () => controller.toggleBookmark(ayah)),
                                IconButton(icon: const Icon(Icons.share_outlined, color: AppColors.textGrey), onPressed: () => Share.share('${ayah.text}\n\n[$surahName, ${ayah.numberInSurah}]')),
                              ]),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(ayah.text, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: TextStyle(fontFamily: 'Uthmanic', fontSize: settings.arabicFontSize.value, height: 1.8, color: AppColors.deepOrange)),
                          const SizedBox(height: 16),
                          Text(ayah.textBangla ?? '', style: TextStyle(fontSize: settings.translationFontSize.value, color: settings.isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.8), height: 1.5)),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
            Obx(() {
              if (controller.playingAyahNumber.value == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight, border: Border(top: BorderSide(color: settings.isDark ? AppColors.borderDark : AppColors.borderLight))),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      const Icon(Icons.music_note, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        Text('${settings.isBangla ? "তিলওয়াত হচ্ছে" : "Reciting"} - ${settings.isBangla ? "পারা" : "Juz"} ${controller.paraNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${settings.isBangla ? "আয়াত নং" : "Ayah No"}: ${controller.ayahs.firstWhereOrNull((element) => element.number == controller.playingAyahNumber.value)?.numberInSurah ?? ""}', style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                      ])),
                      IconButton(icon: Icon(controller.isPlaying.value ? Icons.pause_circle : Icons.play_circle, color: AppColors.primary, size: 32), onPressed: () {
                        controller.togglePlayback();
                      }),
                      IconButton(icon: const Icon(Icons.stop_circle, color: AppColors.error, size: 32), onPressed: () => controller.stopAudio()),
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
      decoration: BoxDecoration(gradient: AppColors.islamicGradient, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(controller.currentParaName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${settings.isBangla ? "পারা নং" : "Juz No"}: ${controller.paraNumber}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _buildHeaderStatItem(settings.isBangla ? 'মোট আয়াত' : 'Ayahs', '${controller.ayahs.length}'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStatItem(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }
}
