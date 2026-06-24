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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(settings.isBangla ? 'নামাজ শিক্ষা গাইড' : 'Salah Guide'),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: settings.isDark ? AppColors.textGrey : AppColors.textMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: [
              Tab(text: settings.isBangla ? 'নিয়মাবলী' : 'Salah Steps'),
              Tab(text: settings.isBangla ? 'রাকাতসমূহ' : 'Daily Rak\'ahs'),
              Tab(text: settings.isBangla ? 'প্রকারভেদ' : 'Types of Prayer'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStepsTab(context, settings),
            _buildRakahsTab(context, settings),
            _buildTypesTab(context, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsTab(BuildContext context, SettingsController settings) {
    return Obx(() {
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                          color: settings.isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.8),
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
    });
  }

  Widget _buildRakahsTab(BuildContext context, SettingsController settings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: controller.prayers.length,
      itemBuilder: (context, index) {
        final prayer = controller.prayers[index];
        final breakdown = prayer.breakdown;
        final totalRakahs = breakdown.total;

        Color prayerColor;
        switch (prayer.nameEn.toLowerCase()) {
          case 'fajr':
            prayerColor = AppColors.fajr;
            break;
          case 'dhuhr':
            prayerColor = AppColors.dhuhr;
            break;
          case 'asr':
            prayerColor = AppColors.asr;
            break;
          case 'maghrib':
            prayerColor = AppColors.maghrib;
            break;
          case 'isha':
            prayerColor = AppColors.isha;
            break;
          default:
            prayerColor = AppColors.primary;
        }

        return Card(
          color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              collapsedIconColor: AppColors.primary,
              iconColor: AppColors.primary,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: prayerColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.access_time_filled_rounded, color: prayerColor),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settings.isBangla ? prayer.nameBn : prayer.nameEn,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      settings.isBangla 
                          ? '$totalRakahs রাকাত' 
                          : '$totalRakahs Rak\'ah',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                settings.isBangla ? prayer.timeBn : prayer.timeEn,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Text(
                        settings.isBangla ? prayer.descBn : prayer.descEn,
                        style: TextStyle(
                          fontSize: 14,
                          color: settings.isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        settings.isBangla ? 'রাকাতের বিন্যাস:' : 'Rak\'ah Breakdown:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBreakdownTable(breakdown, settings),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreakdownTable(RakahBreakdown breakdown, SettingsController settings) {
    final List<Map<String, dynamic>> items = [
      if (breakdown.sunnahMuakkadah > 0)
        {
          'labelEn': 'Sunnah Mu\'akkadah (Emphasized)',
          'labelBn': 'সুন্নতে মুয়াক্কাদাহ (নিয়মিত)',
          'value': breakdown.sunnahMuakkadah
        },
      if (breakdown.sunnahGhairMuakkadah > 0)
        {
          'labelEn': 'Sunnah Ghair Mu\'akkadah',
          'labelBn': 'সুন্নতে গাইরে মুয়াক্কাদাহ (অনিয়মিত)',
          'value': breakdown.sunnahGhairMuakkadah
        },
      if (breakdown.fard > 0)
        {
          'labelEn': 'Fard (Obligatory)',
          'labelBn': 'ফরজ (আবশ্যকীয়)',
          'value': breakdown.fard
        },
      if (breakdown.witr > 0)
        {
          'labelEn': 'Witr (Wajib)',
          'labelBn': 'বিতর (ওয়াজিব)',
          'value': breakdown.witr
        },
      if (breakdown.nafl > 0)
        {
          'labelEn': 'Nafl (Voluntary)',
          'labelBn': 'নফল (ঐচ্ছিক)',
          'value': breakdown.nafl
        },
    ];

    return Container(
      decoration: BoxDecoration(
        color: settings.isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(1),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(
            color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        children: items.map((item) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Text(
                  settings.isBangla ? item['labelBn'] : item['labelEn'],
                  style: TextStyle(
                    fontSize: 13,
                    color: settings.isDark ? AppColors.textGrey : AppColors.textDark,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Text(
                  settings.isBangla 
                      ? '${item['value']} রাকাত' 
                      : '${item['value']} Rak\'ah',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypesTab(BuildContext context, SettingsController settings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: controller.salahTypes.length,
      itemBuilder: (context, index) {
        final type = controller.salahTypes[index];

        return Card(
          color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          margin: const EdgeInsets.only(bottom: 16.0),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        settings.isBangla ? type.typeBn : type.typeEn,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildTypeDetailRow(
                  title: settings.isBangla ? 'তাৎপর্য:' : 'Significance:',
                  content: settings.isBangla ? type.significanceBn : type.significanceEn,
                  settings: settings,
                ),
                const SizedBox(height: 12),
                _buildTypeDetailRow(
                  title: settings.isBangla ? 'বিধান:' : 'Rule:',
                  content: settings.isBangla ? type.ruleBn : type.ruleEn,
                  settings: settings,
                ),
                const SizedBox(height: 12),
                _buildTypeDetailRow(
                  title: settings.isBangla ? 'উদাহরণ:' : 'Examples:',
                  content: settings.isBangla ? type.exampleBn : type.exampleEn,
                  settings: settings,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeDetailRow({
    required String title,
    required String content,
    required SettingsController settings,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: settings.isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  String _truncateText(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }
}
