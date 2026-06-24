import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
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
  static const String _keyAsrSchool = 'prayer_asr_school';

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
  final RxMap<String, String> rawPrayerTimings = <String, String>{}.obs;
  
  // Sunrise & Sunset Pill Values
  final RxString sunriseTimeStr = '05:11 AM'.obs;
  final RxString sunsetTimeStr = '06:50 PM'.obs;
  final RxString makruhTimeStr = ''.obs;

  // Arc & Semicircle Period details
  final RxDouble periodProgress = 0.0.obs;
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
      
      _latitude = customLatitude.value;
      _longitude = customLongitude.value;

      calculationMethod.value = prefs.getInt(_keyCalcMethod) ?? 1; // Default to Karachi (1)
      asrSchool.value = prefs.getInt(_keyAsrSchool) ?? 1; // Default to Hanafi (1)

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
        bool gpsSuccess = false;
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
            try {
              final position = await Geolocator.getCurrentPosition(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.low,
                  timeLimit: Duration(seconds: 4), // 4 seconds timeout for fast startup
                ),
              );
              _latitude = position.latitude;
              _longitude = position.longitude;
              customLatitude.value = position.latitude;
              customLongitude.value = position.longitude;
              
              // Try to reverse geocode city name
              final address = await _getAddressFromLatLng(_latitude, _longitude);
              locationName.value = address;
              gpsSuccess = true;

              // Cache current GPS location to SharedPreferences
              await prefs.setDouble(_keyLat, _latitude);
              await prefs.setDouble(_keyLng, _longitude);
              await prefs.setString(_keyLocName, address);
            } catch (e) {
              Get.log('GPS fetch failed or timed out: $e');
            }
          }
        }

        // IP-based location fallback if GPS failed and we don't have cached coordinates yet
        if (!gpsSuccess && !prefs.containsKey(_keyLat)) {
          try {
            final dio = Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
            ));
            final response = await dio.get('http://ip-api.com/json/');
            if (response.statusCode == 200 && response.data != null && response.data['status'] == 'success') {
              final double lat = response.data['lat'] ?? 23.8103;
              final double lng = response.data['lon'] ?? 90.4125;
              final String city = response.data['city'] ?? 'Dhaka';
              final String country = response.data['country'] ?? 'Bangladesh';
              final String address = '$city, $country';

              _latitude = lat;
              _longitude = lng;
              customLatitude.value = lat;
              customLongitude.value = lng;
              locationName.value = address;

              // Cache to SharedPreferences
              await prefs.setDouble(_keyLat, lat);
              await prefs.setDouble(_keyLng, lng);
              await prefs.setString(_keyLocName, address);
              Get.log('IP Location fallback succeeded: $address ($lat, $lng)');
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

  Future<Map<String, dynamic>?> _getOrFetchMonthlyCalendar(
      int year, int month, SharedPreferences prefs) async {
    final cacheKey = 'cached_calendar_${year}_$month';
    final cachedStr = prefs.getString(cacheKey);
    
    // Round lat/lng to 2 decimal places to avoid tiny differences causing refetch
    final double targetLat = double.parse(_latitude.toStringAsFixed(2));
    final double targetLng = double.parse(_longitude.toStringAsFixed(2));
    final int targetMethod = calculationMethod.value;
    final int targetSchool = asrSchool.value;

    if (cachedStr != null) {
      try {
        final Map<String, dynamic> cachedMap = jsonDecode(cachedStr);
        final double cachedLat = double.parse((cachedMap['lat'] ?? 0.0).toStringAsFixed(2));
        final double cachedLng = double.parse((cachedMap['lng'] ?? 0.0).toStringAsFixed(2));
        final int cachedMethod = cachedMap['method'] ?? 0;
        final int cachedSchool = cachedMap['school'] ?? 1;

        if ((cachedLat - targetLat).abs() < 0.02 &&
            (cachedLng - targetLng).abs() < 0.02 &&
            cachedMethod == targetMethod &&
            cachedSchool == targetSchool) {
          return cachedMap;
        }
      } catch (e) {
        Get.log('Error parsing cached calendar: $e');
      }
    }

    // Cache miss or invalid - fetch from API
    try {
      final response = await _api.fetchMonthlyPrayerTimes(
        latitude: _latitude,
        longitude: _longitude,
        year: year,
        month: month,
        method: targetMethod,
        school: targetSchool,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> cacheData = {
          'lat': _latitude,
          'lng': _longitude,
          'method': targetMethod,
          'school': targetSchool,
          'data': response.data['data'],
        };
        await prefs.setString(cacheKey, jsonEncode(cacheData));
        return cacheData;
      }
    } catch (e) {
      Get.log('Error fetching monthly prayer times for $year-$month: $e');
    }
    return null;
  }

  Future<void> loadPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Gather weekly timings list
      final List<Map<String, dynamic>> weeklyTimings = [];

      for (int i = 0; i < 7; i++) {
        final targetDate = now.add(Duration(days: i));
        final calendar = await _getOrFetchMonthlyCalendar(targetDate.year, targetDate.month, prefs);
        
        if (calendar != null) {
          final List<dynamic> daysList = calendar['data'];
          // Days in AlAdhan list are 1-indexed by day number
          final dayIdx = targetDate.day - 1;
          if (dayIdx >= 0 && dayIdx < daysList.length) {
            final dayData = daysList[dayIdx];
            weeklyTimings.add({
              'date': targetDate,
              'timings': dayData['timings'],
            });
          }
        }
      }

      if (weeklyTimings.isNotEmpty) {
        final todayData = weeklyTimings[0];
        final timings = todayData['timings'] as Map<String, dynamic>;
        
        // Find gregDateData or date details for today
        final todayDate = todayData['date'] as DateTime;
        Map<String, dynamic>? dateData;
        final calendar = await _getOrFetchMonthlyCalendar(todayDate.year, todayDate.month, prefs);
        if (calendar != null) {
          final List<dynamic> daysList = calendar['data'];
          final dayIdx = todayDate.day - 1;
          if (dayIdx >= 0 && dayIdx < daysList.length) {
            dateData = daysList[dayIdx]['date'] as Map<String, dynamic>?;
          }
        }

        // Pick only 5 daily prayers for the list
        prayerTimes.assignAll({
          'Fajr': _formatTime12h(timings['Fajr']),
          'Dhuhr': _formatTime12h(timings['Dhuhr']),
          'Asr': _formatTime12h(timings['Asr']),
          'Maghrib': _formatTime12h(timings['Maghrib']),
          'Isha': _formatTime12h(timings['Isha']),
        });

        // Populate raw timings map (24h strings from API) so the view can
        // compute start-time labels and ranges for each prayer row.
        rawPrayerTimings.assignAll({
          'Fajr': timings['Fajr']?.toString() ?? '',
          'Sunrise': timings['Sunrise']?.toString() ?? '',
          'Dhuhr': timings['Dhuhr']?.toString() ?? '',
          'Asr': timings['Asr']?.toString() ?? '',
          'Maghrib': timings['Maghrib']?.toString() ?? '',
          'Isha': timings['Isha']?.toString() ?? '',
        });

        // Set Sunrise & Sunset
        sunriseTimeStr.value = _formatTime12h(timings['Sunrise'] ?? '');
        sunsetTimeStr.value = _formatTime12h(timings['Sunset'] ?? timings['Maghrib'] ?? '');

        // Format Hijri Date
        if (dateData != null && dateData.containsKey('hijri')) {
          final hijriData = dateData['hijri'] as Map<String, dynamic>;
          final day = hijriData['day'] as String;
          final monthEn = hijriData['month']['en'] as String;
          final year = hijriData['year'] as String;
          hijriDateStr.value = _formatHijriDate(day, monthEn, year);
        }

        // Start countdown and active period detection
        _startCountdown(timings);

        // Schedule Azan notifications if enabled and notification service is ready.
        // On first app launch, AppBinding registers PrayerTimeController before
        // NotificationService.init() runs in splash. The guard in
        // scheduleWeeklyAzanNotifications() will silently skip in that case;
        // SplashController calls loadPrayerTimes() again after init() completes.
        try {
          final settings = Get.find<SettingsController>();
          if (settings.azanEnabled.value &&
              NotificationService.instance.isInitialized) {
            await NotificationService.instance.scheduleWeeklyAzanNotifications(weeklyTimings);
          } else if (!NotificationService.instance.isInitialized) {
            Get.log('[PrayerTime] NotificationService not ready yet — splash will reschedule.');
          }
        } catch (e) {
          Get.log('Error scheduling weekly azan notifications: $e');
        }
      }
    } catch (e) {
      Get.log('Error loading prayer times: $e');
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
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateCurrentPeriod(timings);
    });
  }

  void _calculateCurrentPeriod(Map<String, dynamic> timings) {
    final now = DateTime.now();
    
    DateTime parseTime(String key, {bool nextDay = false}) {
      final clean = timings[key].toString().split(' ')[0];
      final parts = clean.split(':');
      final dt = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      return nextDay ? dt.add(const Duration(days: 1)) : dt;
    }
    
    DateTime parseTimePrevDay(String key) {
      final clean = timings[key].toString().split(' ')[0];
      final parts = clean.split(':');
      return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1])).subtract(const Duration(days: 1));
    }

    try {
      final fajr = parseTime('Fajr');
      final sunrise = parseTime('Sunrise');
      final dhuhr = parseTime('Dhuhr');
      final asr = parseTime('Asr');
      final maghrib = parseTime('Maghrib');
      final isha = parseTime('Isha');
      
      final ishraqStart = sunrise.add(const Duration(minutes: 15));
      final zawalStart = dhuhr.subtract(const Duration(minutes: 15));
      final makruhAsrStart = maghrib.subtract(const Duration(minutes: 15));

      DateTime periodStart;
      DateTime periodEnd;
      String nameEn;
      String nameBn;
      bool isActive;
      
      // Determine the active period (Fajr, Dhuhr Upcoming, Dhuhr, Asr, Maghrib, Isha)
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
        // Isha or Night period before Fajr (Isha to Fajr)
        if (now.isAfter(isha)) {
          final nextFajr = parseTime('Fajr', nextDay: true);
          periodStart = isha;
          periodEnd = nextFajr;
        } else {
          final prevIsha = parseTimePrevDay('Isha');
          periodStart = prevIsha;
          periodEnd = fajr;
        }
        nameEn = 'Isha';
        nameBn = 'ইশা';
        isActive = true;
      }

      final settings = Get.find<SettingsController>();
      periodName.value = settings.isBangla ? nameBn : nameEn;
      isPeriodActive.value = isActive;

      // Set nextPrayerName for highlights
      if (nameEn == 'Fajr') {
        nextPrayerName.value = 'Fajr';
      } else if (nameEn.startsWith('Dhuhr')) {
        nextPrayerName.value = 'Dhuhr';
      } else if (nameEn == 'Asr') {
        nextPrayerName.value = 'Asr';
      } else if (nameEn == 'Maghrib') {
        nextPrayerName.value = 'Maghrib';
      } else if (nameEn == 'Isha') {
        nextPrayerName.value = 'Isha';
      }

      // Progress calculation
      final totalSeconds = periodEnd.difference(periodStart).inSeconds;
      final passedSeconds = now.difference(periodStart).inSeconds;
      double progress = totalSeconds > 0 ? (passedSeconds / totalSeconds) : 0.0;
      periodProgress.value = progress.clamp(0.0, 1.0);

      // Remaining time
      final remaining = periodEnd.difference(now);
      final hours = remaining.inHours.toString().padLeft(2, '0');
      final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
      
      final countdown = '$hours:$minutes:$seconds';
      periodTimeRemaining.value = settings.isBangla ? _toBanglaDigits(countdown) : countdown;

      // Update Makruh banner timings
      final format = DateFormat('hh:mm a');
      final sunriseMakruhRange = '${format.format(sunrise)} - ${format.format(ishraqStart)}';
      final zawalRange = '${format.format(zawalStart)} - ${format.format(dhuhr)}';
      final sunsetMakruhRange = '${format.format(makruhAsrStart)} - ${format.format(maghrib)}';
      
      final makruhEn = 'Makruh times: Sunrise ($sunriseMakruhRange), Midday ($zawalRange), Sunset ($sunsetMakruhRange)';
      final makruhBn = 'মাকরুহ সময়: সূর্যোদয় (${_translateTime(sunriseMakruhRange, true)}), জাওয়াল (${_translateTime(zawalRange, true)}), সূর্যাস্ত (${_translateTime(sunsetMakruhRange, true)})';
      makruhTimeStr.value = settings.isBangla ? makruhBn : makruhEn;

    } catch (e) {
      Get.log('Error calculating period: $e');
    }
  }

  String _formatHijriDate(String day, String monthEn, String year) {
    final settings = Get.find<SettingsController>();

    final Map<String, String> monthsBn = {
      'Muharram': 'মুহাররম',
      'Safar': 'সফর',
      'Rabi\' al-awwal': 'রবিউল আউয়াল',
      'Rabi\' al-Awwal': 'রবিউল আউয়াল',
      'Rabi\' ath-thani': 'রবিউস সানি',
      'Rabi\' al-Thani': 'রবিউস সানি',
      'Jumada al-awwal': 'জুমাদাল উলা',
      'Jumada al-Awwal': 'জুমাদাল উলা',
      'Jumada al-thani': 'জুমাদাস সানি',
      'Jumada al-Thani': 'জুমাদাস সানি',
      'Rajab': 'রজব',
      'Sha\'ban': 'শাবান',
      'Ramadan': 'রমজান',
      'Shawwal': 'শাওয়াল',
      'Dhu al-Qadah': 'জিলকদ',
      'Dhu al-Hijjah': 'জিলহজ',
    };

    if (!settings.isBangla) {
      // English: compact "8 Muharram" — no year in header
      return '$day $monthEn';
    }

    final dayBn = _toBanglaDigits(day);
    // Case-insensitive fallback so API spelling variations never leak English
    final monthBn = monthsBn[monthEn] ??
        monthsBn.entries
            .firstWhere(
              (e) => e.key.toLowerCase() == monthEn.toLowerCase(),
              orElse: () => MapEntry(monthEn, monthEn),
            )
            .value;

    // Compact: "৮ মুহাররম" — year omitted so it fits in the one-line header
    return '$dayBn $monthBn';
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

  String toBanglaDigits(String englishDigits) {
    return _toBanglaDigits(englishDigits);
  }

  String get bengaliDateStr {
    return _getBengaliDate(DateTime.now());
  }

  String _getBengaliDate(DateTime date) {
    final settings = Get.find<SettingsController>();
    final isBangla = settings.isBangla;
    final day = date.day;
    final month = date.month;
    
    int bDay = 1;
    String bMonthBn = '';
    String bMonthEn = '';
    
    if (month == 4) { // April
      if (day < 14) {
        bMonthBn = 'চৈত্র'; bMonthEn = 'Choitro';
        bDay = day + 17;
      } else {
        bMonthBn = 'বৈশাখ'; bMonthEn = 'Baishakh';
        bDay = day - 13;
      }
    } else if (month == 5) { // May
      if (day < 15) {
        bMonthBn = 'বৈশাখ'; bMonthEn = 'Baishakh';
        bDay = day + 17;
      } else {
        bMonthBn = 'জ্যৈষ্ঠ'; bMonthEn = 'Jyeshtha';
        bDay = day - 14;
      }
    } else if (month == 6) { // June
      if (day < 15) {
        bMonthBn = 'জ্যৈষ্ঠ'; bMonthEn = 'Jyeshtha';
        bDay = day + 17;
      } else {
        bMonthBn = 'আষাঢ়'; bMonthEn = 'Ashar';
        bDay = day - 14;
      }
    } else if (month == 7) { // July
      if (day < 16) {
        bMonthBn = 'আষাঢ়'; bMonthEn = 'Ashar';
        bDay = day + 16;
      } else {
        bMonthBn = 'শ্রাবণ'; bMonthEn = 'Shrabon';
        bDay = day - 15;
      }
    } else if (month == 8) { // August
      if (day < 16) {
        bMonthBn = 'শ্রাবণ'; bMonthEn = 'Shrabon';
        bDay = day + 16;
      } else {
        bMonthBn = 'ভাদ্র'; bMonthEn = 'Bhadra';
        bDay = day - 15;
      }
    } else if (month == 9) { // September
      if (day < 16) {
        bMonthBn = 'ভাদ্র'; bMonthEn = 'Bhadra';
        bDay = day + 16;
      } else {
        bMonthBn = 'আশ্বিন'; bMonthEn = 'Ashwin';
        bDay = day - 15;
      }
    } else if (month == 10) { // October
      if (day < 16) {
        bMonthBn = 'আশ্বিন'; bMonthEn = 'Ashwin';
        bDay = day + 15;
      } else {
        bMonthBn = 'কার্তিক'; bMonthEn = 'Kartik';
        bDay = day - 15;
      }
    } else if (month == 11) { // November
      if (day < 15) {
        bMonthBn = 'কার্তিক'; bMonthEn = 'Kartik';
        bDay = day + 16;
      } else {
        bMonthBn = 'অগ্রহায়ণ'; bMonthEn = 'Ograhayon';
        bDay = day - 14;
      }
    } else if (month == 12) { // December
      if (day < 15) {
        bMonthBn = 'অগ্রহায়ণ'; bMonthEn = 'Ograhayon';
        bDay = day + 16;
      } else {
        bMonthBn = 'পৌষ'; bMonthEn = 'Poush';
        bDay = day - 14;
      }
    } else if (month == 1) { // January
      if (day < 14) {
        bMonthBn = 'পৌষ'; bMonthEn = 'Poush';
        bDay = day + 17;
      } else {
        bMonthBn = 'মাঘ'; bMonthEn = 'Magh';
        bDay = day - 13;
      }
    } else if (month == 2) { // February
      if (day < 13) {
        bMonthBn = 'মাঘ'; bMonthEn = 'Magh';
        bDay = day + 18;
      } else {
        bMonthBn = 'ফাল্গুন'; bMonthEn = 'Falgun';
        bDay = day - 12;
      }
    } else if (month == 3) { // March
      if (day < 15) {
        bMonthBn = 'ফাল্গুন'; bMonthEn = 'Falgun';
        final isLeap = (date.year % 4 == 0 && date.year % 100 != 0) || (date.year % 400 == 0);
        bDay = day + (isLeap ? 17 : 16);
      } else {
        bMonthBn = 'চৈত্র'; bMonthEn = 'Choitro';
        bDay = day - 14;
      }
    }
    
    if (isBangla) {
      return '${_toBanglaDigits(bDay.toString())} $bMonthBn';
    } else {
      return '$bDay $bMonthEn';
    }
  }

  String _translateTime(String time, bool isBangla) {
    if (!isBangla) return time;
    var res = time
        .replaceAll('0', '০')
        .replaceAll('1', '১')
        .replaceAll('2', '২')
        .replaceAll('3', '৩')
        .replaceAll('4', '৪')
        .replaceAll('5', '৫')
        .replaceAll('6', '৬')
        .replaceAll('7', '৭')
        .replaceAll('8', '৮')
        .replaceAll('9', '৯')
        .replaceAll('AM', 'ভোর/সকাল')
        .replaceAll('PM', 'দুপুর/বিকাল/রাত');
    return res;
  }


  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}

