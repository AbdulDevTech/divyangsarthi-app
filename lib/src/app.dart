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
      initialRoute: '/',
      routes: {
        '/': (c) => const SplashScreen(),
        '/login': (c) => const LoginScreen(),
        '/home': (c) => const HomeScreen(),
        // TODO: add /profile, /students, /media routes
      },
    );
  }
}
