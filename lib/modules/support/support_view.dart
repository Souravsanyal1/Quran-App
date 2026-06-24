import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'support_controller.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  InputDecoration _buildInputDecoration({
    required String label,
    required Widget prefixIcon,
    required bool isDark,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      prefixIcon: prefixIcon,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.chat_bubble_rounded,
                    title: 'WhatsApp',
                    subtitle: settings.isBangla ? 'মেসেজ দিন' : 'Chat now',
                    color: const Color(0xFF25D366),
                    onTap: controller.launchWhatsApp,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.facebook_rounded,
                    title: 'Facebook',
                    subtitle: settings.isBangla ? 'পেজে যান' : 'Visit page',
                    color: const Color(0xFF1877F2),
                    onTap: controller.launchFacebook,
                    isDark: isDark,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),
            const SizedBox(height: 32),

            // Form Title
            Text(
              settings.isBangla
                  ? 'পরামর্শ ও মতামত পাঠান'
                  : 'Send Feedback or Suggestions',
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
                  ? 'আপনার কোনো মতামত, পরামর্শ বা কারিগরি সমস্যা থাকলে নিচের ফর্মটি পূরণ করে আমাদের জানান।'
                  : 'If you have any suggestions or technical issues, please let us know by filling out the form below.',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Form
            Card(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: controller.nameController,
                      style: TextStyle(color: isDark ? AppColors.textWhite : AppColors.textDark),
                      decoration: _buildInputDecoration(
                        label: settings.isBangla ? 'আপনার নাম' : 'Your Name',
                        prefixIcon: const Icon(Icons.person_rounded, color: AppColors.textGrey),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Message Field
                    TextFormField(
                      controller: controller.messageController,
                      style: TextStyle(color: isDark ? AppColors.textWhite : AppColors.textDark),
                      maxLines: 5,
                      decoration: _buildInputDecoration(
                        label: settings.isBangla ? 'আপনার বার্তা' : 'Your Message',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 80.0),
                          child: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textGrey),
                        ),
                        isDark: isDark,
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            gradient: controller.isSubmitting.value
                                ? null
                                : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              if (!controller.isSubmitting.value)
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: controller.isSubmitting.value
                                ? null
                                : () => controller.submitTicket(settings.isBangla),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isSubmitting.value
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        settings.isBangla ? 'পাঠানো হচ্ছে...' : 'Sending...',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : Text(
                                    settings.isBangla ? 'বার্তা পাঠান' : 'Send Message',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        )),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
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
