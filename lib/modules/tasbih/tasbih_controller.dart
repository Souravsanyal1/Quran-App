import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class DhikrItem {
  final String arabic;
  final String transliterationEn;
  final String transliterationBn;
  final String meaningEn;
  final String meaningBn;
  final int defaultTarget;

  const DhikrItem({
    required this.arabic,
    required this.transliterationEn,
    required this.transliterationBn,
    required this.meaningEn,
    required this.meaningBn,
    required this.defaultTarget,
  });
}

class TasbihController extends GetxController {
  final RxInt count = 0.obs;
  final RxInt target = 33.obs;
  final RxInt totalSaves = 0.obs;
  final RxInt selectedDhikrIndex = 0.obs;

  static const String _keyCount = 'tasbih_count';
  static const String _keyRounds = 'tasbih_rounds';
  static const String _keyTarget = 'tasbih_target';
  static const String _keyDhikr = 'tasbih_dhikr';

  SharedPreferences? _prefs;

  final List<DhikrItem> dhikrList = const [
    DhikrItem(
      arabic: 'سُبْحَانَ اللَّهِ',
      transliterationEn: 'Subhanallah',
      transliterationBn: 'সুবহানাল্লাহ',
      meaningEn: 'Glory be to Allah',
      meaningBn: 'আল্লাহ পবিত্র ও মহিমান্বিত',
      defaultTarget: 33,
    ),
    DhikrItem(
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliterationEn: 'Alhamdulillah',
      transliterationBn: 'আলহামদুলিল্লাহ',
      meaningEn: 'All praise is for Allah',
      meaningBn: 'সকল প্রশংসা আল্লাহর জন্য',
      defaultTarget: 33,
    ),
    DhikrItem(
      arabic: 'اللَّهُ أَكْبَرُ',
      transliterationEn: 'Allahu Akbar',
      transliterationBn: 'আল্লাহু আকবার',
      meaningEn: 'Allah is the Greatest',
      meaningBn: 'আল্লাহ সর্বশ্রেষ্ঠ',
      defaultTarget: 34,
    ),
    DhikrItem(
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      transliterationEn: 'La ilaha illallah',
      transliterationBn: 'লা ইলাহা ইল্লাল্লাহ',
      meaningEn: 'There is no god but Allah',
      meaningBn: 'আল্লাহ ছাড়া কোনো উপাস্য নেই',
      defaultTarget: 100,
    ),
    DhikrItem(
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      transliterationEn: 'Astaghfirullah',
      transliterationBn: 'আস্তাগফিরুল্লাহ',
      meaningEn: 'I seek forgiveness from Allah',
      meaningBn: 'আমি আল্লাহর কাছে ক্ষমা চাই',
      defaultTarget: 100,
    ),
    DhikrItem(
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      transliterationEn: 'La hawla wa la quwwata illa billah',
      transliterationBn: 'লা হাওলা ওয়ালা কুওয়াতা ইল্লা বিল্লাহ',
      meaningEn: 'There is no might nor power except with Allah',
      meaningBn: 'আল্লাহর সাহায্য ছাড়া কোনো শক্তি নেই',
      defaultTarget: 33,
    ),
    DhikrItem(
      arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
      transliterationEn: 'Allahumma salli ala Muhammad',
      transliterationBn: 'আল্লাহুম্মা সাল্লি আলা মুহাম্মাদ',
      meaningEn: 'O Allah, send blessings upon Muhammad',
      meaningBn: 'হে আল্লাহ, মুহাম্মদ (সাঃ) এর উপর রহমত বর্ষণ করুন',
      defaultTarget: 100,
    ),
  ];

  DhikrItem get currentDhikr => dhikrList[selectedDhikrIndex.value];

  @override
  void onInit() {
    super.onInit();
    _loadState();
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    count.value = _prefs?.getInt(_keyCount) ?? 0;
    totalSaves.value = _prefs?.getInt(_keyRounds) ?? 0;
    target.value = _prefs?.getInt(_keyTarget) ?? 33;
    selectedDhikrIndex.value = _prefs?.getInt(_keyDhikr) ?? 0;
  }

  Future<void> _saveState() async {
    await _prefs?.setInt(_keyCount, count.value);
    await _prefs?.setInt(_keyRounds, totalSaves.value);
    await _prefs?.setInt(_keyTarget, target.value);
    await _prefs?.setInt(_keyDhikr, selectedDhikrIndex.value);
  }

  void increment() {
    count.value++;
    _triggerVibration(30);

    if (count.value >= target.value) {
      _triggerVibration(300);
      totalSaves.value++;
      count.value = 0;
    }
    _saveState();
  }

  void reset() {
    count.value = 0;
    totalSaves.value = 0;
    _triggerVibration(100);
    _saveState();
  }

  void setTarget(int value) {
    target.value = value;
    count.value = 0;
    _triggerVibration(100);
    _saveState();
  }

  void selectDhikr(int index) {
    selectedDhikrIndex.value = index;
    count.value = 0;
    totalSaves.value = 0;
    target.value = dhikrList[index].defaultTarget;
    _triggerVibration(80);
    _saveState();
  }

  Future<void> _triggerVibration(int durationMs) async {
    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: durationMs);
      }
    } catch (e) {
      Get.log('Vibration error: $e');
    }
  }
}
