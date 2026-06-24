class WordModel {
  final int id;
  final String text;
  final String? translationEn;
  final String? translationBn;
  final String? transliterationEn;
  final String? transliterationBn;
  final String? audioUrl;

  WordModel({
    required this.id,
    required this.text,
    this.translationEn,
    this.translationBn,
    this.transliterationEn,
    this.transliterationBn,
    this.audioUrl,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    // Handling Quran.com v4 word structure
    final translation = json['translation'] as Map<String, dynamic>?;
    final transliteration = json['transliteration'] as Map<String, dynamic>?;
    
    return WordModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      translationEn: translation?['text'],
      transliterationEn: transliteration?['text'],
      audioUrl: json['audio_url'] != null ? 'https://audio.qurancdn.com/${json['audio_url']}' : null,
    );
  }
}
