import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';

class DonationView extends StatelessWidget {
  const DonationView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(settings.isBangla ? 'অনুদান ও সদকা' : 'Donation & Sadakah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Islamic Quote Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.islamicGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    'مَّن ذَا الَّذِي يُقْرِضُ اللَّهَ قَرْضًا حَسَنًا فَيُضَاعِفَهُ لَهُ أَضْعَافًا كَثِيرَةً',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Uthmanic',
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    settings.isBangla
                        ? '“কে সেই যে আল্লাহকে করজে হাসানা (উত্তম ঋণ) দেবে? ফলে তিনি তার জন্য তা বহু গুণ বাড়িয়ে দেবেন।” (সূরা আল-বাকারাহ: ২৪৫)'
                        : '“Who is it that would loan Allah a goodly loan so He may multiply it for him many times over?” (Surah Al-Baqarah: 245)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sadakah Jariyah Card
            Card(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.isBangla
                          ? 'সদকায়ে জারিয়া হিসেবে অংশ নিন'
                          : 'Sadakah Jariyah (Ongoing Charity)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      settings.isBangla
                          ? 'এই অ্যাপটি সম্পূর্ণ বিজ্ঞাপনমুক্ত এবং বিনামূল্যে কুরআন শিক্ষার উদ্দেশ্যে তৈরি। অ্যাপটির উন্নয়ন ও সার্ভার মেইনটেন্যান্স সচল রাখতে আপনার সদকা দিয়ে সাহায্য করতে পারেন।'
                          : 'This application is entirely ad-free and free for teaching Al-Quran. To keep updates, feature developments and server maintenance running, you can contribute your Sadakah.',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Methods Title
            Text(
              settings.isBangla
                  ? 'মোবাইল ও ব্যাংক অ্যাকাউন্ট'
                  : 'Payment Accounts',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Bkash/Nagad/Rocket
            _buildDonationMethod(
              context,
              settings,
              'bKash / Nagad (Personal)',
              '+880 13074 60389',
              Icons.phone_android,
            ),
            const SizedBox(height: 12),

            // Bank Account
            _buildDonationMethod(
              context,
              settings,
              'Islami Bank Bangladesh Ltd',
              'A/C No: 2050 356 67 00160203\nName: Quran App Project',
              Icons.account_balance,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationMethod(
    BuildContext context,
    SettingsController settings,
    String method,
    String details,
    IconData icon,
  ) {
    final isDark = settings.isDark;
    return Card(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 28),
        title: Text(
          method,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textWhite : AppColors.textDark,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            details,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_all, color: AppColors.textGrey),
          onPressed: () {
            // Remove text formatting to copy raw number
            final cleanNum = details.replaceAll(RegExp(r'[^0-9+]'), '');
            Clipboard.setData(
              ClipboardData(text: cleanNum.isNotEmpty ? cleanNum : details),
            );
            Get.snackbar(
              settings.isBangla ? 'অনুলিপি করা হয়েছে' : 'Copied',
              settings.isBangla
                  ? 'অ্যাকাউন্ট নম্বরটি কপি করা হয়েছে!'
                  : 'Account details copied to clipboard!',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ),
    );
  }
}
