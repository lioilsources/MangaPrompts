import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki_shared/tsumiki_shared.dart';

import 'support.dart';

/// The main safety: every mask Python wrote to the fixtures is rebuilt here
/// from the same parse.png, and must match pixel for pixel.
void check(FixtureCase c, Map<String, dynamic> e, MaskResult Function() build) {
  final style = e['style'];
  final error = e['error'] as String?;
  if (error != null) {
    expect(
      build,
      throwsA(isA<HairMaskException>().having((x) => x.code, 'code', error)),
      reason: '${c.name}/$style',
    );
    return;
  }
  final res = build();
  final want = decodeMaskPng(File('${c.dir}/${e['file']}').readAsBytesSync());
  expect(iou(res.mask, want), 1.0, reason: '${c.name}/$style');
  final box = (e['face_box'] as List).cast<int>();
  expect(
    [res.faceBox.$1, res.faceBox.$2, res.faceBox.$3, res.faceBox.$4],
    box,
    reason: '${c.name}/$style',
  );
  expect(
    res.area,
    closeTo(e['area'] as double, 1e-12),
    reason: '${c.name}/$style',
  );
}

GlassesSize _size(String name) =>
    GlassesSize.values.firstWhere((s) => s.name == name);

BeardRegion _region(Map<String, dynamic> r) => BeardRegion(
  BeardRegionKind.values.firstWhere((k) => k.name == r['kind']),
  belowChin: (r['below_chin'] as num).toDouble(),
  moustache: r['moustache'] as bool? ?? false,
  chinSides: r['chin_sides'] as bool? ?? false,
);

void main() {
  final cases = loadCases();
  test('fixtures cover what they should', () {
    expect(cases.length, greaterThanOrEqualTo(15));
    expect(cases.where((c) => c.width > kMaskWorkSide), isNotEmpty);
    expect(cases.where((c) => c.json['clothes'] as bool), isNotEmpty);
    for (final c in cases) {
      expect(c.expected('hair'), isNotEmpty);
      expect(c.expected('beard'), isNotEmpty);
    }
  });

  for (final c in cases) {
    group(c.name, () {
      late HairAnalysis a;
      setUpAll(() => a = c.parse().toAnalysis());

      test('hair mask == hairmask.py', () {
        for (final e in c.expected('hair')) {
          final s = e['shape'] as Map;
          final shape = HairShape(
            length: HairLength.values.firstWhere((v) => v.name == s['length']),
            bangs: HairBangs.values.firstWhere((v) => v.name == s['bangs']),
            updo: s['updo'] as bool,
          );
          check(
            c,
            e,
            () => buildHairMask(
              a,
              shape,
              mode: e['mode'] as String? ?? kHairMaskMode,
            ),
          );
        }
      });

      test('beard mask == beardmask.py', () {
        final beard = c.json['has_beard'] as bool?;
        for (final e in c.expected('beard')) {
          check(
            c,
            e,
            () => buildBeardMask(
              a,
              _region((e['region'] as Map).cast()),
              shave: e['mode'] == 'shave',
              hasBeard: beard,
            ),
          );
        }
      });

      test(
        'glasses mask == glassesmask.py',
        () {
          final all = c.expected('glasses');
          for (final e in all) {
            final fit = e['fit'] as Map;
            check(
              c,
              e,
              () => buildGlassesMask(
                a,
                GlassesFit(size: _size(fit['size'] as String)),
                remove: e['remove'] as bool,
              ),
            );
          }
        },
        skip: c.expected('glasses').isEmpty
            ? 'no glasses fixtures: tgbot/glassesmask.py is not in this tree yet; '
                  'rerun tools/sync_fixtures.sh --gen after merging it'
            : false,
      );

      if (c.hasPhoto) {
        test('colour and has_beard off the photo', () {
          final photo = c.photo();
          expect(estimateHairColour(photo, a.hair), c.json['colour']);
          expect(detectBeard(photo, a), c.json['has_beard']);
        });
      }
    });
  }

  test('resize samples what Pillow samples', () {
    final doc =
        jsonDecode(File('$fixtures/masks/cases.json').readAsStringSync())
            as Map;
    final rows = doc['resizes'] as List;
    expect(rows, isNotEmpty);
    for (final r in rows.cast<Map>()) {
      final w = r['width'] as int, h = r['height'] as int;
      final pattern = BoolMask(w, h);
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          if ((x * 3 + y * 5) % 7 < 3) pattern.set(x, y);
        }
      }
      final down = resizeMask(
        pattern,
        r['small_width'] as int,
        r['small_height'] as int,
      );
      final wantDown = decodeMaskPng(
        File('$fixtures/masks/${r['down']}').readAsBytesSync(),
      );
      expect(iou(down, wantDown), 1.0, reason: '${r['down']}');
      final wantUp = decodeMaskPng(
        File('$fixtures/masks/${r['up']}').readAsBytesSync(),
      );
      expect(iou(resizeMask(down, w, h), wantUp), 1.0, reason: '${r['up']}');
    }
  });

  test('Python read a beard, smooth skin and noise in the fixtures', () {
    final byName = {for (final c in cases) c.name: c};
    expect(byName['man-bearded']!.json['has_beard'], isTrue);
    expect(byName['man-short']!.json['has_beard'], isFalse);
    expect(byName['noisy-face']!.json['has_beard'], isNull);
    expect(byName['noisy-face']!.hasPhoto, isTrue);
  });
}
