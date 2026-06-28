import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../settings/settings_controller.dart';
import 'support_controller.dart';
import 'support_view.dart'; // SupportChatView
import 'support_form_view.dart';

class SupportCenterView extends GetView<SupportController> {
  const SupportCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isBn = settings.isBangla;

    return Obx(() {
      final title = isBn ? 'সাপোর্ট সেন্টার' : 'Live Support';
      
      // 1. Loading State
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Get.back(),
            ),
            title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }

      // 2. Chat View (If an active chat exists)
      if (controller.activeTicket.value != null) {
        return const SupportChatView();
      }

      // 3. Welcome/Onboarding View (If no tickets)
      return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Get.back(),
          ),
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                _buildModernHeader(isBn),
                const SizedBox(height: 48),
                _buildActionButtons(isBn),
                const SizedBox(height: 60),
                _buildContactInfo(isBn),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildModernHeader(bool isBn) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: const Duration(seconds: 2)),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_rounded, size: 48, color: Colors.black),
            ),
          ],
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 32),
        Text(
          isBn ? 'আপনার ব্যক্তিগত সহকারী' : 'Your Personal Assistant',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        Text(
          isBn 
            ? 'আমাদের বিশেষজ্ঞ দল আপনার দ্বীনি এবং অ্যাপ সংক্রান্ত যে কোনো সমস্যায় সাহায্য করতে প্রস্তুত।' 
            : 'Our expert team is ready to help you with any Deen or App related issues in real-time.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.5), height: 1.5, fontSize: 14),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildActionButtons(bool isBn) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Obx(() => ElevatedButton(
            onPressed: controller.isSubmitting.value ? null : controller.startInstantChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: controller.isSubmitting.value 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_rounded),
                      const SizedBox(width: 12),
                      Text(
                        isBn ? 'সরাসরি চ্যাট শুরু করুন' : 'Start Live Chat Now',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
          )),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () => Get.to(() => const SupportFormView()),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              isBn ? 'বিস্তারিত সমস্যা জানাতে টিকেট ওপেন করুন' : 'or open a ticket for detailed issues',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(bool isBn) {
    return Column(
      children: [
        Text(
          isBn ? 'অথবা সরাসরি যোগাযোগ করুন' : 'Or Contact Us Directly',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.3),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildContactCard(
              icon: Icons.chat_bubble_rounded,
              color: const Color(0xFF25D366),
              label: 'WhatsApp',
              onTap: controller.launchWhatsApp,
            ),
            const SizedBox(width: 20),
            _buildContactCard(
              icon: Icons.facebook_rounded,
              color: const Color(0xFF1877F2),
              label: 'Facebook',
              onTap: controller.launchFacebook,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          '+8801340989509',
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportInfo(BuildContext context) {
    final isBn = Get.find<SettingsController>().isBangla;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBn ? 'সাপোর্ট তথ্য' : 'Support Information',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.chat_bubble_rounded, isBn ? 'হোয়াটসঅ্যাপ' : 'WhatsApp', '+8801340989509'),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.facebook_rounded, isBn ? 'ফেসবুক' : 'Facebook', 'Quran App Page'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
