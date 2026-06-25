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
    final translations = json['translations'] as List<dynamic>?;
    final transliteration = json['transliteration'] as Map<String, dynamic>?;

    String? transEn;
    String? transBn;

    if (translations != null) {
      for (var t in translations) {
        if (t['resource_id'] == 131) transEn = t['text'];
        if (t['resource_id'] == 161) transBn = t['text'];
      }
      // Fallback if resource IDs are different or missing
      if (transEn == null && translations.isNotEmpty) transEn = translations[0]['text'];
    }
    
    return WordModel(
      id: json['id'] ?? 0,
      text: json['text_uthmani'] ?? json['text'] ?? '',
      translationEn: transEn,
      translationBn: transBn,
      transliterationEn: transliteration?['text'],
      audioUrl: json['audio_url'] != null ? 'https://audio.qurancdn.com/${json['audio_url']}' : null,
    );
  }
}
