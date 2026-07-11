import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App theme: Satoshi type, bold black headings, pill-shaped controls,
/// clean near-white surfaces that let the color-blocked cards pop.
class AppTheme {
  AppTheme._();

  static const String _font = 'Satoshi';

  static TextStyle _t(double size, FontWeight weight, Color color,
          {double? height}) =>
      TextStyle(
        fontFamily: _font,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.yellow,
        error: AppColors.error,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.black,
        onSurface: AppColors.grey900,
      ),
      textTheme: base.textTheme
          .apply(fontFamily: _font)
          .copyWith(
            displayLarge: _t(34, FontWeight.w900, AppColors.grey900, height: 1.1),
            displayMedium: _t(30, FontWeight.w900, AppColors.grey900, height: 1.15),
            displaySmall: _t(26, FontWeight.w900, AppColors.grey900, height: 1.15),
            headlineLarge: _t(23, FontWeight.w800, AppColors.grey900),
            headlineMedium: _t(21, FontWeight.w800, AppColors.grey900),
            headlineSmall: _t(19, FontWeight.w700, AppColors.grey900),
            titleLarge: _t(17, FontWeight.w700, AppColors.grey900),
            titleMedium: _t(15, FontWeight.w600, AppColors.grey900),
            titleSmall: _t(13, FontWeight.w600, AppColors.grey600),
            bodyLarge: _t(16, FontWeight.w400, AppColors.grey800),
            bodyMedium: _t(14, FontWeight.w400, AppColors.grey700),
            bodySmall: _t(12, FontWeight.w400, AppColors.grey500),
            labelLarge: _t(15, FontWeight.w700, AppColors.white),
          ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.grey50,
        foregroundColor: AppColors.grey900,
        titleTextStyle: _t(17, FontWeight.w700, AppColors.grey900),
        iconTheme: const IconThemeData(color: AppColors.grey900),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.grey200,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: _t(15, FontWeight.w700, AppColors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.black, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: _t(15, FontWeight.w700, AppColors.black),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: _t(14, FontWeight.w700, AppColors.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: _t(14, FontWeight.w400, AppColors.grey400),
        labelStyle: _t(14, FontWeight.w500, AppColors.grey600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: AppColors.white,
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        labelStyle: _t(12, FontWeight.w600, AppColors.grey700),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.grey100,
        thickness: 1,
        space: 0,
      ),
      scaffoldBackgroundColor: AppColors.grey50,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: _t(11, FontWeight.w700, AppColors.black),
        unselectedLabelStyle: _t(11, FontWeight.w500, AppColors.grey400),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppColors.black,
        contentTextStyle: _t(14, FontWeight.w500, AppColors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 2,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.black,
        unselectedLabelColor: AppColors.grey400,
        indicatorColor: AppColors.black,
        labelStyle: _t(13, FontWeight.w700, AppColors.black),
        unselectedLabelStyle: _t(13, FontWeight.w500, AppColors.grey400),
      ),
    );
  }
}
