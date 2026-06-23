/// All API base URLs used in the app
class AppUrls {
  AppUrls._();

  // ── Quran API ─────────────────────────────────────────────────────────────
  static const String quranBase = 'https://api.alquran.cloud/v1';
  static const String quranSurahList = '$quranBase/surah';
  static const String quranSurah = '$quranBase/surah/{number}/editions/quran-uthmani,bn.bengali,en.asad';
  // Note: juz/editions endpoint returns 404; use two separate calls
  static const String quranParaArabic = '$quranBase/juz/{number}/quran-uthmani';
  static const String quranParaBangla = '$quranBase/juz/{number}/bn.bengali';

  // ── Audio CDN ────────────────────────────────────────────────────────────
  // Base URL: https://cdn.islamic.network/quran/audio-surah/128/{identifier}/{surah}.mp3
  static const String audioBase = 'https://cdn.islamic.network/quran/audio-surah/128';
  // Per-ayah audio
  static const String ayahAudioBase = 'https://cdn.islamic.network/quran/audio/128';

  // ── Prayer Times API ──────────────────────────────────────────────────────
  static const String prayerBase = 'https://api.aladhan.com/v1';
  static const String prayerByLocation = '$prayerBase/timings/{date}';
  static const String prayerMonthly = '$prayerBase/calendar/{year}/{month}';

  // ── Hadith API ────────────────────────────────────────────────────────────
  static const String hadithBase = 'https://api.hadith.gading.dev';
  static const String dailyHadith = '$hadithBase/books/shahih-bukhari';

  // ── Default Qari Identifiers ──────────────────────────────────────────────
  static const String defaultQari = 'ar.alafasy';
  static const String defaultQariId = 'ar.alafasy'; // Mishary Rashid Alafasy
  static const List<Map<String, String>> qariList = [
    {'id': 'ar.alafasy', 'name': 'Mishary Rashid Alafasy'},
    {'id': 'ar.abdullahbasfar', 'name': 'Abdullah Basfar'},
    {'id': 'ar.abdurrahmaansudais', 'name': 'Abdul Rahman Al-Sudais'},
    {'id': 'ar.hudhaify', 'name': 'Ali Al-Hudhaify'},
    {'id': 'ar.shaatree', 'name': 'Abu Bakr Al-Shatri'},
    {'id': 'ar.mahermuaiqly', 'name': 'Maher Al-Muaiqly'},
  ];
}
