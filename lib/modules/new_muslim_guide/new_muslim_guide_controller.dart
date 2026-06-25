import 'package:get/get.dart';

class WuduStep {
  final int stepNumber;
  final String titleEn;
  final String titleBn;
  final String descEn;
  final String descBn;

  const WuduStep({
    required this.stepNumber,
    required this.titleEn,
    required this.titleBn,
    required this.descEn,
    required this.descBn,
  });
}

class SalahStep {
  final int stepNumber;
  final String titleEn;
  final String titleBn;
  final String descEn;
  final String descBn;
  final String? arabic;
  final String? translitEn;
  final String? translitBn;

  const SalahStep({
    required this.stepNumber,
    required this.titleEn,
    required this.titleBn,
    required this.descEn,
    required this.descBn,
    this.arabic,
    this.translitEn,
    this.translitBn,
  });
}

class RakahBreakdown {
  final int fard;
  final int sunnahMuakkadah;
  final int sunnahGhairMuakkadah;
  final int nafl;
  final int witr;

  const RakahBreakdown({
    this.fard = 0,
    this.sunnahMuakkadah = 0,
    this.sunnahGhairMuakkadah = 0,
    this.nafl = 0,
    this.witr = 0,
  });

  int get total => fard + sunnahMuakkadah + sunnahGhairMuakkadah + nafl + witr;
}

class PrayerRakahInfo {
  final String nameEn;
  final String nameBn;
  final String timeEn;
  final String timeBn;
  final RakahBreakdown breakdown;
  final String descEn;
  final String descBn;

  const PrayerRakahInfo({
    required this.nameEn,
    required this.nameBn,
    required this.timeEn,
    required this.timeBn,
    required this.breakdown,
    required this.descEn,
    required this.descBn,
  });
}

class MistakeInfo {
  final String titleEn;
  final String titleBn;
  final String correctionEn;
  final String correctionBn;

  const MistakeInfo({
    required this.titleEn,
    required this.titleBn,
    required this.correctionEn,
    required this.correctionBn,
  });
}

class NewMuslimGuideController extends GetxController {
  final RxInt currentSalahStep = 0.obs;

  final List<WuduStep> wuduSteps = const [
    WuduStep(
      stepNumber: 1,
      titleEn: 'Intention (Niyyah)',
      titleBn: 'নিয়ত করা',
      descEn: 'Make a silent intention to perform Wudu for purification, and say "Bismillah" (In the name of Allah).',
      descBn: 'ওযু করার জন্য মনে মনে নিয়ত করুন এবং বলুন "বিসমিল্লাহ"।',
    ),
    WuduStep(
      stepNumber: 2,
      titleEn: 'Washing Hands',
      titleBn: 'হাত ধোয়া',
      descEn: 'Wash both hands up to the wrists three times, ensuring water reaches between the fingers.',
      descBn: 'দুই হাতের কবজি পর্যন্ত ভালো করে ৩ বার ধৌত করুন। আঙুলের ফাঁকে ভালো করে পানি পৌঁছান।',
    ),
    WuduStep(
      stepNumber: 3,
      titleEn: 'Rinsing the Mouth',
      titleBn: 'কুলি করা',
      descEn: 'Take water in your right hand, put it into your mouth, rinse thoroughly, and spit it out. Repeat three times.',
      descBn: 'ডান হাতে পানি নিয়ে মুখের ভেতর দিন এবং ভালো করে গড়গড়া করে কুলি করুন। এভাবে ৩ বার করুন।',
    ),
    WuduStep(
      stepNumber: 4,
      titleEn: 'Inhaling Water in Nose',
      titleBn: 'নাকে পানি দেওয়া',
      descEn: 'Take water in your right hand, sniff it into your nose, and expel it with your left hand. Repeat three times.',
      descBn: 'ডান হাত দিয়ে নাকে হালকা পানি টেনে দিন এবং বাম হাত দিয়ে নাক পরিষ্কার করুন। এভাবে ৩ বার করুন।',
    ),
    WuduStep(
      stepNumber: 5,
      titleEn: 'Washing the Face',
      titleBn: 'মুখমণ্ডল ধোয়া',
      descEn: 'Wash the entire face three times, from the hairline to the chin, and from ear to ear.',
      descBn: 'কপাল থেকে থুতনি এবং দুই কানের লতি পর্যন্ত পুরো মুখমণ্ডল ৩ বার ভালো করে ধৌত করুন।',
    ),
    WuduStep(
      stepNumber: 6,
      titleEn: 'Washing Arms',
      titleBn: 'হাত কনুই পর্যন্ত ধোয়া',
      descEn: 'Wash both arms up to the elbows three times, starting with the right arm first and then the left.',
      descBn: 'প্রথমে ডান হাত এবং পরে বাম হাত কনুই পর্যন্ত ভালো করে ৩ বার ধৌত করুন।',
    ),
    WuduStep(
      stepNumber: 7,
      titleEn: 'Wiping the Head (Masah)',
      titleBn: 'মাথা মাসেহ করা',
      descEn: 'Wet your hands, run them from the front of the head to the back, then wipe the inside of your ears with your index fingers and the back of your ears with your thumbs. Perform once.',
      descBn: 'দুই হাত ভিজিয়ে কপাল থেকে পেছনের দিক পর্যন্ত পুরো মাথা এবং তর্জনী ও বুড়ো আঙুল দিয়ে কানের ভেতর ও বাইরে ১ বার মাসেহ করুন।',
    ),
    WuduStep(
      stepNumber: 8,
      titleEn: 'Washing Feet',
      titleBn: 'পা টাখনু পর্যন্ত ধোয়া',
      descEn: 'Wash both feet up to the ankles three times, starting with the right foot and ensuring water flows between the toes.',
      descBn: 'প্রথমে ডান পা এবং পরে বাম পা টাখনু (গিরা) পর্যন্ত ভালো করে ৩ বার ধৌত করুন। পায়ের আঙুলের ফাঁকে ভালো করে পানি পৌঁছান।',
    ),
  ];

