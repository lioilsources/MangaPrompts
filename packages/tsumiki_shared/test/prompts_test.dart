import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki_shared/tsumiki_shared.dart';

import 'support.dart';

List<Map<String, dynamic>> _list(Map<String, dynamic> p, String key) => [
  for (final e in p[key] as List) (e as Map).cast<String, dynamic>(),
];

void main() {
  final p = loadPrompts();

  test('hair == hairprompt.py', () {
    final rows = _list(p, 'hair');
    expect(rows, isNotEmpty);
    for (final r in rows) {
      final s = r['shape'] as Map;
      final style = Hairstyle(
        id: r['style_id'] as String,
        label: '',
        group: '',
        section: '',
        block: r['block'] as String,
        shape: HairShape(
          length: HairLength.values.firstWhere((v) => v.name == s['length']),
          bangs: HairBangs.values.firstWhere((v) => v.name == s['bangs']),
          updo: s['updo'] as bool,
        ),
      );
      final phrase = r['new_colour_phrase'] as String?;
      expect(
        hairPrompt(
          style,
          r['colour'] as String?,
          engine: HairPromptEngine.values.firstWhere(
            (e) => e.name == r['engine'],
          ),
          newColour: phrase == null
              ? null
              : HairColour(id: '', label: '', group: '', phrase: phrase),
        ),
        r['expected'],
      );
    }
  });

  test('beard == beardprompt.py', () {
    final rows = _list(p, 'beard');
    expect(rows.length, 63);
    for (final r in rows) {
      final style = Beard(
        id: r['style_id'] as String,
        label: '',
        cs: '',
        section: '',
        block: r['block'] as String,
        region: const BeardRegion(BeardRegionKind.full),
      );
      expect(
        beardPrompt(style, r['colour'] as String?, grey: r['grey'] as bool),
        r['expected'],
      );
    }
  });

  test(
    'glasses == glassesprompt.py',
    () {
      for (final r in _list(p, 'glasses')) {
        final style = Glasses(
          id: r['style_id'] as String,
          label: '',
          cs: '',
          group: '',
          section: '',
          block: r['block'] as String,
          finishes: const [],
          fit: GlassesFit(tinted: r['tinted'] as bool),
        );
        expect(glassesPrompt(style, r['finish'] as String?), r['expected']);
      }
    },
    skip: p.containsKey('glasses')
        ? false
        : 'no glasses prompts: tgbot/glassesprompt.py is not in this tree yet; '
              'rerun tools/sync_fixtures.sh --gen after merging it',
  );

  test('restyle == the bench reading of the Dart source', () {
    final rows = _list(p, 'restyle');
    expect(rows, isNotEmpty);
    for (final r in rows) {
      final style = restyleStyleById(r['style_id'] as String)!;
      final medium = RestyleMedium.values.firstWhere(
        (m) => m.wire == r['medium'],
      );
      expect(restylePrompt(style, medium), r['expected']);
      expect(restyleNegative(medium), r['negative']);
      expect(restyleLookPrompt(style, medium), r['expected']);
    }
  });

  test('colour words == hairmask.colour_name', () {
    for (final r in _list(p, 'colour_names')) {
      final lab = (r['lab'] as List).cast<double>();
      expect(hairColourName(lab[0], lab[1], lab[2]), r['name'], reason: '$lab');
    }
  });

  test('feather == hairmask.feather_px', () {
    for (final r in _list(p, 'feather')) {
      expect(hairFeatherPx(r['width'] as int, r['height'] as int), (
        r['expand'],
        r['blur'],
      ));
    }
  });

  test('negatives', () {
    expect(kHairNegative, p['hair_negative']);
    expect(kBeardNegative, p['beard_negative']);
  });

  test('look sits between medium and style, skipped steps leave no trace', () {
    final style = restyleStyleById('ukiyoe')!;
    final head = restyleMediumHead(RestyleMedium.photo);
    final glasses = Glasses(
      id: 'round',
      label: '',
      cs: '',
      group: '',
      section: '',
      block: 'round eyeglasses',
      finishes: const [],
      fit: const GlassesFit(),
    );
    expect(
      restyleLookPrompt(
        style,
        RestyleMedium.photo,
        look: RestyleLook.of(glasses: glasses, finish: 'gold wire'),
      ),
      '$head, wearing gold wire round eyeglasses, ${style.block}',
    );
    const clean = Beard(
      id: kCleanShavenId,
      label: '',
      cs: '',
      section: '',
      block: '',
      region: BeardRegion(BeardRegionKind.full),
    );
    expect(RestyleLook.of(beard: clean).parts, ['clean-shaven']);
    expect(RestyleLook.of().parts, isEmpty);
  });
}
