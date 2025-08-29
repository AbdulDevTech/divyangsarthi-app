import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // wait a short moment then navigate to LoginScreen
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      try {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      } catch (e) {
        debugPrint('Navigation from SplashScreen failed: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Divyangsarthi (debug)', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}