  final List<SalahStep> salahSteps = const [
    SalahStep(
      stepNumber: 1,
      titleEn: 'Niyyah (Intention)',
      titleBn: 'নিয়ত (Niyyah)',
      descEn: 'Stand facing the Qiblah. Focus your mind and heart on the prayer you are about to perform.',
      descBn: 'কিবলামুখী হয়ে দাঁড়ান এবং মনে মনে যে নামাজ পড়ছেন তার নিয়ত করুন।',
    ),
    SalahStep(
      stepNumber: 2,
      titleEn: 'Takbeeratul Ihram',
      titleBn: 'তাকবিরে তাহরিমা',
      descEn: 'Raise your hands and say "Allahu Akbar".',
      descBn: 'হাত কান পর্যন্ত উঠিয়ে বলুন "আল্লাহু আকবার"।',
      arabic: 'اللَّهُ أَكْبَرُ',
      translitEn: 'Allahu Akbar',
      translitBn: 'আল্লাহু আকবার',
    ),
    SalahStep(
      stepNumber: 3,
      titleEn: 'Qiyam & Recitation',
      titleBn: 'কিয়াম ও তিলওয়াত',
      descEn: 'Recite Surah Al-Fatihah followed by another Surah.',
      descBn: 'সূরা আল-ফাতেহা এবং অন্য একটি ছোট সূরা তিলওয়াত করুন।',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ...',
      translitEn: 'Bismillahir Rahmanir Rahim...',
      translitBn: 'বিসমিল্লাহির রাহমানির রাহিম...',
    ),
    SalahStep(
      stepNumber: 4,
      titleEn: 'Ruku (Bowing)',
      titleBn: 'রুকু (নত হওয়া)',
      descEn: 'Bow down and recite the glorification 3 times.',
      descBn: 'রুকুতে গিয়ে ৩ বার তাসবীহ পাঠ করুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      translitEn: 'Subhana Rabbiyal-Azeem',
      translitBn: 'সুবহানা রাব্বিয়াল আজীম',
    ),
    SalahStep(
      stepNumber: 5,
      titleEn: 'Sajdah (Prostration)',
      titleBn: 'সেজদাহ',
      descEn: 'Prostrate and recite the glorification 3 times.',
      descBn: 'সেজদায় গিয়ে ৩ বার তাসবীহ পাঠ করুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translitEn: 'Subhana Rabbiyal-A\'la',
      translitBn: 'সুবহানা রাব্বিয়াল আলা',
    ),
  ];

  final List<PrayerRakahInfo> prayers = const [
    PrayerRakahInfo(
      nameEn: 'Fajr',
      nameBn: 'ফজর',
      timeEn: 'Dawn',
      timeBn: 'ভোর',
      breakdown: RakahBreakdown(sunnahMuakkadah: 2, fard: 2),
      descEn: '2 Sunnah + 2 Fard',
      descBn: '২ রাকাত সুন্নত + ২ রাকাত ফরজ',
    ),
    PrayerRakahInfo(
      nameEn: 'Dhuhr',
      nameBn: 'যোহর',
      timeEn: 'Noon',
      timeBn: 'দুপুর',
      breakdown: RakahBreakdown(sunnahMuakkadah: 6, fard: 4, nafl: 2),
      descEn: '4 Sunnah + 4 Fard + 2 Sunnah + 2 Nafl',
      descBn: '৪ সুন্নত + ৪ ফরজ + ২ সুন্নত + ২ নফল',
    ),
    PrayerRakahInfo(
      nameEn: 'Asr',
      nameBn: 'আসর',
      timeEn: 'Afternoon',
      timeBn: 'বিকাল',
      breakdown: RakahBreakdown(sunnahGhairMuakkadah: 4, fard: 4),
      descEn: '4 Sunnah + 4 Fard',
      descBn: '৪ সুন্নত + ৪ ফরজ',
    ),
    PrayerRakahInfo(
      nameEn: 'Maghrib',
      nameBn: 'মাগরিব',
      timeEn: 'Sunset',
      timeBn: 'সন্ধ্যা',
      breakdown: RakahBreakdown(fard: 3, sunnahMuakkadah: 2, nafl: 2),
      descEn: '3 Fard + 2 Sunnah + 2 Nafl',
      descBn: '৩ ফরজ + ২ সুন্নত + ২ নফল',
    ),
    PrayerRakahInfo(
      nameEn: 'Isha',
      nameBn: 'ইশা',
      timeEn: 'Night',
      timeBn: 'রাত',
      breakdown: RakahBreakdown(fard: 4, sunnahMuakkadah: 2, witr: 3),
      descEn: '4 Fard + 2 Sunnah + 3 Witr',
      descBn: '৪ ফরজ + ২ সুন্নত + ৩ বিতর',
    ),
  ];

