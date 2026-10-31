/// Glasses (`06-PLAN-bryle.md` §4). A style is a shape ([Glasses.block]) plus
/// finishes; the bench gate decides what reaches [kGlasses]
/// (`glasses_catalog.dart`), candidates are in `candidates/glasses.json`.
library;

import 'glasses_catalog.dart';

export 'glasses_catalog.dart' show kGlasses;

enum GlassesSize { small, regular, oversized }

/// `glassesmask.GlassesFit`.
class GlassesFit {
  const GlassesFit({this.size = GlassesSize.regular, this.tinted = false});

  /// How far below the eyes the frame reaches.
  final GlassesSize size;

  /// Same mask; the prompt says the lenses are dark.
  final bool tinted;

  Map<String, Object> toJson() => {'size': size.name, 'tinted': tinted};
}

class Glasses {
  const Glasses({
    required this.id,
    required this.label,
    required this.cs,
    required this.group,
    required this.section,
    required this.block,
    required this.finishes,
    required this.fit,
  });

  final String id;
  final String label;

  /// Czech name, from the bench candidates.
  final String cs;

  /// One of [kGlassesGroups].
  final String group;

  /// One of [kGlassesSections].
  final String section;

  /// Prompt fragment: shape and how it sits. Empty for [kNoGlassesId].
  final String block;

  /// Materials and colours, what keeps the photos of a set apart.
  final List<String> finishes;
  final GlassesFit fit;

  String get preview => 'packages/tsumiki_shared/assets/glasses/$id.jpg';
}

const kGlassesGroups = ['Eyeglasses', 'Sunglasses'];
const kGlassesSections = [
  'Round',
  'Rectangular',
  'Cat-eye',
  'Browline',
  'Aviator',
  'Oversized',
  'Geometric',
  'Rimless',
  'Sport',
  'Remove',
];

/// `glassesprompt.NO_GLASSES`.
const kNoGlassesId = 'no-glasses';

Glasses? glassesById(String? id) {
  if (id == null) return null;
  for (final g in kGlasses) {
    if (g.id == id) return g;
  }
  return null;
}
