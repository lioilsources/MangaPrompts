// Mirror of `tgbot/hairprompt.py`, pinned by `fixtures/prompts.json`.

import '../catalogs/hairstyles.dart';

enum HairPromptEngine { flux, sdxl, kontext }

const kHairNegative =
    'nude, naked, nsfw, hat, cap, helmet, headband, deformed hair, floating hair, extra face, '
    'second person, blurry, watermark, low quality';

const _lengthClauses = {
  HairLength.short:
      'short hair ending above the jaw with the neck clear of hair',
  HairLength.medium: 'hair ending between the chin and the shoulders',
  HairLength.long: 'long hair falling past the shoulders',
};
const _updoClause = 'all hair gathered up and away from the neck and shoulders';

/// Styles whose shape says "updo" but that keep hair down on purpose.
const kKeepsHairDown = {'half-up'};

String hairLengthClause(String styleId, HairShape shape) {
  if (shape.updo) return kKeepsHairDown.contains(styleId) ? '' : _updoClause;
  return _lengthClauses[shape.length] ?? '';
}

/// Positive prompt for [engine]. [colour] is the word read off the photo;
/// [newColour] replaces it. With [kKeepCutStyle] only the colour changes.
String hairPrompt(
  Hairstyle style,
  String? colour, {
  HairPromptEngine engine = HairPromptEngine.kontext,
  HairColour? newColour,
}) {
  final keepCut = style.id == kKeepCutId;
  final target = newColour?.phrase;
  final c = colour ?? 'natural';
  final clause = keepCut ? '' : hairLengthClause(style.id, style.shape);
  if (engine == HairPromptEngine.kontext) {
    final length = clause.isEmpty
        ? ''
        : '${clause[0].toUpperCase()}${clause.substring(1)}. ';
    final lead = keepCut
        ? "Change the person's hair colour to $target. Keep the haircut, length and hair texture."
        : "Change the person's hairstyle to a ${style.block}. $length"
              '${target != null ? 'Dye the hair $target.' : 'Keep the $c hair colour.'}';
    return '$lead Keep the face, facial features, expression, skin, clothes, lighting and '
        'background exactly the same.';
  }
  final hair = '${target ?? c} hair';
  if (keepCut) {
    return 'a photo of the same person with the same haircut as in the photo, $hair, '
        'natural hair texture, realistic strands, same clothes, same lighting and background, '
        'photorealistic';
  }
  final length = clause.isEmpty ? '' : '$clause, ';
  return 'a photo of the same person with a ${style.block}, $length$hair, natural hair texture, '
      'realistic strands, same clothes, same lighting and background, photorealistic';
}
