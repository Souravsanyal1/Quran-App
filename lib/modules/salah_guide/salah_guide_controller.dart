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

class SalahGuideController extends GetxController {
  final RxInt currentStep = 0.obs;

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
