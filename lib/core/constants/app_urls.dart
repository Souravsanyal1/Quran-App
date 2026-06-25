/// All API base URLs used in the app
class AppUrls {
  AppUrls._();

  // ── Quran API ─────────────────────────────────────────────────────────────
  static const String quranBase = 'https://api.alquran.cloud/v1';
  static const String quranSurahList = '$quranBase/surah';
  static const String quranSurah = '$quranBase/surah/{number}/editions/quran-uthmani,bn.bengali,en.asad,en.transliteration';
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

  // ── Quran.com API v4 (Word-by-Word) ──────────────────────────────────────
  static const String quranComBaseV4 = 'https://api.quran.com/api/v4';
  static const String wordsBySurah = '$quranComBaseV4/verses/by_chapter/{number}';

  // ── Default Qari Identifiers ──────────────────────────────────────────────
  static const String defaultQari = 'ar.alafasy';
  static const String defaultQariId = 'ar.alafasy'; // Mishary Rashid Alafasy
  static const List<Map<String, String>> qariList = [
    {'id': 'ar.alafasy', 'name': 'Mishary Rashid Alafasy', 'bitrate': '128'},
    {'id': 'ar.abdullahbasfar', 'name': 'Abdullah Basfar', 'bitrate': '64'},
    {'id': 'ar.abdurrahmaansudais', 'name': 'Abdul Rahman Al-Sudais', 'bitrate': '192'},
    {'id': 'ar.hudhaify', 'name': 'Ali Al-Hudhaify', 'bitrate': '128'},
    {'id': 'ar.shaatree', 'name': 'Abu Bakr Al-Shatri', 'bitrate': '128'},
    {'id': 'ar.mahermuaiqly', 'name': 'Maher Al-Muaiqly', 'bitrate': '128'},
    {'id': 'ar.minshawi', 'name': 'Mohamed Siddiq Al-Minshawi', 'bitrate': '128'},
    {'id': 'ar.abdulbasitmujawwad', 'name': 'Abdul Basit (Mujawwad)', 'bitrate': '128'},
    {'id': 'ar.saoodshuraym', 'name': 'Saood bin Ibrahim Ash-Shuraym', 'bitrate': '128'},
    {'id': 'ar.ahmedajamy', 'name': 'Ahmed bin Ali Al-Ajamy', 'bitrate': '128'},
  ];

  static const Map<int, String> surahNamesBn = {
    1: "আল ফাতিহা", 2: "আল বাক্বারাহ", 3: "আলে ইমরান", 4: "আন নিসা", 5: "আল মায়িদাহ",
    6: "আল আনআম", 7: "আল আ’রাফ", 8: "আল আনফাল", 9: "আত তাওবাহ", 10: "ইউনুস",
    11: "হুদ", 12: "ইউসুফ", 13: "আর রা’দ", 14: "ইব্রাহিম", 15: "আল হিজর",
    16: "আন নাহল", 17: "বনী ইসরাঈল", 18: "আল কাহফ", 19: "মারইয়াম", 20: "ত্বোয়া-হা",
    21: "আল আম্বিয়া", 22: "আল হাজ্জ", 23: "আল মু’মিনূন", 24: "আন নূর", 25: "আল ফুরক্বান",
    26: "আশ শুআরা", 27: "আন নামল", 28: "আল ক্বাসাস", 29: "আল আনকাবূত", 30: "আর রূম",
    31: "লুক্বমান", 32: "আস সাজদাহ", 33: "আল আহ্যাব", 34: "সাবা", 35: "ফাতিমির",
    36: "ইয়াসীন", 37: "আস ছাফফাত", 38: "ছোয়াদ", 39: "আয যুমার", 40: "আল মু’মিন",
    41: "হা-মীম সাজদাহ", 42: "আশ শূরা", 43: "আয যুখরুফ", 44: "আদ দুখান", 45: "আল জাসিয়াহ",
    46: "আল আহক্বাফ", 47: "মুহাম্মদ", 48: "আল ফাতহ", 49: "আল হুজুরাত", 50: "ক্বাফ",
    51: "আয যারিয়াত", 52: "আত তূর", 53: "আন নাজম", 54: "আল ক্বামার", 55: "আর রাহমান",
    56: "আল ওয়াক্বিআহ", 57: "আল হাদীদ", 58: "আল মুজাদালাহ", 59: "আল হাশর", 60: "আল মুমতাহিনাহ",
    61: "আস ছফ", 62: "আল জুমুআহ", 63: "আল মুনাফিকুন", 64: "আত তাগাবুন", 65: "আত তালাক্ব",
    66: "আত তাহরীম", 67: "আল মুলক", 68: "আল ক্বালাম", 69: "আল হাক্বক্বাহ", 70: "আল মাআরিজ",
    71: "নূহ", 72: "আল জিন", 73: "আল মুয্যাম্মিল", 74: "আল মুদ্দাস্সির", 75: "আল ক্বিয়ামাহ",
    76: "আদ দাহর", 77: "আল মুরসালাত", 78: "আন নাবা", 79: "আন নাযিআত", 80: "আবাসা",
    81: "আত তাকবীর", 82: "আল ইনফিতার", 83: "আল মুতাফফিফীন", 84: "আল ইনশিক্বাক্ব", 85: "আল বুরূজ",
    86: "আত তারিক্ব", 87: "আল আ’লা", 88: "আল গাশিয়াহ", 89: "আল ফাজর", 90: "আল বালাদ",
    91: "আশ শামস", 92: "আল লাইল", 93: "আদ দুহা", 94: "আল ইনশিরাহ", 95: "আত তীন",
    96: "আল আলাক্ব", 97: "আল ক্বাদর", 98: "আল বাইয়্যিনাহ", 99: "আয যিলযাল", 100: "আল আদিয়াত",
    101: "আল ক্বারিআহ", 102: "আত তাকাসুর", 103: "আল আছর", 104: "আল হুমাযাহ", 105: "আল ফীল",
    106: "কুরাইশ", 107: "আল মাউন", 108: "আল কাউসার", 109: "আল কাফিরুন", 110: "আন নাসর",
    111: "আল লাহাব", 112: "আল ইখলাস", 113: "আল ফালাক্ব", 114: "আন নাস"
  };
}
