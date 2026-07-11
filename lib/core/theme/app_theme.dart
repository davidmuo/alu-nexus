import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.black,
        onSurface: AppColors.grey900,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.grey900,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.grey900,
        ),
        displaySmall: GoogleFonts.dmSans(
          fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.grey900,
        ),
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.grey900,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.grey900,
        ),
        headlineSmall: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.grey900,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.grey900,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.grey900,
        ),
        titleSmall: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.grey700,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.grey800,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.grey700,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.grey600,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grey900,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.grey900,
        ),
        iconTheme: const IconThemeData(color: AppColors.grey900),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.dmSans(color: AppColors.grey400, fontSize: 14),
        labelStyle: GoogleFonts.dmSans(color: AppColors.grey600, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.grey200),
        ),
        color: AppColors.white,
        margin: const EdgeInsets.all(0),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.grey100,
        thickness: 1,
        space: 0,
      ),
      scaffoldBackgroundColor: AppColors.grey50,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w400),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.grey900,
        contentTextStyle: GoogleFonts.dmSans(color: AppColors.white, fontSize: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey500,
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400),
      ),
    );
  }
}
