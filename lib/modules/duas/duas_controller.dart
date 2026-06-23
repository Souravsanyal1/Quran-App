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
  ];

  List<DuaItem> get filteredDuas {
    return duas.where((dua) => dua.categoryEn == selectedCategoryEn.value).toList();
  }

  void selectCategory(String category) {
    selectedCategoryEn.value = category;
  }
}
