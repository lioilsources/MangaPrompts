/// Hairstyles offered by the Hairdresser card (portrait → same photo, new cut).
///
/// A hairstyle is a prompt block plus a [HairShape]. The shape never reaches
/// the model as text alone: the bot sizes the inpaint mask from it (where new
/// hair may grow) and this file turns it into a length clause, because in the
/// bench a mask alone did not stop a model from growing the old length back.
///
/// The catalog itself ([kHairstyles], `hairstyle_catalog.dart`) holds only
/// styles that passed the bench gate on both engines — see
/// `docs/hair-matrix.md`. `tgbot/tools/bench/catalog.py` mirrors
/// [hairPrompt] and [kHairNegative]; the tests on both sides pin the strings.
library;

import 'hairstyle_catalog.dart';

export 'hairstyle_catalog.dart' show kHairstyles;

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
  'Updos',
];

/// Token the bot replaces with the colour it reads off the photo.
const kHairColourToken = '__HAIRCOLOR__';

const kHairNegative =
    'hat, cap, helmet, headband, deformed hair, floating hair, '
    'extra face, second person, blurry, watermark, low quality';

/// Said out loud next to the block: without it a pixie on long hair left
/// strands on the shoulders and a ponytail kept hair hanging at the sides.
String hairLengthClause(Hairstyle style) {
  final shape = style.shape;
  if (shape.updo) {
    // half-up keeps half the hair down on purpose
    return style.id == 'half-up'
        ? ''
        : 'all hair gathered up and away from the neck and shoulders, ';
  }
  return switch (shape.length) {
    HairLength.short =>
      'short hair ending above the jaw with the neck clear of hair, ',
    HairLength.medium => 'hair ending between the chin and the shoulders, ',
    HairLength.long => 'long hair falling past the shoulders, ',
    HairLength.keep => '',
  };
}

/// Positive prompt for the bot, with [kHairColourToken] still in it.
String hairPrompt(Hairstyle style) =>
    'a photo of the same person with a ${style.block}, '
    '${hairLengthClause(style)}$kHairColourToken hair, '
    'natural hair texture, realistic strands, same clothes, '
    'same lighting and background, photorealistic';

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
