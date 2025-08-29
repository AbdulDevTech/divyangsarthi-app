import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divyangsarthi Home'),
      ),
      body: const Center(
        child: Text('Welcome to Divyangsarthi!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
