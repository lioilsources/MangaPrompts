/// Hairstyles offered by the Hairdresser card (portrait → same photo, new cut).
///
/// A hairstyle is a prompt block plus a [HairShape]. The app sends both; the
/// bot sizes the inpaint mask from the shape (where new hair may grow) and
/// writes the prompt itself (`tgbot/hairprompt.py`), because the engine it runs
/// decides whether that is a description or an instruction.
///
/// The catalog itself ([kHairstyles], `hairstyle_catalog.dart`) holds only
/// styles that passed the bench gate — see `docs/hair-matrix.md`.
library;

import 'hairstyle_catalog.dart';

export 'hairstyle_catalog.dart' show kHairstyles, kHairColours;

enum HairLength { keep, short, medium, long }

enum HairBangs { none, full, side, curtain, wispy }

class HairShape {
  const HairShape({
    required this.length,
    this.bangs = HairBangs.none,
    this.updo = false,
  });

  final HairLength length;
  final HairBangs bangs;
  final bool updo;

  /// Body of the `shape` field of `POST /api/hair`.
  Map<String, Object> toJson() => {
    'length': length.name,
    'bangs': bangs.name,
    'updo': updo,
  };
}

class Hairstyle {
  const Hairstyle({
    required this.id,
    required this.label,
    required this.group,
    required this.section,
    required this.block,
    required this.shape,
  });

  final String id;

  /// Chip text (English, the Mini App's language).
  final String label;

  /// [kHairGroupWomen] or [kHairGroupMen].
  final String group;

  /// Section inside the group, one of [kHairSections].
  final String section;

  /// Prompt fragment: the name plus what it looks like. Names alone are not
  /// enough — a bixie or a butterfly cut is younger than the training data.
  final String block;

  final HairShape shape;

  /// Bundled preview: the bench's own output for this style on the group's
  /// primary synthetic portrait (export_catalog.py --bench). Same face under
  /// every style, so the picker compares hair and nothing else.
  String get preview => 'assets/hair/$id.jpg';
}

const kHairGroupWomen = 'Women';
const kHairGroupMen = 'Men';
const kHairGroups = [kHairGroupWomen, kHairGroupMen];

/// Display order of sections; a group shows the ones it has.
const kHairSections = [
  'Cuts',
  'Bangs',
  'Texture',
  'Short',
  'Medium',
  'Long',
  'Braids',
  'Updos',
];

/// A hair colour the bot knows (`tgbot/haircolours.py` holds the prompt
/// phrase); the app sends only the id. [group] orders the chips.
class HairColour {
  const HairColour({
    required this.id,
    required this.label,
    required this.group,
    this.swatch,
  });

  final String id;
  final String label;
  final String group;

  /// ARGB of the colour the bench *measured* on the accepted cells — what the
  /// model paints, not the target range. Null while unmeasured.
  final int? swatch;
}

const kHairColourGroups = ['Blonde', 'Red', 'Brown', 'Black & grey', 'Fashion'];

/// Style id for "same haircut, new colour" (`haircolours.KEEP_CUT`).
const kKeepCutId = 'keep-cut';
const kKeepCutBlock = 'the same haircut as in the photo';

Hairstyle? hairstyleById(String? id) {
  if (id == null) return null;
  for (final s in kHairstyles) {
    if (s.id == id) return s;
  }
  return null;
}

/// Styles of one group and section, in catalog order.
List<Hairstyle> hairstylesIn(
  String group,
  String section, [
  List<Hairstyle> catalog = kHairstyles,
]) => catalog
    .where((s) => s.group == group && s.section == section)
    .toList(growable: false);
