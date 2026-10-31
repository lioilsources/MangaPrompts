/// Beard styles (`Prompts/08-PLAN-vousy.md`). The mask extent comes from
/// [BeardRegion], the wording from `prompts/beard_prompt.dart`. The catalog
/// itself ([kBeards], `beard_catalog.dart`) holds only what passed the bench
/// gate; candidates are in `tgbot/tools/bench/candidates/beards.json`.
library;

import 'beard_catalog.dart';

export 'beard_catalog.dart' show kBeards;

enum BeardRegionKind { moustache, chin, jaw, full }

/// `beardmask.BeardRegion`.
class BeardRegion {
  const BeardRegion(
    this.kind, {
    this.belowChin = 0.0,
    this.moustache = false,
    this.chinSides = false,
  });

  final BeardRegionKind kind;

  /// How many face heights the beard hangs under the chin.
  final double belowChin;

  /// Chin or jaw plus the moustache strip (van dyke, anchor).
  final bool moustache;

  /// Moustache running down beside the mouth (horseshoe).
  final bool chinSides;
}

class Beard {
  const Beard({
    required this.id,
    required this.label,
    required this.cs,
    required this.section,
    required this.block,
    required this.region,
  });

  final String id;
  final String label;

  /// Czech name, from the bench candidates.
  final String cs;

  /// One of [kBeardSections].
  final String section;

  /// Prompt fragment; empty for [kCleanShavenId].
  final String block;
  final BeardRegion region;

  /// Bench output for this style on `m-short`.
  String get previewPath => 'packages/tsumiki_shared/assets/beard/$id.jpg';
}

const kBeardSections = [
  'Shave',
  'Stubble',
  'Short',
  'Full',
  'Goatee',
  'Moustache',
];

/// `beardprompt.CLEAN`.
const kCleanShavenId = 'clean-shaven';

Beard? beardById(String? id) {
  if (id == null) return null;
  for (final b in kBeards) {
    if (b.id == id) return b;
  }
  return null;
}

/// Styles of one section, in catalog order.
List<Beard> beardsIn(String section, [List<Beard> catalog = kBeards]) =>
    catalog.where((b) => b.section == section).toList(growable: false);
