import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // safe dotenv load: don't fail the app if .env is missing or invalid
    await dotenv.load();
    debugPrint('Loaded .env successfully');
  } catch (e, st) {
    debugPrint('dotenv.load() failed: $e');
    debugPrint('$st');
  }

  // Run the app inside a guarded zone to catch errors early
  runZonedGuarded(() {
    runApp(const ProviderScope(child: DivyangsarthiApp()));
  }, (error, stack) {
    debugPrint('Uncaught error in runZonedGuarded: $error');
    debugPrint('$stack');
  });
}
