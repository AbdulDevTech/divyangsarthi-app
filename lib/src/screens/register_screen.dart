import 'package:flutter/material.dart';
import '../shared/services/api_client.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  bool get _canSubmit => _nameController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && !_loading && _nameError == null && _emailError == null && _passwordError == null;

  void _validateName(String value) {
    if (value.isEmpty) {
      _nameError = 'Name is required';
    } else {
      _nameError = null;
    }
  }

  void _validateEmail(String value) {
    if (value.isEmpty) {
      _emailError = 'Email is required';
  } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(value)) {
      _emailError = 'Enter a valid email';
    } else {
      _emailError = null;
    }
  }

  void _validatePassword(String value) {
    if (value.isEmpty) {
      _passwordError = 'Password is required';
    } else if (value.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
    } else {
      _passwordError = null;
    }
  }

  void _register() async {
    _validateName(_nameController.text);
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);
    setState(() {});
    if (!_canSubmit) return;
    setState(() => _loading = true);
    try {
      final client = ApiClient.create();
      final result = await client.register(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text);
      setState(() => _loading = false);
      if (result != null && result['token'] != null) {
        final user = result['user'] as Map<String, dynamic>?;
        final role = user != null && user['role'] != null ? user['role'].toString() : 'user';
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen(role: role)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed: no token')));
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration error: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            height: 360,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Icon(Icons.school, size: 120, color: Colors.white70)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Create an account', style: Theme.of(context).textTheme.headline6),
                            const SizedBox(height: 8),
                            TextField(controller: _nameController, decoration: InputDecoration(prefixIcon: const Icon(Icons.person_outline), labelText: 'Name', errorText: _nameError, filled: true, fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.98), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), onChanged: (v) { _validateName(v); setState(() {}); }),
                            const SizedBox(height: 8),
                            TextField(controller: _emailController, decoration: InputDecoration(prefixIcon: const Icon(Icons.email_outlined), labelText: 'Email', errorText: _emailError, filled: true, fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.98), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), keyboardType: TextInputType.emailAddress, onChanged: (v) { _validateEmail(v); setState(() {}); }),
                            const SizedBox(height: 8),
                            TextField(controller: _passwordController, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline), labelText: 'Password', errorText: _passwordError, filled: true, fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.98), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), obscureText: _obscurePassword, onChanged: (v) { _validatePassword(v); setState(() {}); }),
                            const SizedBox(height: 12),
                            FilledButton(onPressed: _canSubmit ? _register : null, child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Register')),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [ const Text('Already a member? '), TextButton(onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Login')) ]),
                          ],
                        ),
                      ),
                    ],
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
