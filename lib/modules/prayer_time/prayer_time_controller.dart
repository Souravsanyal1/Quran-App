import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Model ────────────────────────────────────────────────────────────────
class PrayerTime {
  final String nameEn;
  final String nameBn;
  final String arabicName;
  final TimeOfDay time;
  final IconData icon;

  PrayerTime({
    required this.nameEn,
    required this.nameBn,
    required this.arabicName,
    required this.time,
    required this.icon,
  });
}

// ── Controller ──────────────────────────────────────────────────────────
class PrayerTimeController extends GetxController {
  final RxBool isLoading = false.obs;
  final locationName = 'ঢাকা, বাংলাদেশ'.obs;
  final hijriDate = '১৫ মুহাররম, ১৪৪৮ হিজরি'.obs;
  final RxList<PrayerTime> prayers = <PrayerTime>[].obs;
  final Rx<Duration> countdown = Duration.zero.obs;
  final RxInt nextPrayerIndex = 0.obs;
  final RxInt activePrayerIndex = 0.obs;
  final RxString globalPrayerMessage = ''.obs;
  
  final RxDouble _latitude = 23.8103.obs;
  final RxDouble _longitude = 90.4125.obs;
  
  double get latitude => _latitude.value;
  double get longitude => _longitude.value;
  
  final RxMap<String, String> rawPrayerTimings = <String, String>{}.obs;
  final RxMap<String, String> prayerTimes = <String, String>{}.obs;
  
  Timer? _ticker;
  StreamSubscription? _prayerConfigSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocation();
    _loadTimes();
    _listenToPrayerConfig();
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void onClose() {
    _ticker?.cancel();
    _prayerConfigSubscription?.cancel();
    super.onClose();
  }

  void _listenToPrayerConfig() {
    try {
      _prayerConfigSubscription = FirebaseFirestore.instance
          .collection('app_settings')
          .doc('prayer_config')
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            globalPrayerMessage.value = data['globalMessage'] ?? '';
          }
        }
      });
    } catch (e) {
      Get.log('Error listening to prayer config: $e');
    }
  }

  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('custom_latitude');
      final lng = prefs.getDouble('custom_longitude');
      final name = prefs.getString('custom_location_name');
      if (lat != null && lng != null && name != null) {
        _latitude.value = lat;
        _longitude.value = lng;
        locationName.value = name;
      }
    } catch (_) {}
  }

  void _loadTimes() {
    prayers.value = [
      PrayerTime(nameEn: 'Fajr', nameBn: 'ফজর', arabicName: 'الفجر',
          time: const TimeOfDay(hour: 4, minute: 22), icon: Icons.nightlight_round),
      PrayerTime(nameEn: 'Sunrise', nameBn: 'সূর্যোদয়', arabicName: 'الشروق',
          time: const TimeOfDay(hour: 5, minute: 42), icon: Icons.wb_twilight),
      PrayerTime(nameEn: 'Dhuhr', nameBn: 'যোহর', arabicName: 'الظهر',
          time: const TimeOfDay(hour: 12, minute: 10), icon: Icons.wb_sunny_outlined),
      PrayerTime(nameEn: 'Asr', nameBn: 'আসর', arabicName: 'العصر',
          time: const TimeOfDay(hour: 16, minute: 0), icon: Icons.cloud_outlined),
      PrayerTime(nameEn: 'Maghrib', nameBn: 'মাগরিব', arabicName: 'المغرب',
          time: const TimeOfDay(hour: 18, minute: 12), icon: Icons.wb_twilight),
      PrayerTime(nameEn: 'Isha', nameBn: 'ইশা', arabicName: 'العشاء',
          time: const TimeOfDay(hour: 19, minute: 30), icon: Icons.dark_mode_outlined),
    ];
    rawPrayerTimings.value = {
      'Fajr': '04:22',
      'Dhuhr': '12:10',
      'Asr': '16:00',
      'Maghrib': '18:12',
      'Isha': '19:30',
    };
    prayerTimes.value = rawPrayerTimings;
  }

  Future<void> loadPrayerTimes() async {
    _loadTimes();
  }

  Future<void> updateLocation(double lat, double lng, String name) async {
    _latitude.value = lat;
    _longitude.value = lng;
    locationName.value = name;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('custom_latitude', lat);
      await prefs.setDouble('custom_longitude', lng);
      await prefs.setString('custom_location_name', name);
    } catch (_) {}
  }

  void _tick() {
    final now = DateTime.now();
    DateTime? nextDt;
    int nextIdx = -1;
    int activeIdx = prayers.length - 1;

    for (int i = 0; i < prayers.length; i++) {
      final p = prayers[i];
      final dt = DateTime(now.year, now.month, now.day, p.time.hour, p.time.minute);
      if (dt.isAfter(now) && nextDt == null) {
        nextDt = dt;
        nextIdx = i;
      }
    }

    for (int i = prayers.length - 1; i >= 0; i--) {
      final p = prayers[i];
      final dt = DateTime(now.year, now.month, now.day, p.time.hour, p.time.minute);
      if (!dt.isAfter(now)) {
        activeIdx = i;
        break;
      }
    }

    if (nextDt == null) {
      // Next prayer is tomorrow's Fajr
      final tomorrowFajr = prayers.first;
      nextDt = DateTime(now.year, now.month, now.day + 1, tomorrowFajr.time.hour, tomorrowFajr.time.minute);
      nextIdx = 0;
    }

    nextPrayerIndex.value = nextIdx;
    activePrayerIndex.value = activeIdx;
    countdown.value = nextDt.difference(now);
  }

  String formatTime(TimeOfDay t, bool bangla) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am
        ? (bangla ? 'পূর্বাহ্ণ' : 'AM')
        : (bangla ? 'অপরাহ্ণ' : 'PM');
    final hourStr = bangla ? _toBanglaDigits(h.toString()) : h.toString();
    final minStr = bangla ? _toBanglaDigits(m) : m;
    return '$hourStr:$minStr $period';
  }

  String _toBanglaDigits(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var out = input;
    for (int i = 0; i < en.length; i++) {
      out = out.replaceAll(en[i], bn[i]);
    }
    return out;
  }

  String formatCountdown(Duration d, bool bangla) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final text = '$h:$m:$s';
    return bangla ? _toBanglaDigits(text) : text;
  }
}
