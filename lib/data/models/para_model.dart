class ParaModel {
  final int number;
  final String name;        // Arabic name of para
  final String nameMeaning; // English meaning
  final String nameBn;      // Bangla name
  final int startSurah;
  final int startAyah;

  const ParaModel({
    required this.number,
    required this.name,
    required this.nameMeaning,
    required this.nameBn,
    required this.startSurah,
    required this.startAyah,
  });

  static const List<ParaModel> allParas = [
    ParaModel(number: 1,  name: 'الم',                nameMeaning: 'Alif Lam Meem',             nameBn: 'আলিফ লাম মীম',          startSurah: 1,  startAyah: 1),
    ParaModel(number: 2,  name: 'سَيَقُولُ',          nameMeaning: 'Sayaqool',                  nameBn: 'সায়াকুল',               startSurah: 2,  startAyah: 142),
    ParaModel(number: 3,  name: 'تِلْكَ الرُّسُلُ',   nameMeaning: 'Tilkar Rusul',              nameBn: 'তিলকার রাসুল',          startSurah: 2,  startAyah: 253),
    ParaModel(number: 4,  name: 'لَن تَنَالُواْ',    nameMeaning: 'Lan Tana Lu',               nameBn: 'লান তানালু',            startSurah: 3,  startAyah: 92),
    ParaModel(number: 5,  name: 'وَالْمُحْصَنَاتُ',  nameMeaning: 'Wal Mohsanat',              nameBn: 'ওয়াল মুহসানাত',         startSurah: 4,  startAyah: 24),
    ParaModel(number: 6,  name: 'لَا يُحِبُّ اللَّهُ', nameMeaning: 'La Yuhibbullah',         nameBn: 'লা ইউহিব্বুল্লাহ',        startSurah: 4,  startAyah: 148),
    ParaModel(number: 7,  name: 'وَإِذَا سَمِعُواْ', nameMeaning: 'Wa Iza Samiu',             nameBn: 'ওয়া ইযা সামিউ',          startSurah: 5,  startAyah: 82),
    ParaModel(number: 8,  name: 'وَلَوْ أَنَّنَا',   nameMeaning: 'Wa Lau Annana',            nameBn: 'ওয়া লাউ আন্নানা',         startSurah: 6,  startAyah: 111),
    ParaModel(number: 9,  name: 'قَالَ الْمَلَأُ',   nameMeaning: 'Qalal Malao',              nameBn: 'কলাল মালায়ু',            startSurah: 7,  startAyah: 88),
    ParaModel(number: 10, name: 'وَاعْلَمُواْ',       nameMeaning: 'Wa Alamu',                 nameBn: 'ওয়ালামু',                startSurah: 8,  startAyah: 41),
    ParaModel(number: 11, name: 'يَعْتَذِرُونَ',      nameMeaning: 'Yatazeroon',               nameBn: 'ইয়াতাযেরুন',             startSurah: 9,  startAyah: 94),
    ParaModel(number: 12, name: 'وَمَا مِن دَآبَّةٍ', nameMeaning: 'Wa Mamin Dabbah',        nameBn: 'ওয়ামা মিন দাব্বাহ',       startSurah: 11, startAyah: 6),
    ParaModel(number: 13, name: 'وَمَا أُبَرِّئُ',   nameMeaning: 'Wa Ma Ubarrio',           nameBn: 'ওয়ামা উবাররিয়ু',         startSurah: 12, startAyah: 53),
    ParaModel(number: 14, name: 'رُّبَمَا',           nameMeaning: 'Rubama',                   nameBn: 'রুবামা',                  startSurah: 15, startAyah: 1),
    ParaModel(number: 15, name: 'سُبْحَانَ الَّذِي',  nameMeaning: 'Subhanallazi',             nameBn: 'সুবহানাল্লাযী',           startSurah: 17, startAyah: 1),
    ParaModel(number: 16, name: 'قَالَ أَلَمْ',       nameMeaning: 'Qal Alam',                 nameBn: 'কলা আলাম',                startSurah: 18, startAyah: 75),
    ParaModel(number: 17, name: 'اقْتَرَبَ لِلنَّاسِ', nameMeaning: 'Aqtaraba Linnas',       nameBn: 'ইকতারা বা লিন্নাস',      startSurah: 21, startAyah: 1),
    ParaModel(number: 18, name: 'قَدْ أَفْلَحَ',      nameMeaning: 'Qadd Aflaha',              nameBn: 'কাদ আফলাহা',              startSurah: 23, startAyah: 1),
    ParaModel(number: 19, name: 'وَقَالَ الَّذِينَ',  nameMeaning: 'Wa Qalallazina',          nameBn: 'ওয়া কলাল্লাযীনা',         startSurah: 25, startAyah: 21),
    ParaModel(number: 20, name: 'أَمَّن خَلَقَ',      nameMeaning: 'Amman Khalaqa',            nameBn: 'আম্মান খালাকা',            startSurah: 27, startAyah: 60),
    ParaModel(number: 21, name: 'اتْلُ مَا أُوحِيَ',  nameMeaning: 'Utlu Ma Oohi',            nameBn: 'উতলু মা উহিয়া',          startSurah: 29, startAyah: 45),
    ParaModel(number: 22, name: 'وَمَن يَقْنُتْ',     nameMeaning: 'Wa Manyaqnut',            nameBn: 'ওয়ামান ইয়াকনুত',        startSurah: 33, startAyah: 31),
    ParaModel(number: 23, name: 'وَمَا لِي',           nameMeaning: 'Wa Mali',                  nameBn: 'ওয়ামা লিয়া',             startSurah: 36, startAyah: 27),
    ParaModel(number: 24, name: 'فَمَن أَظْلَمُ',     nameMeaning: 'Faman Azlam',              nameBn: 'ফামান আযলাম',             startSurah: 39, startAyah: 32),
    ParaModel(number: 25, name: 'إِلَيْهِ يُرَدُّ',   nameMeaning: 'Ilahe Yuruddu',           nameBn: 'ইলাইহি ইউরাদ্দু',         startSurah: 41, startAyah: 47),
    ParaModel(number: 26, name: 'حم',                  nameMeaning: 'Ha Meem',                  nameBn: 'হা মীম',                  startSurah: 46, startAyah: 1),
    ParaModel(number: 27, name: 'قَالَ فَمَا خَطْبُكُمْ', nameMeaning: 'Qala Fama Khatbukum', nameBn: 'কলা ফামা খাতবুকুম',     startSurah: 51, startAyah: 31),
    ParaModel(number: 28, name: 'قَدْ سَمِعَ اللَّهُ', nameMeaning: 'Qadd Samia Allah',       nameBn: 'কাদ সামিয়া আল্লাহ',      startSurah: 58, startAyah: 1),
    ParaModel(number: 29, name: 'তَبَارَكَ الَّذِي',   nameMeaning: 'Tabarakallazi',           nameBn: 'তাবারাকাল্লাযী',          startSurah: 67, startAyah: 1),
    ParaModel(number: 30, name: 'عَمَّ',               nameMeaning: 'Amma',                     nameBn: 'আম্মা',                    startSurah: 78, startAyah: 1),
  ];
}
