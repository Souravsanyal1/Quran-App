import 'package:get/get.dart';
import '../../data/models/dua_model.dart';
import 'duas_data.dart';

class DuasController extends GetxController {
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 800), () {
      isLoading.value = false;
    });
  }

  final RxString selectedCategoryEn = 'Sleep'.obs;

  final List<String> categoriesEn = const [
    'Sleep',
    'Home',
    'Toilet',
    'Ablution & Prayer',
    'Food',
    'Clothing',
    'Travel',
    'Family',
    'Morning & Evening',
    'Forgiveness',
    'Hardship & Danger',
    'Rizq & Blessings',
    'Rain',
    'Sickness',
    'Death',
    'Hajj & Umrah',
    'Quranic',
    'Daily Life',
    'Dhikr',
    'Special'
  ];

  final List<String> categoriesBn = const [
    'ঘুম সম্পর্কিত',
    'ঘর সম্পর্কিত',
    'টয়লেট',
    'ওযু ও নামাজ',
    'খাবার',
    'পোশাক',
    'ভ্রমণ',
    'পরিবার',
    'সকাল-সন্ধ্যার আমল',
    'ক্ষমা ও তাওবা',
    'বিপদ-আপদ',
    'রিজিক ও বরকত',
    'বৃষ্টি',
    'অসুস্থতা',
    'মৃত্যু',
    'হজ ও উমরাহ',
    'কুরআনের দোয়া',
    'বিভিন্ন পরিস্থিতি',
    'যিকির',
    'বিশেষ দোয়া'
  ];

  final List<DuaItem> duas = staticDuas;

  List<DuaItem> get filteredDuas {
    return duas.where((dua) => dua.categoryEn == selectedCategoryEn.value).toList();
  }

  void selectCategory(String category) {
    selectedCategoryEn.value = category;
  }
}
