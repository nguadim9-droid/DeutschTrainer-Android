import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color brandPrimary = Color(0xFF1E40AF); // Deep Indigo
  static const Color brandSecondary = Color(0xFF3B82F6); // Vibrant Blue
  static const Color brandLight = Color(0xFFEFF6FF);

  // Status colors
  static const Color successGreen = Color(0xFF059669); // Emerald Green
  static const Color successGreenLight = Color(0xFFD1FAE5);
  static const Color errorRed = Color(0xFFDC2626); // Ruby Red
  static const Color errorRedLight = Color(0xFFFEE2E2);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color warningAmberLight = Color(0xFFFEF3C7);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: Brightness.light,
      primary: brandPrimary,
      secondary: brandSecondary,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
      iconTheme: IconThemeData(color: Color(0xFF0F172A)),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: brandPrimary, width: 2),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandSecondary,
      brightness: Brightness.dark,
      primary: brandSecondary,
      surface: const Color(0xFF1E293B),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
    ),
  );
}
