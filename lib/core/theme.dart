import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class AppColors {
  AppColors._();

  // ---- Primary (Blue) ----
  static const Color primary50 = Color(0xFFEAF1FD);
  static const Color primary100 = Color(0xFFC1D4F8);
  static const Color primary200 = Color(0xFF98B7F1);
  static const Color primary300 = Color(0xFF719AE9);
  static const Color primary400 = Color(0xFF4A7CE0);
  static const Color primary500 = Color(0xFF235BD6); // default
  static const Color primary600 = Color(0xFF1844A3);
  static const Color primary700 = Color(0xFF13398B);
  static const Color primary800 = Color(0xFF09235D);
  static const Color primary900 = Color(0xFF031032);

  // ---- Secondary (Lime) ----
  static const Color secondary50 = Color(0xFFF8FCEF);
  static const Color secondary100 = Color(0xFFEAF5CF);
  static const Color secondary200 = Color(0xFFDCEEAD);
  static const Color secondary300 = Color(0xFFCEE68A);
  static const Color secondary400 = Color(0xFFC1DE61);
  static const Color secondary500 = Color(0xFFB4D623); // default
  static const Color secondary600 = Color(0xFF89A318);
  static const Color secondary700 = Color(0xFF748B13);
  static const Color secondary800 = Color(0xFF4D5D09);
  static const Color secondary900 = Color(0xFF293203);

  // ---- Error (Red) ----
  static const Color error50 = Color(0xFFFEEEEC);
  static const Color error100 = Color(0xFFFBCBC5);
  static const Color error200 = Color(0xFFF4A8A0);
  static const Color error300 = Color(0xFFEB857B);
  static const Color error400 = Color(0xFFE05F56);
  static const Color error500 = Color(0xFFD32F2F); // default
  static const Color error600 = Color(0xFFA12121);
  static const Color error700 = Color(0xFF891B1B);
  static const Color error800 = Color(0xFF5B0F0F);
  static const Color error900 = Color(0xFF320505);

  // ---- Success (Green) ----
  static const Color success50 = Color(0xFFECF3EC);
  static const Color success100 = Color(0xFFC6DBC5);
  static const Color success200 = Color(0xFFA1C3A0);
  static const Color success300 = Color(0xFF7CAC7C);
  static const Color success400 = Color(0xFF579457);
  static const Color success500 = Color(0xFF2E7D32); // default
  static const Color success600 = Color(0xFF215E24);
  static const Color success700 = Color(0xFF1A4F1D);
  static const Color success800 = Color(0xFF0E3310);
  static const Color success900 = Color(0xFF041905);

  // ---- Warning (Orange) ----
  static const Color warning50 = Color(0xFFFFF2EC);
  static const Color warning100 = Color(0xFFFFD9C6);
  static const Color warning200 = Color(0xFFFEBF9F);
  static const Color warning300 = Color(0xFFFAA578);
  static const Color warning400 = Color(0xFFF5894D);
  static const Color warning500 = Color(0xFFEF6C00); // default
  static const Color warning600 = Color(0xFFB75100);
  static const Color warning700 = Color(0xFF9C4400);
  static const Color warning800 = Color(0xFF692B00);
  static const Color warning900 = Color(0xFF391400);

  // ---- Information (Sky Blue) ----
  static const Color info50 = Color(0xFFECF4FC);
  static const Color info100 = Color(0xFFC6DFF4);
  static const Color info200 = Color(0xFF9FCAEC);
  static const Color info300 = Color(0xFF78B4E4);
  static const Color info400 = Color(0xFF4D9EDB);
  static const Color info500 = Color(0xFF0288D1); // default
  static const Color info600 = Color(0xFF0167A0);
  static const Color info700 = Color(0xFF015788);
  static const Color info800 = Color(0xFF00385B);
  static const Color info900 = Color(0xFF001C31);

  // ---- Neutral (Slate) ----
  static const Color neutral50 = Color(0xFFE2E3E7);
  static const Color neutral100 = Color(0xFFC6C7D0);
  static const Color neutral200 = Color(0xFFAAACB9);
  static const Color neutral300 = Color(0xFF9092A3);
  static const Color neutral400 = Color(0xFF76788D);
  static const Color neutral500 = Color(0xFF5D6077); // default
  static const Color neutral600 = Color(0xFF454862);
  static const Color neutral700 = Color(0xFF2F314D);
  static const Color neutral800 = Color(0xFF1B1C39);
  static const Color neutral900 = Color(0xFF090726);

  // ---- Base ----
  static const Color baseWhite = Color(0xFFFFFFFF);
  static const Color baseBlack = Color(0xFF000000);

  // Convenience shade maps (e.g. AppColors.primary[500])
  static const Map<int, Color> primary = {
    50: primary50, 100: primary100, 200: primary200, 300: primary300,
    400: primary400, 500: primary500, 600: primary600, 700: primary700,
    800: primary800, 900: primary900,
  };
  static const Map<int, Color> secondary = {
    50: secondary50, 100: secondary100, 200: secondary200, 300: secondary300,
    400: secondary400, 500: secondary500, 600: secondary600, 700: secondary700,
    800: secondary800, 900: secondary900,
  };
  static const Map<int, Color> error = {
    50: error50, 100: error100, 200: error200, 300: error300,
    400: error400, 500: error500, 600: error600, 700: error700,
    800: error800, 900: error900,
  };
  static const Map<int, Color> success = {
    50: success50, 100: success100, 200: success200, 300: success300,
    400: success400, 500: success500, 600: success600, 700: success700,
    800: success800, 900: success900,
  };
  static const Map<int, Color> warning = {
    50: warning50, 100: warning100, 200: warning200, 300: warning300,
    400: warning400, 500: warning500, 600: warning600, 700: warning700,
    800: warning800, 900: warning900,
  };
  static const Map<int, Color> info = {
    50: info50, 100: info100, 200: info200, 300: info300,
    400: info400, 500: info500, 600: info600, 700: info700,
    800: info800, 900: info900,
  };
  static const Map<int, Color> neutral = {
    50: neutral50, 100: neutral100, 200: neutral200, 300: neutral300,
    400: neutral400, 500: neutral500, 600: neutral600, 700: neutral700,
    800: neutral800, 900: neutral900,
  };
}

