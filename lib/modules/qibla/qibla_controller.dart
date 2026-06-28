import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';

class QiblaController extends GetxController {
  final Rx<QiblahDirection?> direction = Rx<QiblahDirection?>(null);
  final RxDouble qiblaAngle = 0.0.obs;
  final RxDouble compassAngle = 0.0.obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  
  final RxBool hasPermission = false.obs;
  final RxBool isLocationEnabled = false.obs;
  final RxDouble manualQiblaBearing = 0.0.obs;
  final RxDouble distanceToKaaba = 0.0.obs;

  StreamSubscription<QiblahDirection>? _subscription;
  bool _lastVibrationState = false;

  @override
  void onInit() {
    super.onInit();
    _initQibla();
  }

  Future<void> _initQibla() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      isLocationEnabled.value = serviceEnabled;
      if (!serviceEnabled) {
        isLoading.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          hasPermission.value = false;
          isLoading.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        hasPermission.value = false;
        isLoading.value = false;
        return;
      }

      hasPermission.value = true;

      final bool? hasSensor = await FlutterQiblah.androidDeviceSensorSupport();
      if (hasSensor == false) {
        errorMessage.value = 'No sensor';
        isLoading.value = false;
        return;
      }

      final Position position = await Geolocator.getCurrentPosition();
      manualQiblaBearing.value = calculateQibla(position.latitude, position.longitude);
      distanceToKaaba.value = Geolocator.distanceBetween(position.latitude, position.longitude, 21.422487, 39.826206) / 1000;

      _subscription = FlutterQiblah.qiblahStream.listen((data) {
        direction.value = data;
        compassAngle.value = data.direction;
        qiblaAngle.value = data.qiblah;
        isLoading.value = false;
      }, onError: (err) {
        isLoading.value = false;
      });

    } catch (e) {
      isLoading.value = false;
    }
  }

  void handleAlignmentVibration(bool isAligned) {
    if (isAligned && !_lastVibrationState) {
      Vibration.vibrate(duration: 100);
    }
    _lastVibrationState = isAligned;
  }

  Future<void> requestPermission() async {
    if (!isLocationEnabled.value) {
      await Geolocator.openLocationSettings();
    } else {
      final permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
        _initQibla();
      }
    }
  }

  double calculateQibla(double lat, double lon) {
    const double kLat = 21.422487;
    const double kLon = 39.826206;
    double latRad = lat * math.pi / 180;
    double lonRad = lon * math.pi / 180;
    double kLatRad = kLat * math.pi / 180;
    double kLonRad = kLon * math.pi / 180;
    double y = math.sin(kLonRad - lonRad);
    double x = math.cos(latRad) * math.tan(kLatRad) - math.sin(latRad) * math.cos(kLonRad - lonRad);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
