import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

class DivyangsarthiApp extends StatelessWidget {
  const DivyangsarthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divyangsarthi',
      theme: ThemeData(primarySwatch: Colors.blue),
      // for debugging, use home directly to avoid route registration issues
      home: const SplashScreen(),
    );
  }
}
