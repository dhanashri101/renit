import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF235BD6);
  static const Color lightBackground = Color(0xFFEAF1FD);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        surface: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        surface: darkSurface,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      useMaterial3: true,
    );
  }
}

class ActivityColors {
  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color pendingText = Color(0xFFD97706);
  static const Color approvedBg = Color(0xFFD1FAE5);
  static const Color approvedText = Color(0xFF059669);
  static const Color rejectedBg = Color(0xFFFEE2E2);
  static const Color rejectedText = Color(0xFFDC2626);
  static const Color inactiveBg = Color(0xFFF3F4F6);
  static const Color inactiveText = Color(0xFF4B5563);
}