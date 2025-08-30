import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

class DivyangsarthiApp extends StatelessWidget {
  const DivyangsarthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Derive a seed scheme from a purple accent, then tune primary/secondary to match the website
    var scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF6A2FB9));
    scheme = scheme.copyWith(
      primary: const Color(0xFF020024), // deep navy (splash base)
      primaryContainer: const Color(0xFF090979), // mid purple
      secondary: const Color(0xFF6A2FB9), // purple accent
      tertiary: const Color(0xFF00D4FF), // cyan highlight
      background: Colors.white,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    );

    return MaterialApp(
      title: 'Divyangsarthi',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        primaryColor: scheme.primary,
        scaffoldBackgroundColor: scheme.background,
        appBarTheme: AppBarTheme(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: scheme.tertiary, foregroundColor: scheme.onTertiary),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: scheme.secondary)),
        textTheme: Typography.material2021().black.apply(bodyColor: Colors.black),
      ),
      // for debugging, use home directly to avoid route registration issues
      home: const SplashScreen(),
    );
  }
}
