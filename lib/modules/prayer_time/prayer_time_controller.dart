import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/providers/quran_api_provider.dart';
import '../../services/notification_service.dart';
import '../settings/settings_controller.dart';

class PrayerTimeController extends GetxController {
  final QuranApiProvider _api = Get.find<QuranApiProvider>();

  static const String _keyLat = 'custom_latitude';
  static const String _keyLng = 'custom_longitude';
  static const String _keyLocName = 'custom_location_name';
  static const String _keyIsManual = 'is_manual_location';
  static const String _keyCalcMethod = 'prayer_calc_method';

  static const Map<int, String> calculationMethods = {
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America (ISNA)',
    3: 'Muslim World League (MWL)',
    4: 'Umm Al-Qura University, Makkah',
    5: 'Egyptian General Authority of Survey',
    15: 'Moonsighting Committee Worldwide',
  };

  static const Map<int, String> calculationMethodsBn = {
    1: 'ইসলামিক বিজ্ঞান বিশ্ববিদ্যালয়, করাচি',
    2: 'ইসলামিক সোসাইটি অফ উত্তর আমেরিকা',
    3: 'মুসলিম ওয়ার্ল্ড লীগ (MWL)',
    4: 'উম্মুল কুরা বিশ্ববিদ্যালয়, মক্কা',
    5: 'মিশরীয় জরিপ কর্তৃপক্ষ',
    15: 'মুুনসাইটিং কমিটি ওয়ার্ল্ডওয়াইড',
  };

  final RxBool isLoading = true.obs;
  final RxString locationName = 'Dhaka, Bangladesh'.obs;
  final RxMap<String, String> prayerTimes = <String, String>{}.obs;
  final RxString nextPrayerName = ''.obs;
  final RxString nextPrayerTimeRemaining = ''.obs;

  final RxDouble customLatitude = 23.8103.obs;
  final RxDouble customLongitude = 90.4125.obs;
  final RxBool isManualLocation = false.obs;
  final RxInt calculationMethod = 2.obs;
  final RxMap<String, bool> azanNotifications = <String, bool>{
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  }.obs;

  Timer? _countdownTimer;
  double _latitude = 23.8103; // Default Dhaka
  double _longitude = 90.4125; // Default Dhaka

