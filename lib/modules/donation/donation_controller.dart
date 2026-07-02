import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationController extends GetxController {
  final RxString bkashNagad = '+880 13074 60389'.obs;
  final RxString bankName = 'Islami Bank Bangladesh Ltd'.obs;
  final RxString bankDetails = 'A/C No: 2050 356 67 00160203\nName: Qurania Project'.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDonationConfig();
  }

  Future<void> _loadDonationConfig() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('donation_config')
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          bkashNagad.value = data['bkashNagad'] ?? '+880 13074 60389';
          bankName.value = data['bankName'] ?? 'Islami Bank Bangladesh Ltd';
          bankDetails.value = data['bankDetails'] ?? 'A/C No: 2050 356 67 00160203\nName: Qurania Project';
        }
      }
    } catch (e) {
      Get.log('Error loading donation config: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
