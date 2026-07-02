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
        final rId = t['resource_id'];
        final text = t['text']?.toString() ?? '';
        // 131: English (Dr. Shehnaz Shaikh), 85: English (Sahih International)
        if (rId == 131 || rId == 85) transEn = text;
        // 161: Bengali, 163: Bengali, 162: Bengali
        if (rId == 161 || rId == 163 || rId == 162) transBn = text;
      }
      // Fallback: If Bangla is missing but we have translations, use the first one as English
      if (transEn == null && translations.isNotEmpty) transEn = translations[0]['text'];
    }
    
    // Final cleanup: Remove HTML tags if any (rare in word-by-word but possible)
    transEn = transEn?.replaceAll(RegExp(r'<[^>]*>'), '');
    transBn = transBn?.replaceAll(RegExp(r'<[^>]*>'), '');
    
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
