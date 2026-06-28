import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';

class QiblaController extends GetxController {
  final Rx<QiblahDirection?> direction = Rx<QiblahDirection?>(null);
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  
  final RxBool hasPermission = false.obs;
  final RxBool isLocationEnabled = false.obs;
  final RxDouble distanceToKaaba = 0.0.obs;
  final RxString currentAddress = 'Locating...'.obs;
  final RxString latLong = '...'.obs;

  StreamSubscription<QiblahDirection>? _subscription;
  bool _lastVibrationState = false;

  @override
  void onInit() {
    super.onInit();
    _checkStatusAndInit();
  }

  Future<void> _checkStatusAndInit() async {
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

      hasPermission.value = true;

      final bool? hasSensor = await FlutterQiblah.androidDeviceSensorSupport();
      if (hasSensor == false) {
        errorMessage.value = 'কম্পাস সেন্সর পাওয়া যায়নি';
        isLoading.value = false;
        return;
      }

      final Position position = await Geolocator.getCurrentPosition();
      latLong.value = '${position.latitude.toStringAsFixed(4)}° N, ${position.longitude.toStringAsFixed(4)}° E';
      
      _getAddressFromLatLng(position.latitude, position.longitude);
      
      distanceToKaaba.value = Geolocator.distanceBetween(
        position.latitude, position.longitude, 21.422487, 39.826206
      ) / 1000;

      _startQiblaStream();

    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'zoom': 10,
          'addressdetails': 1,
        },
      );
      if (response.statusCode == 200) {
        final address = response.data['address'];
        final city = address['city'] ?? address['town'] ?? address['state'] ?? 'Unknown';
        final country = address['country'] ?? '';
        currentAddress.value = '$city, $country';
      }
    } catch (e) {
      currentAddress.value = 'Locally Detected';
    }
  }

  void _startQiblaStream() {
    _subscription?.cancel();
    _subscription = FlutterQiblah.qiblahStream.listen((data) {
      direction.value = data;
      if (isLoading.value) isLoading.value = false;
    });
  }

  void handleAlignmentVibration(bool isAligned) {
    if (isAligned && !_lastVibrationState) {
      Vibration.hasVibrator().then((has) {
        if (has == true) Vibration.vibrate(duration: 50);
      });
    }
    _lastVibrationState = isAligned;
  }

  Future<void> requestPermission() async => _checkStatusAndInit();

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
