import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsumiki/providers/api_provider.dart';
import 'package:tsumiki/providers/video_scenes_provider.dart';
import 'package:tsumiki/services/telegram_backend_service.dart';
import 'package:tsumiki/ui/screens/animate_screen.dart';
import 'package:tsumiki/ui/screens/home_screen.dart';
import 'package:tsumiki/ui/screens/web_entry.dart';

/// The Mini App opens on animation, but only when there is something to
/// animate with — a dead render server must not become the app's front door.
const _scene = TgVideoScene(
  id: 'wink',
  label: 'Wink at the camera',
  desc: '',
  beats: 3,
  seconds: 15.1,
  minutesEst: 8,
);

Future<void> _pump(
  WidgetTester tester,
  Override override,
  SharedPreferences prefs,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [override, sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(home: WebEntry()),
    ),
  );
  await tester.pump();
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });
  testWidgets('catalog available → lands on the animate screen', (tester) async {
    await _pump(
      tester,
      videoScenesProvider.overrideWith((ref) async => [_scene]),
      prefs,
    );
    expect(find.byType(AnimateScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('render server down → falls back to image generation',
      (tester) async {
    await _pump(
      tester,
      videoScenesProvider.overrideWith((ref) async => throw Exception('502')),
      prefs,
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AnimateScreen), findsNothing);
  });

  testWidgets('empty catalog → falls back to image generation', (tester) async {
    await _pump(
      tester,
      videoScenesProvider.overrideWith((ref) async => <TgVideoScene>[]),
      prefs,
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AnimateScreen), findsNothing);
  });
}
