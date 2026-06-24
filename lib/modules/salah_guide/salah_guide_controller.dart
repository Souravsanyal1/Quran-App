import 'package:get/get.dart';

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

class SalahTypeInfo {
  final String typeEn;
  final String typeBn;
  final String significanceEn;
  final String significanceBn;
  final String ruleEn;
  final String ruleBn;
  final String exampleEn;
  final String exampleBn;

  const SalahTypeInfo({
    required this.typeEn,
    required this.typeBn,
    required this.significanceEn,
    required this.significanceBn,
    required this.ruleEn,
    required this.ruleBn,
    required this.exampleEn,
    required this.exampleBn,
  });
}

class SalahGuideController extends GetxController {
  final RxInt currentStep = 0.obs;

  final List<PrayerRakahInfo> prayers = const [
    PrayerRakahInfo(
      nameEn: 'Fajr',
      nameBn: 'ফজর',
      timeEn: 'Dawn (before sunrise)',
      timeBn: 'ভোর (সূর্যোদয়ের পূর্বে)',
      breakdown: RakahBreakdown(sunnahMuakkadah: 2, fard: 2),
      descEn: 'Fajr is the first of the five daily prayers. It is performed at dawn before sunrise. It consists of 2 Rak\'ah Sunnah Mu\'akkadah followed by 2 Rak\'ah Fard.',
      descBn: 'ফজর হলো দিনের প্রথম ফরজ নামাজ। এটি ভোরবেলা সূর্যোদয়ের পূর্বে আদায় করতে হয়। এতে প্রথমে ২ রাকাত সুন্নাতে মুয়াক্কাদাহ এবং পরে ২ রাকাত ফরজ নামাজ রয়েছে।',
    ),
    PrayerRakahInfo(
      nameEn: 'Dhuhr',
      nameBn: 'যোহর',
      timeEn: 'Midday (after sun passes zenith)',
      timeBn: 'দুপুর (সূর্য পশ্চিম আকাশে ঢলে পড়ার পর)',
      breakdown: RakahBreakdown(sunnahMuakkadah: 6, fard: 4, nafl: 2),
      descEn: 'Dhuhr is the second daily prayer, performed in the afternoon. It contains a total of 12 Rak\'ahs: 4 Sunnah Mu\'akkadah (before Fard), 4 Fard, 2 Sunnah Mu\'akkadah (after Fard), and 2 Nafl.',
      descBn: 'যোহর হলো দিনের দ্বিতীয় ফরজ নামাজ। এটি দুপুরে সূর্য পশ্চিম আকাশে ঢলে পড়ার পর পড়তে হয়। এতে মোট ১২ রাকাত রয়েছে: ৪ রাকাত সুন্নাতে মুয়াক্কাদাহ, ৪ রাকাত ফরজ, ২ রাকাত সুন্নাতে মুয়াক্কাদাহ এবং ২ রাকাত নফল।',
    ),
    PrayerRakahInfo(
      nameEn: 'Asr',
      nameBn: 'আসর',
      timeEn: 'Late afternoon (before sunset)',
      timeBn: 'বিকাল (সূর্য ডোবার পূর্ব মুহূর্ত পর্যন্ত)',
      breakdown: RakahBreakdown(sunnahGhairMuakkadah: 4, fard: 4),
      descEn: 'Asr is the third daily prayer, performed in the late afternoon. It consists of 4 Rak\'ah Sunnah Ghair Mu\'akkadah followed by 4 Rak\'ah Fard.',
      descBn: 'আসর হলো দিনের তৃতীয় ফরজ নামাজ। এটি বিকালে সূর্য ডোবার আগে পড়তে হয়। এতে প্রথমে ৪ রাকাত সুন্নাতে গাইরে মুয়াক্কাদাহ এবং পরে ৪ রাকাত ফরজ নামাজ রয়েছে।',
    ),
    PrayerRakahInfo(
      nameEn: 'Maghrib',
      nameBn: 'মাগরিব',
      timeEn: 'Just after sunset',
      timeBn: 'সন্ধ্যা (সূর্যাস্তের ঠিক পরপরই)',
      breakdown: RakahBreakdown(fard: 3, sunnahMuakkadah: 2, nafl: 2),
      descEn: 'Maghrib is the fourth daily prayer, performed right after sunset. It consists of 3 Rak\'ah Fard, 2 Rak\'ah Sunnah Mu\'akkadah, and 2 Rak\'ah Nafl.',
      descBn: 'মাগরিব হলো দিনের চতুর্থ ফরজ নামাজ। এটি সূর্যাস্তের ঠিক পরপরই আদায় করতে হয়। এতে প্রথমে ৩ রাকাত ফরজ, তারপর ২ রাকাত সুন্নাতে মুয়াক্কাদাহ এবং শেষে ২ রাকাত নফল রয়েছে।',
    ),
    PrayerRakahInfo(
      nameEn: 'Isha',
      nameBn: 'ইশা',
      timeEn: 'Night (after twilight disappears)',
      timeBn: 'রাত (পশ্চিম আকাশের লালিমা সম্পূর্ণ মুছে যাওয়ার পর)',
      breakdown: RakahBreakdown(sunnahGhairMuakkadah: 4, fard: 4, sunnahMuakkadah: 2, witr: 3, nafl: 4),
      descEn: 'Isha is the fifth daily prayer, performed at night. It contains a total of 17 Rak\'ahs: 4 Sunnah Ghair Mu\'akkadah, 4 Fard, 2 Sunnah Mu\'akkadah, 2 Nafl, 3 Witr (Wajib), and 2 Nafl.',
      descBn: 'ইশা হলো দিনের পঞ্চম ও শেষ ফরজ নামাজ। এটি রাতে আদায় করতে হয়। এতে মোট ১৭ রাকাত রয়েছে: ৪ রাকাত সুন্নাতে গাইরে মুয়াক্কাদাহ, ৪ রাকাত ফরজ, ২ রাকাত সুন্নাতে মুয়াক্কাদাহ, ২ রাকাত নফল, ৩ রাকাত বিতর (ওয়াজিব) এবং শেষে আরও ২ রাকাত নফল নামাজ।',
    ),
  ];

