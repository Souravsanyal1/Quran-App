# 🕌 Al-Quran App

A premium, production-ready Islamic Music & Quran application built with Flutter (GetX) and Firebase. Inspired by modern user experiences, this application provides an elegant, responsive, and visual platform for learning, tracking, and reciting Al-Quran.

## ✨ Key Features

### 📖 1. Al-Quran Module
* **Surah & Para (Juz) Lists**: Tabbed navigation with comprehensive search indexing.
* **Uthmanic Arabic Script**: Beautiful text rendering with customizable Arabic and translation font sizes.
* **Bangla & English Translations**: Inline verse-by-verse translations.
* **Audio Recitations**: High-quality single-ayah audio playback with Qari selection and auto-play next progression.
* **Bookmarks & Last Read Tracker**: Quick-resume reading banners to continue from where you left off.
* **Offline Cache**: Pre-download and cache Surahs for reading without an active internet connection.

### 🕋 2. Daily Deen Helpers
* **Prayer Times**: Location-based timings (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) with live countdown remaining timers.
* **Qibla Compass**: Live direction tracker withKaaba alignment indicators and vibration feedback.
* **Salah Step-by-Step Guide**: Illustrated instructions from Niyyah to Salam, including phonetics and Arabic recitations.
* **New Muslim Guide**: Introductory pillars of faith and visual guides for performing Wudu (ablution).

### ⚙️ 3. Utility Modules
* **Duas & Azkar**: Categorized list of daily supplications (with copy/share options).
* **Digital Tasbih**: Clicker counter with limit/round triggers and haptic feedback.
* **Daily Tracker**: Checklist showing completion rates of daily salahs and Quran readings.
* **FCM Push Notifications**: Synchronized Firebase topic updates (`all`, `daily_hadith`) with toggles in settings.
* **Theme Support**: Premium dark and light theme aesthetics.

---

## 🛠️ Tech Stack

* **State Management**: GetX
* **Local Database**: Hive (Cache-first offline repositories)
* **Backend Integration**: Firebase Auth, Cloud Firestore (Support Tickets), Firebase Cloud Messaging (FCM)
* **Audio Playback**: `just_audio`, `audio_service`
* **Sensor Services**: `geolocator`, `flutter_qiblah`, `vibration`
