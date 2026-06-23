import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  final RxBool isSubmitting = false.obs;

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
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.log('Error submitting support ticket: $e');
      Get.snackbar(
        isBangla ? 'ব্যর্থ হয়েছে' : 'Error',
        isBangla ? 'বার্তা পাঠাতে সমস্যা হয়েছে। পরে আবার চেষ্টা করুন।' : 'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
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
