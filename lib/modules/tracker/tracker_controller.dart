import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TrackerController extends GetxController {
  static const String _trackerBoxName = 'tracker_v2';
  late Box _box;
  final RxBool isLoading = true.obs;

  // Track today's accomplishments
  final RxMap<String, bool> todayRecords = <String, bool>{
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
    'Quran': false,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _initHiveAndLoad();
  }

  Future<void> _initHiveAndLoad() async {
    isLoading.value = true;
    try {
      _box = await Hive.openBox(_trackerBoxName);
      loadTodayRecords();
    } catch (e) {
      Get.log('Error opening tracker box: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void loadTodayRecords() {
    final key = _getTodayKey();
    final data = _box.get(key);
    if (data != null) {
      final map = Map<String, bool>.from(data as Map);
      todayRecords.assignAll(map);
    } else {
      todayRecords.assignAll({
        'Fajr': false,
        'Dhuhr': false,
        'Asr': false,
        'Maghrib': false,
        'Isha': false,
        'Quran': false,
      });
    }
  }

  Future<void> toggleRecord(String activity) async {
    if (todayRecords.containsKey(activity)) {
      todayRecords[activity] = !(todayRecords[activity] ?? false);
      final key = _getTodayKey();
      await _box.put(key, Map<String, bool>.from(todayRecords));
    }
  }

  double get todayCompletionRate {
    if (todayRecords.isEmpty) return 0.0;
    int completed = todayRecords.values.where((v) => v).length;
    return completed / todayRecords.length;
  }
}
