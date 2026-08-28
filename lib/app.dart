import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/web_entry.dart';

class TsumikiApp extends ConsumerWidget {
  const TsumikiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Tsumiki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Mini App opens on photo animation; native builds have no bot backend
      // to animate against, so they keep the prompt builder as their home.
      home: kIsWeb ? const WebEntry() : const HomeScreen(),
    );
  }
}
