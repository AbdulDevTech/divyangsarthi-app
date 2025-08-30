import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../shared/services/api_client.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 500));
  final client = ApiClient.create();
  final token = await client.getAccessToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      // Optionally, fetch user role from storage or API
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardScreen(role: 'user')),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
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
