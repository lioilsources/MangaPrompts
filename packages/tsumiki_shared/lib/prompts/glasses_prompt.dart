// Mirror of `tgbot/glassesprompt.py`, pinned by `fixtures/prompts.json` once
// that module is in the tree.

import '../catalogs/glasses.dart';

const kGlassesNegative =
    'floating glasses, double frames, deformed glasses, extra face, second person, blurry, watermark';

const _keep =
    'Keep the face, eyes, expression, skin, hair, clothes, lighting and background exactly the same.';

/// Kontext instruction for [style] in one of its finishes (null = the block
/// alone). `style.fit.tinted` adds the dark-lens sentence: without it Kontext
/// paints clear glass.
String glassesPrompt(Glasses style, String? finish) {
  if (style.id == kNoGlassesId) {
    return "Remove the person's glasses completely, showing the bare face and eyes underneath. $_keep";
  }
  final frames = finish != null ? '$finish ${style.block}' : style.block;
  final lead =
      "Put $frames on the person's face. The glasses fit naturally on the nose and ears";
  if (style.fit.tinted) {
    return '$lead. The lenses are dark and the eyes are not visible through them. $_keep';
  }
  return '$lead, with realistic lens reflections and soft shadows on the skin. $_keep';
}