  @override
  void onInit() {
    super.onInit();
    _fetchLocationAndPrayerTimes();
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final city = pm.locality ?? pm.subAdministrativeArea ?? pm.administrativeArea ?? '';
        final country = pm.country ?? '';
        if (city.isNotEmpty) {
          return '$city, $country';
        } else if (pm.name != null) {
          return '${pm.name}, $country';
        }
      }
    } catch (e) {
      Get.log('Reverse geocoding failed: $e');
    }
    return 'Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  Future<void> _fetchLocationAndPrayerTimes() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load saved settings
      isManualLocation.value = prefs.getBool(_keyIsManual) ?? false;
      customLatitude.value = prefs.getDouble(_keyLat) ?? 23.8103;
      customLongitude.value = prefs.getDouble(_keyLng) ?? 90.4125;
      locationName.value = prefs.getString(_keyLocName) ?? 'Dhaka, Bangladesh';
      calculationMethod.value = prefs.getInt(_keyCalcMethod) ?? 2;

      // Load individual notification settings
      for (var k in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        azanNotifications[k] = prefs.getBool('azan_notification_$k') ?? true;
      }

      if (isManualLocation.value) {
        _latitude = customLatitude.value;
        _longitude = customLongitude.value;
      } else {
        // Try auto GPS location
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
            final position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 5),
              ),
            );
            _latitude = position.latitude;
            _longitude = position.longitude;
            customLatitude.value = position.latitude;
            customLongitude.value = position.longitude;
            
            // Try to reverse geocode city name
            final address = await _getAddressFromLatLng(_latitude, _longitude);
            locationName.value = address;
          }
        }
      }
    } catch (e) {
      Get.log('Error setting up location: $e');
    }

    await loadPrayerTimes();
  }

  Future<void> updateLocation(double lat, double lng, String name) async {
    isLoading.value = true;
    _latitude = lat;
    _longitude = lng;
    customLatitude.value = lat;
    customLongitude.value = lng;
    locationName.value = name;
    isManualLocation.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsManual, true);
      await prefs.setDouble(_keyLat, lat);
      await prefs.setDouble(_keyLng, lng);
      await prefs.setString(_keyLocName, name);
    } catch (e) {
      Get.log('Error saving custom location: $e');
    }

    await loadPrayerTimes();
  }

  Future<void> resetToGPS() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsManual, false);
    isManualLocation.value = false;
    await _fetchLocationAndPrayerTimes();
  }

  Future<void> setCalculationMethod(int methodId) async {
    calculationMethod.value = methodId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCalcMethod, methodId);
    } catch (e) {
      Get.log('Error saving calculation method: $e');
    }
    isLoading.value = true;
    await loadPrayerTimes();
  }

  Future<void> toggleAzanNotification(String prayerKey) async {
    final current = azanNotifications[prayerKey] ?? true;
    final updated = !current;
    azanNotifications[prayerKey] = updated;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('azan_notification_$prayerKey', updated);
      
      // Force reload to update scheduled notifications
      await loadPrayerTimes();
    } catch (e) {
      Get.log('Error toggling prayer notification: $e');
    }
  }

  double get latitude => _latitude;
  double get longitude => _longitude;

  Future<void> loadPrayerTimes() async {
    try {
      final now = DateTime.now();
      final formatter = DateFormat('dd-MM-yyyy');
      final dateStr = formatter.format(now);

      final response = await _api.fetchPrayerTimes(
        latitude: _latitude,
        longitude: _longitude,
        date: dateStr,
        method: calculationMethod.value,
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['timings'] as Map<String, dynamic>;
        
        // Pick only primary timings
        prayerTimes.assignAll({
          'Fajr': _formatTime12h(data['Fajr']),
          'Sunrise': _formatTime12h(data['Sunrise']),
          'Dhuhr': _formatTime12h(data['Dhuhr']),
          'Asr': _formatTime12h(data['Asr']),
          'Maghrib': _formatTime12h(data['Maghrib']),
          'Isha': _formatTime12h(data['Isha']),
        });

        _startCountdown(data);

        // Schedule Azan notifications if enabled
        try {
          final settings = Get.find<SettingsController>();
          if (settings.azanEnabled.value) {
            await NotificationService.instance.scheduleAzanNotifications(data);
          }
        } catch (e) {
          Get.log('Error scheduling azan notifications: $e');
        }
      }
    } catch (e) {
      Get.log('Error fetching prayer times: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _formatTime12h(String time24) {
    try {
      final cleanTime = time24.split(' ')[0]; // remove time zone e.g. "05:15 (+06)"
      final date = DateFormat('HH:mm').parse(cleanTime);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return time24;
    }
  }

  void _startCountdown(Map<String, dynamic> timings) {
    _countdownTimer?.cancel();

    final now = DateTime.now();
    final List<MapEntry<String, DateTime>> list = [];
    final keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (var k in keys) {
      final cleanTime = timings[k].toString().split(' ')[0];
      final timeParts = cleanTime.split(':');
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      list.add(MapEntry(k, dt));
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      
      // Find next prayer
      MapEntry<String, DateTime>? next;
      for (var entry in list) {
        if (entry.value.isAfter(currentTime)) {
          next = entry;
          break;
        }
      }

      next ??= MapEntry(
        'Fajr',
        list.first.value.add(const Duration(days: 1)),
      );

      nextPrayerName.value = next.key;
      final diff = next.value.difference(currentTime);
      
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
      
      nextPrayerTimeRemaining.value = '$hours:$minutes:$seconds';
    });
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}
