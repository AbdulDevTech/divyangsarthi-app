import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // schedule a short navigation to a placeholder so we can confirm render
    Timer(const Duration(milliseconds: 500), () {
      // navigate to a simple scaffold so we can see the UI changed
      try {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Splash OK', style: TextStyle(fontSize: 24))),
          ),
        ));
      } catch (e) {
        debugPrint('Navigation from SplashScreen failed: $e');
      }
    });

    return const Scaffold(
      body: Center(
        child: Text('Divyangsarthi (debug)', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}
