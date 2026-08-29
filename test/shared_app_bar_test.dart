import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsumiki/providers/api_provider.dart';
import 'package:tsumiki/providers/video_scenes_provider.dart';
import 'package:tsumiki/services/telegram_backend_service.dart';
import 'package:tsumiki/ui/screens/animate_screen.dart';
import 'package:tsumiki/ui/screens/home_screen.dart';
import 'package:tsumiki/ui/widgets/tsumiki_app_bar.dart';

/// The chrome must not shift between the two screens: same bar, so the Stars
/// shop and the way across are always in the same place.
const _scene = TgVideoScene(
  id: 'wink',
  label: 'Wink at the camera',
  desc: '',
  beats: 3,
  seconds: 15.1,
  minutesEst: 8,
);

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          videoScenesProvider.overrideWith((ref) async => [_scene]),
        ],
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pump();
  }

  testWidgets('the animate screen uses the shared title bar', (tester) async {
    await pump(tester, const AnimateScreen());
    expect(find.byType(TsumikiAppBar), findsOneWidget);
    expect(find.text('Tsumiki'), findsOneWidget);
  });

  testWidgets('the prompt builder uses the shared title bar', (tester) async {
    await pump(tester, const HomeScreen());
    expect(find.byType(TsumikiAppBar), findsOneWidget);
    expect(find.text('Tsumiki'), findsOneWidget);
  });
}
