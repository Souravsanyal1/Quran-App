import 'package:get/get.dart';

class DuaItem {
  final String titleEn;
  final String titleBn;
  final String arabic;
  final String translationEn;
  final String translationBn;
  final String pronunciationBn;
  final String categoryEn;
  final String categoryBn;

  const DuaItem({
    required this.titleEn,
    required this.titleBn,
    required this.arabic,
    required this.translationEn,
    required this.translationBn,
    required this.pronunciationBn,
    required this.categoryEn,
    required this.categoryBn,
  });
}

class DuasController extends GetxController {
  final RxString selectedCategoryEn = 'Daily'.obs;

  final List<String> categoriesEn = const ['Daily', 'Prayer', 'Protection', 'Morning & Evening'];
  final List<String> categoriesBn = const ['দৈনন্দিন', 'নামাজ', 'সুরক্ষা', 'সকাল ও সন্ধ্যা'];

  final List<DuaItem> duas = const [
    // ── Daily Category ──────────────────────────────────────────────────────
    DuaItem(
      titleEn: 'Before Eating',
      titleBn: 'খাবারের শুরুতে দোয়া',
      arabic: 'بِسْمِ اللَّهِ',
      translationEn: 'In the name of Allah.',
      translationBn: 'আল্লাহর নামে (শুরু করছি)।',
      pronunciationBn: 'বিসমিল্লাহ।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'After Eating',
      titleBn: 'খাবার শেষের দোয়া',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      translationEn: 'Praise be to Allah Who has fed us and given us drink, and made us Muslims.',
      translationBn: 'সব প্রশংসা আল্লাহর জন্য, যিনি আমাদের খাইয়েছেন, পান করিয়েছেন এবং মুসলিম বানিয়েছেন।',
      pronunciationBn: 'আলহামদু লিল্লাহিল্লাজী আতআমানা ওয়া সাকানা ওয়া জাআালানা মুসলিমীন।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'Dua for Parents',
      titleBn: 'পিতামাতার জন্য দোয়া',
      arabic: 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      translationEn: 'My Lord, have mercy upon them as they brought me up [when I was] small.',
      translationBn: 'হে আমার প্রতিপালক! তাদের প্রতি দয়া করো যেভাবে তারা শৈশবে আমাকে প্রতিপালন করেছিলেন।',
      pronunciationBn: 'রাব্বির হামহুমা কামা রাব্বাইয়ানি সাগীরা।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'Before Sleeping',
      titleBn: 'ঘুমানোর পূর্বের দোয়া',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      translationEn: 'In Your name, O Allah, I die and I live.',
      translationBn: 'হে আল্লাহ! আপনার নামে আমি মৃত্যুবরণ করি (ঘুমাই) এবং জীবিত হই (জাগি)।',
      pronunciationBn: 'বিইসমিকা আল্লাহুম্মা আমূতু ওয়া আহয়া।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'Upon Waking Up',
      titleBn: 'ঘুম থেকে ওঠার দোয়া',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      translationEn: 'Praise is to Allah Who gives us life after He has caused us to die and unto Him is the resurrection.',
      translationBn: 'সব প্রশংসা আল্লাহর জন্য যিনি মৃত্যুর পর আমাদের জীবিত করলেন এবং তাঁর দিকেই ফিরে যেতে হবে।',
      pronunciationBn: 'আলহামদু লিল্লাহিল্লাজী আহইয়ানা বা’দা মা আমাতানা ওয়া ইলাইহিন নুশূর।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'Entering the Home',
      titleBn: 'ঘরে প্রবেশের দোয়া',
      arabic: 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
      translationEn: 'In the name of Allah we enter, and in the name of Allah we leave, and upon our Lord we depend.',
      translationBn: 'আল্লাহর নামে আমরা প্রবেশ করি, আল্লাহর নামে আমরা বের হই এবং আমাদের প্রতিপালক আল্লাহর ওপর ভরসা করি।',
      pronunciationBn: 'বিসমিল্লাহি ওয়ালাজনা, ওয়া বিসমিল্লাহি খারাজনা, ওয়া আলাল্লাহি রাব্বিনা তাওয়াক্কালনা।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'Leaving the Home',
      titleBn: 'ঘর থেকে বের হওয়ার দোয়া',
      arabic: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      translationEn: 'In the name of Allah, I place my trust in Allah, and there is no might or power except with Allah.',
      translationBn: 'আল্লাহর নামে, আমি আল্লাহর ওপর ভরসা করলাম। আল্লাহর সাহায্য ছাড়া গুনাহ থেকে বাঁচার এবং নেক কাজ করার কোনো শক্তি নেই।',
      pronunciationBn: 'বিসমিল্লাহি তাওয়াক্কালতু আলাল্লাহি, ওয়া লা হাওলা ওয়া লা কুয়্যাতা ইল্লা বিল্লাহ।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'Entering the Mosque',
      titleBn: 'মসজিদে প্রবেশের দোয়া',
      arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      translationEn: 'O Allah, open for me the gates of Your mercy.',
      translationBn: 'হে আল্লাহ! আমার জন্য আপনার রহমতের দরজাগুলো খুলে দিন।',
      pronunciationBn: 'আল্লাহুম্মাফ তাহলী আবওয়াবা রাহমাতিকা।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'Leaving the Mosque',
      titleBn: 'মসজিদ থেকে বের হওয়ার দোয়া',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      translationEn: 'O Allah, I ask You of Your bounty.',
      translationBn: 'হে আল্লাহ! আমি আপনার অনুগ্রহ প্রার্থনা করছি।',
      pronunciationBn: 'আল্লাহুম্মা ইন্নী আসআলুকা মিন ফাদলিকা।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),

    // ── Prayer Category ─────────────────────────────────────────────────────
    DuaItem(
      titleEn: 'Dua for Knowledge',
      titleBn: 'জ্ঞান বৃদ্ধির দোয়া',
      arabic: 'رَّبِّ زِدْنِي عِلْمًا',
      translationEn: 'My Lord, increase me in knowledge.',
      translationBn: 'হে আমার প্রতিপালক! আমার জ্ঞান বাড়িয়ে দিন।',
      pronunciationBn: 'রাব্বি জিদনি ইলমা।',
      categoryEn: 'Prayer',
      categoryBn: 'নামাজ',
    ),
    DuaItem(
      titleEn: 'For Goodness in This Life & Hereafter',
      titleBn: 'দুনিয়া ও আখেরাতের কল্যাণের দোয়া',
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      translationEn: 'Our Lord, give us in this world [that which is] good and in the Hereafter [that which is] good and protect us from the punishment of the Fire.',
      translationBn: 'হে আমাদের প্রতিপালক! আমাদের দুনিয়াতে কল্যাণ দিন এবং আখেরাতেও কল্যাণ দিন এবং আমাদের আগুনের আজাব থেকে রক্ষা করুন।',
      pronunciationBn: 'রাব্বানা আতিনা ফিদ দুনিয়া হাসানাতাও ওয়া ফিল আখিরাতি হাসানাতাও ওয়া কিনা আজাবান নার।',
      categoryEn: 'Prayer',
      categoryBn: 'নামাজ',
    ),
    DuaItem(
      titleEn: 'For Steadfastness of Heart',
      titleBn: 'ঈমানের ওপর অবিচল থাকার দোয়া',
      arabic: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
      translationEn: 'O Controller of hearts, make my heart steadfast in Your religion.',
      translationBn: 'হে অন্তরের পরিবর্তনকারী! আমার অন্তরকে আপনার দ্বীনের ওপর অবিচল রাখুন।',
      pronunciationBn: 'ইয়া মুকাল্লিবাল কুলূবি সাব্বিত কালবী আলা দীনিকা।',
      categoryEn: 'Prayer',
      categoryBn: 'নামাজ',
    ),
    DuaItem(
      titleEn: 'Protection from Hell & Grave',
      titleBn: 'জাহান্নাম ও কবরের আজাব থেকে মুক্তি',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَمِنْ عَذَابِ الْقَبْرِ، وَمِنْ فِতْنَةِ الْمَحْيَا وَالْمَمَاتِ، وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ',
      translationEn: 'O Allah, I seek refuge in You from the punishment of Hell, from the punishment of the grave, from the trials of life and death, and from the evil of the trial of Dajjal.',
      translationBn: 'হে আল্লাহ! আমি আপনার কাছে আশ্রয় চাই জাহান্নামের আজাব থেকে, কবরের আজাব থেকে, জীবন ও মৃত্যুর ফিতনা থেকে এবং দাজ্জালের ফিতনার ক্ষতি থেকে।',
      pronunciationBn: 'আল্লাহুম্মা ইন্নী আউযুবিকা মিন আযাবি জাহান্নামা, ওয়া মিন আযাবিল কাবরি, ওয়া মিন ফিতনাতিল মাহয়া ওয়াল মামাতি, ওয়া মিন শাররি ফিতনাতিল মাসীহিদ দাজ্জাল।',
      categoryEn: 'Prayer',
      categoryBn: 'নামাজ',
    ),
    DuaItem(
      titleEn: 'Dua for Patience',
      titleBn: 'ধৈর্য ও অবিচলতার দোয়া',
      arabic: 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      translationEn: 'Our Lord, pour upon us patience and plant firmly our feet and give us victory over the disbelieving people.',
      translationBn: 'হে আমাদের প্রতিপালক! আমাদের ওপর ধৈর্য ঢেলে দিন, আমাদের পা অবিচল রাখুন এবং কাফের সম্প্রদায়ের বিরুদ্ধে আমাদের সাহায্য করুন।',
      pronunciationBn: 'রাব্বানা আফরিগ আলাইনা সাবরাও ওয়া সাব্বিত আকদামানা ওয়ানসুরনা আলাল কাওমিল কাফিরীন।',
      categoryEn: 'Prayer',
      categoryBn: 'নামাজ',
    ),

    // ── Protection Category ─────────────────────────────────────────────────
    DuaItem(
      titleEn: 'Seeking Forgiveness (Istighfar)',
      titleBn: 'ক্ষমা প্রার্থনা (ইস্তিগফার)',
      arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      translationEn: 'I seek the forgiveness of Allah and turn to Him in repentance.',
      translationBn: 'আমি আল্লাহর কাছে ক্ষমা চাচ্ছি এবং তাঁর দিকেই ফিরে যাচ্ছি।',
      pronunciationBn: 'আস্তাগফিরুল্লাহ ওয়া আতূবু ইলাইহি।',
      categoryEn: 'Protection',
      categoryBn: 'সুরক্ষা',
    ),
    DuaItem(
      titleEn: 'For Protection from Harm',
      titleBn: 'ক্ষতি থেকে সুরক্ষার দোয়া',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      translationEn: 'In the name of Allah, with whose name nothing can cause harm on earth or in the heaven, and He is the All-Hearing, the All-Knowing.',
      translationBn: 'আল্লাহর নামে, যাঁর নামের বরকতে আসমান ও জমিনের কোনো কিছুই কোনো ক্ষতি করতে পারে না, আর তিনি সর্বশ্রোতা, সর্বজ্ঞ।',
      pronunciationBn: 'বিসমিল্লাহিল্লাজী লা ইয়াদুররু মাআসমিহী শাইউন ফিল আরদি ওয়া লা ফিস সামা-ই, ওয়া হুয়াস সামীউল আলীম।',
      categoryEn: 'Protection',
      categoryBn: 'সুরক্ষা',
    ),
    DuaItem(
      titleEn: 'Protection from Worry & Debt',
      titleBn: 'চিন্তা ও ঋণ থেকে মুক্তির দোয়া',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْজِ وَالْكَসَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
      translationEn: 'O Allah, I seek refuge in You from anxiety and sorrow, weakness and laziness, miserliness and cowardice, the burden of debts and from being overpowered by men.',
      translationBn: 'হে আল্লাহ! আমি আপনার কাছে আশ্রয় চাই দুশ্চিন্তা ও দুঃখ থেকে, অপারগতা ও অলসতা থেকে, কৃপণতা ও ভীরুতা থেকে, ঋণের বোঝা ও মানুষের দমন-পীড়ন থেকে।',
      pronunciationBn: 'আল্লাহুম্মা ইন্নী আউযুবিকা মিনাল হামমি ওয়াল হাযানি, ওয়াল আজযি ওয়াল কাসালি, ওয়াল বুখলি ওয়াল جুবনি, ওয়া দ্বালাইদ দাইনি ওয়া গালাবাতির রিজাল।',
      categoryEn: 'Protection',
      categoryBn: 'সুরক্ষা',
    ),
    DuaItem(
      titleEn: 'Protection from Severe Illness',
      titleBn: 'কঠিন রোগ-ব্যাধি থেকে সুরক্ষার দোয়া',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْبَرَصِ، وَالْجُنُونِ، وَالْجُذَامِ، وَمِنْ سَيِّئِ الْأَسْقَامِ',
      translationEn: 'O Allah, I seek refuge in You from leucoderma, insanity, leprosy and all evil diseases.',
      translationBn: 'হে আল্লাহ! আমি আপনার কাছে আশ্রয় চাই ধবল, উন্মাদনা, কুষ্ঠরোগ এবং সকল প্রকার কঠিন ও মন্দ ব্যাধি থেকে।',
      pronunciationBn: 'আল্লাহুম্মা ইন্নী আউযুবিকা মিনাল বারাসি, ওয়াল জুনূনি, ওয়াল জুযামি, ওয়া মিন সাইয়্যিইল আসক্বাম।',
      categoryEn: 'Protection',
      categoryBn: 'সুরক্ষা',
    ),

    // ── Morning & Evening Category ──────────────────────────────────────────
    DuaItem(
      titleEn: 'Chief Prayer for Forgiveness (Sayyidul Istighfar)',
      titleBn: 'ক্ষমা প্রার্থনার শ্রেষ্ঠ দোয়া (সাইয়্যিদুল ইস্তিগফার)',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      translationEn: 'O Allah, You are my Lord, none has the right to be worshipped except You. You created me and I am Your servant, and I abide by Your covenant and promise as best as I can. I seek refuge in You from the evil of what I have done. I acknowledge Your grace upon me, and I acknowledge my sin, so forgive me, for none forgives sins except You.',
      translationBn: 'হে আল্লাহ! আপনি আমার প্রতিপালক। আপনি ছাড়া কোনো সত্য ইলাহ নেই। আপনি আমাকে সৃষ্টি করেছেন এবং আমি আপনার বান্দা। আমি আমার সাধ্যমতো আপনার অঙ্গীকার ও প্রতিশ্রুতির ওপর প্রতিষ্ঠিত আছি। আমি আমার কৃতকর্মের অনিষ্টতা থেকে আপনার আশ্রয় চাচ্ছি। আমার প্রতি আপনার নেয়ামত স্বীকার করছি এবং আমার গুনাহও স্বীকার করছি। অতএব আমাকে ক্ষমা করুন, কারণ আপনি ছাড়া আর কেউ গুনাহ ক্ষমা করতে পারে না।',
      pronunciationBn: 'আল্লাহুম্মা আনতা রাব্বী লা ইলাহা ইল্লা আনতা খালাকতানি ওয়া আনা আবদুকা ওয়া আনা আলা আহদিকা ওয়া ওয়া’দিকা মাসতাতাতু, আউযুবিকা মিন শাররি মা সানাতু আবূউ লাকা বিনি’মাতিকা আলাইয়্যা ওয়া আবূউ বিযানবী ফাগফিরলী ফাইন্নাহু লা ইয়াগফিরুয যুনূবা ইল্লা আনতা।',
      categoryEn: 'Morning & Evening',
      categoryBn: 'সকাল ও সন্ধ্যা',
    ),
    DuaItem(
      titleEn: 'Dua for Well-being & Protection',
      titleBn: 'কল্যাণ ও নিরাপত্তার দোয়া',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      translationEn: 'O Allah, I ask You for forgiveness and well-being in this world and the Hereafter.',
      translationBn: 'হে আল্লাহ! আমি আপনার কাছে দুনিয়া ও আখেরাতের ক্ষমা ও কল্যাণ প্রার্থনা করছি।',
      pronunciationBn: 'আল্লাহুম্মা ইন্নি আসআলুকাল আফওয়া ওয়াল আফিয়াতা ফিদ দুনইয়া ওয়াল আখিরাহ।',
      categoryEn: 'Morning & Evening',
      categoryBn: 'সকাল ও সন্ধ্যা',
    ),
    DuaItem(
      titleEn: 'Protection from All Evils',
      titleBn: 'সব রকমের অনিষ্ট থেকে সুরক্ষার দোয়া',
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      translationEn: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
      translationBn: 'আল্লাহর পরিপূর্ণ কালিমাসমূহের ওসিলায় তাঁর সৃষ্টির যাবতীয় অনিষ্ট থেকে আশ্রয় চাই।',
      pronunciationBn: 'আউযু বিকালিমাতিলাহিত তাম্মাতি মিন শাররি মা খালাক্ব।',
      categoryEn: 'Morning & Evening',
      categoryBn: 'সকাল ও সন্ধ্যা',
    ),
    DuaItem(
      titleEn: 'Before Wudu',
      titleBn: 'ওযুর শুরুতে দোয়া',
      arabic: 'بِسْمِ اللَّهِ',
      translationEn: 'In the name of Allah.',
      translationBn: 'আল্লাহর নামে (শুরু করছি)।',
      pronunciationBn: 'বিসমিল্লাহ।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'After Wudu',
      titleBn: 'ওযুর শেষের দোয়া',
      arabic: 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
      translationEn: 'I bear witness that there is no god but Allah alone, without partner, and I bear witness that Muhammad is His servant and Messenger.',
      translationBn: 'আমি সাক্ষ্য দিচ্ছি যে, এক আল্লাহ ছাড়া কোনো মাবুদ নেই, তাঁর কোনো অংশীদার নেই। আমি আরও সাক্ষ্য দিচ্ছি যে, মুহাম্মদ (সাঃ) তাঁর বান্দা ও রাসুল।',
      pronunciationBn: 'আশহাদু আল্লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকা লাহু, ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসুলুহু।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'Dua of Prophet Yunus',
      titleBn: 'বিপদের সময় দোয়া (ইউনুস আঃ)',
      arabic: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      translationEn: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
      translationBn: 'আপনি ছাড়া কোনো সত্য উপাস্য নেই, আপনি পবিত্র ও মহান! নিশ্চয়ই আমি জালেমদের অন্তর্ভুক্ত ছিলাম।',
      pronunciationBn: 'লা ইলাহা ইল্লা আনতা সুবহানাকা ইন্নী কুনতু মিনায যালিমীন।',
      categoryEn: 'Prayer',
      categoryBn: 'নামাজ',
    ),
    DuaItem(
      titleEn: 'Dua for Forgiveness (Abu Bakr\'s Prayer)',
      titleBn: 'ক্ষমা প্রার্থনার দোয়া (আবু বকর রাঃ)',
      arabic: 'اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ، فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ وَارْحَمْنِي، إِنَّك أَنْتَ الْغَفُورُ الرَّحِيمُ',
      translationEn: 'O Allah, I have greatly wronged myself, and no one forgives sins except You. So grant me forgiveness from You and have mercy on me. Indeed, You are the Forgiving, the Merciful.',
      translationBn: 'হে আল্লাহ! আমি নিজের ওপর অনেক জুলুম করেছি, আর আপনি ছাড়া গুনাহ ক্ষমা করার কেউ নেই। অতএব আপনার পক্ষ থেকে আমাকে ক্ষমা করুন এবং আমার প্রতি দয়া করুন। নিশ্চয়ই আপনি ক্ষমাশীল ও পরম দয়ালু।',
      pronunciationBn: 'আল্লাহুম্মা ইন্নী যলাকতু নাফসী যুলমান কাছীরাও ওয়া লা ইয়াগফিরুয যুনূবা ইল্লা আনতা, ফাগফিরলী মাগফিরাতাম মিন ইনদিকা ওয়ারহামনী ইন্নাকা আনতাল গাফুরুর রাহীম।',
      categoryEn: 'Prayer',
      categoryBn: 'নামাজ',
    ),
    DuaItem(
      titleEn: 'Protection from Evil Eye',
      titleBn: 'কুদৃষ্টি ও হিংসা থেকে বাঁচার দোয়া',
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ',
      translationEn: 'I seek refuge in the perfect words of Allah from every devil and poisonous beast, and from every envious eye.',
      translationBn: 'আমি আশ্রয় চাচ্ছি আল্লাহর পরিপূর্ণ কালিমাসমূহের ওসিলায় প্রত্যেক শয়তান, বিষাক্ত জীবজন্তু এবং ক্ষতিকর কুদৃষ্টির অনিষ্ট থেকে।',
      pronunciationBn: 'আউযু বিকালিমাতিলাহিত তাম্মাতি মিন কুল্লি শায়তানিও ওয়া হাম্মাহ, ওয়া মিন কুল্লি আইনিন লাম্মাহ।',
      categoryEn: 'Protection',
      categoryBn: 'সুরক্ষা',
    ),
    DuaItem(
      titleEn: 'Dua for Ease',
      titleBn: 'সব কাজ সহজ হওয়ার দোয়া',
      arabic: 'اللَّهُمَّ لَا سَهْلَ إِلَّا مَا جَعَلْتَهُ سَهْلًا، وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلًا',
      translationEn: 'O Allah, there is no ease except in that which You have made easy, and You make the difficulty, if You will, easy.',
      translationBn: 'হে আল্লাহ! আপনি যা সহজ করেছেন তা ছাড়া কোনো কিছুই সহজ নয়। আর আপনি চাইলে কঠিন কাজকেও সহজ করে দেন।',
      pronunciationBn: 'আল্লাহুম্মা লা সাহলা ইল্লা মা জাআলতাহু সাহলা, ওয়া আনতা তাজআলুল হাযনা ইযা শি’তা সাহলা।',
      categoryEn: 'Protection',
      categoryBn: 'সুরক্ষা',
    ),
    DuaItem(
      titleEn: 'Morning Gratitude',
      titleBn: 'দিনের শুকরিয়া আদায়ের দোয়া',
      arabic: 'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
      translationEn: 'O Allah, whatever blessing has come to me or any of Your creation this morning is from You alone, without partner. To You is all praise and to You is all thanks.',
      translationBn: 'হে আল্লাহ! এই সকালে আমার ওপর বা আপনার সৃষ্টির অন্য কারো ওপর যে নেয়ামত নাজিল হয়েছে তা একমাত্র আপনার পক্ষ থেকে, আপনার কোনো অংশীদার নেই। অতএব সব প্রশংসা ও কৃতজ্ঞতা আপনারই জন্য।',
      pronunciationBn: 'আল্লাহুম্মা মা আসবাহা বী মিন নি’মাতিন আও বিআহাদিম মিন খালক্বিকা ফামিনকা ওয়াহদাকা লা শারীকা লাকা ফালাকাল হামদু ওয়া লাকাশ শুকরু।',
      categoryEn: 'Morning & Evening',
      categoryBn: 'সকাল ও সন্ধ্যা',
    ),
    DuaItem(
      titleEn: 'Protection with Ayat al-Kursi',
      titleBn: 'আয়াতুল কুরসি (সুরক্ষার আয়াত)',
      arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَมَا فِي الْأَرْضِ',
      translationEn: 'Allah! There is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth.',
      translationBn: 'আল্লাহ, তিনি ছাড়া কোনো ইলাহ নেই, তিনি চিরঞ্জীব, সবকিছুর ধারক। তাঁকে তন্দ্রা ও ঘুম স্পর্শ করতে পারে না। আসমান ও জমিনে যা কিছু আছে সবকিছু তাঁরই।',
      pronunciationBn: 'আল্লাহু লা ইলাহা ইল্লা হুয়াল হাইয়্যুল কাইয়্যুম, লা তা’খুযুহু সিনাতুও ওয়া লা নাওম, লাহু মা ফিসসামাওয়াতি ওয়া মা ফিল আরদ...',
      categoryEn: 'Morning & Evening',
      categoryBn: 'সকাল ও সন্ধ্যা',
    ),
  ];


  List<DuaItem> get filteredDuas {
    return duas.where((dua) => dua.categoryEn == selectedCategoryEn.value).toList();
  }

  void selectCategory(String category) {
    selectedCategoryEn.value = category;
  }
}
