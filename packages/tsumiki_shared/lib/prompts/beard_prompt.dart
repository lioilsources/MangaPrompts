// Mirror of `tgbot/beardprompt.py`, pinned by `fixtures/prompts.json`.

import '../catalogs/beards.dart';

const kBeardNegative =
    'fake beard, painted beard, patchy beard, deformed lips, extra face, second person, blurry, watermark';

const _keep =
    'Keep the face, eyes, nose, lips, expression, skin tone, hair, clothes, lighting and background exactly the same.';

/// Kontext instruction. [colour] is the hair colour off the photo (null =
/// "natural"); [grey] asks for salt-and-pepper instead.
String beardPrompt(Beard style, String? colour, {bool grey = false}) {
  if (style.id == kCleanShavenId) {
    return 'Shave off the beard and moustache completely so the man is clean-shaven with smooth bare skin. $_keep';
  }
  final shade = grey ? 'salt-and-pepper grey' : (colour ?? 'natural');
  return 'Give the man a ${style.block}, $shade, matching his hair, with realistic individual hairs and natural density. $_keep';
}
