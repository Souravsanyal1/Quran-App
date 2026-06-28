import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'namaz_guide_model.dart';

class NamazGuideController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 600), () {
      isLoading.value = false;
    });
  }

  final List<NamazStep> steps = [
    NamazStep(
      stepNumber: 1,
      posture: PrayerPosture.standing,
      titleEn: 'Start & Intention',
      titleBn: 'শুরু এবং নিয়ত',
      instructionEn: 'Stand straight facing Qibla. Lower your hands at your sides and intend in your heart which prayer you are performing.',
      instructionBn: 'কিবলামুখী হয়ে সোজা হয়ে দাঁড়ান। দুই হাত নিচে স্বাভাবিকভাবে ঝুলিয়ে রাখুন এবং মনে মনে নিয়ত করুন আপনি কোন নামাজ পড়ছেন।',
    ),
    NamazStep(
      stepNumber: 2,
      posture: PrayerPosture.handsRaised,
      titleEn: 'Takbir (Opening)',
      titleBn: 'তাকবীরে তাহরীমা',
      instructionEn: 'Raise hands to ears (or shoulders for women) and say "Allahu Akbar". This starts the prayer.',
      instructionBn: 'দুই হাত কান পর্যন্ত উঠিয়ে "আল্লাহু আকবার" বলুন। এর মাধ্যমেই নামাজ শুরু হয়।',
      arabic: 'اللَّهُ أَكْبَرُ',
      translit: 'আল্লা-হু আকবার',
      meaningBn: 'আল্লাহ সর্বশ্রেষ্ঠ',
      meaningEn: 'Allah is the Greatest',
    ),
    NamazStep(
      stepNumber: 3,
      posture: PrayerPosture.qiyam,
      titleEn: 'Qiyam (Reading Surah Fatiha)',
      titleBn: 'সূরা ফাতিহা পাঠ',
      instructionEn: 'Fold hands on chest/below navel. Recite Surah Al-Fatihah, which is mandatory in every Rakah.',
      instructionBn: 'ডান হাত বাম হাতের উপর রেখে হাত বাঁধুন এবং সূরা ফাতিহা পাঠ করুন। এটি নামাজের প্রতিটি রাকাতেই পড়া ফরজ।',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۞ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۞ الرَّحْمَنِ الرَّحِيمِ ۞ مَالِكِ يَوْمِ الدِّينِ ۞ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۞ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۞ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      translit: '১. বিসমিল্লাহির রাহমানির রাহিম\n২. আলহামদু লিল্লাহি রাব্বিল আলামিন\n৩. আর রাহমানির রাহিম\n৪. মালিকি ইয়াওমিদ্দিন\n৫. ইয়্যাকা নাবুদু ওয়া ইয়্যাকা নাস্তায়িন\n৬. ইহদিনাস সিরাতাল মুস্তাকিম\n৭. সিরাতাল্লাজিনা আনআমতা আলাইহিম, গাইরিল মাগদুবি আলাইহিম ওয়ালাদ্দল্লিন। (আমীন)',
      meaningBn: 'সব প্রশংসা আল্লাহর জন্য যিনি জগতসমূহের প্রতিপালক...',
      meaningEn: 'In the name of Allah, the Most Gracious, the Most Merciful...',
    ),
    NamazStep(
      stepNumber: 4,
      posture: PrayerPosture.qiyam,
      titleEn: 'Reciting Surah Ikhlas',
      titleBn: 'অন্য একটি সূরা পাঠ',
      instructionEn: 'Recite another short Surah after Fatiha. Mandatory in the first two Rakahs.',
      instructionBn: 'সূরা ফাতিহা শেষ করে অন্য একটি সূরা মেলাতে হয় (যেমন: সূরা ইখলাস)। ১ম ও ২য় রাকাতে এটি আবশ্যক।',
      arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۞ اللَّهُ الصَّمَدُ ۞ لَمْ يَلِدْ وَلَمْ يُولَدْ ۞ وَلَمْ يَكُن لَّهُ كُفُوًا أَহَدٌ',
      translit: '১. কুল হুওয়াল্লাহু আহাদ\n২. আল্লাহুস সামাদ\n৩. লাম ইয়ালিদ ওয়া লাম ইউলাদ\n৪. ওয়া লাম ইয়াকুল্লাহু কুফুওয়ান আহাদ।',
      meaningBn: 'বলুন, তিনি আল্লাহ, এক ও অদ্বিতীয়...',
      meaningEn: 'Say, "He is Allah, [who is] One..."',
    ),
    NamazStep(
      stepNumber: 5,
      posture: PrayerPosture.ruku,
      titleEn: 'Ruku (Bowing)',
      titleBn: 'রুকু ও রুকুর তাসবিহ',
      instructionEn: 'Bow down keeping back straight and hands on knees. Say this Tasbih 3 times.',
      instructionBn: 'কোমর সোজা রেখে দুই হাত হাঁটুতে দিয়ে ঝুঁকুন এবং এই দোয়াটি ৩ বার পড়ুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      translit: 'সুবহানা রাব্বিয়াল আজিম',
      meaningBn: 'আমার মহান রবের পবিত্রতা ঘোষণা করছি',
      meaningEn: 'Glory be to my Lord, the Almighty',
    ),
    NamazStep(
      stepNumber: 6,
      posture: PrayerPosture.qaumah,
      titleEn: 'Qawmah (Standing Up)',
      titleBn: 'রুকু থেকে সোজা হয়ে দাঁড়ানো',
      instructionEn: 'Stand straight from Ruku saying "Sami\'Allahu liman hamidah" followed by "Rabbana lakal hamd".',
      instructionBn: 'রুকু থেকে সোজা হয়ে দাঁড়িয়ে বলুন "সামিআল্লাহু লিমান হামিদাহ", এরপর বলুন "রাব্বানা লাকাল হামদ"।',
      arabic: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ ۞ رَبَّنَا لَكَ الْحَمْدُ',
      translit: 'Sami\'Allahu liman hamidah. Rabbana lakal hamd.',
      meaningBn: 'আল্লাহ শোনেন যে তাঁর প্রশংসা করে। হে আমাদের রব, সমস্ত প্রশংসা আপনারই।',
      meaningEn: 'Allah hears those who praise Him. Our Lord, to You is all praise.',
    ),
    NamazStep(
      stepNumber: 7,
      posture: PrayerPosture.sujud,
      titleEn: 'First Sujud (Prostration)',
      titleBn: 'প্রথম সিজদা ও সিজদার তাসবিহ',
      instructionEn: 'Prostrate on the ground with forehead, nose, knees, and palms. Say this Tasbih 3 times.',
      instructionBn: 'মাটিতে হাঁটু, হাত, নাক ও কপাল ঠেকিয়ে সিজদায় যান এবং এই দোয়াটি ৩ বার পড়ুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translit: 'সুবহানা রাব্বিয়াল আলা',
      meaningBn: 'আমার সর্বোচ্চ রবের পবিত্রতা ঘোষণা করছি',
      meaningEn: 'Glory be to my Lord, the Most High',
    ),
    NamazStep(
      stepNumber: 8,
      posture: PrayerPosture.jalsa,
      titleEn: 'Jalsah (Brief Sitting)',
      titleBn: 'দুই সিজদার মাঝখানে বসা',
      instructionEn: 'Rise to a sitting position. Keep your back straight, sit briefly, and recite this prayer.',
      instructionBn: 'সিজদা থেকে মাথা উঠিয়ে সোজা হয়ে বসুন। একটি সংক্ষিপ্ত সময় সোজা হয়ে বসে বলুন "রাব্বিগফির লী"।',
      arabic: 'رَبِّ اغْفِرْ لِي',
      translit: 'Rabbighfir li',
      meaningBn: 'হে আমার প্রতিপালক, আমাকে ক্ষমা করুন',
      meaningEn: 'O Lord, forgive me',
    ),
    NamazStep(
      stepNumber: 9,
      posture: PrayerPosture.sujud,
      titleEn: 'Second Sujud & Rakah Completion',
      titleBn: 'দ্বিতীয় সিজদা ও রাকাত সম্পন্ন',
      instructionEn: 'Perform the second Sujud saying the Tasbih 3 times. This completes 1 Rakah. If it is 1st/3rd Rakah, rise to stand. If 2nd/final Rakah, sit for Tashahhud.',
      instructionBn: 'আবার সিজদায় গিয়ে দোয়াটি ৩ বার পড়ুন। এর মাধ্যমে ১ রাকাত পূর্ণ হলো। ১ম বা ৩য় রাকাত হলে দাঁড়িয়ে যান, ২য় বা শেষ রাকাত হলে বৈঠকে বসুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translit: 'সুবহানা রাব্বিয়াল আলা',
      meaningBn: 'আমার সর্বোচ্চ রবের পবিত্রতা ঘোষণা করছি',
      meaningEn: 'Glory be to my Lord, the Most High',
    ),
    NamazStep(
      stepNumber: 10,
      posture: PrayerPosture.tashahhud,
      titleEn: 'Sitting (Tashahhud)',
      titleBn: 'আত্তাহিয়্যাতু (বৈঠক)',
      instructionEn: 'Sit and recite Tashahhud at the end of 2nd or final Rakah.',
      instructionBn: 'নামাজের ২য় বা শেষ রাকাতের সিজদা শেষে বসে এই দোয়াটি পাঠ করুন:',
      arabic: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ...',
      translit: 'আত্তাহিয়্যাতু লিল্লাহি ওয়াস সালাওয়াতু ওয়াত তাইয়্যিবাতু, আসসালামু আলাইকা আইয়ুহান নাবিয়্যু ওয়া রাহমাতুল্লাহি ওয়া বারাকাতুহু। আসসালামু আলাইনা ওয়া আলা ইবাদিল্লাহিস সালিহীন।',
      meaningBn: 'সব সম্মান, ইবাদত ও পবিত্রতা আল্লাহর জন্য...',
      meaningEn: 'All compliments, prayers, and pure words are due to Allah...',
    ),
    NamazStep(
      stepNumber: 11,
      posture: PrayerPosture.tasleem,
      titleEn: 'Ending with Salam',
      titleBn: 'সালাম - নামাজ শেষ',
      instructionEn: 'Turn head right and left to end the prayer.',
      instructionBn: 'প্রথমে ডানে মুখ ফিরিয়ে এবং পরে বামে মুখ ফিরিয়ে সালাম দিন। আপনার নামাজ শেষ হলো।',
      arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
      translit: 'আসসালামু আলাইকুম ওয়া রাহমাতুল্লাহ',
      meaningBn: 'আপনাদের উপর শান্তি ও আল্লাহর রহমত বর্ষিত হোক',
      meaningEn: 'Peace and blessings of Allah be upon you',
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