  final List<SalahTypeInfo> salahTypes = const [
    SalahTypeInfo(
      typeEn: 'Fard (Obligatory)',
      typeBn: 'ফরজ (অবশ্যই পালনীয়)',
      significanceEn: 'Absolutely mandatory. Intentionally missing them is a grave sin.',
      significanceBn: 'ইসলামের অন্যতম স্তম্ভ। প্রাপ্তবয়স্ক ও সুস্থ প্রত্যেক মুসলিমের উপর এটি পালন করা আবশ্যক। ইচ্ছাকৃতভাবে তরক করা কবিরা গুনাহ।',
      ruleEn: 'Must be performed. If missed due to valid reasons (sleep/forgetfulness), they must be made up (Qada) as soon as possible.',
      ruleBn: 'অবশ্যই আদায় করতে হবে। কোনো কারণে ছুটে গেলে পরবর্তীতে তা কাযা আদায় করা আবশ্যক।',
      exampleEn: 'The Fard parts of the 5 Daily prayers, Jumu\'ah (Friday) prayer, and Janazah (Funeral) prayer (Fard Kifayah).',
      exampleBn: '৫ ওয়াক্ত নামাজের ফরজ অংশসমূহ এবং জুমার নামাজ (ফরজে আইন)। জানাজার নামাজ (ফরজে কিফায়াহ)।',
    ),
    SalahTypeInfo(
      typeEn: 'Wajib (Necessary)',
      typeBn: 'ওয়াজিব (অপরিহার্য)',
      significanceEn: 'Highly emphasized and mandatory in practice. Missing them is a sin.',
      significanceBn: 'ফরজের পরেই এর গুরুত্ব ও স্থান। এটি ওয়াজিব বা অপরিহার্য। ইচ্ছাকৃতভাবে ছেড়ে দেওয়া গুনাহের কাজ।',
      ruleEn: 'Must be performed and requires Qada (makeup) if missed.',
      ruleBn: 'অবশ্যই আদায় করতে হবে এবং ছুটে গেলে তা কাযা আদায় করতে হবে।',
      exampleEn: 'Witr prayer (after Isha), Eid prayers (Eid-ul-Fitr & Eid-ul-Adha), Sajdah of Recitation (Sajdah Sahw/Tilawah).',
      exampleBn: 'ইশার পর ৩ রাকাত বিতর নামাজ, দুই ঈদের নামাজ এবং কুরআন তিলওয়াতের সেজদা (সেজদায়ে তিলাওয়াত)।',
    ),
    SalahTypeInfo(
      typeEn: 'Sunnah (Prophetic Practice)',
      typeBn: 'সুন্নাত (রাসুলুল্লাহ সাঃ এর আমল)',
      significanceEn: 'Prayers established by the Prophet Muhammad (PBUH). Adhering to them brings great rewards and completes shortcomings in Fard prayers.',
      significanceBn: 'রাসুলুল্লাহ (সাঃ) ফরজ নামাজ ব্যতীত অতিরিক্ত যে নামাজ নিজে আদায় করতেন ও পড়তে উৎসাহিত করেছেন। এটি আদায় করলে অনেক সওয়াব।',
      ruleEn: 'Divided into:\n• Sunnah Mu\'akkadah (Emphasized): The Prophet rarely missed these. Omitting them regularly is disliked.\n• Sunnah Ghair Mu\'akkadah (Non-emphasized): The Prophet performed them sometimes and skipped them sometimes.',
      ruleBn: 'দুই প্রকার:\n• সুন্নতে মুয়াক্কাদাহ: যা রাসুলুল্লাহ (সাঃ) নিয়মিত পড়তেন। নিয়মিত তা বর্জন করা অনুচিত।\n• সুন্নতে গাইরে মুয়াক্কাদাহ: যা রাসুলুল্লাহ (সাঃ) কখনো পড়েছেন আবার কখনো পড়েননি।',
      exampleEn: '2 Rak\'ah before Fajr, 4 before Dhuhr, 2 after Dhuhr, 2 after Maghrib, and 2 after Isha (Mu\'akkadah). 4 before Asr and 4 before Isha (Ghair Mu\'akkadah).',
      exampleBn: 'ফজরের ২ রাকাত সুন্নত, যোহরের আগের ৪ ও পরের ২ রাকাত, মাগরিবের পরের ২ রাকাত ও ইশার পরের ২ রাকাত (মুয়াক্কাদাহ)। আসরের আগের ৪ রাকাত ও ইশার আগের ৪ রাকাত (গাইরে মুয়াক্কাদাহ)।',
    ),
    SalahTypeInfo(
      typeEn: 'Nafl (Voluntary)',
      typeBn: 'নফল (ঐচ্ছিক বা অতিরিক্ত)',
      significanceEn: 'Optional prayers that bring one closer to Allah. There is no sin or blame for omitting them.',
      significanceBn: 'সম্পূর্ণ অতিরিক্ত নামাজ। আল্লাহ তাআলার নৈকট্য অর্জনের একটি চমৎকার মাধ্যম। এটি না পড়লে কোনো গুনাহ নেই।',
      ruleEn: 'Can be performed at any permissible time. Compensates for deficiencies in Fard prayers on the Day of Judgment.',
      ruleBn: 'নিষিদ্ধ সময় ছাড়া যে কোনো সময় আদায় করা যায়। হাশরের মাঠে বান্দার ফরজের হিসাব কম পড়লে তা এই নফল নামাজ দ্বারা পূরণ করা হবে।',
      exampleEn: 'Tahajjud (Night Prayer), Ishraq (Sunrise Prayer), Duha/Chasht (Forenoon Prayer), Awabin (Evening Prayer), Tahiyyatul Masjid (Mosque Prayer).',
      exampleBn: 'তাহাজ্জুদ (শেষ রাতের নামাজ), ইশরাক ও চাশত (দিনের শুরুর নামাজ), আওয়াবীন (মাগরিবের পরের নামাজ), তাহিয়্যাতুল মাসজিদ (মসজিদে প্রবেশের পর নামাজ)।',
    ),
  ];

