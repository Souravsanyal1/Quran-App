import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_routes.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  static const String _onboardingKey = 'onboarding_done';

  final List<Map<String, String>> slides = const [
    {
      'icon': '📖',
      'title': 'Complete Quran',
      'titleBn': 'সম্পূর্ণ কুরআন',
      'desc': 'Read all 114 Surahs with Arabic text, Bangla translation, and audio recitation.',
      'descBn': '১১৪টি সূরা আরবি, বাংলা অনুবাদ ও অডিও সহ পড়ুন।',
    },
    {
      'icon': '🕌',
      'title': 'Prayer Times',
      'titleBn': 'নামাজের সময়',
      'desc': 'Get accurate prayer times based on your GPS location with Azan notifications.',
      'descBn': 'GPS ভিত্তিক সঠিক নামাজের সময় ও আজানের নোটিফিকেশন পান।',
    },
    {
      'icon': '🧭',
      'title': 'Qibla & Tracker',
      'titleBn': 'কিবলা ও ট্র্যাকার',
      'desc': 'Find Qibla direction with compass and track your daily prayers & Quran reading.',
      'descBn': 'কম্পাসে কিবলা খুঁজুন এবং নামাজ ও কুরআন পড়ার ট্র্যাক রাখুন।',
    },
  ];

  void onPageChanged(int page) => currentPage.value = page;

  void nextPage() {
    if (currentPage.value < slides.length - 1) {
      currentPage.value++;
    } else {
      completeOnboarding();
    }
  }

  void skipOnboarding() => completeOnboarding();

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    Get.offAllNamed(AppRoutes.home);
  }
}
