import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          title: Text(settings.isBangla ? 'শিক্ষা ও গাইড' : 'Learning & Guide'),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: settings.isBangla ? 'মূলভিত্তি' : 'Basics'),
              Tab(text: settings.isBangla ? 'ওযু' : 'Wudu'),
              Tab(text: settings.isBangla ? 'নামাজ' : 'Salah'),
              Tab(text: settings.isBangla ? 'রাকাত' : 'Rakah'),
              Tab(text: settings.isBangla ? 'ভুল-ত্রুটি' : 'Mistakes'),
              Tab(text: settings.isBangla ? 'রিসোর্স' : 'Resources'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBasicsTab(context, settings),
            _buildWuduTab(context, settings),
            _buildSalahStepsTab(context, settings),
            _buildRakahTab(context, settings),
            _buildMistakesTab(context, settings),
            _buildResourcesTab(context, settings),
          ],
        ),
      ),
    );
  }

  // --- Basics Tab ---
  Widget _buildBasicsTab(BuildContext context, SettingsController settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            settings,
            title: settings.isBangla ? 'কালিমা শাহাদাত' : 'The Shahada',
            arabic: 'أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
            translit: settings.isBangla 
                ? 'আশহাদু আল্লা ইলাহা ইল্লাল্লাহু ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসুলুহু।'
                : 'Ash-hadu alla ilaha illallah, wa ash-hadu anna Muhammadan \'abduhu wa Rasuluh.',
            translation: settings.isBangla
                ? 'আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া কোনো উপাস্য নেই এবং আমি আরও সাক্ষ্য দিচ্ছি যে, মুহাম্মদ (সাঃ) তাঁর বান্দা ও রাসুল।'
                : 'I bear witness that there is no god but Allah, and I bear witness that Muhammad is His servant and messenger.',
          ),
          const SizedBox(height: 24),
          Text(
            settings.isBangla ? 'ইসলামের ৫টি মূল স্তম্ভ' : 'The 5 Pillars of Islam',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPillarItem(settings, '1', settings.isBangla ? 'শাহাদাহ (ঈমান)' : 'Shahadah', settings.isBangla ? 'একত্ববাদে বিশ্বাস' : 'Faith'),
          _buildPillarItem(settings, '2', settings.isBangla ? 'সালাত (নামাজ)' : 'Salah', settings.isBangla ? '৫ ওয়াক্ত নামাজ' : 'Prayer'),
          _buildPillarItem(settings, '3', settings.isBangla ? 'যাকাত (দান)' : 'Zakat', settings.isBangla ? 'দান ও সদকা' : 'Almsgiving'),
          _buildPillarItem(settings, '4', settings.isBangla ? 'সাওম (রোজা)' : 'Sawm', settings.isBangla ? 'রমজানের রোজা' : 'Fasting'),
          _buildPillarItem(settings, '5', settings.isBangla ? 'হজ' : 'Hajj', settings.isBangla ? 'মক্কা ভ্রমণ' : 'Pilgrimage'),
        ],
      ),
    );
  }

  // --- Wudu Tab ---
  Widget _buildWuduTab(BuildContext context, SettingsController settings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.wuduSteps.length,
      itemBuilder: (context, index) {
        final step = controller.wuduSteps[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: settings.isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text('${step.stepNumber}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            title: Text(settings.isBangla ? step.titleBn : step.titleEn, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(settings.isBangla ? step.descBn : step.descEn, style: const TextStyle(fontSize: 12)),
          ),
        );
      },
    );
  }

  // --- Salah Steps Tab ---
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
                  Text(
                    '${settings.isBangla ? "ধাপ" : "Step"} ${controller.currentSalahStep.value + 1} / ${controller.salahSteps.length}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    settings.isBangla ? step.titleBn : step.titleEn,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (step.arabic != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        step.arabic!,
                        style: TextStyle(fontFamily: 'Uthmanic', fontSize: settings.arabicFontSize.value, height: 1.6),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    settings.isBangla ? step.descBn : step.descEn,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: controller.prevSalahStep, icon: const Icon(Icons.arrow_back_ios_rounded)),
                TextButton(
                  onPressed: () => controller.currentSalahStep.value = 0,
                  child: Text(settings.isBangla ? 'রিস্টার্ট' : 'Restart'),
                ),
                IconButton(onPressed: controller.nextSalahStep, icon: const Icon(Icons.arrow_forward_ios_rounded)),
              ],
            ),
          ),
        ],
      );
    });
  }

  // --- Rakah Tab ---
  Widget _buildRakahTab(BuildContext context, SettingsController settings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.prayers.length,
      itemBuilder: (context, index) {
        final p = controller.prayers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: settings.isDark ? AppColors.surfaceDark : Colors.white,
          child: ExpansionTile(
            title: Text(settings.isBangla ? p.nameBn : p.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(settings.isBangla ? p.descBn : p.descEn, style: const TextStyle(fontSize: 12)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  settings.isBangla 
                      ? 'রাকাত: ফরজ: ${p.breakdown.fard}, সুন্নাত: ${p.breakdown.sunnahMuakkadah + p.breakdown.sunnahGhairMuakkadah}'
                      : 'Rakah: Fard: ${p.breakdown.fard}, Sunnah: ${p.breakdown.sunnahMuakkadah}',
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- Mistakes Tab ---
  Widget _buildMistakesTab(BuildContext context, SettingsController settings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.commonMistakes.length,
      itemBuilder: (context, index) {
        final m = controller.commonMistakes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: settings.isDark ? AppColors.surfaceDark : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(settings.isBangla ? m.titleBn : m.titleEn, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${settings.isBangla ? "সঠিক নিয়ম:" : "Correction:"} ${settings.isBangla ? m.correctionBn : m.correctionEn}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Resources Tab ---
  Widget _buildResourcesTab(BuildContext context, SettingsController settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.isBangla ? 'প্রয়োজনীয় ছোট সূরা' : 'Essential Short Surahs', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...controller.shortSurahs.map((s) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: settings.isDark ? AppColors.surfaceDark : Colors.white,
            child: ExpansionTile(
              title: Text(settings.isBangla ? s['nameBn']! : s['nameEn']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(settings.isBangla ? s['descBn']! : s['descEn']!, style: const TextStyle(fontSize: 12)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(s['arabic']!, textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Uthmanic', fontSize: settings.arabicFontSize.value - 2, height: 1.8), textDirection: TextDirection.rtl),
                )
              ],
            ),
          )),
          const SizedBox(height: 24),
          Text(settings.isBangla ? 'ইসলামিক আদব ও শিষ্টাচার' : 'Islamic Etiquette (Adab)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...controller.adabEtiquette.map((a) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: settings.isDark ? AppColors.surfaceDark : Colors.white,
            child: ListTile(
              title: Text(settings.isBangla ? a['titleBn']! : a['titleEn']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(settings.isBangla ? a['descBn']! : a['descEn']!, style: const TextStyle(fontSize: 13)),
            ),
          )),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _buildInfoCard(SettingsController settings, {required String title, required String arabic, required String translit, required String translation}) {
    return Card(
      color: settings.isDark ? AppColors.surfaceDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            const SizedBox(height: 16),
            Text(arabic, style: TextStyle(fontFamily: 'Uthmanic', fontSize: settings.arabicFontSize.value, height: 1.6), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(translit, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: AppColors.textGrey), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(translation, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarItem(SettingsController settings, String n, String t, String d) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: AppColors.primary, radius: 14, child: Text(n, style: const TextStyle(color: Colors.white, fontSize: 12))),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(d, style: const TextStyle(fontSize: 11)),
      dense: true,
    );
  }
}
