import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  final RxBool isSubmitting = false.obs;

  Future<void> launchWhatsApp() async {
    final url = Uri.parse('https://wa.me/8801700000000');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Could not open WhatsApp');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not launch link: $e');
    }
  }

  Future<void> launchFacebook() async {
    final url = Uri.parse('https://facebook.com/quranapp.official');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Could not open Facebook');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not launch link: $e');
    }
  }

  Future<void> launchEmail() async {
    final url = Uri.parse('mailto:support@quranapp.com?subject=Quran%20App%20Support');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Could not open Email client');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not launch link: $e');
    }
  }

  Future<void> submitTicket(bool isBangla) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final message = messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      Get.snackbar(
        isBangla ? 'ভুল ইনপুট' : 'Invalid Input',
        isBangla ? 'অনুগ্রহ করে সকল ঘর পূরণ করুন।' : 'Please fill all fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        isBangla ? 'ভুল ইমেইল' : 'Invalid Email',
        isBangla ? 'অনুগ্রহ করে সঠিক ইমেইল দিন।' : 'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      await FirebaseFirestore.instance.collection('support_tickets').add({
        'name': name,
        'email': email,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });

      nameController.clear();
      emailController.clear();
      messageController.clear();

      Get.snackbar(
        isBangla ? 'সফল হয়েছে' : 'Success',
        isBangla ? 'আপনার বার্তা সফলভাবে পাঠানো হয়েছে!' : 'Your message has been sent successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.log('Error submitting support ticket: $e');
      Get.snackbar(
        isBangla ? 'ব্যর্থ হয়েছে' : 'Error',
        isBangla ? 'বার্তা পাঠাতে সমস্যা হয়েছে। পরে আবার চেষ্টা করুন।' : 'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
