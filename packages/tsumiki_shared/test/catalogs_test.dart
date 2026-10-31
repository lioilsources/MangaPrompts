import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki_shared/tsumiki_shared.dart';

void main() {
  test('hair catalog carries Czech names and previews in the package', () {
    expect(kHairstyles, isNotEmpty);
    for (final s in kHairstyles) {
      expect(s.cs, isNotEmpty, reason: s.id);
      expect(s.preview, 'packages/tsumiki_shared/assets/hair/${s.id}.jpg');
      expect(
        File('assets/hair/${s.id}.jpg').existsSync(),
        isTrue,
        reason: s.id,
      );
    }
  });

  test('hair colours carry the prompt phrase', () {
    for (final c in kHairColours) {
      expect(c.phrase, isNotEmpty, reason: c.id);
      expect(c.cs, isNotEmpty, reason: c.id);
    }
    expect(hairColourById(kHairColours.first.id), kHairColours.first);
    expect(hairColourById('nope'), isNull);
  });

  test('catalogs that wait for the gate are empty', () {
    expect(kBeards, isEmpty);
    expect(kGlasses, isEmpty);
    expect(kMotions, isEmpty);
  });

  test('models', () {
    const b = Beard(
      id: 'goatee',
      label: 'Goatee',
      cs: 'bradka',
      section: 'Goatee',
      block: 'goatee',
      region: BeardRegion(BeardRegionKind.chin, belowChin: 0.1),
    );
    expect(b.previewPath, 'packages/tsumiki_shared/assets/beard/goatee.jpg');
    expect(beardsIn('Goatee', const [b]), [b]);
    expect(
      const GlassesFit(size: GlassesSize.oversized, tinted: true).toJson(),
      {'size': 'oversized', 'tinted': true},
    );
    const m = Motion(
      id: 'blink',
      label: 'Blink',
      cs: 'mrknutí',
      seconds: 3,
      engine: MotionEngine.live,
      loop: true,
    );
    expect(m.engine.name, 'live');
  });

  test('shape key matches hairmask.HairShape.key', () {
    expect(
      const HairShape(
        length: HairLength.long,
        bangs: HairBangs.curtain,
        updo: true,
      ).key,
      'long-curtain-updo',
    );
  });
}
