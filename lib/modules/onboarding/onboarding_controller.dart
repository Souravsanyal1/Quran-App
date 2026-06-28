import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_routes.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  static const String _onboardingKey = 'onboarding_done';

  final List<Map<String, String>> slides = const [
    {
      'icon': '📖',
      'title': 'Holy Quran',
      'titleBn': 'আল-কুরআন',
      'desc': 'Arabic text, Bangla translation, pronunciation and high-quality audio recitation.',
      'descBn': 'আরবি টেক্সট, বাংলা অনুবাদ, উচ্চারণ এবং উন্নত মানের অডিও তেলাওয়াত।',
    },
    {
      'icon': '🕌',
      'title': 'Prayer & Qibla',
      'titleBn': 'নামাজ ও কিবলা',
      'desc': 'Accurate prayer times, Azan reminders and live Qibla compass finder.',
      'descBn': 'সঠিক নামাজের সময়, আযান রিমাইন্ডার এবং লাইভ কিবলা কম্পাস।',
    },
    {
      'icon': '🎓',
      'title': 'Learn Salah',
      'titleBn': 'নামাজ শিক্ষা',
      'desc': 'Step-by-step guide for Wudu, Ruku, Sajdah and complete prayer method.',
      'descBn': 'ওযু, রুকু, সিজদাহ এবং পূর্ণাঙ্গ নামাজ আদায়ের সহজ গাইড।',
    },
    {
      'icon': '🔥',
      'title': 'Daily Habits',
      'titleBn': 'দৈনিক আমল',
      'desc': 'Build consistency with Streaks, XP, and daily achievement rewards.',
      'descBn': 'প্রতিদিনের আমলের ধারাবাহিকতা রক্ষা করুন স্ট্রাক এবং রিওয়ার্ডের মাধ্যমে।',
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
