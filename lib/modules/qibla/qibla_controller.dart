import 'package:get/get.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class QiblaController extends GetxController {
  final RxBool hasPermission = false.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    isLoading.value = true;
    try {
      final locationStatus = await FlutterQiblah.checkLocationStatus();
      if (locationStatus.enabled &&
          (locationStatus.status == LocationPermission.always ||
              locationStatus.status == LocationPermission.whileInUse)) {
        hasPermission.value = true;
      } else {
        final status = await Permission.location.request();
        hasPermission.value = status.isGranted;
      }
    } catch (e) {
      Get.log('Error checking Qibla permissions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestPermission() async {
    final status = await Permission.location.request();
    hasPermission.value = status.isGranted;
  }
}
