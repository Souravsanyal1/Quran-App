import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../namaz_guide/namaz_guide_model.dart';

enum NamazGender { male, female }

class NamazGuide2Controller extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final Rx<NamazGender?> selectedGender = Rx<NamazGender?>(null);

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 400), () {
      isLoading.value = false;
    });
  }

  // ── Male Steps ──────────────────────────────────────────────────────────────
  final List<NamazStep> maleSteps = [
    NamazStep(
      stepNumber: 1,
      posture: PrayerPosture.standing,
      titleEn: 'Start & Intention',
      titleBn: 'শুরু এবং নিয়ত',
      instructionEn: 'Stand straight facing Qibla with feet shoulder-width apart. Lower hands at sides and make intention in your heart.',
      instructionBn: 'কিবলামুখী হয়ে দুই পা কাঁধ বরাবর ফাঁক করে সোজা দাঁড়ান। মনে মনে নামাজের নিয়ত করুন।',
    ),
    NamazStep(
      stepNumber: 2,
      posture: PrayerPosture.handsRaised,
      titleEn: 'Takbir (Opening)',
      titleBn: 'তাকবীরে তাহরীমা',
      instructionEn: 'Raise both hands up to the earlobes with thumbs near the ears. Say "Allahu Akbar".',
      instructionBn: 'দুই হাত কান পর্যন্ত উঠান, বুড়ো আঙুল কানের লতি বরাবর রাখুন। "আল্লাহু আকবার" বলুন।',
      arabic: 'اللَّهُ أَكْبَرُ',
      translit: 'Allaahu Akbar',
      translitBn: 'আল্লাহু আকবার',
      meaningBn: 'আল্লাহ সর্বশ্রেষ্ঠ',
      meaningEn: 'Allah is the Greatest',
    ),
    NamazStep(
      stepNumber: 3,
      posture: PrayerPosture.qiyam,
      titleEn: 'Qiyam — Hands Below Navel',
      titleBn: 'কিয়াম — হাত নাভির নিচে',
      instructionEn: 'Place right hand over left hand below the navel. Recite Surah Al-Fatihah followed by another Surah.',
      instructionBn: 'ডান হাত বাম হাতের উপর রেখে নাভির নিচে বাঁধুন। সূরা ফাতিহা এবং অন্য সূরা পাঠ করুন।',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۞ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ...',
      translit: 'Bismillaahir Rahmaanir Raheem. Alhamdu lillaahi Rabbil \'aalameen...',
      translitBn: 'বিসমিল্লাহির রাহমানির রাহিম। আলহামদু লিল্লাহি রাব্বিল আলামিন...',
      meaningBn: 'পরম করুণাময়, অতি দয়ালু আল্লাহর নামে...',
      meaningEn: 'In the name of Allah, the Most Gracious...',
    ),
    NamazStep(
      stepNumber: 4,
      posture: PrayerPosture.ruku,
      titleEn: 'Ruku — Back Parallel to Ground',
      titleBn: 'রুকু — পিঠ সমান্তরাল',
      instructionEn: 'Bow with back perfectly parallel to the ground, hands gripping knees with fingers spread. Keep head level with back.',
      instructionBn: 'পিঠ মাটির সমান্তরাল রেখে ঝুঁকুন, হাত দিয়ে হাঁটু শক্ত করে ধরুন, আঙুল ছড়িয়ে রাখুন। মাথা পিঠের সমান রাখুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      translit: 'Subhaana Rabbiyal \'Azeem (×3)',
      translitBn: 'সুবহানা রাব্বিয়াল আজিম (৩ বার)',
      meaningBn: 'আমার মহান রবের পবিত্রতা ঘোষণা করছি',
      meaningEn: 'Glory be to my Lord, the Almighty',
    ),
    NamazStep(
      stepNumber: 5,
      posture: PrayerPosture.qaumah,
      titleEn: 'Qawmah — Standing Upright',
      titleBn: 'কাওমা — সোজা হয়ে দাঁড়ানো',
      instructionEn: 'Rise completely upright from Ruku, hands at sides. Pause briefly in this position.',
      instructionBn: 'রুকু থেকে সম্পূর্ণ সোজা হয়ে দাঁড়ান, হাত দুটি পাশে ঝুলিয়ে রাখুন। কিছুক্ষণ এই ভঙ্গিতে থাকুন।',
      arabic: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ ۞ رَبَّنَا لَكَ الْحَمْدُ',
      translit: 'Sami\'Allaahu liman hamidah. Rabbanaa lakal hamd.',
      translitBn: 'সামিআল্লাহু লিমান হামিদাহ। রাব্বানা লাকাল হামদ।',
      meaningBn: 'আল্লাহ তাঁর প্রশংসাকারীদের কথা শোনেন। হে রব, সকল প্রশংসা তোমার।',
      meaningEn: 'Allah hears whoever praises Him. Our Lord, all praise is Yours.',
    ),
    NamazStep(
      stepNumber: 6,
      posture: PrayerPosture.sujud,
      titleEn: 'Sujud — Arms Raised Off Ground',
      titleBn: 'সিজদা — কনুই মাটি থেকে উপরে',
      instructionEn: 'Prostrate with forehead, nose, both palms, both knees and toes on the ground. Elbows raised above the ground, arms away from sides.',
      instructionBn: 'কপাল, নাক, দুই হাতের তালু, দুই হাঁটু ও পায়ের আঙুল মাটিতে রাখুন। কনুই মাটি থেকে উপরে রাখুন, বাহু শরীর থেকে দূরে রাখুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translit: 'Subhaana Rabbiyal A\'laa (×3)',
      translitBn: 'সুবহানা রাব্বিয়াল আলা (৩ বার)',
      meaningBn: 'আমার সর্বোচ্চ রবের পবিত্রতা ঘোষণা করছি',
      meaningEn: 'Glory be to my Lord, the Most High',
    ),
    NamazStep(
      stepNumber: 7,
      posture: PrayerPosture.jalsa,
      titleEn: 'Jalsah — Sitting Between Prostrations',
      titleBn: 'জালসা — দুই সিজদার মাঝে বসা',
      instructionEn: 'Sit on left foot (iftirash), right foot upright. Hands placed flat on thighs near knees.',
      instructionBn: 'বাম পা বিছিয়ে তার উপর বসুন (ইফতিরাশ), ডান পা খাড়া রাখুন। হাত দুটো হাঁটুর কাছে রানের উপর সমতল রাখুন।',
      arabic: 'رَبِّ اغْفِرْ لِي',
      translit: 'Rabbighfir lee',
      translitBn: 'রাব্বিগফির লী',
      meaningBn: 'হে আমার রব, আমাকে ক্ষমা করুন',
      meaningEn: 'O my Lord, forgive me',
    ),
    NamazStep(
      stepNumber: 8,
      posture: PrayerPosture.sujud,
      titleEn: 'Second Sujud',
      titleBn: 'দ্বিতীয় সিজদা',
      instructionEn: 'Perform the second prostration exactly as the first. Elbows off the ground, arms spread away from body.',
      instructionBn: 'প্রথম সিজদার মতোই দ্বিতীয় সিজদা করুন। কনুই মাটি থেকে উঁচু রাখুন, বাহু শরীর থেকে দূরে রাখুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translit: 'Subhaana Rabbiyal A\'laa (×3)',
      translitBn: 'সুবহানা রাব্বিয়াল আলা (৩ বার)',
      meaningBn: 'আমার সর্বোচ্চ রবের পবিত্রতা ঘোষণা করছি',
      meaningEn: 'Glory be to my Lord, the Most High',
    ),
    NamazStep(
      stepNumber: 9,
      posture: PrayerPosture.tashahhud,
      titleEn: 'Tashahhud — Final Sitting',
      titleBn: 'তাশাহহুদ — শেষ বৈঠক',
      instructionEn: 'Sit on left foot (iftirash) for 2nd rakah or tawarruk (right foot under left) for final rakah. Point right index finger during Tashahhud.',
      instructionBn: '২য় রাকাতে বাম পা বিছিয়ে (ইফতিরাশ) এবং শেষ রাকাতে ডান পা বাম পায়ের নিচে দিয়ে (তাওয়াররুক) বসুন। তাশাহহুদে তর্জনী আঙুল উঁচু রাখুন।',
      arabic: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ...',
      translit: 'At-tahiyyaatu lillaahi was-salawaatu wat-tayyibaatu...',
      translitBn: 'আত্তাহিয়্যাতু লিল্লাহি ওয়াস সালাওয়াতু ওয়াত তাইয়্যিবাতু...',
      meaningBn: 'সকল সম্মান, ইবাদত ও পবিত্রতা আল্লাহর জন্য...',
      meaningEn: 'All compliments, prayers and pure words are due to Allah...',
    ),
    NamazStep(
      stepNumber: 10,
      posture: PrayerPosture.tasleem,
      titleEn: 'Salam — Ending Prayer',
      titleBn: 'সালাম — নামাজ শেষ',
      instructionEn: 'Turn head to the right saying "As-salamu alaykum wa rahmatullah", then to the left the same.',
      instructionBn: 'প্রথমে ডানে মুখ ফিরিয়ে "আস-সালামু আলাইকুম ওয়া রাহমাতুল্লাহ" বলুন, তারপর বামে।',
      arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
      translit: 'As-salaamu \'alaykum wa rahmatullaah',
      translitBn: 'আসসালামু আলাইকুম ওয়া রাহমাতুল্লাহ',
      meaningBn: 'আপনাদের উপর শান্তি ও আল্লাহর রহমত বর্ষিত হোক',
      meaningEn: 'Peace and mercy of Allah be upon you',
    ),
  ];

  // ── Female Steps ─────────────────────────────────────────────────────────────
  final List<NamazStep> femaleSteps = [
    NamazStep(
      stepNumber: 1,
      posture: PrayerPosture.standing,
      titleEn: 'Start & Intention',
      titleBn: 'শুরু এবং নিয়ত',
      instructionEn: 'Stand straight facing Qibla with feet together (or slightly apart). Lower hands at sides and make intention in your heart.',
      instructionBn: 'কিবলামুখী হয়ে দুই পা একসাথে (বা সামান্য ফাঁক) রেখে সোজা দাঁড়ান। মনে মনে নামাজের নিয়ত করুন।',
    ),
    NamazStep(
      stepNumber: 2,
      posture: PrayerPosture.handsRaised,
      titleEn: 'Takbir (Opening)',
      titleBn: 'তাকবীরে তাহরীমা',
      instructionEn: 'Raise both hands up to the shoulders (not ears). Say "Allahu Akbar". The dupatta/hijab should remain in place.',
      instructionBn: 'দুই হাত কাঁধ বরাবর উঠান (কান পর্যন্ত নয়)। "আল্লাহু আকবার" বলুন। ওড়না/হিজাব ঠিক রাখুন।',
      arabic: 'اللَّهُ أَكْبَرُ',
      translit: 'Allaahu Akbar',
      translitBn: 'আল্লাহু আকবার',
      meaningBn: 'আল্লাহ সর্বশ্রেষ্ঠ',
      meaningEn: 'Allah is the Greatest',
    ),
    NamazStep(
      stepNumber: 3,
      posture: PrayerPosture.qiyam,
      titleEn: 'Qiyam — Hands on Chest',
      titleBn: 'কিয়াম — হাত বুকের উপর',
      instructionEn: 'Place right hand over left hand on the chest (not below navel). Recite Surah Al-Fatihah followed by another Surah.',
      instructionBn: 'ডান হাত বাম হাতের উপর রেখে বুকের উপর বাঁধুন (নাভির নিচে নয়)। সূরা ফাতিহা ও অন্য সূরা পাঠ করুন।',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۞ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ...',
      translit: 'Bismillaahir Rahmaanir Raheem. Alhamdu lillaahi Rabbil \'aalameen...',
      translitBn: 'বিসমিল্লাহির রাহমানির রাহিম। আলহামদু লিল্লাহি রাব্বিল আলামিন...',
      meaningBn: 'পরম করুণাময়, অতি দয়ালু আল্লাহর নামে...',
      meaningEn: 'In the name of Allah, the Most Gracious...',
    ),
    NamazStep(
      stepNumber: 4,
      posture: PrayerPosture.ruku,
      titleEn: 'Ruku — Slight Bow',
      titleBn: 'রুকু — সামান্য ঝোঁকা',
      instructionEn: 'Bow slightly (back not fully horizontal), hands placed on knees with fingers together. Keep elbows close to sides.',
      instructionBn: 'সামান্য ঝুঁকুন (পিঠ সম্পূর্ণ সমান্তরাল নয়), হাত হাঁটুতে রাখুন আঙুল একসাথে। কনুই শরীরের পাশে কাছে রাখুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      translit: 'Subhaana Rabbiyal \'Azeem (×3)',
      translitBn: 'সুবহানা রাব্বিয়াল আজিম (৩ বার)',
      meaningBn: 'আমার মহান রবের পবিত্রতা ঘোষণা করছি',
      meaningEn: 'Glory be to my Lord, the Almighty',
    ),
    NamazStep(
      stepNumber: 5,
      posture: PrayerPosture.qaumah,
      titleEn: 'Qawmah — Standing Upright',
      titleBn: 'কাওমা — সোজা হয়ে দাঁড়ানো',
      instructionEn: 'Rise completely upright from Ruku, hands at sides. Pause briefly in this position.',
      instructionBn: 'রুকু থেকে সম্পূর্ণ সোজা হয়ে দাঁড়ান, হাত দুটি পাশে ঝুলিয়ে রাখুন।',
      arabic: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ ۞ رَبَّنَا لَكَ الْحَمْدُ',
      translit: 'Sami\'Allaahu liman hamidah. Rabbanaa lakal hamd.',
      translitBn: 'সামিআল্লাহু লিমান হামিদাহ। রাব্বানা লাকাল হামদ।',
      meaningBn: 'আল্লাহ তাঁর প্রশংসাকারীদের কথা শোনেন। সকল প্রশংসা তোমার।',
      meaningEn: 'Allah hears whoever praises Him. All praise is Yours.',
    ),
    NamazStep(
      stepNumber: 6,
      posture: PrayerPosture.sujud,
      titleEn: 'Sujud — Arms Close to Body',
      titleBn: 'সিজদা — বাহু শরীরের সাথে',
      instructionEn: 'Prostrate compactly — keep elbows on the ground, arms close to sides, stomach resting on thighs. Feet together pointing right.',
      instructionBn: 'ছোট করে সিজদা করুন — কনুই মাটিতে রাখুন, বাহু শরীরের কাছে রাখুন, পেট রানের উপর আস্তে রাখুন। পা একসাথে ডানে বাঁকানো।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translit: 'Subhaana Rabbiyal A\'laa (×3)',
      translitBn: 'সুবহানা রাব্বিয়াল আলা (৩ বার)',
      meaningBn: 'আমার সর্বোচ্চ রবের পবিত্রতা ঘোষণা করছি',
      meaningEn: 'Glory be to my Lord, the Most High',
    ),
    NamazStep(
      stepNumber: 7,
      posture: PrayerPosture.jalsa,
      titleEn: 'Jalsah — Sitting Between Prostrations',
      titleBn: 'জালসা — দুই সিজদার মাঝে বসা',
      instructionEn: 'Sit with both feet pointing to the right side (tawarruk style). Hands placed on thighs.',
      instructionBn: 'দুই পা ডান দিকে বের করে বসুন (তাওয়াররুক ভঙ্গি)। হাত রানের উপর রাখুন।',
      arabic: 'رَبِّ اغْفِرْ لِي',
      translit: 'Rabbighfir lee',
      translitBn: 'রাব্বিগফির লী',
      meaningBn: 'হে আমার রব, আমাকে ক্ষমা করুন',
      meaningEn: 'O my Lord, forgive me',
    ),
    NamazStep(
      stepNumber: 8,
      posture: PrayerPosture.sujud,
      titleEn: 'Second Sujud',
      titleBn: 'দ্বিতীয় সিজদা',
      instructionEn: 'Perform second prostration compactly — elbows on ground, arms close to body.',
      instructionBn: 'দ্বিতীয় সিজদা আবার ছোট করে করুন — কনুই মাটিতে, বাহু শরীরের কাছে রাখুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translit: 'Subhaana Rabbiyal A\'laa (×3)',
      translitBn: 'সুবহানা রাব্বিয়াল আলা (৩ বার)',
      meaningBn: 'আমার সর্বোচ্চ রবের পবিত্রতা ঘোষণা করছি',
      meaningEn: 'Glory be to my Lord, the Most High',
    ),
    NamazStep(
      stepNumber: 9,
      posture: PrayerPosture.tashahhud,
      titleEn: 'Tashahhud — Final Sitting',
      titleBn: 'তাশাহহুদ — শেষ বৈঠক',
      instructionEn: 'Sit with both feet pointing right for all sittings. Hands flat on thighs. Raise index finger during Tashahhud.',
      instructionBn: 'সব বৈঠকে দুই পা ডান দিকে বের করে বসুন। হাত রানের উপর সমতল রাখুন। তাশাহহুদের সময় তর্জনী আঙুল উঁচু রাখুন।',
      arabic: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ...',
      translit: 'At-tahiyyaatu lillaahi was-salawaatu wat-tayyibaatu...',
      translitBn: 'আত্তাহিয়্যাতু লিল্লাহি ওয়াস সালাওয়াতু ওয়াত তাইয়্যিবাতু...',
      meaningBn: 'সকল সম্মান, ইবাদত ও পবিত্রতা আল্লাহর জন্য...',
      meaningEn: 'All compliments, prayers and pure words are due to Allah...',
    ),
    NamazStep(
      stepNumber: 10,
      posture: PrayerPosture.tasleem,
      titleEn: 'Salam — Ending Prayer',
      titleBn: 'সালাম — নামাজ শেষ',
      instructionEn: 'Turn head to the right saying "As-salamu alaykum wa rahmatullah", then to the left the same.',
      instructionBn: 'প্রথমে ডানে মুখ ফিরিয়ে "আস-সালামু আলাইকুম ওয়া রাহমাতুল্লাহ" বলুন, তারপর বামে।',
      arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
      translit: 'As-salaamu \'alaykum wa rahmatullaah',
      translitBn: 'আসসালামু আলাইকুম ওয়া রাহমাতুল্লাহ',
      meaningBn: 'আপনাদের উপর শান্তি ও আল্লাহর রহমত বর্ষিত হোক',
      meaningEn: 'Peace and mercy of Allah be upon you',
    ),
  ];

  List<NamazStep> get steps =>
      selectedGender.value == NamazGender.male ? maleSteps : femaleSteps;

  bool get isFirstStep => currentIndex.value == 0;
  bool get isLastStep => currentIndex.value >= steps.length;
  double get progress => (currentIndex.value + 1) / (steps.length + 1);

  void selectGender(NamazGender gender) {
    selectedGender.value = gender;
    currentIndex.value = 0;
  }

  void backToGenderSelection() {
    selectedGender.value = null;
    currentIndex.value = 0;
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  void nextStep() {
    if (!isLastStep) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void previousStep() {
    if (!isFirstStep) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void onPageChanged(int index) => currentIndex.value = index;

  void restart() {
    currentIndex.value = 0;
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