  final List<SalahStep> steps = const [
    SalahStep(
      stepNumber: 1,
      titleEn: 'Niyyah (Intention)',
      titleBn: 'নিয়ত (Niyyah)',
      descEn: 'Stand facing the Qiblah. Focus your mind and heart on the prayer you are about to perform (intention does not need to be verbal).',
      descBn: 'কিবলামুখী হয়ে দাঁড়ান এবং মনে মনে যে নামাজ পড়ছেন তার নিয়ত করুন (মুখে নিয়ত উচ্চারণ করা জরুরি নয়)।',
    ),
    SalahStep(
      stepNumber: 2,
      titleEn: 'Takbeeratul Ihram',
      titleBn: 'তাকবিরে তাহরিমা',
      descEn: 'Raise your hands to your ears (for men) or shoulders (for women) and say "Allahu Akbar". Fold your hands on your chest/navel afterwards.',
      descBn: 'হাত কান পর্যন্ত (পুরুষ) অথবা কাঁধ পর্যন্ত (মহিলা) উঠিয়ে বলুন "আল্লাহু আকবার"। এরপর ডান হাত বাম হাতের উপর বুকের উপর/নাভির নিচে বাঁধুন।',
      arabic: 'اللَّهُ أَكْبَرُ',
      translitEn: 'Allahu Akbar',
      translitBn: 'আল্লাহু আকবার',
    ),
    SalahStep(
      stepNumber: 3,
      titleEn: 'Qiyam & Sana',
      titleBn: 'কিয়াম ও সানা পাঠ',
      descEn: 'Recite the opening invocation (Sana), followed by Surah Al-Fatihah and an additional short Surah or passage from the Quran.',
      descBn: 'প্রথমে সানা পাঠ করুন। এরপর সূরা আল-ফাতেহা পড়ে অন্য একটি ছোট সূরা বা কুরআনের কিছু অংশ তিলওয়াত করুন।',
      arabic: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ',
      translitEn: 'Subhanakal-lahumma wabihamdika watabarakas-muka wata\'ala jadduka wala ilaha ghayruk',
      translitBn: 'সুবহানাকা আল্লাহুম্মা ওয়া বিহামদিকা ওয়া তাবারাকাসমুকা ওয়া তাআলা জাদ্দুকা ওয়া লা ইলাহা গাইরুকা',
    ),
    SalahStep(
      stepNumber: 4,
      titleEn: 'Ruku (Bowing)',
      titleBn: 'রুকু (নত হওয়া)',
      descEn: 'Say "Allahu Akbar" and bow down, placing your hands on your knees with your back straight. Recite the glorification of Ruku 3 times.',
      descBn: '"আল্লাহু আকবার" বলে রুকুতে যান এবং হাত দিয়ে হাঁটু আঁকড়ে ধরুন। রুকুতে ৩ বার তাসবীহ পাঠ করুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      translitEn: 'Subhana Rabbiyal-Azeem (3 times)',
      translitBn: 'সুবহানা রাব্বিয়াল আজীম (৩ বার)',
    ),
    SalahStep(
      stepNumber: 5,
      titleEn: 'Qaumah (Standing)',
      titleBn: 'কওমা (রুকু থেকে দাঁড়ানো)',
      descEn: 'Rise from bowing while saying "Sami\'Allahu liman hamidah" and when standing straight say "Rabbana lakal hamd".',
      descBn: 'রুকু থেকে সোজা হয়ে দাঁড়ানোর সময় বলুন "সামিআল্লাহু লিমান হামিদাহ" এবং সোজা হয়ে দাঁড়িয়ে বলুন "রাব্বানা লাকাল হামদ"।',
      arabic: 'سَمِعَ اللَّهُ لِمَن حَمِدَهُ • رَبَّنَا وَلَكَ الْحَمْدُ',
      translitEn: 'Sami\'Allahu liman hamidah • Rabbana lakal-hamd',
      translitBn: 'সামিআল্লাহু লিমান হামিদাহ • রাব্বানা ওয়া লাকাল হামদ',
    ),
    SalahStep(
      stepNumber: 6,
      titleEn: 'Sajdah (Prostration)',
      titleBn: 'সেজদাহ (Prostration)',
      descEn: 'Say "Allahu Akbar" and prostrate on the floor, with knees, hands, forehead, nose, and toes touching the ground. Recite the glorification of Sajdah 3 times.',
      descBn: '"আল্লাহু আকবার" বলে মাটিতে সেজদা করুন। কপাল, নাক, দুই হাত, দুই হাঁটু এবং পায়ের আঙ্গুল মাটি স্পর্শ করবে। সেজদায় ৩ বার তাসবীহ পাঠ করুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translitEn: 'Subhana Rabbiyal-A\'la (3 times)',
      translitBn: 'সুবহানা রাব্বিয়াল আলা (৩ বার)',
    ),
    SalahStep(
      stepNumber: 7,
      titleEn: 'Jalsah (Sitting)',
      titleBn: 'জলসা (বসা)',
      descEn: 'Say "Allahu Akbar" and sit upright. Place hands on thighs. Say this short dua, then repeat Sajdah again.',
      descBn: '"আল্লাহু আকবার" বলে সেজদা থেকে উঠে সোজা হয়ে বসুন। উরুর উপর হাত রাখুন। এই সংক্ষিপ্ত দোয়াটি পাঠ করুন এবং পুনরায় সেজদা করুন।',
      arabic: 'اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي وَعَافِنِي وَارْزُقْنِي',
      translitEn: 'Allahum-maghfirli warhamni wahdini wa\'afini warzuqni',
      translitBn: 'আল্লাহুম্মাগফিরলী ওয়ারহামনী ওয়াহদিনী ওয়া আফিনী ওয়ারজুকনী',
    ),
    SalahStep(
      stepNumber: 8,
      titleEn: 'Tashahhud (Sitting)',
      titleBn: 'তাশাহুদ (বৈঠক)',
      descEn: 'In the final rak\'ah, sit and recite Tashahhud, Durood Ibrahim, and Dua Masoorah.',
      descBn: 'শেষ রাকাতে বসে তাশাহুদ, দুরুদে ইব্রাহিম এবং দোয়া মাসুরা পাঠ করুন।',
      arabic: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ...',
      translitEn: 'Attahiyyatu lillahi was-salawatu wat-tayyibat...',
      translitBn: 'আত্তাহিয়্যাতু লিল্লাহি ওয়াস-সালাওয়াতু ওয়াত-তাইয়্যিবাত...',
    ),
    SalahStep(
      stepNumber: 9,
      titleEn: 'Salam (Ending)',
      titleBn: 'সালাম ফেরানো',
      descEn: 'Turn your face to the right saying "Assalamu alaykum wa rahmatullah", then turn to the left and say the same.',
      descBn: 'প্রথমে ডানদিকে মুখ ঘুরিয়ে বলুন "আসসালামু আলাইকুম ওয়া রাহমাতুল্লাহ", এরপর বামদিকে মুখ ঘুরিয়ে একই কথা বলুন।',
      arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
      translitEn: 'Assalamu alaykum wa rahmatullah',
      translitBn: 'আসসালামু আলাইকুম ওয়া রাহমাতুল্লাহ',
    ),
  ];

  void nextStep() {
    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void setStep(int index) {
    if (index >= 0 && index < steps.length) {
      currentStep.value = index;
    }
  }
}
