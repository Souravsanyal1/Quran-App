class ParaModel {
  final int number;
  final String name;        // Arabic name of para
  final String nameMeaning; // English meaning
  final int startSurah;
  final int startAyah;

  const ParaModel({
    required this.number,
    required this.name,
    required this.nameMeaning,
    required this.startSurah,
    required this.startAyah,
  });

  static const List<ParaModel> allParas = [
    ParaModel(number: 1,  name: 'الم',                nameMeaning: 'Alif Lam Meem',             startSurah: 1,  startAyah: 1),
    ParaModel(number: 2,  name: 'سَيَقُولُ',          nameMeaning: 'Sayaqool',                  startSurah: 2,  startAyah: 142),
    ParaModel(number: 3,  name: 'تِلْكَ الرُّسُلُ',   nameMeaning: 'Tilkar Rusul',              startSurah: 2,  startAyah: 253),
    ParaModel(number: 4,  name: 'لَن تَنَالُواْ',    nameMeaning: 'Lan Tana Lu',               startSurah: 3,  startAyah: 92),
    ParaModel(number: 5,  name: 'وَالْمُحْصَنَاتُ',  nameMeaning: 'Wal Mohsanat',              startSurah: 4,  startAyah: 24),
    ParaModel(number: 6,  name: 'لَا يُحِبُّ اللَّهُ', nameMeaning: 'La Yuhibbullah',         startSurah: 4,  startAyah: 148),
    ParaModel(number: 7,  name: 'وَإِذَا سَمِعُواْ', nameMeaning: 'Wa Iza Samiu',             startSurah: 5,  startAyah: 82),
    ParaModel(number: 8,  name: 'وَلَوْ أَنَّنَا',   nameMeaning: 'Wa Lau Annana',            startSurah: 6,  startAyah: 111),
    ParaModel(number: 9,  name: 'قَالَ الْمَلَأُ',   nameMeaning: 'Qalal Malao',              startSurah: 7,  startAyah: 88),
    ParaModel(number: 10, name: 'وَاعْلَمُواْ',       nameMeaning: 'Wa Alamu',                 startSurah: 8,  startAyah: 41),
    ParaModel(number: 11, name: 'يَعْتَذِرُونَ',      nameMeaning: 'Yatazeroon',               startSurah: 9,  startAyah: 94),
    ParaModel(number: 12, name: 'وَمَا مِن دَآبَّةٍ', nameMeaning: 'Wa Mamin Dabbah',        startSurah: 11, startAyah: 6),
    ParaModel(number: 13, name: 'وَمَا أُبَرِّئُ',   nameMeaning: 'Wa Ma Ubarrio',           startSurah: 12, startAyah: 53),
    ParaModel(number: 14, name: 'رُّبَمَا',           nameMeaning: 'Rubama',                   startSurah: 15, startAyah: 1),
    ParaModel(number: 15, name: 'سُبْحَانَ الَّذِي',  nameMeaning: 'Subhanallazi',             startSurah: 17, startAyah: 1),
    ParaModel(number: 16, name: 'قَالَ أَلَمْ',       nameMeaning: 'Qal Alam',                 startSurah: 18, startAyah: 75),
    ParaModel(number: 17, name: 'اقْتَرَبَ لِلنَّاسِ', nameMeaning: 'Aqtaraba Linnas',       startSurah: 21, startAyah: 1),
    ParaModel(number: 18, name: 'قَدْ أَفْلَحَ',      nameMeaning: 'Qadd Aflaha',              startSurah: 23, startAyah: 1),
    ParaModel(number: 19, name: 'وَقَالَ الَّذِينَ',  nameMeaning: 'Wa Qalallazina',          startSurah: 25, startAyah: 21),
    ParaModel(number: 20, name: 'أَمَّن خَلَقَ',      nameMeaning: 'Amman Khalaqa',            startSurah: 27, startAyah: 60),
    ParaModel(number: 21, name: 'اتْلُ مَا أُوحِيَ',  nameMeaning: 'Utlu Ma Oohi',            startSurah: 29, startAyah: 45),
    ParaModel(number: 22, name: 'وَمَن يَقْنُتْ',     nameMeaning: 'Wa Manyaqnut',            startSurah: 33, startAyah: 31),
    ParaModel(number: 23, name: 'وَمَا لِي',           nameMeaning: 'Wa Mali',                  startSurah: 36, startAyah: 27),
    ParaModel(number: 24, name: 'فَمَن أَظْلَمُ',     nameMeaning: 'Faman Azlam',              startSurah: 39, startAyah: 32),
    ParaModel(number: 25, name: 'إِلَيْهِ يُرَدُّ',   nameMeaning: 'Ilahe Yuruddu',           startSurah: 41, startAyah: 47),
    ParaModel(number: 26, name: 'حم',                  nameMeaning: 'Ha Meem',                  startSurah: 46, startAyah: 1),
    ParaModel(number: 27, name: 'قَالَ فَمَا خَطْبُكُمْ', nameMeaning: 'Qala Fama Khatbukum', startSurah: 51, startAyah: 31),
    ParaModel(number: 28, name: 'قَدْ سَمِعَ اللَّهُ', nameMeaning: 'Qadd Samia Allah',       startSurah: 58, startAyah: 1),
    ParaModel(number: 29, name: 'تَبَارَكَ الَّذِي',   nameMeaning: 'Tabarakallazi',           startSurah: 67, startAyah: 1),
    ParaModel(number: 30, name: 'عَمَّ',               nameMeaning: 'Amma',                     startSurah: 78, startAyah: 1),
  ];
}
