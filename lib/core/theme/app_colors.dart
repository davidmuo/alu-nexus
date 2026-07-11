import 'package:flutter/material.dart';

/// Design system: bold color-blocked cards on clean surfaces.
/// Palette — #5324FD purple, #F5001E red, #FCC636 yellow, black, white.
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────
  static const Color primary = Color(0xFF5324FD);   // electric purple
  static const Color primaryDark = Color(0xFF3D14CC);
  static const Color primarySurface = Color(0xFFEFEAFF);

  static const Color red = Color(0xFFF5001E);
  static const Color yellow = Color(0xFFFCC636);

  static const Color accent = Color(0xFFFCC636);
  static const Color accentLight = Color(0xFFFFE08A);
  static const Color accentDark = Color(0xFFD9A312);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFE7F8EE);
  static const Color warning = Color(0xFFD9A312);
  static const Color warningLight = Color(0xFFFFF6DE);
  static const Color error = Color(0xFFF5001E);
  static const Color errorLight = Color(0xFFFFE9EB);
  static const Color info = Color(0xFF5324FD);
  static const Color infoLight = Color(0xFFEFEAFF);

  // ── Neutrals ──────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF7F7F8);
  static const Color grey100 = Color(0xFFF0F0F2);
  static const Color grey200 = Color(0xFFE4E4E8);
  static const Color grey300 = Color(0xFFCFCFD6);
  static const Color grey400 = Color(0xFFA0A0AB);
  static const Color grey500 = Color(0xFF71717A);
  static const Color grey600 = Color(0xFF52525B);
  static const Color grey700 = Color(0xFF3F3F46);
  static const Color grey800 = Color(0xFF27272A);
  static const Color grey900 = Color(0xFF111113);

  // Verification badges
  static const Color verifiedBadge = Color(0xFF16A34A);
  static const Color pendingBadge = Color(0xFFD9A312);
  static const Color rejectedBadge = Color(0xFFF5001E);

  // ── Card color blocks (rotate through the feed) ───────
  // Each entry: background + matching foreground for readable contrast.
  static const List<Color> cardColors = [primary, red, yellow];
  static const List<Color> cardForegrounds = [white, white, black];

  /// Foreground color that reads on a given card color.
  static Color onCard(Color card) => card == yellow ? black : white;

  // Skill / category tag tints for light surfaces
  static const List<Color> skillColors = [
    Color(0xFFEFEAFF), // purple tint
    Color(0xFFFFE9EB), // red tint
    Color(0xFFFFF6DE), // yellow tint
    Color(0xFFF0F0F2), // grey
  ];

  static const List<Color> skillTextColors = [
    Color(0xFF5324FD),
    Color(0xFFF5001E),
    Color(0xFFB8860B),
    Color(0xFF3F3F46),
  ];
}
