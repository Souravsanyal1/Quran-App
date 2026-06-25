import 'package:flutter/material.dart';

/// All color constants for the Quran App
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF8A00);
  static const Color primaryDark = Color(0xFFCC6F00);
  static const Color primaryLight = Color(0xFFFFB84D);
  static const Color primaryGlow = Color(0x33FF8A00);
  static const Color secondary = Color(0xFF673AB7); // Added secondary color

  // ── Islamic / Accent ─────────────────────────────────────────────────────
  static const Color islamic = Color(0xFF1B5E20);
  static const Color islamicLight = Color(0xFF4CAF50);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color emerald = Color(0xFF00C853);

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color bgDark2 = Color(0xFF121218);
  static const Color surfaceDark = Color(0xFF1A1A24);
  static const Color cardDark = Color(0xFF222230);
  static const Color borderDark = Color(0xFF2E2E40);

  // ── Light Theme ───────────────────────────────────────────────────────────
  static const Color bgLight = Color(0xFFF8F8FC);
  static const Color bgLight2 = Color(0xFFEEEEF8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF2F2F8);
  static const Color borderLight = Color(0xFFE0E0EE);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0B0C8);
  static const Color textMuted = Color(0xFF5A5A78);
  static const Color textDark = Color(0xFF1A1A2E);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF40C4FF);

  // ── Prayer Times ─────────────────────────────────────────────────────────
  static const Color fajr = Color(0xFF7986CB);
  static const Color dhuhr = Color(0xFFFFB300);
  static const Color asr = Color(0xFFFF7043);
  static const Color maghrib = Color(0xFFE91E63);
  static const Color isha = Color(0xFF3F51B5);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient islamicGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF004D40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [bgDark, bgDark2],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nightGradient = LinearGradient(
    colors: [Color(0xFF1A1A3E), Color(0xFF0A0A1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
