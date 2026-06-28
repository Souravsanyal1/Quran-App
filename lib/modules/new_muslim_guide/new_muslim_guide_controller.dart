import 'package:get/get.dart';

class WuduStep {
  final int stepNumber;
  final String titleEn;
  final String titleBn;
  final String descEn;
  final String descBn;
  const WuduStep({required this.stepNumber, required this.titleEn, required this.titleBn, required this.descEn, required this.descBn});
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
      'arabic': 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا শَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَরَسُولُهُ',
      'translitBn': 'আশহাদু আল্লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারিকা লাহু ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসুলুহু।',
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

  final List<Map<String, String>> shortSurahs = const [
    {
      'nameBn': 'সূরা আল-ফাতিহা',
      'nameEn': 'Surah Al-Fatihah',
      'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۞ الْحَمْدُ لِلَّهِ রَبِّ الْعَالَمِينَ ۞ الرَّحْمَنِ الرَّحِيمِ ۞ মَالِكِ يَوْمِ الدِّينِ ۞ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۞ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۞ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      'translit': 'Bismillahir-rahmanir-rahim. Alhamdu lillahi rabbil \'alamin. Ar-rahmanir rahim. Maliki yawmid-din. Iyyaka na\'budu wa iyyaka nasta\'in. Ihdinas-siratal mustaqim. Siratalladhina an\'amta \'alayhim, ghayril maghdubi \'alayhim walad-dallin.',
      'meaning': 'In the name of Allah, the Most Gracious, the Most Merciful. All praise is due to Allah, the Lord of the worlds. The Most Gracious, the Most Merciful. Master of the Day of Judgment. You alone we worship and You alone we ask for help...',
    },
    {
      'nameBn': 'সূরা আল-ইখলাস',
      'nameEn': 'Surah Al-Ikhlas',
      'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ ۞ اللَّهُ الصَّمَدُ ۞ لَمْ يَلِدْ وَلَمْ يُولَدْ ۞ وَلَمْ يَكُن لَّهُ كُফُوًا أَحَدٌ',
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
