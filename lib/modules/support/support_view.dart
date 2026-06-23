import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
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
        title: Text(settings.isBangla ? 'সহযোগিতা ও সাপোর্ট' : 'Support & Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Text(
              settings.isBangla
                  ? 'আপনার কোনো পরামর্শ, অভিযোগ বা কারিগরি সমস্যা থাকলে নিচের ফর্মটি পূরণ করে আমাদের জানান।'
                  : 'If you have any suggestions, complaints, or technical issues, please let us know by filling out the form below.',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),

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
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
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