  final List<MistakeInfo> commonMistakes = const [
    MistakeInfo(
      titleEn: 'Moving too fast',
      titleBn: 'তাড়াহুড়ো করা',
      correctionEn: 'Perform every movement with calmness and stillness (Tumaneenah).',
      correctionBn: 'নামাজের প্রতিটি রুকন অত্যন্ত ধীরস্থিরভাবে আদায় করুন।',
    ),
    MistakeInfo(
      titleEn: 'Looking around',
      titleBn: 'এদিকে ওদিকে তাকানো',
      correctionEn: 'Keep your eyes fixed on the spot where your head touches the ground during prostration.',
      correctionBn: 'সেজদার জায়গায় দৃষ্টি স্থির রাখুন।',
    ),
    MistakeInfo(
      titleEn: 'Resting forearms on ground',
      titleBn: 'সেজদায় কনুই মাটিতে রাখা',
      correctionEn: 'Keep your elbows and forearms raised off the ground during Sajdah (for men).',
      correctionBn: 'সেজদা করার সময় দুই হাতের কনুই মাটি থেকে উপরে তুলে রাখুন।',
    ),
  ];

  final List<Map<String, String>> shortSurahs = const [
    {
      'nameEn': 'Al-Fatihah',
      'nameBn': 'আল-ফাতিহা',
      'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ (১) الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ (২) الرَّحْمَٰنِ الرَّحِيمِ (৩) مَالِكِ يَوْمِ الدِّينِ (৪) إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ (৫) اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ (৬) صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ (৭)',
      'descEn': 'Essential for every Rak\'ah of Salah.',
      'descBn': 'নামাজের প্রতিটি রাকাতে এটি পাঠ করা আবশ্যক।',
    },
    {
      'nameEn': 'Al-Ikhlas',
      'nameBn': 'আল-ইখলাস',
      'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ (১) اللَّهُ الصَّمَدُ (২) لَمْ يَلِدْ وَلَمْ يُولَدْ (৩) وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ (৪)',
      'descEn': 'Declaration of Allah\'s Oneness.',
      'descBn': 'আল্লাহর একত্ববাদের ঘোষণা। এটি কুরআনের এক-তৃতীয়াংশের সমান।',
    },
    {
      'nameEn': 'Al-Falaq',
      'nameBn': 'আল-ফালাক',
      'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ (১) مِن شَرِّ مَا خَلَقَ (২) وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ (৩) وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ (৪) وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ (৫)',
      'descEn': 'Seeking protection from outer evils.',
      'descBn': 'বাইরের অনিষ্ট থেকে আল্লাহর কাছে আশ্রয় চাওয়ার সূরা।',
    },
    {
      'nameEn': 'An-Nas',
      'nameBn': 'আন-নাস',
      'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ (১) مَلِكِ النَّاسِ (২) إِلَٰهِ النَّاسِ (৩) مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ (৪) الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ (৫) مِنَ الْجِنَّةِ وَالنَّاسِ (৬)',
      'descEn': 'Seeking protection from inner whispers.',
      'descBn': 'শয়তানের কুপ্ররোচনা থেকে আল্লাহর কাছে আশ্রয় চাওয়ার সূরা।',
    },
  ];

  final List<Map<String, String>> adabEtiquette = const [
    {
      'titleEn': 'Eating',
      'titleBn': 'খাওয়ার আদব',
      'descEn': 'Say "Bismillah", eat with right hand, and say "Alhamdulillah" after finishing.',
      'descBn': 'বিসমিল্লাহ বলে শুরু করা, ডান হাতে খাওয়া এবং শেষে আলহামদুলিল্লাহ বলা।',
    },
    {
      'titleEn': 'Sleeping',
      'titleBn': 'শোয়ার আদব',
      'descEn': 'Perform Wudu, sleep on the right side, and recite the sleeping dua.',
      'descBn': 'ওযু করা, ডান কাতে শোয়া এবং শোয়ার দোয়া পাঠ করা।',
    },
    {
      'titleEn': 'Speaking',
      'titleBn': 'কথা বলার আদব',
      'descEn': 'Speak the truth, be kind, and avoid backbiting or lying.',
      'descBn': 'সত্য কথা বলা, নম্রভাবে কথা বলা এবং গীবত বা মিথ্যা পরিহার করা।',
    },
  ];

  void nextSalahStep() {
    if (currentSalahStep.value < salahSteps.length - 1) {
      currentSalahStep.value++;
    }
  }

  void prevSalahStep() {
    if (currentSalahStep.value > 0) {
      currentSalahStep.value--;
    }
  }
}
