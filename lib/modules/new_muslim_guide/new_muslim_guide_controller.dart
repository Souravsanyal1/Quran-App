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
  final String? translitBn;
  final String? meaningBn;

  const SalahStep({
    required this.stepNumber,
    required this.titleEn,
    required this.titleBn,
    required this.descEn,
    required this.descBn,
    this.arabic,
    this.translitBn,
    this.meaningBn,
  });
}

class NewMuslimGuideController extends GetxController {
  final RxInt currentSalahStep = 0.obs;

  final List<WuduStep> wuduSteps = const [
    WuduStep(stepNumber: 1, titleEn: 'Intention', titleBn: 'নিয়ত', descEn: 'Say Bismillah.', descBn: 'বিসমিল্লাহ বলে শুরু করা।'),
    WuduStep(stepNumber: 2, titleEn: 'Hands', titleBn: 'হাত ধোয়া', descEn: 'Wash hands 3 times.', descBn: 'কবজি পর্যন্ত ৩ বার হাত ধোয়া।'),
    WuduStep(stepNumber: 3, titleEn: 'Mouth', titleBn: 'কুলি করা', descEn: 'Rinse mouth 3 times.', descBn: '৩ বার কুলি করা।'),
    WuduStep(stepNumber: 4, titleEn: 'Nose', titleBn: 'নাক পরিষ্কার', descEn: 'Clean nose 3 times.', descBn: '৩ বার নাকে পানি দিয়ে পরিষ্কার করা।'),
    WuduStep(stepNumber: 5, titleEn: 'Face', titleBn: 'মুখমণ্ডল', descEn: 'Wash face 3 times.', descBn: 'পুরো মুখমণ্ডল ৩ বার ধোয়া।'),
    WuduStep(stepNumber: 6, titleEn: 'Arms', titleBn: 'হাত ধোয়া', descEn: 'Wash arms to elbows 3 times.', descBn: 'কনুই পর্যন্ত ৩ বার হাত ধোয়া।'),
    WuduStep(stepNumber: 7, titleEn: 'Head', titleBn: 'মাসেহ', descEn: 'Wipe head once.', descBn: 'মাথা ও কান ১ বার মাসেহ করা।'),
    WuduStep(stepNumber: 8, titleEn: 'Feet', titleBn: 'পা ধোয়া', descEn: 'Wash feet 3 times.', descBn: 'টাখনু পর্যন্ত ৩ বার পা ধোয়া।'),
  ];