// Semantic activity/status colors (kept from your existing chip usage)
class ActivityColors {
  ActivityColors._();
  static const Color pendingBg = AppColors.warning100;
  static const Color pendingText = AppColors.warning700;
  static const Color approvedBg = AppColors.success100;
  static const Color approvedText = AppColors.success700;
  static const Color rejectedBg = AppColors.error100;
  static const Color rejectedText = AppColors.error700;
  static const Color inactiveBg = AppColors.neutral100;
  static const Color inactiveText = AppColors.neutral700;
}

// =============================================================================
// TYPOGRAPHY
// Font family: Outfit. Base value: 14, Scale: 1.125 (Major Second).
// Sizes below are the modular scale (14 * 1.125^n), rounded to the nearest px.
// =============================================================================

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Outfit';

  static const double bodyXS = 11;
  static const double bodySM = 12;
  static const double bodyMD = 14; // base
  static const double bodyLG = 16;
  static const double h6 = 18;
  static const double h5 = 20;
  static const double h4 = 22;
  static const double h3 = 25;
  static const double h2 = 28;
  static const double h1 = 32;

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static TextStyle _style(double size, FontWeight weight, Color color,
      {TextDecoration? decoration}) {
    return GoogleFonts.outfit(
      fontSize: size,
      fontWeight: weight,
      color: color,
      decoration: decoration,
      height: 1.35,
    );
  }

  static TextStyle headingStyle(double size, Color color) =>
      _style(size, bold, color);

  static TextStyle h1Style(Color c) => headingStyle(h1, c);
  static TextStyle h2Style(Color c) => headingStyle(h2, c);
  static TextStyle h3Style(Color c) => headingStyle(h3, c);
  static TextStyle h4Style(Color c) => headingStyle(h4, c);
  static TextStyle h5Style(Color c) => headingStyle(h5, c);
  static TextStyle h6Style(Color c) => headingStyle(h6, c);

  // ---- Body text, parametrized by size + weight ----
  static TextStyle bodyLarge(FontWeight w, Color c) => _style(bodyLG, w, c);
  static TextStyle bodyMedium(FontWeight w, Color c) => _style(bodyMD, w, c);
  static TextStyle bodySmall(FontWeight w, Color c) => _style(bodySM, w, c);
  static TextStyle bodyExtraSmall(FontWeight w, Color c) =>
      _style(bodyXS, w, c);

  // ---- Link variants (underlined, primary color by default) ----
  static TextStyle linkLarge(Color c) =>
      _style(bodyLG, regular, c, decoration: TextDecoration.underline);
  static TextStyle linkMedium(Color c) =>
      _style(bodyMD, regular, c, decoration: TextDecoration.underline);
  static TextStyle linkSmall(Color c) =>
      _style(bodySM, regular, c, decoration: TextDecoration.underline);
  static TextStyle linkExtraSmall(Color c) =>
      _style(bodyXS, regular, c, decoration: TextDecoration.underline);

  static TextTheme textTheme(Color onSurface, Color linkColor) {
    return TextTheme(
      displayLarge: h1Style(onSurface),
      displayMedium: h2Style(onSurface),
      displaySmall: h3Style(onSurface),
      headlineMedium: h4Style(onSurface),
      headlineSmall: h5Style(onSurface),
      titleLarge: h6Style(onSurface),
      bodyLarge: bodyLarge(regular, onSurface),
      bodyMedium: bodyMedium(regular, onSurface),
      bodySmall: bodySmall(regular, onSurface),
      labelLarge: bodyMedium(medium, onSurface),
      labelMedium: bodySmall(medium, onSurface),
      labelSmall: bodyExtraSmall(medium, onSurface),
    );
  }
}



