import 'package:get/get.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';
import 'dart:math' as math;

class QiblaController extends GetxController {
  final RxBool hasPermission = false.obs;
  final RxBool isLocationEnabled = true.obs;
  final RxBool isLoading = true.obs;
  final Rxn<Position> userPosition = Rxn<Position>();
  final RxDouble distanceToKaaba = 0.0.obs;
  final RxDouble manualQiblaBearing = 0.0.obs;
  
  bool _lastIsAligned = false;

  // Mecca Coordinates
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
  }

  void handleAlignmentVibration(bool isAligned) {
    if (isAligned && !_lastIsAligned) {
      Vibration.vibrate(duration: 100, amplitude: 128);
    }
    _lastIsAligned = isAligned;
  }

  double calculateManualBearing(double lat, double lng) {
    final dLon = (kaabaLng - lng) * math.pi / 180;
    final lat1 = lat * math.pi / 180;
    final lat2 = kaabaLat * math.pi / 180;

    final y = math.sin(dLon);
    final x = math.cos(lat1) * math.tan(lat2) -
        math.sin(lat1) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    bearing = bearing * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  Future<void> _checkPermissions() async {
    isLoading.value = true;
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      isLocationEnabled.value = enabled;
      
      if (!enabled) {
        hasPermission.value = false;
        isLoading.value = false;
        return;
      }

      var status = await Permission.location.status;
      if (status.isDenied) {
        status = await Permission.location.request();
      }

      if (status.isGranted) {
        hasPermission.value = true;
        await _getUserLocation();
      } else {
        hasPermission.value = false;
      }
    } catch (e) {
      Get.log('Error checking Qibla permissions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestPermission() async {
    if (!isLocationEnabled.value) {
      await Geolocator.openLocationSettings();
      _checkPermissions();
      return;
    }

    isLoading.value = true;
    final status = await Permission.location.request();
    hasPermission.value = status.isGranted;
    if (hasPermission.value) {
      await _getUserLocation();
    }
    isLoading.value = false;
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userPosition.value = position;
      
      // Calculate distance
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        kaabaLat,
        kaabaLng,
      );
      distanceToKaaba.value = distance / 1000;

      // Calculate manual bearing for verification
      manualQiblaBearing.value = calculateManualBearing(
        position.latitude,
        position.longitude,
      );

    } catch (e) {
      Get.log('Error getting user location: $e');
    }
  }
}
