import 'dart:async';
import 'package:adhan/adhan.dart' as adhan;
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../services/notification_service.dart';
import '../settings/settings_controller.dart';

class PrayerTimeController extends GetxController {
  static const String _keyLat = 'custom_latitude';
  static const String _keyLng = 'custom_longitude';
  static const String _keyLocName = 'custom_location_name';
  static const String _keyIsManual = 'is_manual_location';
  static const String _keyCalcMethod = 'prayer_calc_method';
  static const String _keyAsrSchool = 'prayer_asr_school';

  // ── Calculation methods (maps to adhan package) ────────────────────────
  static const Map<int, String> calculationMethods = {
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America (ISNA)',
    3: 'Muslim World League (MWL)',
    4: 'Umm Al-Qura University, Makkah',
    5: 'Egyptian General Authority of Survey',
    15: 'Moonsighting Committee Worldwide',
  };

  static const Map<int, String> calculationMethodsBn = {
    1: 'ইসলামিক বিজ্ঞান বিশ্ববিদ্যালয়, করাচি',
    2: 'ইসলামিক সোসাইটি অফ উত্তর আমেরিকা',
    3: 'মুসলিম ওয়ার্ল্ড লীগ (MWL)',
    4: 'উম্মুল কুরা বিশ্ববিদ্যালয়, মক্কা',
    5: 'মিশরীয় জরিপ কর্তৃপক্ষ',
    15: 'মুুনসাইটিং কমিটি ওয়ার্ল্ডওয়াইড',
  };

  final RxBool isLoading = true.obs;
  final RxString locationName = 'Dhaka, Bangladesh'.obs;
  final RxMap<String, String> prayerTimes = <String, String>{}.obs;
  final RxString nextPrayerName = ''.obs;
  final RxMap<String, String> rawPrayerTimings = <String, String>{}.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Sunrise & Sunset
  final RxString sunriseTimeStr = '05:11 AM'.obs;
  final RxString sunsetTimeStr = '06:50 PM'.obs;
  final RxString makruhTimeStr = ''.obs;

  // Arc & Semicircle period
  final RxDouble periodProgress = 0.0.obs;
  final RxDouble dayNightProgress = 0.0.obs; // Global progress for Sun/Moon
  final RxBool isDayTime = true.obs;         // Whether it's currently day
  final RxString periodName = ''.obs;
  final RxString periodTimeRemaining = '00:00:00'.obs;
  final RxString hijriDateStr = ''.obs;
  final RxBool isPeriodActive = true.obs;

  final RxDouble customLatitude = 23.8103.obs;
  final RxDouble customLongitude = 90.4125.obs;
  final RxBool isManualLocation = false.obs;
  final RxInt calculationMethod = 1.obs;
  final RxInt asrSchool = 1.obs;
  final RxMap<String, bool> azanNotifications = <String, bool>{
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  }.obs;

  Timer? _countdownTimer;
  Timer? _dailyRefreshTimer;
  double _latitude = 23.8103;
  double _longitude = 90.4125;

  // Holds today's computed prayer times (DateTime)
  adhan.PrayerTimes? _todayPrayerTimes;
  // Holds tomorrow's prayer times for overnight Isha→Fajr span
  adhan.PrayerTimes? _tomorrowPrayerTimes;

  @override
  void onInit() {
    super.onInit();
    _fetchLocationAndPrayerTimes();
    _scheduleMidnightRefresh();
  }

  // ── Midnight auto-refresh so times update at 00:00 without restart ──────
  void _scheduleMidnightRefresh() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final untilMidnight = nextMidnight.difference(now);