class AppTheme {
  AppTheme._();
  static const Color primaryBlue = Color(0xFF235BD6);

  static const Color lightBackground = AppColors.primary50;
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  static ThemeData get lightTheme {
    const onSurface = AppColors.neutral900;
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: lightBackground,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme(onSurface, AppColors.primary500),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary500,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.baseWhite),
        titleTextStyle: AppTypography.bodyLarge(
          AppTypography.semibold,
          AppColors.baseWhite,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        secondary: AppColors.secondary500,
        error: AppColors.error500,
        surface: AppColors.baseWhite,
        onPrimary: AppColors.baseWhite,
        onSecondary: AppColors.neutral900,
        onSurface: AppColors.neutral900,
        onError: AppColors.baseWhite,
      ),
      cardTheme: CardThemeData(
        color: AppColors.baseWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: AppColors.baseWhite,
          textStyle: AppTypography.bodyMedium(
            AppTypography.semibold,
            AppColors.baseWhite,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.baseWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error500),
        ),
      ),
      dividerColor: AppColors.neutral100,
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    const onSurface = AppColors.neutral50;
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary400,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme(onSurface, AppColors.primary300),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.baseWhite),
        titleTextStyle: AppTypography.bodyLarge(
          AppTypography.semibold,
          AppColors.baseWhite,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary400,
        secondary: AppColors.secondary400,
        error: AppColors.error400,
        surface: darkSurface,
        onPrimary: AppColors.baseWhite,
        onSecondary: AppColors.neutral900,
        onSurface: AppColors.neutral50,
        onError: AppColors.baseWhite,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary400,
          foregroundColor: AppColors.baseWhite,
          textStyle: AppTypography.bodyMedium(
            AppTypography.semibold,
            AppColors.baseWhite,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerColor: AppColors.neutral700,
      useMaterial3: true,
    );
  }
}