"""Prompts for the beard step (FLUX Kontext, "do X, keep Y").

The colour is the hair colour read off the photo: a beard of another colour is
the exception, and salt-and-pepper the one alternative people ask for. The
Dart mirror is `tsumiki_shared/lib/prompts/beard_prompt.dart`, pinned by
`tests/fixtures/prompts.json`.
"""

from __future__ import annotations

CLEAN = "clean-shaven"

# cfg 1 ignores it; kept so the bench records what would be sent.
NEGATIVE = "fake beard, painted beard, patchy beard, deformed lips, extra face, second person, blurry, watermark"

KEEP = "Keep the face, eyes, nose, lips, expression, skin tone, hair, clothes, lighting and background exactly the same."


def prompt(block: str, style_id: str, colour: str | None, grey: bool = False) -> str:
    if style_id == CLEAN:
        return f"Shave off the beard and moustache completely so the man is clean-shaven with smooth bare skin. {KEEP}"
    shade = "salt-and-pepper grey" if grey else f"{colour or 'natural'}"
    return f"Give the man a {block}, {shade}, matching his hair, with realistic individual hairs and natural density. {KEEP}"
