import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; 
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/login_screens/login_screen.dart';
import 'package:rentit24/pages/splash_screen/splash_screen.dart';
import 'package:rentit24/pages/welcomescreen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, 
      statusBarBrightness: Brightness.light, 
    ),
  );

  runApp(const RentItApp());
}

class RentItApp extends StatelessWidget {
  const RentItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Rentit 24 Clone',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const SplashScreen(), 
        );
      },
    );
  }
}

