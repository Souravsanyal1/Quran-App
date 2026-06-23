class AyahModel {
  final int number;        // Global ayah number
  final int numberInSurah;
  final int? surahNumber;  // Surah number (optional or null if not available)
  final String text;       // Arabic text
  final String? textBangla;
  final String? textBanglaTranslit; // Pronunciation
  final String? textEnglish;
  final String? audioUrl;
  final int page;
  final int juz;

  const AyahModel({
    required this.number,
    required this.numberInSurah,
    this.surahNumber,
    required this.text,
    this.textBangla,
    this.textBanglaTranslit,
    this.textEnglish,
    this.audioUrl,
    required this.page,
    required this.juz,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      number: json['number'] ?? 0,
      numberInSurah: json['numberInSurah'] ?? 0,
      surahNumber: json['surahNumber'],
      text: json['text'] ?? '',
      textBangla: json['textBangla'],
      textBanglaTranslit: json['textBanglaTranslit'],
      textEnglish: json['textEnglish'],
      audioUrl: json['audioUrl'],
      page: json['page'] ?? 0,
      juz: json['juz'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'numberInSurah': numberInSurah,
        'surahNumber': surahNumber,
        'text': text,
        'textBangla': textBangla,
        'textBanglaTranslit': textBanglaTranslit,
        'textEnglish': textEnglish,
        'audioUrl': audioUrl,
        'page': page,
        'juz': juz,
      };
}
