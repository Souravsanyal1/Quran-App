enum PrayerPosture {
  standing,
  handsRaised,
  qiyam,
  ruku,
  qaumah,
  sujud,
  jalsa,
  tashahhud,
  tasleem,
}

class NamazStep {
  final int stepNumber;
  final PrayerPosture posture;
  final String titleEn;
  final String titleBn;
  final String instructionEn;
  final String instructionBn;
  final String? arabic;
  final String? translit;
  final String? meaningEn;
  final String? meaningBn;

  const NamazStep({
    required this.stepNumber,
    required this.posture,
    required this.titleEn,
    required this.titleBn,
    required this.instructionEn,
    required this.instructionBn,
    this.arabic,
    this.translit,
    this.meaningEn,
    this.meaningBn,
  });
}
