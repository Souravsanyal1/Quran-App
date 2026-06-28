import 'package:get/get.dart';

class DuaItem {
  final String titleEn;
  final String titleBn;
  final String arabic;
  final String translationEn;
  final String translationBn;
  final String pronunciationEn;
  final String pronunciationBn;
  final String categoryEn;
  final String categoryBn;

  const DuaItem({
    required this.titleEn,
    required this.titleBn,
    required this.arabic,
    required this.translationEn,
    required this.translationBn,
    required this.pronunciationEn,
    required this.pronunciationBn,
    required this.categoryEn,
    required this.categoryBn,
  });
}

class DuasController extends GetxController {
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 800), () {
      isLoading.value = false;
    });
  }

  final RxString selectedCategoryEn = 'Daily'.obs;

  final List<String> categoriesEn = const ['Daily', 'Prayer', 'Protection', 'Morning & Evening'];
  final List<String> categoriesBn = const ['দৈনন্দিন', 'নামাজ', 'সুরক্ষা', 'সকাল ও সন্ধ্যা'];

  final List<DuaItem> duas = const [
    DuaItem(
      titleEn: 'Before Eating',
      titleBn: 'খাবারের শুরুতে দোয়া',
      arabic: 'بِسْمِ اللَّهِ',
      translationEn: 'In the name of Allah.',
      translationBn: 'আল্লাহর নামে (শুরু করছি)।',
      pronunciationEn: 'Bismillah.',
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
      pronunciationEn: 'Alhamdulillahilladhi at\'amana wa saqana wa ja\'alana muslimin.',
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
      pronunciationEn: 'Rabbir-hamhuma kama rabbayani saghira.',
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
      pronunciationEn: 'Bismika Allahumma amutu wa ahya.',
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
      pronunciationEn: 'Alhamdulillahilladhi ahyana ba\'da ma amatana wa ilayhin-nushur.',
      pronunciationBn: 'আলহামদু লিল্লাহিল্লাজী আহইয়ানা বা’দা মা আমাতানা ওয়া ইলাইহিন নুশূর।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'Entering the Mosque',
      titleBn: 'মসজিদে প্রবেশের দোয়া',
      arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      translationEn: 'O Allah, open for me the gates of Your mercy.',
      translationBn: 'হে আল্লাহ! আমার জন্য আপনার রহমতের দরজাগুলো খুলে দিন।',
      pronunciationEn: 'Allahumma-ftah li abwaba rahmatik.',
      pronunciationBn: 'আল্লাহুম্মাফ তাহলী আবওয়াবা রাহমাতিকা।',
      categoryEn: 'Daily',
      categoryBn: 'দৈনন্দিন',
    ),
    DuaItem(
      titleEn: 'Dua for Knowledge',
      titleBn: 'জ্ঞান বৃদ্ধির দোয়া',
      arabic: 'رَّبِّ زِدْنِي عِلْمًا',
      translationEn: 'My Lord, increase me in knowledge.',
      translationBn: 'হে আমার প্রতিপালক! আমার জ্ঞান বাড়িয়ে দিন।',
      pronunciationEn: 'Rabbi zidni \'ilma.',
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
      pronunciationEn: 'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina \'adhaban-nar.',
      pronunciationBn: 'রাব্বানা আতিনা ফিদ দুনিয়া হাসানাতাও ওয়া ফিল আখিরাতি হাসানাতাও ওয়া কিনা আজাবান নার।',
      categoryEn: 'Prayer',
      categoryBn: 'নামাজ',
    ),
    DuaItem(
      titleEn: 'Seeking Forgiveness (Istighfar)',
      titleBn: 'ক্ষমা প্রার্থনা (ইস্তিগফার)',
      arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      translationEn: 'I seek the forgiveness of Allah and turn to Him in repentance.',
      translationBn: 'আমি আল্লাহর কাছে ক্ষমা চাচ্ছি এবং তাঁর দিকেই ফিরে যাচ্ছি।',
      pronunciationEn: 'Astaghfirullah wa atubu ilayh.',
      pronunciationBn: 'আস্তাগফিরুল্লাহ ওয়া আতূবু ইলাইহি।',
      categoryEn: 'Protection',
      categoryBn: 'সুরক্ষা',
    ),
    DuaItem(
      titleEn: 'Protection from Harm',
      titleBn: 'ক্ষতি থেকে সুরক্ষার দোয়া',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ মَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      translationEn: 'In the name of Allah, with whose name nothing can cause harm on earth or in the heaven, and He is the All-Hearing, the All-Knowing.',
      translationBn: 'আল্লাহর নামে, যাঁর নামের বরকতে আসমান ও জমিনের কোনো কিছুই কোনো ক্ষতি করতে পারে না, আর তিনি সর্বশ্রোতা, সর্বজ্ঞ।',
      pronunciationEn: 'Bismillahilladhi la yadurru ma\'as-mihi shay\'un fil-ardi wa la fis-sama\'i wa huwas-sami\'ul-\'alim.',
      pronunciationBn: 'বিসমিল্লাহিল্লাজী লা ইয়াদুররু মাআসমিহী শাইউন ফিল আরদি ওয়া লা ফিস সামা-ই, ওয়া হুয়াস সামীউল আলীম।',
      categoryEn: 'Protection',
      categoryBn: 'সুরক্ষা',
    ),
    DuaItem(
      titleEn: 'Sayyidul Istighfar',
      titleBn: 'সাইয়্যিদুল ইস্তিগফার',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ...',
      translationEn: 'O Allah, You are my Lord, none has the right to be worshipped except You...',
      translationBn: 'হে আল্লাহ! আপনি আমার প্রতিপালক। আপনি ছাড়া কোনো সত্য ইলাহ নেই...',
      pronunciationEn: 'Allahumma anta rabbi la ilaha illa ant...',
      pronunciationBn: 'আল্লাহুম্মা আনতা রাব্বী লা ইলাহা ইল্লা আনতা...',
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
