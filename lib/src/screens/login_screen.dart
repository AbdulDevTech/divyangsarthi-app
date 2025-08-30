import 'package:flutter/material.dart';
import '../shared/services/api_client.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String _lastApiLog = '';
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  bool get _canSubmit => _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && !_loading && _emailError == null && _passwordError == null;

  void _validateEmail(String value) {
    if (value.isEmpty) {
      _emailError = 'Email or phone is required';
    } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(value) && !RegExp(r'^\d{10,}\$').hasMatch(value)) {
      _emailError = 'Enter a valid email or phone';
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

  void _login() async {
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);
    setState(() {});
    if (!_canSubmit) return;
    setState(() => _loading = true);
    try {
      final client = ApiClient.create();
      final payload = {'emailorphone': _emailController.text.trim(), 'password': _passwordController.text};
      debugPrint('Attempting login with payload: $payload');
      final result = await client.login(_emailController.text.trim(), _passwordController.text);
      setState(() => _loading = false);
      _lastApiLog = 'Request: /users/public/login\nPayload: $payload\nResult: [32m${result ?? 'null'}[0m';
      if (!mounted) return;
      if (result != null && result['token'] != null) {
        final user = result['user'] as Map<String, dynamic>?;
        final role = user != null && user['role'] != null ? user['role'].toString() : 'user';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login success. Role: $role')));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen(role: role)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed: no token')));
      }
    } catch (e, st) {
      setState(() => _loading = false);
      debugPrint('Login error: $e');
      debugPrint('$st');
      _lastApiLog = 'Request: /users/public/login\nPayload: {emailorphone: ${_emailController.text.trim()}}\nError: $e\nStack: $st';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login error: ${e.runtimeType}: ${e.toString()}')));
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forgot password functionality not implemented.')));
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
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email or phone',
                errorText: _emailError,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) {
                _validateEmail(v);
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              onChanged: (v) {
                _validatePassword(v);
                setState(() {});
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgotPassword,
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit ? _login : null,
                child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Login'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text("Don't have an account? Register"),
            ),
            const SizedBox(height: 12),
            if (_lastApiLog.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text('Last API log:', style: Theme.of(context).textTheme.caption),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.black12,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(_lastApiLog, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
