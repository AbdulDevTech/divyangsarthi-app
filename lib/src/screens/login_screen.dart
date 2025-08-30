import 'package:flutter/material.dart';
import '../shared/services/api_client.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'package:flutter/services.dart';
import '../widgets/header_logo.dart';

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
  } else if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}').hasMatch(value) && !RegExp(r'^\d{10,}').hasMatch(value)) {
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isWide
                      ? Row(
                          children: [
                            // Left illustration card
                            Expanded(
                              flex: 5,
                              child: Card(
                                color: Theme.of(context).colorScheme.primary,
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Illustration placeholder (image will be added later)
                                      Expanded(
                                        child: Center(
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.symmetric(horizontal: 12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.all(24),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.school, size: 110, color: Colors.white70),
                                                const SizedBox(height: 12),
                                                Text('Illustration placeholder', style: Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.white70)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Knowledge Unleashed, Virtually Limitless',
                                        style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            // Right form card
                            Expanded(
                              flex: 4,
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // header
                                        HeaderLogo(title: "Welcome, let's get started!"),
                                      const SizedBox(height: 12),
                                      Text('Please use your credentials to login.', style: Theme.of(context).textTheme.bodyText2),
                                      const SizedBox(height: 18),
                                      // email
                                        TextField(
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSurface),
                                          labelText: 'Enter email or Phone number',
                                          errorText: _emailError,
                                          filled: true,
                                          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.98),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                        onChanged: (v) {
                                          _validateEmail(v);
                                          setState(() {});
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      // password
                                        TextField(
                                          controller: _passwordController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.onSurface),
                                          labelText: 'Password',
                                          errorText: _passwordError,
                                          filled: true,
                                          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.98),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                          suffixIcon: IconButton(
                                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).colorScheme.onSurface),
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
                                        child: TextButton(onPressed: _forgotPassword, child: const Text('Forgot password?')),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: FilledButton(
                                              onPressed: _canSubmit ? _login : null,
                                              child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          OutlinedButton(
                                            onPressed: () {/* guest login action */},
                                            child: const Text('Guest Login'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        const Text('Not a member yet? '),
                                        TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Register')),
                                      ]),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Card(
                                color: Theme.of(context).colorScheme.primary,
                                elevation: 6,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    height: 220,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(child: Icon(Icons.school, size: 90, color: Colors.white70)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                        HeaderLogo(title: "Welcome, let's get started!"),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _emailController,
                                        decoration: InputDecoration(prefixIcon: const Icon(Icons.person_outline), labelText: 'Enter email or Phone number', errorText: _emailError, filled: true, fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.98), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                                        onChanged: (v) { _validateEmail(v); setState(() {}); },
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline), labelText: 'Password', errorText: _passwordError, filled: true, fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.98), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
                                        obscureText: _obscurePassword,
                                        onChanged: (v) { _validatePassword(v); setState(() {}); },
                                      ),
                                      const SizedBox(height: 12),
                                      FilledButton(onPressed: _canSubmit ? _login : null, child: const Text('Login')),
                                      const SizedBox(height: 8),
                                      OutlinedButton(onPressed: () {}, child: const Text('Guest Login')),
                                      const SizedBox(height: 8),
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [ const Text('Not a member yet? '), TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Register')) ]),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
