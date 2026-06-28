import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'namaz_guide_model.dart';

class NamazGuideController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  final List<NamazStep> steps = [
    NamazStep(
      stepNumber: 1,
      posture: PrayerPosture.standing,
      titleEn: 'Start & Intention',
      titleBn: 'শুরু এবং নিয়ত',
      instructionEn: 'Stand straight facing Qibla. Intend in your heart which prayer you are performing.',
      instructionBn: 'কিবলামুখী হয়ে সোজা হয়ে দাঁড়ান। মনে মনে নিয়ত করুন আপনি কোন ওয়াক্তের (যেমন: ফজর বা জোহর) নামাজ পড়ছেন।',
    ),
    NamazStep(
      stepNumber: 2,
      posture: PrayerPosture.handsRaised,
      titleEn: 'Takbir (Opening)',
      titleBn: 'তাকবীরে তাহরীমা',
      instructionEn: 'Raise hands to ears and say "Allahu Akbar". This starts the prayer.',
      instructionBn: 'দুই হাত কান পর্যন্ত উঠিয়ে "আল্লাহু আকবার" বলুন। এর মাধ্যমেই নামাজ শুরু হয়।',
      arabic: 'اللَّهُ أَكْبَرُ',
      translit: 'উচ্চারণ: আল্লা-হু আকবার',
      meaningBn: 'অর্থ: আল্লাহ সর্বশ্রেষ্ঠ',
    ),
    NamazStep(
      stepNumber: 3,
      posture: PrayerPosture.qiyam,
      titleEn: 'Qiyam (Reading Surah Fatiha)',
      titleBn: 'সূরা ফাতিহা পাঠ',
      instructionEn: 'Recite Surah Al-Fatiha. Mandatory in every Rakah.',
      instructionBn: 'হাত বেঁধে নিচের সুরাটি সুন্দর করে পাঠ করুন। এটি নামাজের প্রতিটি রাকাতেই পড়তে হয়।',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۞ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۞ الرَّحْمَنِ الرَّحِيمِ ۞ مَالِكِ يَوْمِ الدِّينِ ۞ إِيَّاكَ نَعْبُدُ وَإِيَّাكَ نَسْتَعِينُ ۞ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۞ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      translit: '১. বিসমিল্লাহির রাহমানির রাহিম\n২. আলহামদু লিল্লাহি রাব্বিল আলামিন\n৩. আর রাহমানির রাহিম\n৪. মালিকি ইয়াওমিদ্দিন\n৫. ইয়্যাকা নাবুদু ওয়া ইয়্যাকা নাস্তায়িন\n৬. ইহদিনাস সিরাতাল মুস্তাকিম\n৭. সিরাতাল্লাজিনা আনআমতা আলাইহিম, গাইরিল মাগদুবি আলাইহিম ওয়ালাদ্দল্লিন। (আমীন)',
      meaningBn: 'অর্থ: সব প্রশংসা আল্লাহর জন্য যিনি জগতসমূহের প্রতিপালক...',
    ),
    NamazStep(
      stepNumber: 4,
      posture: PrayerPosture.qiyam,
      titleEn: 'Reciting Surah Ikhlas',
      titleBn: 'সূরা ইখলাস পাঠ',
      instructionEn: 'Recite another short Surah after Fatiha.',
      instructionBn: 'সূরা ফাতিহা শেষ করে অন্য একটি সূরা পড়তে হয়। এখানে সূরা ইখলাস দেওয়া হলো:',
      arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۞ اللَّهُ الصَّمَدُ ۞ لَمْ يَلِدْ وَلَمْ يُولَدْ ۞ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      translit: '১. কুল হুওয়াল্লাহু আহাদ\n২. আল্লাহুস সামাদ\n৩. লাম ইয়ালিদ ওয়া লাম ইউলাদ\n৪. ওয়া লাম ইয়াকুল্লাহু কুফুওয়ান আহাদ।',
      meaningBn: 'অর্থ: বলুন, তিনি আল্লাহ, এক ও অদ্বিতীয়...',
    ),
    NamazStep(
      stepNumber: 5,
      posture: PrayerPosture.ruku,
      titleEn: 'Ruku (Bowing)',
      titleBn: 'রুকু ও রুকুর তাসবিহ',
      instructionEn: 'Bow down and say this Tasbih 3 times.',
      instructionBn: 'কোমর সোজা রেখে দুই হাত হাঁটুতে দিয়ে ঝুঁকুন এবং এই দোয়াটি ৩ বার পড়ুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      translit: 'উচ্চারণ: সুবহানা রাব্বিয়াল আজিম',
      meaningBn: 'অর্থ: আমার মহান রবের পবিত্রতা ঘোষণা করছি',
    ),
    NamazStep(
      stepNumber: 6,
      posture: PrayerPosture.sujud,
      titleEn: 'Sujud (Prostration)',
      titleBn: 'সিজদা ও সিজদার তাসবিহ',
      instructionEn: 'Prostrate and say this Tasbih 3 times.',
      instructionBn: 'মাটিতে কপাল ও নাক ঠেকিয়ে এই দোয়াটি ৩ বার পড়ুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translit: 'উচ্চারণ: সুবহানা রাব্বিয়াল আলা',
      meaningBn: 'অর্থ: আমার সর্বোচ্চ রবের পবিত্রতা ঘোষণা করছি',
    ),
    NamazStep(
      stepNumber: 7,
      posture: PrayerPosture.jalsa,
      titleEn: 'Completing Rakah',
      titleBn: 'রাকাত শেষ করার নিয়ম',
      instructionEn: 'After two sujuds, one Rakah is complete.',
      instructionBn: 'দুইটি সিজদা শেষ করার পর ১ রাকাত পূর্ণ হয়। এরপর আবার দাঁড়িয়ে ২য় রাকাত শুরু করতে হয়। ২য় রাকাতের শেষে আত্তাহিয়্যাতু পড়তে হয়।',
    ),
    NamazStep(
      stepNumber: 8,
      posture: PrayerPosture.tashahhud,
      titleEn: 'Sitting (Tashahhud)',
      titleBn: 'আত্তাহিয়্যাতু (বৈঠক)',
      instructionEn: 'Sit and recite Tashahhud at the end of 2nd or final Rakah.',
      instructionBn: 'নামাজের মাঝে বা শেষে বসে এই দোয়াটি পাঠ করুন:',
      arabic: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ...',
      translit: 'আত্তাহিয়্যাতু লিল্লাহি ওয়াস সালাওয়াতু ওয়াত তাইয়্যিবাতু, আসসালামু আলাইকা আইয়ুহান নাবিয়্যু ওয়া রাহমাতুল্লাহি ওয়া বারাকাতুহু। আসসালামু আলাইনা ওয়া আলা ইবাদিল্লাহিস সালিহীন।',
      meaningBn: 'অর্থ: সব সম্মান, ইবাদত ও পবিত্রতা আল্লাহর জন্য...',
    ),
    NamazStep(
      stepNumber: 9,
      posture: PrayerPosture.tasleem,
      titleEn: 'Ending with Salam',
      titleBn: 'সালাম - নামাজ শেষ',
      instructionEn: 'Turn head right and left to end the prayer.',
      instructionBn: 'প্রথমে ডানে মুখ ফিরিয়ে এবং পরে বামে মুখ ফিরিয়ে সালাম দিন। আপনার নামাজ শেষ হলো।',
      arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
      translit: 'উচ্চারণ: আসসালামু আলাইকুম ওয়া রাহমাতুল্লাহ',
      meaningBn: 'অর্থ: আপনাদের উপর শান্তি ও আল্লাহর রহমত বর্ষিত হোক',
    ),
  ];

  bool get isFirstStep => currentIndex.value == 0;
  bool get isLastStep => currentIndex.value == steps.length - 1;
  double get progress => (currentIndex.value + 1) / steps.length;
  NamazStep get currentStep => steps[currentIndex.value];

  void nextStep() {
    if (!isLastStep) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void previousStep() {
    if (!isFirstStep) {
      pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void onPageChanged(int index) => currentIndex.value = index;

  void restart() {
    currentIndex.value = 0;
    pageController.jumpToPage(0);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
