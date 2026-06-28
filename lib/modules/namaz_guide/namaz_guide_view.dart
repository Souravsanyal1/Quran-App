import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'package:quran_app/widgets/shimmer_loading.dart';
import 'namaz_guide_controller.dart';
import 'widgets/posture_illustration.dart';

class NamazGuideView extends GetView<NamazGuideController> {
  const NamazGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isBn = settings.isBangla;
    final isDark = settings.isDark;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(isBn ? 'নামাজের ধাপে ধাপে গাইড' : 'Step-by-Step Namaz Guide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: isBn ? 'পুনরায় শুরু করুন' : 'Restart',
            onPressed: controller.restart,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ShimmerLoading.rounded(height: 40),
                const SizedBox(height: 20),
                ShimmerLoading.rounded(height: 200, borderRadius: 20),
                const SizedBox(height: 20),
                ShimmerLoading.rounded(height: 30, width: 200),
                const SizedBox(height: 20),
                ShimmerLoading.rounded(height: 100, borderRadius: 14),
              ],
            ),
          );
        }
        return Column(
          children: [
            // Progress bar + step counter
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Obx(() => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBn
                              ? 'ধাপ ${controller.currentIndex.value + 1} / ${controller.steps.length}'
                              : 'Step ${controller.currentIndex.value + 1} of ${controller.steps.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textGrey),
                        ),
                        Text(
                          '${(controller.progress * 100).round()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: controller.progress,
                        minHeight: 8,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                )),
          ),

          // Swipeable step pages
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.steps.length,
              itemBuilder: (context, index) {
                final step = controller.steps[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    children: [
                      // Illustration card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                        ),
                        child: PostureIllustration(
                          posture: step.posture,
                          color: AppColors.primary,
                          size: 150,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Step title
                      Text(
                        isBn ? step.titleBn : step.titleEn,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textWhite : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Instruction
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                        ),
                        child: Text(
                          isBn ? step.instructionBn : step.instructionEn,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? AppColors.textWhite : AppColors.textDark),
                        ),
                      ),

                      // Arabic / translit / meaning (if available)
                      if (step.arabic != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                step.arabic!,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Uthmanic', fontSize: settings.arabicFontSize.value, color: AppColors.primary, height: 1.8),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isBn ? 'উচ্চারণ: ${step.translit}' : 'Transliteration: ${step.translit}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textGrey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isBn ? 'অর্থ: ${step.meaningBn}' : 'Meaning: ${step.meaningEn}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom navigation buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Obx(() => Row(
                  children: [
                    if (!controller.isFirstStep)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.previousStep,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text(isBn ? 'আগের ধাপ' : 'Previous'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                    if (!controller.isFirstStep) const SizedBox(width: 12),
                    Expanded(
                      flex: controller.isFirstStep ? 1 : 1,
                      child: ElevatedButton.icon(
                        onPressed: controller.isLastStep ? controller.restart : controller.nextStep,
                        icon: Icon(controller.isLastStep ? Icons.replay_rounded : Icons.arrow_forward_rounded, size: 18),
                        label: Text(
                          controller.isLastStep
                              ? (isBn ? 'আবার শুরু করুন' : 'Restart Guide')
                              : (isBn ? 'পরের ধাপ' : 'Next'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      );
    }),
  );
}
}