    _dailyRefreshTimer?.cancel();
    _dailyRefreshTimer = Timer(untilMidnight, () {
      loadPrayerTimes();
      _scheduleMidnightRefresh(); // reschedule for the next midnight
    });
  }

  // ── Address helper ───────────────────────────────────────────────────────
  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<geo.Placemark> placemarks =
          await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final city = pm.locality ??
            pm.subAdministrativeArea ??
            pm.administrativeArea ??
            '';
        final country = pm.country ?? '';
        if (city.isNotEmpty) return '$city, $country';
        if (pm.name != null) return '${pm.name}, $country';
      }
    } catch (e) {
      Get.log('Reverse geocoding failed: $e');
    }
    return 'Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  // ── Main startup: detect location → compute prayer times ────────────────
  Future<void> _fetchLocationAndPrayerTimes() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved settings
      isManualLocation.value = prefs.getBool(_keyIsManual) ?? false;
      customLatitude.value = prefs.getDouble(_keyLat) ?? 23.8103;
      customLongitude.value = prefs.getDouble(_keyLng) ?? 90.4125;
      locationName.value = prefs.getString(_keyLocName) ?? 'Dhaka, Bangladesh';

      _latitude = customLatitude.value;
      _longitude = customLongitude.value;

      calculationMethod.value = prefs.getInt(_keyCalcMethod) ?? 1;
      asrSchool.value = prefs.getInt(_keyAsrSchool) ?? 1;

      // Load notification toggles
      for (var k in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        azanNotifications[k] = prefs.getBool('azan_notification_$k') ?? true;
      }

      if (!isManualLocation.value) {
        bool gpsSuccess = false;
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            try {
              final position = await Geolocator.getCurrentPosition(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.low,
                  timeLimit: Duration(seconds: 5),
                ),
              );
              _latitude = position.latitude;
              _longitude = position.longitude;
              customLatitude.value = _latitude;
              customLongitude.value = _longitude;

              final address =
                  await _getAddressFromLatLng(_latitude, _longitude);
              locationName.value = address;
              gpsSuccess = true;

              await prefs.setDouble(_keyLat, _latitude);
              await prefs.setDouble(_keyLng, _longitude);
              await prefs.setString(_keyLocName, address);
            } catch (e) {
              Get.log('GPS fetch failed or timed out: $e');
            }
          }
        }

        // IP fallback when GPS unavailable and nothing cached
        if (!gpsSuccess && !prefs.containsKey(_keyLat)) {
          try {
            final dio = Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
            ));
            final response = await dio.get('http://ip-api.com/json/');
            if (response.statusCode == 200 &&
                response.data != null &&
                response.data['status'] == 'success') {
              final double lat = (response.data['lat'] ?? 23.8103).toDouble();
              final double lng = (response.data['lon'] ?? 90.4125).toDouble();
              final String city = response.data['city'] ?? 'Dhaka';
              final String country = response.data['country'] ?? 'Bangladesh';
              final String address = '$city, $country';

              _latitude = lat;
              _longitude = lng;
              customLatitude.value = lat;
              customLongitude.value = lng;
              locationName.value = address;

              await prefs.setDouble(_keyLat, lat);
              await prefs.setDouble(_keyLng, lng);
              await prefs.setString(_keyLocName, address);
              Get.log('IP Location fallback: $address ($lat, $lng)');
            }
          } catch (e) {
            Get.log('IP Location fallback failed: $e');
          }
        }
      }
    } catch (e) {
      Get.log('Error setting up location: $e');
    }

    await loadPrayerTimes();
  }

  // ── Build adhan CalculationParameters from saved method/school ──────────
  adhan.CalculationParameters _buildParams() {
    adhan.CalculationParameters params;

    switch (calculationMethod.value) {
      case 1:
        params = adhan.CalculationMethod.karachi.getParameters();
        break;
      case 2:
        params = adhan.CalculationMethod.north_america.getParameters();
        break;
      case 3:
        params = adhan.CalculationMethod.muslim_world_league.getParameters();
        break;
      case 4:
        params = adhan.CalculationMethod.umm_al_qura.getParameters();
        break;
      case 5:
        params = adhan.CalculationMethod.egyptian.getParameters();
        break;
      case 15:
        params = adhan.CalculationMethod.moon_sighting_committee.getParameters();
        break;
      default:
        params = adhan.CalculationMethod.karachi.getParameters();
    }

    // 0 = Shafi, 1 = Hanafi
    params.madhab = asrSchool.value == 1
        ? adhan.Madhab.hanafi
        : adhan.Madhab.shafi;

    return params;
  }

  // ── Core: compute prayer times locally using adhan package ───────────────
  Future<void> loadPrayerTimes() async {
    try {
      final coords =
          adhan.Coordinates(_latitude, _longitude);
      final params = _buildParams();

      final now = DateTime.now();
      final todayComponents = adhan.DateComponents.from(now);
      final tomorrowComponents =
          adhan.DateComponents.from(now.add(const Duration(days: 1)));

      _todayPrayerTimes =
          adhan.PrayerTimes(coords, todayComponents, params);
      _tomorrowPrayerTimes =
          adhan.PrayerTimes(coords, tomorrowComponents, params);

      // Compute display times for the selected date
      final date = selectedDate.value;
      final selComponents = adhan.DateComponents.from(date);
      final selPrayerTimes = adhan.PrayerTimes(coords, selComponents, params);

      // 12h formatted display strings for the selected date
      prayerTimes.assignAll({
        'Fajr': _fmt12h(selPrayerTimes.fajr),
        'Dhuhr': _fmt12h(selPrayerTimes.dhuhr),
        'Asr': _fmt12h(selPrayerTimes.asr),
        'Maghrib': _fmt12h(selPrayerTimes.maghrib),
        'Isha': _fmt12h(selPrayerTimes.isha),
      });

      // 24h raw strings for notification scheduler (always based on current date)
      final pt = _todayPrayerTimes!;
      rawPrayerTimings.assignAll({
        'Fajr': _fmt24h(pt.fajr),
        'Sunrise': _fmt24h(pt.sunrise),
        'Dhuhr': _fmt24h(pt.dhuhr),
        'Asr': _fmt24h(pt.asr),
        'Maghrib': _fmt24h(pt.maghrib),
        'Isha': _fmt24h(pt.isha),
      });

      sunriseTimeStr.value = _fmt12h(selPrayerTimes.sunrise);
      sunsetTimeStr.value = _fmt12h(selPrayerTimes.maghrib);

      // Hijri date based on the selected date
      hijriDateStr.value = _computeHijriDate(date);

      // Start real-time countdown (always uses _todayPrayerTimes / actual current date)
      _startCountdown();

      // Schedule Azan notifications for next 7 days
      try {
        final settings = Get.find<SettingsController>();
        if (settings.azanEnabled.value &&
            NotificationService.instance.isInitialized) {
          final weeklyTimings = _buildWeeklyTimings(coords, params, now);
          await NotificationService.instance
              .scheduleWeeklyAzanNotifications(weeklyTimings);
        } else if (!NotificationService.instance.isInitialized) {
          Get.log(
              '[PrayerTime] NotificationService not ready — splash will reschedule.');
        }
      } catch (e) {
        Get.log('Error scheduling azan notifications: $e');
      }
    } catch (e) {
      Get.log('Error loading prayer times: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    loadPrayerTimes();
  }

  // ── Build 7-day timings list for notification scheduler ─────────────────
  List<Map<String, dynamic>> _buildWeeklyTimings(
      adhan.Coordinates coords,
      adhan.CalculationParameters params,
      DateTime baseDate) {
    final List<Map<String, dynamic>> result = [];
    for (int i = 0; i < 7; i++) {
      final day = baseDate.add(Duration(days: i));
      final dayComp = adhan.DateComponents.from(day);
      final pt = adhan.PrayerTimes(coords, dayComp, params);
      result.add({
        'date': day,
        'timings': {
          'Fajr': _fmt24h(pt.fajr),
          'Sunrise': _fmt24h(pt.sunrise),
          'Dhuhr': _fmt24h(pt.dhuhr),
          'Asr': _fmt24h(pt.asr),
          'Maghrib': _fmt24h(pt.maghrib),
          'Isha': _fmt24h(pt.isha),
        },
      });
    }
    return result;
  }

  // ── Countdown timer ──────────────────────────────────────────────────────
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick(); // immediate first tick
  }

  void _tick() {
    final pt = _todayPrayerTimes;
    final ptTomorrow = _tomorrowPrayerTimes;
    if (pt == null) return;

    final now = DateTime.now();

    final fajr = pt.fajr.toLocal();
    final sunrise = pt.sunrise.toLocal();
    final dhuhr = pt.dhuhr.toLocal();
    final asr = pt.asr.toLocal();
    final maghrib = pt.maghrib.toLocal();
    final isha = pt.isha.toLocal();
    final nextFajr = ptTomorrow?.fajr.toLocal() ??
        fajr.add(const Duration(days: 1));

    DateTime periodStart;
    DateTime periodEnd;
    String nameEn;
    String nameBn;
    bool isActive;

    if (now.isAfter(fajr) && now.isBefore(sunrise)) {
      periodStart = fajr;
      periodEnd = sunrise;
      nameEn = 'Fajr';
      nameBn = 'ফজর';
      isActive = true;
    } else if (now.isAfter(sunrise) && now.isBefore(dhuhr)) {
      periodStart = sunrise;
      periodEnd = dhuhr;
      nameEn = 'Dhuhr (Upcoming)';
      nameBn = 'যোহর (আসন্ন)';
      isActive = false;
    } else if (now.isAfter(dhuhr) && now.isBefore(asr)) {
      periodStart = dhuhr;
      periodEnd = asr;
      nameEn = 'Dhuhr';
      nameBn = 'যোহর';
      isActive = true;
    } else if (now.isAfter(asr) && now.isBefore(maghrib)) {
      periodStart = asr;
      periodEnd = maghrib;
      nameEn = 'Asr';
      nameBn = 'আসর';
      isActive = true;
    } else if (now.isAfter(maghrib) && now.isBefore(isha)) {
      periodStart = maghrib;
      periodEnd = isha;
      nameEn = 'Maghrib';
      nameBn = 'মাগরিব';
      isActive = true;
    } else {
      // Isha period → next Fajr
      if (now.isAfter(isha)) {
        periodStart = isha;
        periodEnd = nextFajr;
      } else {
        // Before Fajr: previous Isha → today Fajr
        periodStart = isha.subtract(const Duration(days: 1));
        periodEnd = fajr;
      }
      nameEn = 'Isha';
      nameBn = 'ইশা';
      isActive = true;
    }

    final settings = Get.find<SettingsController>();
    periodName.value = settings.isBangla ? nameBn : nameEn;
    isPeriodActive.value = isActive;

    // Next prayer highlight
    if (nameEn == 'Fajr') {
      nextPrayerName.value = 'Sunrise';
    } else if (nameEn == 'Dhuhr (Upcoming)') {
      nextPrayerName.value = 'Dhuhr';
    } else if (nameEn == 'Dhuhr') {
      nextPrayerName.value = 'Asr';
    } else if (nameEn == 'Asr') {
      nextPrayerName.value = 'Maghrib';
    } else if (nameEn == 'Maghrib') {
      nextPrayerName.value = 'Isha';
    } else {
      nextPrayerName.value = 'Fajr';
    }

    // Progress
    final totalSec = periodEnd.difference(periodStart).inSeconds;
    final passedSec = now.difference(periodStart).inSeconds;
    periodProgress.value =
        (totalSec > 0 ? passedSec / totalSec : 0.0).clamp(0.0, 1.0);

    // Countdown string
    final remaining = periodEnd.difference(now);
    final h = remaining.inHours.toString().padLeft(2, '0');
    final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    final countdown = '$h:$m:$s';
    periodTimeRemaining.value =
        settings.isBangla ? _toBanglaDigits(countdown) : countdown;

    // Calculate Day/Night progress for Sun/Moon Animation
    if (now.isAfter(sunrise) && now.isBefore(maghrib)) {
      // Day time: Sunrise to Sunset
      isDayTime.value = true;
      final totalDaySec = maghrib.difference(sunrise).inSeconds;
      final passedDaySec = now.difference(sunrise).inSeconds;
      dayNightProgress.value = (passedDaySec / totalDaySec).clamp(0.0, 1.0);
    } else {
      // Night time: Sunset to next Sunrise
      isDayTime.value = false;
      DateTime nightStart;
      DateTime nightEnd;

      if (now.isAfter(maghrib)) {
        // Between Sunset and Midnight
        nightStart = maghrib;
        nightEnd = ptTomorrow?.sunrise.toLocal() ?? sunrise.add(const Duration(days: 1));
      } else {
        // Between Midnight and Sunrise
        nightStart = isha.subtract(const Duration(days: 1)); // Approximate start of previous night
        nightEnd = sunrise;
      }
      
      final totalNightSec = nightEnd.difference(nightStart).inSeconds;
      final passedNightSec = now.difference(nightStart).inSeconds;
      dayNightProgress.value = (passedNightSec / totalNightSec).clamp(0.0, 1.0);
    }

    // Makruh banners
    final fmt = DateFormat('hh:mm a');
    final ishraqStart = sunrise.add(const Duration(minutes: 15));
    final zawalStart = dhuhr.subtract(const Duration(minutes: 15));
    final makruhAsrStart = maghrib.subtract(const Duration(minutes: 15));
    final sunriseMakruh =
        '${fmt.format(sunrise)} - ${fmt.format(ishraqStart)}';
    final zawalRange =
        '${fmt.format(zawalStart)} - ${fmt.format(dhuhr)}';
    final sunsetMakruh =
        '${fmt.format(makruhAsrStart)} - ${fmt.format(maghrib)}';
    final makruhEn =
        'Makruh times: Sunrise ($sunriseMakruh), Midday ($zawalRange), Sunset ($sunsetMakruh)';
    final makruhBn =
        'মাকরুহ সময়: সূর্যোদয় (${_translateTime(sunriseMakruh, true)}), জাওয়াল (${_translateTime(zawalRange, true)}), সূর্যাস্ত (${_translateTime(sunsetMakruh, true)})';
    makruhTimeStr.value = settings.isBangla ? makruhBn : makruhEn;
  }

  // ── Public actions ───────────────────────────────────────────────────────
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
      Get.log('Error saving location: $e');
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
      Get.log('Error saving calc method: $e');
    }
    isLoading.value = true;
    await loadPrayerTimes();
  }

  Future<void> setAsrSchool(int schoolId) async {
    asrSchool.value = schoolId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyAsrSchool, schoolId);
    } catch (e) {
      Get.log('Error saving asr school: $e');
    }
    isLoading.value = true;
    await loadPrayerTimes();
  }

  Future<void> toggleAzanNotification(String prayerKey) async {
    final current = azanNotifications[prayerKey] ?? true;
    azanNotifications[prayerKey] = !current;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('azan_notification_$prayerKey', !current);
      await loadPrayerTimes();
    } catch (e) {
      Get.log('Error toggling azan notification: $e');
    }
  }

  double get latitude => _latitude;
  double get longitude => _longitude;

  // ── Hijri date via standalone Gregorian→Hijri conversion ────────────────
  /// Converts a Gregorian date to Hijri using the Julian Day Number method.
  String _computeHijriDate(DateTime date) {
    try {
      final g = date;
      // Step 1: Julian Day Number from Gregorian date
      final int a = ((14 - g.month) / 12).floor();
      final int y = g.year + 4800 - a;
      final int m = g.month + 12 * a - 3;
      int jdn = g.day +
          ((153 * m + 2) / 5).floor() +
          365 * y +
          (y / 4).floor() -
          (y / 100).floor() +
          (y / 400).floor() -
          32045;

      // Step 2: Julian Day Number → Hijri
      final int l = jdn - 1948440 + 10632;
      final int n = ((l - 1) / 10631).floor();
      final int l2 = l - 10631 * n + 354;
      final int j = (((10985 - l2) / 5316).floor()) *
              (((50 * l2) / 17719).floor()) +
          (((l2) / 5670).floor()) * (((43 * l2) / 15238).floor());
      final int l3 = l2 -
          ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
          (j / 16).floor() * ((15238 * j) / 43).floor() +
          29;
      final int hMonth = ((24 * l3) / 709).floor();
      final int hDay = l3 - ((709 * hMonth) / 24).floor();
      final int hYear = 30 * n + j - 29;

      final monthEn = _hijriMonthEn(hMonth);
      return _formatHijriDate(hDay.toString(), monthEn, hYear.toString());
    } catch (e) {
      return '';
    }
  }

  String _hijriMonthEn(int month) {
    const names = [
      'Muharram', 'Safar', "Rabi' al-awwal", "Rabi' al-Thani",
      'Jumada al-awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah'
    ];
    if (month >= 1 && month <= 12) return names[month - 1];
    return '';
  }

  String _formatHijriDate(String day, String monthEn, String year) {
    final settings = Get.find<SettingsController>();

    const monthsBn = {
      'Muharram': 'মুহাররম',
      "Rabi' al-awwal": 'রবিউল আউয়াল',
      "Rabi' al-Awwal": 'রবিউল আউয়াল',
      "Rabi' ath-thani": 'রবিউস সানি',
      "Rabi' al-Thani": 'রবিউস সানি',
      'Safar': 'সফর',
      'Jumada al-awwal': 'জুমাদাল উলা',
      'Jumada al-Awwal': 'জুমাদাল উলা',
      'Jumada al-thani': 'জুমাদাস সানি',
      'Jumada al-Thani': 'জুমাদাস সানি',
      'Rajab': 'রজব',
      "Sha'ban": 'শাবান',
      'Ramadan': 'রমজান',
      'Shawwal': 'শাওয়াল',
      'Dhu al-Qadah': 'জিলকদ',
      'Dhu al-Hijjah': 'জিলহজ',
    };

    if (!settings.isBangla) return '$day $monthEn';

    final dayBn = _toBanglaDigits(day);
    final monthBn = monthsBn[monthEn] ??
        monthsBn.entries
            .firstWhere(
              (e) => e.key.toLowerCase() == monthEn.toLowerCase(),
              orElse: () => MapEntry(monthEn, monthEn),
            )
            .value;

    return '$dayBn $monthBn';
  }

  // ── Formatters ──────────────────────────────────────────────────────────
  /// Format a UTC DateTime from adhan to "hh:mm a" local time
  String _fmt12h(DateTime? dt) {
    if (dt == null) return '--:--';
    try {
      return DateFormat('hh:mm a').format(dt.toLocal());
    } catch (_) {
      return '--:--';
    }
  }

  /// Format a UTC DateTime from adhan to "HH:mm" local time (for notification schedule)
  String _fmt24h(DateTime? dt) {
    if (dt == null) return '00:00';
    try {
      return DateFormat('HH:mm').format(dt.toLocal());
    } catch (_) {
      return '00:00';
    }
  }

  String _toBanglaDigits(String englishDigits) {
    return englishDigits
        .replaceAll('0', '০')
        .replaceAll('1', '১')
        .replaceAll('2', '২')
        .replaceAll('3', '৩')
        .replaceAll('4', '৪')
        .replaceAll('5', '৫')
        .replaceAll('6', '৬')
        .replaceAll('7', '৭')
        .replaceAll('8', '৮')
        .replaceAll('9', '৯');
  }

  String toBanglaDigits(String englishDigits) => _toBanglaDigits(englishDigits);

  String get bengaliDateStr => _getBengaliDate(DateTime.now());

  String _getBengaliDate(DateTime date) {
    final settings = Get.find<SettingsController>();
    final isBangla = settings.isBangla;
    final day = date.day;
    final month = date.month;
    int bDay = 1;
    String bMonthBn = '';
    String bMonthEn = '';
    if (month == 4) {
      if (day < 14) { bMonthBn = 'চৈত্র'; bMonthEn = 'Choitro'; bDay = day + 17; }
      else { bMonthBn = 'বৈশাখ'; bMonthEn = 'Baishakh'; bDay = day - 13; }
    } else if (month == 5) {
      if (day < 15) { bMonthBn = 'বৈশাখ'; bMonthEn = 'Baishakh'; bDay = day + 17; }
      else { bMonthBn = 'জ্যৈষ্ঠ'; bMonthEn = 'Jyeshtha'; bDay = day - 14; }
    } else if (month == 6) {
      if (day < 15) { bMonthBn = 'জ্যৈষ্ঠ'; bMonthEn = 'Jyeshtha'; bDay = day + 17; }
      else { bMonthBn = 'আষাঢ়'; bMonthEn = 'Ashar'; bDay = day - 14; }
    } else if (month == 7) {
      if (day < 16) { bMonthBn = 'আষাঢ়'; bMonthEn = 'Ashar'; bDay = day + 16; }
      else { bMonthBn = 'শ্রাবণ'; bMonthEn = 'Shrabon'; bDay = day - 15; }
    } else if (month == 8) {
      if (day < 16) { bMonthBn = 'শ্রাবণ'; bMonthEn = 'Shrabon'; bDay = day + 16; }
      else { bMonthBn = 'ভাদ্র'; bMonthEn = 'Bhadra'; bDay = day - 15; }
    } else if (month == 9) {
      if (day < 16) { bMonthBn = 'ভাদ্র'; bMonthEn = 'Bhadra'; bDay = day + 16; }
      else { bMonthBn = 'আশ্বিন'; bMonthEn = 'Ashwin'; bDay = day - 15; }
    } else if (month == 10) {
      if (day < 16) { bMonthBn = 'আশ্বিন'; bMonthEn = 'Ashwin'; bDay = day + 15; }
      else { bMonthBn = 'কার্তিক'; bMonthEn = 'Kartik'; bDay = day - 15; }
    } else if (month == 11) {
      if (day < 15) { bMonthBn = 'কার্তিক'; bMonthEn = 'Kartik'; bDay = day + 16; }
      else { bMonthBn = 'অগ্রহায়ণ'; bMonthEn = 'Ograhayon'; bDay = day - 14; }
    } else if (month == 12) {
      if (day < 15) { bMonthBn = 'অগ্রহায়ণ'; bMonthEn = 'Ograhayon'; bDay = day + 16; }
      else { bMonthBn = 'পৌষ'; bMonthEn = 'Poush'; bDay = day - 14; }
    } else if (month == 1) {
      if (day < 14) { bMonthBn = 'পৌষ'; bMonthEn = 'Poush'; bDay = day + 17; }
      else { bMonthBn = 'মাঘ'; bMonthEn = 'Magh'; bDay = day - 13; }
    } else if (month == 2) {
      if (day < 13) { bMonthBn = 'মাঘ'; bMonthEn = 'Magh'; bDay = day + 18; }
      else { bMonthBn = 'ফাল্গুন'; bMonthEn = 'Falgun'; bDay = day - 12; }
    } else if (month == 3) {
      if (day < 15) {
        bMonthBn = 'ফাল্গুন'; bMonthEn = 'Falgun';
        final isLeap = (date.year % 4 == 0 && date.year % 100 != 0) || (date.year % 400 == 0);
        bDay = day + (isLeap ? 17 : 16);
      } else {
        bMonthBn = 'চৈত্র'; bMonthEn = 'Choitro'; bDay = day - 14;
      }
    }
    if (isBangla) return '${_toBanglaDigits(bDay.toString())} $bMonthBn';
    return '$bDay $bMonthEn';
  }

  String _translateTime(String time, bool isBangla) {
    if (!isBangla) return time;
    return time
        .replaceAll('0', '০').replaceAll('1', '১').replaceAll('2', '২')
        .replaceAll('3', '৩').replaceAll('4', '৪').replaceAll('5', '৫')
        .replaceAll('6', '৬').replaceAll('7', '৭').replaceAll('8', '৮')
        .replaceAll('9', '৯').replaceAll('AM', 'ভোর/সকাল')
        .replaceAll('PM', 'দুপুর/বিকাল/রাত');
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _dailyRefreshTimer?.cancel();
    super.onClose();
  }
}
