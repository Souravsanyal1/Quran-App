import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'duas_controller.dart';

class DuasView extends GetView<DuasController> {
  const DuasView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(settings.isBangla ? 'দোয়া ও যিকর' : 'Duas & Azkar'),
      ),
      body: Column(
        children: [
          // Categories list horizontal scroll
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: controller.categoriesEn.length,
              itemBuilder: (context, index) {
                final catEn = controller.categoriesEn[index];
                final catBn = controller.categoriesBn[index];
                
                return Obx(() {
                  final isSelected = controller.selectedCategoryEn.value == catEn;
                  return GestureDetector(
                    onTap: () => controller.selectCategory(catEn),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (settings.isDark ? AppColors.borderDark : AppColors.borderLight),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        settings.isBangla ? catBn : catEn,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (settings.isDark ? AppColors.textWhite : AppColors.textDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
              final list = controller.filteredDuas;
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    settings.isBangla ? 'কোনো দোয়া পাওয়া যায়নি' : 'No Duas found',
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final dua = list[index];
                  return Card(
                    color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  settings.isBangla ? dua.titleBn : dua.titleEn,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share_outlined, color: AppColors.textGrey),
                                onPressed: () {
                                  final text = settings.isBangla
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: settings.isDark ? AppColors.cardDark : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dua.arabic,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Uthmanic',
                                fontSize: settings.arabicFontSize.value,
                                color: AppColors.deepOrange,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Pronunciation
                          Text(
                            settings.isBangla ? 'উচ্চারণ:' : 'Pronunciation:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settings.isBangla ? dua.pronunciationBn : dua.pronunciationEn,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Translation
                          Text(
                            settings.isBangla ? 'অনুবাদ:' : 'Translation:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settings.isBangla ? dua.translationBn : dua.translationEn,
                            style: TextStyle(
                              fontSize: 13,
                              color: settings.isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.8),
                              height: 1.4,
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
  }
}