  final List<SalahStep> salahSteps = const [
    SalahStep(
      stepNumber: 1,
      titleEn: 'Takbir', titleBn: 'তাকবিরে তাহরিমা',
      descEn: 'Raise hands to ears and say Allahu Akbar.',
      descBn: 'হাত কান পর্যন্ত উঠিয়ে "আল্লাহু আকবার" বলে হাত বাঁধুন।',
      arabic: 'اللَّهُ أَكْبَرُ',
      translitBn: 'আল্লাহু আকবার',
      meaningBn: 'আল্লাহ মহান।',
    ),
    SalahStep(
      stepNumber: 2,
      titleEn: 'Sana', titleBn: 'ছানা পাঠ',
      descEn: 'Recite Sana after starting.',
      descBn: 'হাত বাঁধার পর প্রথম রাকাতে এটি পড়তে হয়।',
      arabic: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ',
      translitBn: 'সুবহানাকা আল্লাহুম্মা ওয়া বিহামদিকা ওয়া তাবারাকাসমুকা ওয়া তাআলা জাদ্দুকা ওয়া লা ইলাহা গাইরুকা।',
      meaningBn: 'হে আল্লাহ! আমি আপনার পবিত্রতা বর্ণনা করছি এবং আপনার প্রশংসা করছি। আপনার নাম বরকতময়, আপনার মর্যাদা অতি উচ্চ এবং আপনি ব্যতীত আর কোন উপাস্য নেই।',
    ),
    SalahStep(
      stepNumber: 3,
      titleEn: 'Fatihah', titleBn: 'সূরা ফাতিহা',
      descEn: 'Recite Surah Al-Fatihah.',
      descBn: 'নামাজের প্রতিটি রাকাতে এটি পড়া বাধ্যতামূলক।',
      arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۞ الرَّحْمَنِ الرَّحِيمِ ۞ مَالِكِ يَوْمِ الدِّينِ ۞ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۞ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۞ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      translitBn: 'আলহামদু লিল্লাহি রাব্বিল আলামিন। আর রাহমানির রাহিম। মালিকি ইয়াওমিদ্দিন। ইয়্যাকা নাবুদু ওয়া ইয়্যাকা নাস্তায়িন। ইহদিনাস সিরাতাল মুস্তাকিম। সিরাতাল্লাজিনা আনআমতা আলাইহিম, গাইরিল মাগদুবি আলাইহিম ওয়ালাদ্দল্লিন।',
      meaningBn: 'সব প্রশংসা জগতসমূহের প্রতিপালক আল্লাহর জন্য। যিনি পরম দয়ালু ও অতি দয়ালু। বিচার দিবসের মালিক। আমরা কেবল আপনারই ইবাদত করি এবং কেবল আপনারই সাহায্য চাই...',
    ),
    SalahStep(
      stepNumber: 4,
      titleEn: 'Ruku', titleBn: 'রুকু (নত হওয়া)',
      descEn: 'Bow down and say Tasbih 3 times.',
      descBn: 'কোমর বাঁকিয়ে দুই হাঁটু ধরে ৩ বার এটি পড়ুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      translitBn: 'সুবহানা রাব্বিয়াল আজীম',
      meaningBn: 'আমার মহান প্রতিপালকের পবিত্রতা বর্ণনা করছি।',
    ),
    SalahStep(
      stepNumber: 5,
      titleEn: 'Sajdah', titleBn: 'সিজদাহ',
      descEn: 'Prostrate and say Tasbih 3 times.',
      descBn: 'মাটিতে কপাল ঠেকিয়ে ৩ বার এটি পড়ুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translitBn: 'সুবহানা রাব্বিয়াল আলা',
      meaningBn: 'আমার সর্বোচ্চ প্রতিপালকের পবিত্রতা বর্ণনা করছি।',
    ),
    SalahStep(
      stepNumber: 6,
      titleEn: 'Tashahhud', titleBn: 'তাশাহহুদ (আত্তাহিয়্যাতু)',
      descEn: 'Sit and recite in 2nd and last Rakah.',
      descBn: 'নামাজের বৈঠকে বসে এটি পড়তে হয়।',
      arabic: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ...',
      translitBn: 'আত্তাহিয়্যাতু লিল্লাহি ওয়াস সালাওয়াতু ওয়াত তাইয়্যিবাতু, আসসালামু আলাইকা আইয়ুহান নাবিয়্যু ওয়া রাহমাতুল্লাহি ওয়া বারাকাতুহু...',
      meaningBn: 'সমস্ত মৌখিক, শারীরিক ও আর্থিক ইবাদত আল্লাহর জন্য। হে নবী! আপনার উপর শান্তি, আল্লাহর রহমত ও বরকত বর্ষিত হোক...',
    ),
  ];

  final List<Map<String, String>> shortSurahs = const [
    {
      'nameBn': 'সূরা আল-ইখলাস',
      'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ ۞ اللَّهُ الصَّمَدُ ۞ لَمْ يَلِدْ وَلَمْ يُولَدْ ۞ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      'translit': 'কুল হুওয়াল্লাহু আহাদ। আল্লাহু সামাদ। লাম ইয়ালিদ ওয়া লাম ইউলাদ। ওয়া লাম ইয়াকুল্লাহু কুফুয়ান আহাদ।',
      'meaning': 'বলুন, তিনিই আল্লাহ, এক-অদ্বিতীয়। আল্লাহ কারো মুখাপেক্ষী নন, সবাই তাঁর মুখাপেক্ষী। তিনি কাউকে জন্ম দেননি এবং তাঁকেও জন্ম দেয়া হয়নি। এবং তাঁর সমতুল্য কেউ নেই।',
    },
    {
      'nameBn': 'সূরা আল-কাউসার',
      'arabic': 'إِنَّا أَعْطَيْنَاكَ الْكَوْوثرَ ۞ فَصَلِّ لِرَبِّكَ وَانْحَرْ ۞ إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
      'translit': 'ইন্না আ’তাইনা কাল কাউসার। ফাসাল্লি লিরাব্বিকা ওয়ানহার। ইন্না শানিআকা হুওয়াল আবতার।',
      'meaning': 'নিশ্চয় আমি আপনাকে কাউসার দান করেছি। অতএব আপনার প্রতিপালকের উদ্দেশ্যে নামাজ পড়ুন এবং কোরবানি করুন। নিশ্চয় আপনার শত্রুই নির্বংশ।',
    },
  ];

