import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'platform/telegram_webapp.dart';
import 'providers/api_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TsumikiApp(),
    ),
  );

  // No-ops outside the Telegram Mini App webview.
  TelegramWebApp.ready();
  TelegramWebApp.expand();
  TelegramWebApp.disableVerticalSwipes();
}
