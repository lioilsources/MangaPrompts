"""Prompts for the Hairdresser card, per engine.

Composed server-side, unlike Restyle: the engine is a deployment choice
(HAIR_ENGINE) and the engines disagree about what a prompt is. FLUX Fill and
SDXL inpaint want a description of the finished photo; FLUX Kontext is an
instruction model and wants "change X, keep Y". The app sends the hairstyle's
block and shape; the bench builds its cells with this same module.
"""

from __future__ import annotations

import haircolours

NEGATIVE = (
    "nude, naked, nsfw, hat, cap, helmet, headband, deformed hair, floating hair, extra face, "
    "second person, blurry, watermark, low quality"
)

# Said out loud because the mask alone does not stop a model from growing the
# old length back: in bench round 0 a pixie on long hair left strands on the
# shoulders, and a high ponytail kept hair hanging at both sides.
LENGTH_CLAUSES = {
    "short": "short hair ending above the jaw with the neck clear of hair",
    "medium": "hair ending between the chin and the shoulders",
    "long": "long hair falling past the shoulders",
    "updo": "all hair gathered up and away from the neck and shoulders",
}

# Styles whose shape says "updo" but that keep hair down on purpose.
KEEPS_HAIR_DOWN = {"half-up"}

ENGINES = ("flux", "sdxl", "kontext")


def length_clause(style_id: str, shape: dict) -> str:
    if shape.get("updo"):
        return "" if style_id in KEEPS_HAIR_DOWN else LENGTH_CLAUSES["updo"]
    return LENGTH_CLAUSES.get(shape.get("length", "keep"), "")


def prompt(
    block: str,
    style_id: str,
    shape: dict,
    colour: str | None,
    engine: str,
    new_colour: str | None = None,
) -> str:
    """Positive prompt for `engine`. `colour` is the word read off the photo;
    `new_colour` a haircolours id the user picked (None = keep theirs). With
    style `keep-cut` the cut stays and only the colour changes."""
    if engine not in ENGINES:
        raise ValueError(f"unknown hair engine '{engine}'")
    keep_cut = style_id == haircolours.KEEP_CUT
    target = haircolours.phrase(new_colour) if new_colour else None
    colour = colour or "natural"
    clause = "" if keep_cut else length_clause(style_id, shape)
    if engine == "kontext":
        length = f"{clause[:1].upper()}{clause[1:]}. " if clause else ""
        if keep_cut:
            lead = f"Change the person's hair colour to {target}. Keep the haircut, length and hair texture."
        else:
            lead = f"Change the person's hairstyle to a {block}. {length}" + (
                f"Dye the hair {target}." if target else f"Keep the {colour} hair colour."
            )
        return (
            f"{lead} Keep the face, facial features, expression, skin, clothes, lighting and "
            "background exactly the same."
        )
    length = f"{clause}, " if clause else ""
    hair = f"{target} hair" if target else f"{colour} hair"
    if keep_cut:
        return (
            f"a photo of the same person with the same haircut as in the photo, {hair}, "
            "natural hair texture, realistic strands, same clothes, same lighting and background, "
            "photorealistic"
        )
    return (
        f"a photo of the same person with a {block}, {length}{hair}, natural hair texture, "
        "realistic strands, same clothes, same lighting and background, photorealistic"
    )
