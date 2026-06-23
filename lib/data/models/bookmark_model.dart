class BookmarkModel {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String ayahText; // Arabic snippet
  final DateTime savedAt;

  const BookmarkModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.ayahText,
    required this.savedAt,
  });

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      surahNumber: map['surahNumber'] ?? 0,
      ayahNumber: map['ayahNumber'] ?? 0,
      surahName: map['surahName'] ?? '',
      ayahText: map['ayahText'] ?? '',
      savedAt: DateTime.tryParse(map['savedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'surahName': surahName,
        'ayahText': ayahText,
        'savedAt': savedAt.toIso8601String(),
      };

  String get key => '${surahNumber}_$ayahNumber';
}
