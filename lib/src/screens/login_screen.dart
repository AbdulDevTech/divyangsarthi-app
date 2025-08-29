import 'package:flutter/material.dart';
import '../shared/services/api_client.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

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

  bool get _canSubmit => _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && !_loading;

  void _login() async {
    if (!_canSubmit) return;
    setState(() => _loading = true);
    try {
      final client = ApiClient.create();
      // capture request payload for logging
      final payload = {'emailorphone': _emailController.text.trim(), 'password': _passwordController.text};
      debugPrint('Attempting login with payload: $payload');
      final result = await client.login(_emailController.text.trim(), _passwordController.text);
      setState(() => _loading = false);
      // Build a readable log for the UI
      _lastApiLog = 'Request: /users/public/login\nPayload: $payload\nResult: ${result ?? 'null'}';
      if (!mounted) return;
      if (result != null && result['token'] != null) {
        final user = result['user'] as Map<String, dynamic>?;
        final role = user != null && user['role'] != null ? user['role'].toString() : 'user';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login success. Role: $role')));
        // intentionally do NOT navigate to dashboard — keep user on login screen so logs can be inspected
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed: no token')));
      }
    } catch (e, st) {
      setState(() => _loading = false);
      // log full error and stacktrace to help diagnose NotInitializedError
      debugPrint('Login error: $e');
      debugPrint('$st');
      _lastApiLog = 'Request: /users/public/login\nPayload: {emailorphone: ${_emailController.text.trim()}}\nError: $e\nStack: $st';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login error: ${e.runtimeType}: ${e.toString()}')));
    }
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
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email or phone'), onChanged: (_) => setState(() {})),
            const SizedBox(height: 8),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true, onChanged: (_) => setState(() {})),
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
              child: const Text('Don\'t have an account? Register'),
            ),
            const SizedBox(height: 12),
            // Display last API log for debugging
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
