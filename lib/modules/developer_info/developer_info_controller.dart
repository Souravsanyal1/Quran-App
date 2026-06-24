import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperInfoController extends GetxController {
  Future<void> launchURL(String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Could not open $urlString');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not launch link: $e');
    }
  }

  Future<void> launchEmail() async {
    final url = Uri.parse('mailto:joysanyal1999@gmail.com?subject=Quran%20App%20Feedback');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Could not open Email client');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not launch link: $e');
    }
  }
}
