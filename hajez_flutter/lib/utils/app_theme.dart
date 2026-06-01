import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0097A7);
  static const primaryLight = Color(0xFF4DD0E1);
  static const primaryDark = Color(0xFF006064);
  static const secondary = Color(0xFF00838F);
  static const accent = Color(0xFFB2EBF2);
  static const background = Color(0xFFF5F7F8);
  static const white = Color(0xFFFFFFFF);
  static const dark = Color(0xFF1A2B3C);
  static const darkSecondary = Color(0xFF2D4A5C);
  static const grey = Color(0xFF9E9E9E);
  static const greyLight = Color(0xFFEEF2F3);
  static const greyMedium = Color(0xFFDDE4E7);
  static const error = Color(0xFFE53935);
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFF8F00);
  static const star = Color(0xFFFFC107);
}

class AppText {
  static const heading1 = TextStyle(fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.dark);
  static const heading2 = TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark);
  static const heading3 = TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.dark);
  static const body = TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.dark);
  static const bodyGrey = TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.grey);
  static const small = TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.grey);
  static const price = TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.dark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: 'Cairo', color: AppColors.dark, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.greyLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.grey),
      hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.grey),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
