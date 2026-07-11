import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand: mainly blue ────────────────────────────────
  static const Color primary = Color(0xFF2563EB);      // Royal blue
  static const Color primaryLight = Color(0xFF5B8DEF);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySurface = Color(0xFFEAF1FE); // very light blue tint

  static const Color accent = Color(0xFF0EA5E9);       // Sky blue
  static const Color accentLight = Color(0xFF7DD3FC);
  static const Color accentDark = Color(0xFF0369A1);

  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFE7F8EE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3E2);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFDECEC);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFEAF1FE);

  // Neutrals (cool-tinted for a bluer feel)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0A1220);
  static const Color grey50 = Color(0xFFF6F8FC);
  static const Color grey100 = Color(0xFFEEF2F8);
  static const Color grey200 = Color(0xFFE3E9F2);
  static const Color grey300 = Color(0xFFCBD5E4);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // Verification badges
  static const Color verifiedBadge = Color(0xFF16A34A);
  static const Color pendingBadge = Color(0xFFF59E0B);
  static const Color rejectedBadge = Color(0xFFEF4444);

  // Skill / category tag tints (soft pastels, cool-leaning)
  static const List<Color> skillColors = [
    Color(0xFFEAF1FE), // blue
    Color(0xFFE7F8EE), // green
    Color(0xFFEDE9FE), // indigo
    Color(0xFFE0F5FB), // cyan
    Color(0xFFFCE9F3), // pink
    Color(0xFFFEF3E2), // amber
  ];

  static const List<Color> skillTextColors = [
    Color(0xFF2563EB),
    Color(0xFF15803D),
    Color(0xFF6D28D9),
    Color(0xFF0369A1),
    Color(0xFFBE185D),
    Color(0xFFB45309),
  ];

}
