import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'support_controller.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(settings.isBangla ? 'সহযোগিতা ও সাপোর্ট' : 'Support & Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Direct Contact Section
            Text(
              settings.isBangla ? 'সরাসরি আমাদের সাথে যোগাযোগ করুন' : 'Contact Us Directly',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'WhatsApp',
                    subtitle: settings.isBangla ? 'মেসেজ দিন' : 'Chat now',
                    color: Colors.green,
                    onTap: controller.launchWhatsApp,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.facebook_rounded,
                    title: 'Facebook',
                    subtitle: settings.isBangla ? 'পেজে যান' : 'Visit page',
                    color: Colors.blue,
                    onTap: controller.launchFacebook,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.email_outlined,
                    title: settings.isBangla ? 'ইমেইল' : 'Email',
                    subtitle: settings.isBangla ? 'মেইল করুন' : 'Mail us',
                    color: Colors.orange,
                    onTap: controller.launchEmail,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Form Title
            Text(
              settings.isBangla
                  ? 'পরামর্শ বা অভিযোগ পাঠান'
                  : 'Send Feedback or Query',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            // Instructions
            Text(
              settings.isBangla
                  ? 'আপনার কোনো পরামর্শ, অভিযোগ বা কারিগরি সমস্যা থাকলে নিচের ফর্মটি পূরণ করে আমাদের জানান।'
                  : 'If you have any suggestions, complaints, or technical issues, please let us know by filling out the form below.',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Form
            Card(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: controller.nameController,
                      style: TextStyle(color: isDark ? AppColors.textWhite : AppColors.textDark),
                      decoration: InputDecoration(
                        labelText: settings.isBangla ? 'আপনার নাম' : 'Your Name',
                        labelStyle: const TextStyle(color: AppColors.textGrey),
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: controller.emailController,
                      style: TextStyle(color: isDark ? AppColors.textWhite : AppColors.textDark),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: settings.isBangla ? 'ইমেইল অ্যাড্রেস' : 'Email Address',
                        labelStyle: const TextStyle(color: AppColors.textGrey),
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message Field
                    TextFormField(
                      controller: controller.messageController,
                      style: TextStyle(color: isDark ? AppColors.textWhite : AppColors.textDark),
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: settings.isBangla ? 'আপনার বার্তা' : 'Your Message',
                        labelStyle: const TextStyle(color: AppColors.textGrey),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 80.0),
                          child: Icon(Icons.message_outlined, color: AppColors.textGrey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    Obx(() => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () => controller.submitTicket(settings.isBangla),
                          child: controller.isSubmitting.value
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark ? Colors.black : Colors.white,
                                  ),
                                )
                              : Text(settings.isBangla ? 'বার্তা পাঠান' : 'Send Message'),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
