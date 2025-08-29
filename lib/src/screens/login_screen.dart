import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // stub
    setState(() => _loading = false);
    // TODO: call API client and navigate to home on success
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login flow not implemented')));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator() : const Text('Login')),
          ],
        ),
      ),
    );
  }
}
