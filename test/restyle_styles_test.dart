import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki/config/restyle_styles.dart';

/// The restyle catalog is what the Mini App shows to a global audience and
/// what it sends to the model: ids stable, copy English, medium first.
void main() {
  test('style ids are unique and every style sits in a known group', () {
    final ids = kRestyleStyles.map((s) => s.id).toSet();
    expect(ids.length, kRestyleStyles.length);
    for (final s in kRestyleStyles) {
      expect(kRestyleGroups, contains(s.group), reason: s.id);
      expect(s.block.trim(), isNotEmpty, reason: s.id);
      expect(s.label.trim(), isNotEmpty, reason: s.id);
    }
  });

  test('every group has at least one style, in catalog order', () {
    for (final g in kRestyleGroups) {
      expect(restyleStylesIn(g), isNotEmpty, reason: g);
    }
    final flattened = [for (final g in kRestyleGroups) ...restyleStylesIn(g)];
    expect(flattened.length, kRestyleStyles.length);
  });

  test('labels are English (ASCII letters only, no diacritics)', () {
    final ascii = RegExp(r'^[A-Za-z0-9 \-&()]+$');
    for (final s in kRestyleStyles) {
      expect(ascii.hasMatch(s.label), isTrue, reason: '${s.id}: ${s.label}');
    }
    for (final m in RestyleMedium.values) {
      expect(ascii.hasMatch(m.label), isTrue);
    }
  });

  test('lookup by id', () {
    expect(restyleStyleById('ukiyoe')?.label, 'Ukiyo-e woodblock');
    expect(restyleStyleById('nope'), isNull);
    expect(restyleStyleById(null), isNull);
  });

  test('prompt leads with the medium and ends with the style block', () {
    final style = restyleStyleById('baroque')!;
    final photo = restylePrompt(style, RestyleMedium.photo);
    final drawn = restylePrompt(style, RestyleMedium.illustration);
    expect(photo, startsWith('a photorealistic photograph'));
    expect(drawn, startsWith('a painted illustration'));
    expect(photo, endsWith(style.block));
    expect(drawn, endsWith(style.block));
    // the medium is the only thing that differs between the two
    expect(photo.split(', ').last, drawn.split(', ').last);
  });

  test('negatives push away from the other medium', () {
    final photo = restyleNegative(RestyleMedium.photo);
    final drawn = restyleNegative(RestyleMedium.illustration);
    expect(photo, contains('painting'));
    expect(photo, isNot(contains('photograph')));
    expect(drawn, contains('photograph'));
    expect(drawn, isNot(contains('painting')));
    // both keep the model's quality negative
    expect(photo, contains('bad anatomy'));
    expect(drawn, contains('bad anatomy'));
  });

  test('wire values match what the backend routes on', () {
    expect(RestyleMedium.photo.wire, 'photo');
    expect(RestyleMedium.illustration.wire, 'illustration');
  });
}