  final List<PrayerRakahInfo> prayers = const [
    PrayerRakahInfo(nameEn: 'Fajr', nameBn: 'ফজর', timeEn: 'Dawn', timeBn: 'ভোর', breakdown: RakahBreakdown(sunnahMuakkadah: 2, fard: 2), descEn: '2 Sunnah, 2 Fard', descBn: '২ রাকাত সুন্নত, ২ রাকাত ফরজ।'),
    PrayerRakahInfo(nameEn: 'Dhuhr', nameBn: 'যোহর', timeEn: 'Noon', timeBn: 'দুপুর', breakdown: RakahBreakdown(sunnahMuakkadah: 6, fard: 4, nafl: 2), descEn: '4+2 Sunnah, 4 Fard, 2 Nafl', descBn: '৪+২ রাকাত সুন্নত, ৪ রাকাত ফরজ, ২ রাকাত নফল।'),
    PrayerRakahInfo(nameEn: 'Asr', nameBn: 'আসর', timeEn: 'Afternoon', timeBn: 'বিকাল', breakdown: RakahBreakdown(fard: 4, sunnahGhairMuakkadah: 4), descEn: '4 Fard, 4 Sunnah', descBn: '৪ রাকাত ফরজ, ৪ রাকাত সুন্নতে গাইরে মুয়াক্কাদাহ।'),
    PrayerRakahInfo(nameEn: 'Maghrib', nameBn: 'মাগরিব', timeEn: 'Sunset', timeBn: 'সন্ধ্যা', breakdown: RakahBreakdown(fard: 3, sunnahMuakkadah: 2, nafl: 2), descEn: '3 Fard, 2 Sunnah, 2 Nafl', descBn: '৩ রাকাত ফরজ, ২ রাকাত সুন্নত, ২ রাকাত নফল।'),
    PrayerRakahInfo(nameEn: 'Isha', nameBn: 'ইশা', timeEn: 'Night', timeBn: 'রাত', breakdown: RakahBreakdown(fard: 4, sunnahMuakkadah: 2, witr: 3), descEn: '4 Fard, 2 Sunnah, 3 Witr', descBn: '৪ রাকাত ফরজ, ২ রাকাত সুন্নত, ৩ রাকাত বিতর।'),
  ];

  final List<MistakeInfo> commonMistakes = const [
    MistakeInfo(titleEn: 'Fast Speed', titleBn: 'তাড়াহুড়ো করা', correctionEn: 'Pray slowly.', correctionBn: 'নামাজের প্রতিটি কাজ ধীরস্থিরভাবে আদায় করুন।'),
    MistakeInfo(titleEn: 'Eyes position', titleBn: 'দৃষ্টি এদিক সেদিক করা', correctionEn: 'Look at Sajdah spot.', correctionBn: 'সেজদার জায়গায় দৃষ্টি স্থির রাখুন।'),
  ];

  void nextSalahStep() { if (currentSalahStep.value < salahSteps.length - 1) currentSalahStep.value++; }
  void prevSalahStep() { if (currentSalahStep.value > 0) currentSalahStep.value--; }
}

class PrayerRakahInfo {
  final String nameEn; final String nameBn; final String timeEn; final String timeBn;
  final RakahBreakdown breakdown; final String descEn; final String descBn;
  const PrayerRakahInfo({required this.nameEn, required this.nameBn, required this.timeEn, required this.timeBn, required this.breakdown, required this.descEn, required this.descBn});
}

class RakahBreakdown {
  final int fard; final int sunnahMuakkadah; final int sunnahGhairMuakkadah; final int nafl; final int witr;
  const RakahBreakdown({this.fard = 0, this.sunnahMuakkadah = 0, this.sunnahGhairMuakkadah = 0, this.nafl = 0, this.witr = 0});
}

class MistakeInfo {
  final String titleEn; final String titleBn; final String correctionEn; final String correctionBn;
  const MistakeInfo({required this.titleEn, required this.titleBn, required this.correctionEn, required this.correctionBn});
}
