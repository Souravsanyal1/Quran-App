import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'salah_guide_controller.dart';

class SalahGuideView extends GetView<SalahGuideController> {
  const SalahGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(settings.isBangla ? 'নামাজ শিক্ষা গাইড' : 'Salah Guide'),
      ),
      body: Obx(() {
        final stepIndex = controller.currentStep.value;
        final step = controller.steps[stepIndex];
        final totalSteps = controller.steps.length;

        return Column(
          children: [
            // Linear Progress Bar
            LinearProgressIndicator(
              value: (stepIndex + 1) / totalSteps,
              backgroundColor: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
              color: AppColors.primary,
              minHeight: 6,
            ),
            
            // Step count header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${settings.isBangla ? "ধাপ" : "Step"} ${stepIndex + 1} / $totalSteps',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  DropdownButton<int>(
                    value: stepIndex,
                    dropdownColor: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    style: TextStyle(
                      color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    underline: const SizedBox.shrink(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    items: List.generate(totalSteps, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text(
                          settings.isBangla
                              ? '${index + 1}. ${_truncateText(controller.steps[index].titleBn, 15)}'
                              : '${index + 1}. ${_truncateText(controller.steps[index].titleEn, 15)}',
                        ),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) controller.setStep(val);
                    },
                  ),
                ],
              ),
            ),

            // Step Content Detail
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          settings.isBangla ? step.titleBn : step.titleEn,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        Text(
                          settings.isBangla ? step.descBn : step.descEn,
                          style: TextStyle(
                            fontSize: 14,
                            color: settings.isDark ? AppColors.textGrey : AppColors.textDark.withOpacity(0.8),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Arabic Text Box (If available)
                        if (step.arabic != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: settings.isDark ? AppColors.cardDark : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            child: Text(
                              step.arabic!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Uthmanic',
                                fontSize: settings.arabicFontSize.value,
                                color: AppColors.primary,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Transliteration Box (If available)
                        if (step.translitBn != null || step.translitEn != null) ...[
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
                            settings.isBangla ? step.translitBn! : step.translitEn!,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation Row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  OutlinedButton(
                    onPressed: stepIndex > 0 ? () => controller.previousStep() : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(settings.isBangla ? 'পূর্ববর্তী' : 'Previous'),
                  ),
                  
                  // Next / Finish button
                  ElevatedButton(
                    onPressed: stepIndex < totalSteps - 1
                        ? () => controller.nextStep()
                        : () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      stepIndex < totalSteps - 1
                          ? (settings.isBangla ? 'পরবর্তী' : 'Next')
                          : (settings.isBangla ? 'সমাপ্ত' : 'Finish'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  String _truncateText(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }
}
