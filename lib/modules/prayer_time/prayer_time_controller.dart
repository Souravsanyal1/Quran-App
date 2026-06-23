import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../data/providers/quran_api_provider.dart';

class PrayerTimeController extends GetxController {
  final QuranApiProvider _api = Get.find<QuranApiProvider>();

  final RxBool isLoading = true.obs;
  final RxString locationName = 'Dhaka, Bangladesh'.obs;
  final RxMap<String, String> prayerTimes = <String, String>{}.obs;
  final RxString nextPrayerName = ''.obs;
  final RxString nextPrayerTimeRemaining = ''.obs;

  Timer? _countdownTimer;
  double _latitude = 23.8103; // Default Dhaka
  double _longitude = 90.4125; // Default Dhaka

  @override
  void onInit() {
    super.onInit();
    _fetchLocationAndPrayerTimes();
  }

  Future<void> _fetchLocationAndPrayerTimes() async {
    isLoading.value = true;
    try {
      // Check location permissions
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          );
          _latitude = position.latitude;
          _longitude = position.longitude;
          locationName.value = 'Current Location';
        }
      }
    } catch (e) {
      Get.log('Error getting location: $e');
    }

    await loadPrayerTimes();
  }

  Future<void> loadPrayerTimes() async {
    try {
      final now = DateTime.now();
      final formatter = DateFormat('dd-MM-yyyy');
      final dateStr = formatter.format(now);

      final response = await _api.fetchPrayerTimes(
        latitude: _latitude,
        longitude: _longitude,
        date: dateStr,
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

      if (next == null) {
        next = MapEntry(
          'Fajr',
          list.first.value.add(const Duration(days: 1)),
        );
      }

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
