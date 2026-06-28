import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../settings/settings_controller.dart';
import 'support_controller.dart';

class SupportFormView extends GetView<SupportController> {
  const SupportFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isBn = Get.find<SettingsController>().isBangla;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isBn ? 'নতুন চ্যাট' : 'New Chat', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.forum_rounded, size: 48, color: AppColors.primary),
                  ).animate().scale(),
                  const SizedBox(height: 24),
                  Text(
                    isBn ? 'কিভাবে সাহায্য করতে পারি?' : 'Start a conversation',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isBn 
                      ? 'নিচে আপনার সমস্যাটি লিখুন এবং আমাদের টিম দ্রুত আপনার সাথে যোগাযোগ করবে।' 
                      : 'Please describe your issue below and our team will get back to you shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), height: 1.5),
                  ),
                  const SizedBox(height: 48),
                  
                  // Message Starter Bubble
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'বিষয় (ঐচ্ছিক)' : 'Subject (Optional)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        TextField(
                          controller: controller.subjectController,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: isBn ? 'যেমন: লগইন সমস্যা' : 'e.g., Recitation error',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 8),
                        Text(
                          isBn ? 'আপনার বার্তা' : 'Your Message',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        TextField(
                          controller: controller.descriptionController,
                          maxLines: 5,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: isBn ? 'এখানে লিখুন...' : 'Type details here...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
          
          // Submit Section (Messenger style footer)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.createTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(isBn ? 'মেসেজ পাঠান' : 'Send Message', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
