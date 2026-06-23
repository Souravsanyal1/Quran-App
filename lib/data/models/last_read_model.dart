class LastReadModel {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final DateTime readAt;

  const LastReadModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.readAt,
  });

  factory LastReadModel.fromMap(Map<String, dynamic> map) {
    return LastReadModel(
      surahNumber: map['surahNumber'] ?? 0,
      ayahNumber: map['ayahNumber'] ?? 0,
      surahName: map['surahName'] ?? '',
      readAt: DateTime.tryParse(map['readAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'surahName': surahName,
        'readAt': readAt.toIso8601String(),
      };
}
