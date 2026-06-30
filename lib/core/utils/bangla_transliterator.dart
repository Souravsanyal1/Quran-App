class BanglaQuranTransliterator {
  BanglaQuranTransliterator._();

  // Dictionary of common Quranic words for 100% accurate transliteration
  static const Map<String, String> _wordDictionary = {
    "allah": "আল্লাহ",
    "allahu": "আল্লাহু",
    "allahs": "আল্লাহর",
    "bismillaahir": "বিসমিল্লাহির",
    "bismillaahi": "বিসমিল্লাহি",
    "bismillah": "বিসমিল্লাহ",
    "alhamdu": "আলহামদু",
    "lillaahi": "লিল্লাহি",
    "lillahi": "লিল্লাহি",
    "rabbil": "রব্বিল",
    "rabbi": "রব্বি",
    "aalameen": "আলামিন",
    "al-hamdu": "আল-হামদু",
    "ar-rahmaanir-raheem": "আর-রাহমানির-রাহিম",
    "ar-rahmaani": "আর-রাহমানি",
    "ar-rahmaan": "আর-রাহমান",
    "ar-raheem": "আর-রাহিম",
    "maaliki": "মালিকি",
    "yawmid-deen": "ইয়াওমিদ্দিন",
    "yawmi": "ইয়াওমি",
    "ad-deen": "আদ-দ্বীন",
    "iyyaaka": "ইয়্যাকা",
    "na'budu": "নাবুদু",
    "wa-iyyaaka": "ওয়া-ইয়্যাকা",
    "nasta'een": "নাস্তায়িন",
    "nasta'in": "নাস্তায়িন",
    "ihdinas-siraatal-mustaqeem": "ইহদিনাস-সিরাতাল-মুস্তাকিম",
    "ihdinas": "ইহদিনাস",
    "siraatal": "সিরাতাল",
    "siraata": "সিরাতা",
    "mustaqeem": "মুস্তাকিম",
    "siraatal-lazeena": "সিরাতাল্লাজিনা",
    "lazeena": "লাজিনা",
    "an'amta": "আনআমতা",
    "alayhim": "আলাইহিম",
    "ghayril": "গাইরিল",
    "maghdoobi": "মাগদুবি",
    "walad-daalleen": "ওয়ালাদ্দল্লিন",
    "walaad-daalleen": "ওয়ালাদ্দল্লিন",
    "ameen": "আমীন",
    "qul": "কুল",
    "huwallaahu": "হুওয়াল্লাহু",
    "huwallahu": "হুওয়াল্লাহু",
    "ahad": "আহাদ",
    "allahus-samad": "আল্লাহুস-সামাদ",
    "samad": "সামাদ",
    "lam": "লাম",
    "yalid": "ইয়ালিদ",
    "walam": "ওয়ালাম",
    "yoolad": "ইউলাদ",
    "yakul-lahu": "ইয়াকুল-লাহু",
    "kufuwan": "কুফুয়ান",
    "minal": "মিনাল",
    "jinnati": "জিন্নতি",
    "wannaas": "ওয়াননাস",
    "naas": "নাস",
    "inna": "ইন্না",
    "fi": "ফি",
    "ila": "ইলা",
    "ala": "আলা",
    "ya": "ইয়া",
    "yuhyi": "ইউহয়ী",
    "wa": "ওয়া",
    "bi": "বি",
    "la": "লা",
    "ma": "মা",
    "min": "মিন",
    "kum": "কুম",
    "hum": "হুম",
    "ibada": "ইবাদা",
    "rasool": "রাসূল",
    "nabi": "নবী",
    "ketaab": "কিতাব",
  };

  /// Transliterate Romanized Arabic text to Bengali script
  static String transliterate(String text) {
    if (text.isEmpty) return text;

    // Split text into words while keeping punctuation
    final RegExp wordRegExp = RegExp(r"([a-zA-Z0-9'-]+)|([^a-zA-Z0-9'-]+)");
    final matches = wordRegExp.allMatches(text);
    final StringBuffer result = StringBuffer();

    for (final match in matches) {
      final token = match.group(0)!;
      if (RegExp(r"^[a-zA-Z0-9'-]+$").hasMatch(token)) {
        result.write(_transliterateWord(token));
      } else {
        result.write(token);
      }
    }

    return result.toString();
  }

  static String _transliterateWord(String word) {
    final cleanWord = word.toLowerCase();

    // Check direct dictionary match
    if (_wordDictionary.containsKey(cleanWord)) {
      return _wordDictionary[cleanWord]!;
    }

    // Handle hyphens (e.g. ar-rahmaan)
    if (cleanWord.contains('-')) {
      return cleanWord.split('-').map(_transliterateWord).join('-');
    }

    // Phonetic parsing engine
    final StringBuffer sb = StringBuffer();
    int i = 0;

    bool isConsonant(String ch) {
      return !const ["a", "e", "i", "o", "u"].contains(ch);
    }

    while (i < cleanWord.length) {
      // Lookahead helper
      String charAt(int offset) {
        if (i + offset < cleanWord.length) {
          return cleanWord[i + offset];
        }
        return '';
      }

      final ch = cleanWord[i];
      final next = charAt(1);
      final next2 = charAt(2);

      // Digraph consonants
      if (ch == 's' && next == 'h') {
        sb.write('শ');
        i += 2;
        continue;
      }
      if (ch == 'k' && next == 'h') {
        sb.write('খ');
        i += 2;
        continue;
      }
      if (ch == 'g' && next == 'h') {
        sb.write('গ');
        i += 2;
        continue;
      }
      if (ch == 't' && next == 'h') {
        // Arabic 'Thaa' is closer to 'ছ' or 'স' in Bengali recitation context
        sb.write('ছ');
        i += 2;
        continue;
      }
      if (ch == 'd' && next == 'h') {
        sb.write('জ');
        i += 2;
        continue;
      }
      if (ch == 'p' && next == 'h') {
        sb.write('ফ');
        i += 2;
        continue;
      }

      // Long/special vowels at the beginning of word
      final bool isWordStart = i == 0;
      if (isWordStart) {
        if (ch == 'a' && next == 'a') {
          sb.write('আ');
          i += 2;
          continue;
        }
        if (ch == 'e' && next == 'e') {
          sb.write('ঈ');
          i += 2;
          continue;
        }
        if (ch == 'o' && next == 'o') {
          sb.write('ঊ');
          i += 2;
          continue;
        }
        if (ch == 'a') {
          sb.write('আ');
          i++;
          continue;
        }
        if (ch == 'i') {
          sb.write('ই');
          i++;
          continue;
        }
        if (ch == 'u') {
          sb.write('উ');
          i++;
          continue;
        }
      }

      // Vowel diacritics (Kar) after consonants
      if (!isWordStart) {
        if (ch == 'a' && next == 'a') {
          sb.write('া');
          i += 2;
          continue;
        }
        if (ch == 'e' && next == 'e') {
          sb.write('ী');
          i += 2;
          continue;
        }
        if (ch == 'o' && next == 'o') {
          sb.write('ূ');
          i += 2;
          continue;
        }
        if (ch == 'a') {
          // If 'a' is at the end, or followed by consonant then vowel, use 'া' (aa-kar)
          if (next.isEmpty || (isConsonant(next) && next2.isNotEmpty && !isConsonant(next2))) {
            sb.write('া');
          } else {
            // Default short 'a' in Arabic is often represented by no kar in Bangla (e.g. rab -> রব)
          }
          i++;
          continue;
        }
        if (ch == 'i') {
          sb.write('ি');
          i++;
          continue;
        }
        if (ch == 'u') {
          sb.write('ু');
          i++;
          continue;
        }
        if (ch == 'e') {
          sb.write('ে');
          i++;
          continue;
        }
        if (ch == 'o') {
          sb.write('ো');
          i++;
          continue;
        }
      }

      // Glottal stop / Hamza / Ain
      if (ch == "'" || ch == '`') {
        i++;
        continue;
      }

      // Consonants mapping
      String banglaCons = '';
      if (ch == 'b') banglaCons = 'ব';
      else if (ch == 'd') banglaCons = 'দ';
      else if (ch == 'f') banglaCons = 'ফ';
      else if (ch == 'g') banglaCons = 'গ';
      else if (ch == 'h') banglaCons = 'হ';
      else if (ch == 'j') banglaCons = 'জ';
      else if (ch == 'k') banglaCons = 'ক';
      else if (ch == 'l') banglaCons = 'ল';
      else if (ch == 'm') banglaCons = 'ম';
      else if (ch == 'n') banglaCons = 'ন';
      else if (ch == 'p') banglaCons = 'প';
      else if (ch == 'q') banglaCons = 'ক';
      else if (ch == 'r') banglaCons = 'র';
      else if (ch == 's') banglaCons = 'স';
      else if (ch == 't') banglaCons = 'ত';
      else if (ch == 'v') banglaCons = 'ভ';
      else if (ch == 'w') banglaCons = 'ও';
      else if (ch == 'y') banglaCons = 'ই';
      else if (ch == 'z') banglaCons = 'জ';

      if (banglaCons.isNotEmpty) {
        sb.write(banglaCons);
        // If consecutive consonants, insert Hasanta to form conjunct
        if (next.isNotEmpty && isConsonant(next) && next != "'" && next != '`') {
          sb.write('্');
        }
      }

      i++;
    }

    return sb.toString();
  }
}
