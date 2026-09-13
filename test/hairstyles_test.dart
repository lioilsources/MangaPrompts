import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki/config/hairstyles.dart';
import 'package:tsumiki/ui/screens/hair_screen.dart';
import 'package:tsumiki/ui/widgets/tsumiki_app_bar.dart';

const _pixie = Hairstyle(
  id: 'pixie',
  label: 'Pixie Cut',
  group: kHairGroupWomen,
  section: 'Cuts',
  block: "pixie cut, very short cropped women's haircut",
  shape: HairShape(length: HairLength.short),
);
const _bun = Hairstyle(
  id: 'm-man-bun',
  label: 'Man Bun',
  group: kHairGroupMen,
  section: 'Updos',
  block: 'man bun, long hair tied into a bun',
  shape: HairShape(length: HairLength.keep, updo: true),
);
const _halfUp = Hairstyle(
  id: 'half-up',
  label: 'Half-Up Half-Down',
  group: kHairGroupWomen,
  section: 'Updos',
  block: 'half-up half-down hairstyle',
  shape: HairShape(length: HairLength.keep, updo: true),
);

void main() {
  test('shape serialises to the backend enum names', () {
    expect(
      const HairShape(
        length: HairLength.medium,
        bangs: HairBangs.curtain,
      ).toJson(),
      {'length': 'medium', 'bangs': 'curtain', 'updo': false},
    );
  });

  test('shipped catalog: unique ids, English labels, known sections', () {
    final ids = kHairstyles.map((s) => s.id).toSet();
    expect(ids.length, kHairstyles.length);
    final ascii = RegExp(r'^[A-Za-z0-9 \-&()/]+$');
    for (final s in kHairstyles) {
      expect(kHairGroups, contains(s.group), reason: s.id);
      expect(kHairSections, contains(s.section), reason: s.id);
      expect(ascii.hasMatch(s.label), isTrue, reason: s.label);
      expect(RegExp(r'^[a-z0-9-]+$').hasMatch(s.id), isTrue, reason: s.id);
      for (final word in ['anime', 'illustration', 'painting']) {
        expect(s.block, isNot(contains(word)), reason: s.id);
      }
    }
  });

  test('the card is only offered once a hairstyle passed the gate', () {
    expect(
      screenOffered(
        TsumikiScreen.hair,
        animateAvailable: true,
        hairstylesAvailable: false,
      ),
      isFalse,
    );
    expect(
      screenOffered(
        TsumikiScreen.hair,
        animateAvailable: false,
        hairstylesAvailable: true,
      ),
      isTrue,
    );
    expect(
      screenOffered(
        TsumikiScreen.restyle,
        animateAvailable: false,
        hairstylesAvailable: false,
      ),
      isTrue,
    );
    expect(TsumikiScreen.hair.video, isFalse);
  });

  testWidgets('hair screen: groups, sections, submit needs photo and style', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HairScreen(catalog: [_pixie, _halfUp, _bun])),
      ),
    );
    await tester.pump();
    expect(find.text('Pixie Cut'), findsOneWidget);
    expect(find.text('Man Bun'), findsNothing);
    expect(find.text('Cuts'), findsOneWidget);
    expect(find.text('Updos'), findsOneWidget);

    await tester.tap(find.text('Men'));
    await tester.pump();
    expect(find.text('Man Bun'), findsOneWidget);
    expect(find.text('Pixie Cut'), findsNothing);

    await tester.tap(find.text('Man Bun'));
    await tester.pump();
    final fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(fab.onPressed, isNull, reason: 'no photo picked yet');
  });

  testWidgets('a colour alone is enough; the button says what happens',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: HairScreen(
          catalog: [_pixie],
          colours: [
            HairColour(id: 'copper-red', label: 'Copper red', group: 'Red'),
          ],
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('Keep mine'), findsOneWidget);
    expect(find.text('Keep my cut'), findsOneWidget);
    await tester.tap(find.text('Copper red'));
    await tester.pump();
    expect(find.text('New colour'), findsOneWidget);
    await tester.tap(find.text('Pixie Cut'));
    await tester.pump();
    expect(find.text('New haircut'), findsOneWidget);
  });

  testWidgets('empty catalog says so instead of showing nothing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HairScreen(catalog: [], colours: [])),
      ),
    );
    await tester.pump();
    expect(find.textContaining('No hairstyles yet'), findsOneWidget);
  });
}
