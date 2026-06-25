import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'new_muslim_guide_controller.dart';

class NewMuslimGuideView extends GetView<NewMuslimGuideController> {
  const NewMuslimGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: settings.isDark ? AppColors.bgDark : const Color(0xFFF9F5F0),
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text(settings.isBangla ? 'সহজ নামাজ শিক্ষা' : 'Simple Salah Guide'),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: settings.isBangla ? 'ওযু' : 'Wudu'),
              Tab(text: settings.isBangla ? 'নামাজ' : 'Salah'),
              Tab(text: settings.isBangla ? 'ছোট সূরা' : 'Surahs'),
              Tab(text: settings.isBangla ? 'রাকাত' : 'Rakah'),
              Tab(text: settings.isBangla ? '৫ স্তম্ভ' : 'Pillars'),
              Tab(text: settings.isBangla ? 'টিপস' : 'Tips'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWuduTab(context, settings),
            _buildSalahStepsTab(context, settings),
            _buildSurahTab(context, settings),
            _buildRakahTab(context, settings),
            _buildBasicsTab(context, settings),
            _buildMistakesTab(context, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildWuduTab(BuildContext context, SettingsController settings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.wuduSteps.length,
      itemBuilder: (context, index) {
        final step = controller.wuduSteps[index];
        return _buildListItem(settings, step.stepNumber, step.titleBn, step.descBn);
      },
    );
  }

  Widget _buildSalahStepsTab(BuildContext context, SettingsController settings) {
    return Obx(() {
      final step = controller.salahSteps[controller.currentSalahStep.value];
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('${settings.isBangla ? "ধাপ" : "Step"} ${controller.currentSalahStep.value + 1} / ${controller.salahSteps.length}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(settings.isBangla ? step.titleBn : step.titleEn,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  if (step.arabic != null)
                    _buildArabicBox(settings, step.arabic!, step.translitBn!, step.meaningBn!),
                  const SizedBox(height: 16),
                  Text(settings.isBangla ? step.descBn : step.descEn,
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.5)),
                ],
              ),
            ),
          ),
          _buildStepNavigation(settings),
        ],
      );
    });
  }

  Widget _buildSurahTab(BuildContext context, SettingsController settings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.shortSurahs.length,
      itemBuilder: (context, index) {
        final s = controller.shortSurahs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: settings.isDark ? AppColors.surfaceDark : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s['nameBn']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                const SizedBox(height: 12),
                Text(s['arabic']!, textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                    style: TextStyle(fontFamily: 'Uthmanic', fontSize: settings.arabicFontSize.value - 2, color: AppColors.gold, height: 1.8)),
                const SizedBox(height: 12),
                Text('উচ্চারণ: ${s['translit']!}', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Text('অর্থ: ${s['meaning']!}', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRakahTab(BuildContext context, SettingsController settings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.prayers.length,
      itemBuilder: (context, index) {
        final p = controller.prayers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: settings.isDark ? AppColors.surfaceDark : Colors.white,
          child: ListTile(
            title: Text(settings.isBangla ? p.nameBn : p.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(settings.isBangla ? p.descBn : p.descEn, style: const TextStyle(fontSize: 13)),
          ),
        );
      },
    );
  }

  Widget _buildBasicsTab(BuildContext context, SettingsController settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildListItem(settings, 1, 'শাহাদাহ', 'একত্ববাদে বিশ্বাস স্থাপন করা।'),
          _buildListItem(settings, 2, 'সালাত', 'প্রতিদিন ৫ ওয়াক্ত নামাজ আদায় করা।'),
          _buildListItem(settings, 3, 'যাকাত', 'নির্দিষ্ট পরিমাণ সম্পদ দান করা।'),
          _buildListItem(settings, 4, 'সাওম', 'রমজান মাসে রোজা রাখা।'),
          _buildListItem(settings, 5, 'হজ', 'মক্কায় পবিত্র হজ পালন করা।'),
        ],
      ),
    );
  }

  Widget _buildMistakesTab(BuildContext context, SettingsController settings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.commonMistakes.length,
      itemBuilder: (context, index) {
        final m = controller.commonMistakes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: settings.isDark ? AppColors.surfaceDark : Colors.white,
          child: ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: Text(settings.isBangla ? m.titleBn : m.titleEn, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(settings.isBangla ? m.correctionBn : m.correctionEn),
          ),
        );
      },
    );
  }

  // --- UI Helpers ---
  Widget _buildArabicBox(SettingsController settings, String arabic, String translit, String meaning) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(arabic, style: TextStyle(fontFamily: 'Uthmanic', fontSize: settings.arabicFontSize.value, height: 1.6, color: AppColors.primary), textAlign: TextAlign.center),
          const Divider(height: 32),
          Text('উচ্চারণ: $translit', textAlign: TextAlign.center, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
          const SizedBox(height: 8),
          Text('অর্থ: $meaning', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildListItem(SettingsController settings, int num, String title, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: settings.isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.primary, radius: 15, child: Text('$num', style: const TextStyle(color: Colors.white, fontSize: 12))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildStepNavigation(SettingsController settings) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: controller.prevSalahStep, icon: const Icon(Icons.arrow_back_ios_rounded)),
          ElevatedButton(
            onPressed: controller.nextSalahStep,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: Text(settings.isBangla ? 'পরবর্তী ধাপ' : 'Next Step'),
          ),
          IconButton(onPressed: controller.nextSalahStep, icon: const Icon(Icons.arrow_forward_ios_rounded)),
        ],
      ),
    );
  }
}
