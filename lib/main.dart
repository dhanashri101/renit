import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/splash_screen/splash_screen.dart';


final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const RentItApp());
}

class RentItApp extends StatelessWidget {
  const RentItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (
        BuildContext context,
        ThemeMode currentMode,
        Widget? child,
      ) {
        final bool isDarkMode = currentMode == ThemeMode.dark;

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                isDarkMode ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: isDarkMode
                ? AppTheme.darkBackground
                : AppTheme.lightBackground,
            systemNavigationBarIconBrightness:
                isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'Rentit 24 Clone',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // Uses only the manually selected theme.
          themeMode: currentMode,

          home: const SplashScreen(),
        );
      },
    );
  }
}

/// Enable light mode.
void setLightTheme() {
  themeNotifier.value = ThemeMode.light;
}

/// Enable dark mode.
void setDarkTheme() {
  themeNotifier.value = ThemeMode.dark;
}

/// Toggle light and dark modes.
void toggleTheme() {
  themeNotifier.value =
      themeNotifier.value == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
}