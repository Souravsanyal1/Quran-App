import 'package:get/get.dart';

class WuduStep {
  final int stepNumber;
  final String titleEn;
  final String titleBn;
  final String descEn;
  final String descBn;
  const WuduStep({required this.stepNumber, required this.titleEn, required this.titleBn, required this.descEn, required this.descBn});
}

class SalahStep {
  final int stepNumber;
  final String titleEn;
  final String titleBn;
  final String descEn;
  final String descBn;
  final String? arabic;
  final String? translit;
  final String? meaning;

  const SalahStep({
    required this.stepNumber,
    required this.titleEn,
    required this.titleBn,
    required this.descEn,
    required this.descBn,
    this.arabic,
    this.translit,
    this.meaning,
  });
}

class NewMuslimGuideController extends GetxController {
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Simulate data loading for shimmer effect
    Future.delayed(const Duration(milliseconds: 800), () {
      isLoading.value = false;
    });
  }

  final List<Map<String, String>> essentialBeliefs = const [
    {
      'titleBn': 'কালিমা তাইয়্যিবা',
      'titleEn': 'Kalima Tayyiba',
      'arabic': 'لَا إِلَهَ إِلَّا اللهُ مُحَمَّدٌ رَسُولُ اللهِ',
      'translitBn': 'লা ইলাহা ইল্লাল্লাহু মুহাম্মাদুর রাসুলুল্লাহ।',
      'translitEn': 'La ilaha illallah Muhammadur Rasulullah',
      'meaningBn': 'আল্লাহ ছাড়া কোনো উপাস্য নেই, মুহাম্মদ (সাঃ) আল্লাহর রাসূল।',
      'meaningEn': 'There is no god but Allah, and Muhammad is the Messenger of Allah.',
    },
    {
      'titleBn': 'কালিমা শাহাদাত',
      'titleEn': 'Kalima Shahadat',
      'arabic': 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
      'translitBn': 'আশহাদু আল্লা ইলাহা ইল্লাল্লাহু ওয়ান-হু লা শারিকা লাহু ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসুলুহু।',
      'translitEn': 'Ash-hadu alla ilaha illallahu wahdahu la sharika lahu wa ash-hadu anna Muhammadan abduhu wa Rasuluhu.',
      'meaningBn': 'আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া কোনো উপাস্য নেই, তিনি এক, তাঁর কোনো শরিক নেই। আমি আরও সাক্ষ্য দিচ্ছি যে, মুহাম্মদ (সাঃ) তাঁর বান্দা ও রাসূল।',
      'meaningEn': 'I bear witness that there is no god but Allah, He is one, He has no partner. And I bear witness that Muhammad is His servant and Messenger.',
    },
    {
      'titleBn': 'ঈমানের মূল স্তম্ভসমূহ',
      'titleEn': 'Pillars of Iman',
      'descBn': '১. আল্লাহর প্রতি বিশ্বাস\n২. ফেরেশতাদের প্রতি বিশ্বাস\n৩. আসমানী কিতাবসমূহের প্রতি বিশ্বাস\n৪. নবী ও রাসূলদের প্রতি বিশ্বাস\n৫. পরকাল বা কিয়ামতের প্রতি বিশ্বাস\n৬. ভাগ্যের (তাকদীরের) প্রতি বিশ্বাস',
      'descEn': '1. Belief in Allah\n2. Belief in Angels\n3. Belief in Divine Books\n4. Belief in Prophets\n5. Belief in the Day of Judgment\n6. Belief in Fate (Qadr)',
    },
  ];

  final List<Map<String, String>> dailyLifestyle = const [
    {
      'titleBn': 'পোশাক ও শালীনতা',
      'titleEn': 'Clothing & Modesty',
      'descBn': 'ইসলামে শালীন পোশাক পরা বাধ্যতামূলক। পুরুষদের নাভি থেকে হাঁটু পর্যন্ত এবং নারীদের পুরো শরীর (মুখমণ্ডল ও দুই হাত ছাড়া) ঢেকে রাখা ইসলামের নির্দেশ।',
      'descEn': 'In Islam, wearing modest clothing is mandatory. For men, from the navel to the knees, and for women, the entire body (except face and hands) should be covered.',
    },
    {
      'titleBn': 'পারিবারিক ও সামাজিক আচরণ',
      'titleEn': 'Family & Social Behavior',
      'descBn': 'পিতা-মাতার সাথে সদাচরণ, প্রতিবেশীর হক আদায় এবং সত্য কথা বলা একজন মুমিনের প্রধান বৈশিষ্ট্য।',
      'descEn': 'Good behavior towards parents, fulfilling the rights of neighbors, and speaking the truth are key characteristics of a believer.',
    },
    {
      'titleBn': 'আয় ও উপার্জনের মাধ্যম',
      'titleEn': 'Income & Earnings',
      'descBn': 'ইসলামে বৈধ (হালাল) উপায়ে উপার্জন করা ইবাদতের অংশ। সুদ, ঘুষ, জুয়া এবং প্রতারণার মাধ্যমে উপার্জন করা সম্পূর্ণ হারাম।',
      'descEn': 'Earning through lawful (Halal) means is considered an act of worship in Islam. Income from interest, bribery, gambling, and fraud is strictly forbidden.',
    },
  ];

  final List<WuduStep> wuduSteps = const [
    WuduStep(stepNumber: 1, titleEn: 'Intention', titleBn: 'নিয়ত', descEn: 'Say Bismillah and have the intention in your heart.', descBn: 'বিসমিল্লাহ বলে শুরু করা এবং মনে মনে ওযুর নিয়ত করা।'),
    WuduStep(stepNumber: 2, titleEn: 'Hands', titleBn: 'হাত ধোয়া', descEn: 'Wash hands up to the wrists 3 times.', descBn: 'কবজি পর্যন্ত ৩ বার হাত ধোয়া।'),
    WuduStep(stepNumber: 3, titleEn: 'Mouth', titleBn: 'কুলি করা', descEn: 'Rinse mouth 3 times.', descBn: '৩ বার কুলি করা।'),
    WuduStep(stepNumber: 4, titleEn: 'Nose', titleBn: 'নাক পরিষ্কার', descEn: 'Clean nose 3 times by sniffing water and blowing it out.', descBn: '৩ বার নাকে পানি দিয়ে পরিষ্কার করা।'),
    WuduStep(stepNumber: 5, titleEn: 'Face', titleBn: 'মুখমণ্ডল', descEn: 'Wash face 3 times, from hairline to chin and ear to ear.', descBn: 'পুরো মুখমণ্ডল ৩ বার ধোয়া।'),
    WuduStep(stepNumber: 6, titleEn: 'Arms', titleBn: 'হাত ধোয়া', descEn: 'Wash arms up to and including the elbows 3 times, right then left.', descBn: 'কনুই পর্যন্ত ৩ বার হাত ধোয়া (প্রথমে ডান হাত, তারপর বাম)।'),
    WuduStep(stepNumber: 7, titleEn: 'Head', titleBn: 'মাসেহ', descEn: 'Wipe head once with wet hands, and wipe ears.', descBn: 'মাথা ও কান ১ বার মাসেহ করা।'),
    WuduStep(stepNumber: 8, titleEn: 'Feet', titleBn: 'পা ধোয়া', descEn: 'Wash feet up to the ankles 3 times, starting with the right.', descBn: 'টাখনু পর্যন্ত ৩ বার পা ধোয়া (প্রথমে ডান পা, তারপর বাম)।'),
  ];

  final List<SalahStep> salahSteps = const [
    SalahStep(
      stepNumber: 1,
      titleEn: 'Takbeer & Intention',
      titleBn: 'নিয়ত ও তাকবীরে তাহরীমা',
      descEn: 'Stand straight facing Qibla. Raise hands to your ears and say "Allahu Akbar".',
      descBn: 'কিবলামুখী হয়ে সোজা হয়ে দাঁড়ান। মনে মনে নিয়ত করে দুই হাত কান পর্যন্ত উঠিয়ে বলুন "আল্লাহু আকবার"।',
      arabic: 'اللَّهُ أَكْبَرُ',
      translit: 'Allahu Akbar',
      meaning: 'Allah is the Greatest',
    ),
    SalahStep(
      stepNumber: 2,
      titleEn: 'Qiyam (Standing & Recitation)',
      titleBn: 'কিয়াম ও কিরাত পাঠ',
      descEn: 'Fold hands on chest/below navel. Recite Sana, Surah Al-Fatihah, and a short Surah.',
      descBn: 'ডান হাত বাম হাতের উপর রেখে নাভির নিচে বা বুকের উপর বাঁধুন। এরপর সানা, সূরা ফাতিহা এবং অন্য একটি সূরা পাঠ করুন।',
    ),
    SalahStep(
      stepNumber: 3,
      titleEn: 'Ruku (Bowing)',
      titleBn: 'রুকু ও রুকুর তাসবিহ',
      descEn: 'Bow down keeping back straight and hands on knees. Say "Subhana Rabbiyal Azim" 3 times.',
      descBn: 'কোমর সোজা রেখে দুই হাত হাঁটুতে দিয়ে ঝুঁকুন। এরপর রুকুর তাসবিহ ৩ বার পড়ুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      translit: 'Subhana Rabbiyal Azim',
      meaning: 'Glory be to my Lord, the Almighty',
    ),
    SalahStep(
      stepNumber: 4,
      titleEn: 'Qawmah (Standing Up)',
      titleBn: 'রুকু থেকে সোজা হয়ে দাঁড়ানো',
      descEn: 'Stand straight from Ruku saying "Sami\'Allahu liman hamidah", then "Rabbana lakal hamd".',
      descBn: 'রুকু থেকে সোজা হয়ে দাঁড়িয়ে বলুন "সামিআল্লাহু লিমান হামিদাহ", এরপর বলুন "রাব্বানা লাকাল হামদ"।',
      arabic: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ ۞ رَبَّنَا لَكَ الْحَمْدُ',
      translit: 'Sami\'Allahu liman hamidah. Rabbana lakal hamd.',
      meaning: 'Allah hears those who praise Him. Our Lord, to You is all praise.',
    ),
    SalahStep(
      stepNumber: 5,
      titleEn: 'First Sujud (Prostration)',
      titleBn: 'প্রথম সিজদা',
      descEn: 'Go down to prostration with forehead, nose, knees, and palms on floor. Say "Subhana Rabbiyal A\'la" 3 times.',
      descBn: 'মাটিতে হাঁটু, হাত, নাক ও কপাল ঠেকিয়ে সিজদায় যান। সিজদার তাসবিহ ৩ বার পড়ুন।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translit: 'Subhana Rabbiyal A\'la',
      meaning: 'Glory be to my Lord, the Most High',
    ),
    SalahStep(
      stepNumber: 6,
      titleEn: 'Jalsah (Brief Sitting)',
      titleBn: 'দুই সিজদার মাঝখানে বসা',
      descEn: 'Rise to a sitting position. Keep back straight and sit briefly.',
      descBn: 'সিজদা থেকে মাথা উঠিয়ে সোজা হয়ে বসুন। একটি সংক্ষিপ্ত সময় সোজা হয়ে বসুন।',
    ),
    SalahStep(
      stepNumber: 7,
      titleEn: 'Second Sujud & Rakah Completion',
      titleBn: 'দ্বিতীয় সিজদা ও রাকাত সমাপ্তি',
      descEn: 'Perform the second prostration just like the first one. Saying the Tasbih 3 times completes 1 Rakah.',
      descBn: 'প্রথম সিজদার মতোই দ্বিতীয় সিজদা করুন। সিজদার তাসবিহ ৩ বার পাঠের মাধ্যমে ১ রাকাত সম্পন্ন হয়।',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      translit: 'Subhana Rabbiyal A\'la',
      meaning: 'Glory be to my Lord, the Most High',
    ),
    SalahStep(
      stepNumber: 8,
      titleEn: 'Tashahhud (Sitting Session)',
      titleBn: 'তাশাহহুদ বা বৈঠক',
      descEn: 'At the end of the 2nd and final Rakah, sit and recite Tashahhud (Attahiyyaat), Durood, and Dua Masura.',
      descBn: 'প্রতি ২য় এবং শেষ রাকাতে সিজদা শেষে বসে তাশাহহুদ (আত্তাহিয়্যাতু), দুরুদ এবং দুআ মাসূরা পড়ুন।',
      arabic: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ...',
      translit: 'Attahiyyaatu lillaahi was-salawaatu wat-tayyibaatu...',
      meaning: 'All compliments, prayers, and pure words are due to Allah...',
    ),
    SalahStep(
      stepNumber: 9,
      titleEn: 'Tasleem (Ending Salah)',
      titleBn: 'সালাম ফিরিয়ে নামাজ শেষ করা',
      descEn: 'Turn head right then left, saying "Assalamu Alaikum wa Rahmatullah". This ends your Salah.',
      descBn: 'প্রথমে ডান দিকে মুখ ফিরিয়ে সালাম দিন, এরপর বাম দিকে সালাম দিন। এতে নামাজ সম্পন্ন হয়।',
      arabic: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
      translit: 'Assalamu Alaikum wa Rahmatullah',
      meaning: 'Peace and blessings of Allah be upon you',
    ),
  ];

  final List<Map<String, String>> rakahRules = const [
    {
      'titleEn': '1st Rakah (First Unit)',
      'titleBn': '১ম রাকাত সম্পন্ন করার নিয়ম',
      'descEn': 'Start with Takbeer -> recite Sana, Surah Fatihah, and another Surah -> do Ruku -> do Qawmah -> do 2 Sujuds with a brief sitting in-between -> Stand up for the 2nd Rakah.',
      'descBn': 'তাকবীরে তাহরীমা দিয়ে শুরু করুন -> সানা, সূরা ফাতিহা এবং অন্য একটি সূরা পড়ুন -> রুকু করুন -> সোজা হয়ে দাঁড়ান -> মাঝখানে সংক্ষিপ্ত সময় বসে ২টি সিজদা দিন -> দাঁড়িয়ে ২য় রাকাত শুরু করুন।',
    },
    {
      'titleEn': '2nd Rakah (Second Unit)',
      'titleBn': '২য় রাকাত সম্পন্ন করার নিয়ম',
      'descEn': 'Recite Surah Fatihah and another Surah -> do Ruku -> do Qawmah -> do 2 Sujuds. If it is a 2-Rakah prayer (like Fajr), sit down for Tashahhud, Durood, Dua Masura, and Salam. Otherwise, sit, recite Tashahhud only, and stand up for the 3rd Rakah.',
      'descBn': 'সূরা ফাতিহা ও অন্য সূরা পড়ুন -> রুকু করুন -> সোজা হয়ে দাঁড়ান -> ২টি সিজদা দিন। যদি ২ রাকাতের নামাজ (যেমন: ফজর) হয়, তবে বসে তাশাহহুদ, দুরুদ ও দুআ মাসূরা পড়ে সালাম ফিরিয়ে নামাজ শেষ করুন। অন্যথায়, শুধু তাশাহহুদ পড়ে ৩য় রাকাতের জন্য দাঁড়িয়ে যান।',
    },
    {
      'titleEn': '3rd & 4th Rakah (Third & Fourth Units)',
      'titleBn': '৩য় ও ৪র্থ রাকাত সম্পন্ন করার নিয়ম',
      'descEn': 'Recite Surah Fatihah only (no extra Surah in Fard) -> do Ruku -> do Qawmah -> do 2 Sujuds. After the second Sujud of the final Rakah (3rd for Maghrib, 4th for others), sit down for final Tashahhud, Durood, Dua Masura, and Salam to end Salah.',
      'descBn': 'শুধুমাত্র সূরা ফাতিহা পড়ুন (অন্য সূরা মেলানোর প্রয়োজন নেই) -> রুকু করুন -> সোজা হয়ে দাঁড়ান -> ২টি সিজদা দিন। শেষ রাকাতের (মাগরিবের ৩য়, অন্যদের ৪র্থ) ২য় সিজদা শেষে বসে তাশাহহুদ, দুরুদ ও দুআ মাসূরা পড়ে ডানে ও বামে সালাম ফিরিয়ে নামাজ শেষ করুন।',
    },
  ];

  final List<Map<String, String>> shortSurahs = const [
    {
      'nameBn': 'সূরা আল-ফাতিহা',
      'nameEn': 'Surah Al-Fatihah',
      'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۞ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۞ الرَّحْمَنِ الرَّحِيمِ ۞ مَالِكِ يَوْمِ الدِّينِ ۞ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۞ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۞ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      'translit': 'Bismillahir-rahmanir-rahim. Alhamdu lillahi rabbil \'alamin. Ar-rahmanir rahim. Maliki yawmid-din. Iyyaka na\'budu wa iyyaka nasta\'in. Ihdinas-siratal mustaqim. Siratalladhina an\'amta \'alayhim, ghayril maghdubi \'alayhim walad-dallin.',
      'meaning': 'In the name of Allah, the Most Gracious, the Most Merciful. All praise is due to Allah, the Lord of the worlds. The Most Gracious, the Most Merciful. Master of the Day of Judgment. You alone we worship and You alone we ask for help...',
    },
    {
      'nameBn': 'সূরা আল-ইখলাস',
      'nameEn': 'Surah Al-Ikhlas',
      'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ ۞ اللَّهُ الصَّمَدُ ۞ لَمْ يَلِدْ وَلَمْ يُولَدْ ۞ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      'translit': 'Qul huwallahu ahad. Allahus-samad. Lam yalid walam yulad. Wa lam yakul-lahu kufuwan ahad.',
      'meaning': 'Say, "He is Allah, [who is] One. Allah, the Eternal Refuge. He neither begets nor is born. Nor is there to Him any equivalent."',
    },
    {
      'nameBn': 'সূরা আল-কাউসার',
      'nameEn': 'Surah Al-Kawthar',
      'arabic': 'إِنَّا أَعْطَيْنَيَاكَ الْكَوْثَرَ ۞ فَصَلِّ لِرَبِّكَ وَانْحَرْ ۞ إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
      'translit': 'Inna a\'taynaka al-kawthar. Fasalli lirabbika wanhar. Inna shani\'aka huwal-abtar.',
      'meaning': 'Indeed, We have granted you, [O Muhammad], al-Kawthar. So pray to your Lord and sacrifice [to Him alone]. Indeed, your enemy is the one cut off.',
    },
  ];

  final List<Map<String, String>> halalHaramItems = const [
    {
      'type': 'halal',
      'titleEn': 'Halal Meat',
      'titleBn': 'হালাল মাংস',
      'descEn': 'Meat slaughtered according to Islamic guidelines (Zabiha), with Allah\'s name mentioned.',
      'descBn': 'ইসলামিক নিয়মানুযায়ী (যাবিহা) আল্লাহর নাম উল্লেখ করে জবাই করা মাংস।',
    },
    {
      'type': 'haram',
      'titleEn': 'Pork & Alcohol',
      'titleBn': 'শুকরের মাংস ও মদ',
      'descEn': 'Strictly forbidden in Islam under all circumstances.',
      'descBn': 'ইসলামে যেকোনো পরিস্থিতিতে সম্পূর্ণ নিষিদ্ধ।',
    },
    {
      'type': 'halal',
      'titleEn': 'Seafood',
      'titleBn': 'সামুদ্রিক খাবার',
      'descEn': 'Most scholars agree that all fish and seafood from the ocean/river are permissible.',
      'descBn': 'বেশিরভাগ আলেম একমত যে সমুদ্র বা নদীর সব মাছ ও জলজ খাবার হালাল।',
    },
    {
      'type': 'haram',
      'titleEn': 'Interest (Riba)',
      'titleBn': 'সুদ (রিবা)',
      'descEn': 'Engaging in transactions involving interest is strictly prohibited in Islam.',
      'descBn': 'সুদযুক্ত যেকোনো লেনদেন ইসলামে কঠোরভাবে নিষিদ্ধ।',
    },
  ];
}
