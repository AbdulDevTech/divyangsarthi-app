import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../shared/services/api_client.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  final Duration animationDuration;
  final Duration exitDuration;

  const SplashScreen({
    super.key,
  this.animationDuration = const Duration(milliseconds: 2400),
  this.exitDuration = const Duration(milliseconds: 700),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animationDuration);
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Start animation and concurrently check auth
    final client = ApiClient.create();
    final tokenFuture = client.getAccessToken();
    // ensure the animation plays for at least the configured animationDuration
    await Future.wait([tokenFuture, Future.delayed(widget.animationDuration)]);
    final token = await tokenFuture;
    if (!mounted) return;
    // fade out the entire splash smoothly
    setState(() => _opacity = 0.0);
    await Future.delayed(widget.exitDuration);
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen(role: 'user')));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the provided CSS-like gradient for the background
    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF020024), Color(0xFF090979), Color(0xFF00D4FF)],
      stops: [0.0, 0.54, 1.0],
    );

    return Scaffold(
      body: AnimatedOpacity(
        duration: widget.exitDuration,
        opacity: _opacity,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: gradient),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380, maxHeight: 220),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const SizedBox(
                      height: 120,
                      child: Center(child: Text('Divyangsarthi', style: TextStyle(color: Colors.white, fontSize: 28))),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
