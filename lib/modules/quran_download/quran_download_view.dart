import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/percentage_loading_widget.dart';
import 'quran_download_controller.dart';

class QuranDownloadView extends GetView<QuranDownloadController> {
  const QuranDownloadView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(settings.isBangla ? 'অফলাইন কুরআন ডাউনলোড' : 'Offline Quran Download'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: PercentageLoadingWidget(
              message: settings.isBangla ? 'সূরা তালিকা লোড হচ্ছে...' : 'Loading Surah List...',
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          settings.isBangla
                              ? 'আপনার পছন্দের সূরাগুলো ডাউনলোড করে রাখুন যাতে ইন্টারনেট ছাড়াই যেকোনো সময় পড়তে পারেন।'
                              : 'Download your favorite Surahs to read offline anytime without internet connection.',
                          style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.surahs.length,
                separatorBuilder: (context, index) => Divider(
                  color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                itemBuilder: (context, index) {
                  final surah = controller.surahs[index];
                  return Obx(() {
                    final state = controller.downloadStates[surah.number] ?? 0;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: Text(
                          surah.number.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        surah.englishName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                        ),
                      ),
                      subtitle: Text(
                        '${surah.revelationType} • ${surah.numberOfAyahs} ${settings.isBangla ? "আয়াত" : "Ayahs"}',
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            surah.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (state == 2)
                            const Icon(Icons.check_circle, color: AppColors.success)
                          else if (state == 1)
                            SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${((controller.downloadProgress[surah.number] ?? 0.0) * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: controller.downloadProgress[surah.number],
                                      minHeight: 4,
                                      backgroundColor: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.cloud_download_outlined, color: AppColors.primary),
                              onPressed: () => controller.downloadSurah(surah.number),
                            ),
                        ],
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
  }
}
