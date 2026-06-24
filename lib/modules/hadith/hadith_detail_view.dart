import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import '../../data/models/hadith_model.dart';

class HadithDetailView extends StatelessWidget {
  const HadithDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final String bookName = args['bookName'];
    final Hadith hadith = args['hadith'];
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        elevation: 0,
        title: Text(
          bookName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '${hadith.arab}\n\n${hadith.id}'));
              Get.snackbar('Copied', 'Hadith copied to clipboard');
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Share.share('${hadith.arab}\n\n${hadith.id}\n\nShared from Quran App');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${settings.isBangla ? "হাদিস নম্বর" : "Hadith Number"}: ${hadith.number}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hadith.arab,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.8,
                fontFamily: 'Amiri',
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              settings.isBangla ? 'অনুবাদ (ইন্দোনেশীয়)' : 'Translation (Indonesian)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hadith.id,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              settings.isBangla 
                ? 'দ্রষ্টব্য: বর্তমান এপিআই শুধুমাত্র ইন্দোনেশীয় অনুবাদ প্রদান করে। ভবিষ্যতে বাংলা অনুবাদ যোগ করা হবে।'
                : 'Note: Current API provides only Indonesian translation. Bengali translation will be added in future updates.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
