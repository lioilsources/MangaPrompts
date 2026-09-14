"""Hair colours for the Hairdresser card.

`phrase` goes into the prompt; `lab` is what the bench accepts as that colour
on the output's lit strands (see hairmask.hair_lab) — per key a (min, max)
range, None = unbounded, plus the derived `chroma`, `hue` (degrees, a range
with lo > hi wraps through 0 — pink sits either side of it) and `spread`
(balayage).
The ranges are a first cut to sort the bench sheet, not a proof; the eye
decides what reaches the catalog (docs/hair-matrix.md).
"""

from __future__ import annotations

import math

KEEP_CUT = "keep-cut"  # style id for "same haircut, new colour"
KEEP_CUT_BLOCK = "the same haircut as in the photo"

COLOURS: dict[str, dict] = {
    # blondes
    "platinum-blonde": {"label": "Platinum blonde", "cs": "platinová blond", "group": "Blonde",
                        "phrase": "icy platinum blonde", "lab": {"L": (70, None), "chroma": (None, 22)}},
    "ash-blonde": {"label": "Ash blonde", "cs": "popelavá blond", "group": "Blonde",
                   "phrase": "cool ash blonde", "lab": {"L": (55, None), "b": (None, 18), "chroma": (None, 20)}},
    "honey-blonde": {"label": "Honey blonde", "cs": "medová blond", "group": "Blonde",
                     "phrase": "warm honey blonde", "lab": {"L": (50, 80), "b": (18, None)}},
    "strawberry-blonde": {"label": "Strawberry blonde", "cs": "jahodová blond", "group": "Blonde",
                          "phrase": "strawberry blonde", "lab": {"L": (45, None), "a": (10, None), "b": (12, None)}},
    # reds
    "copper-red": {"label": "Copper red", "cs": "měděná zrzavá", "group": "Red",
                   "phrase": "vibrant copper red, natural redhead", "lab": {"L": (22, 65), "a": (18, None), "b": (15, None)}},
    # Brighter and more orange than copper: the "fox" is the hue, not the depth.
    "fox-red": {"label": "Fox red", "cs": "liščí zrzavá", "group": "Red",
                "phrase": "bright fox red, vivid orange ginger",
                "lab": {"L": (30, None), "chroma": (40, None), "hue": (40, 70)}},
    "auburn": {"label": "Auburn", "cs": "kaštanově zrzavá", "group": "Red",
               "phrase": "deep auburn", "lab": {"L": (15, 42), "a": (12, None)}},
    "burgundy": {"label": "Burgundy", "cs": "vínová", "group": "Red",
                 "phrase": "burgundy wine red", "lab": {"L": (None, 42), "a": (12, None), "red_over_yellow": True}},
    # browns
    "chestnut-brown": {"label": "Chestnut brown", "cs": "kaštanová hnědá", "group": "Brown",
                       "phrase": "glossy chestnut brown", "lab": {"L": (24, 46), "a": (6, 20), "b": (8, None)}},
    "chocolate-brown": {"label": "Chocolate brown", "cs": "čokoládová hnědá", "group": "Brown",
                        "phrase": "rich chocolate brown", "lab": {"L": (14, 33), "a": (3, None)}},
    "ash-brown": {"label": "Ash brown", "cs": "popelavě hnědá", "group": "Brown",
                  "phrase": "cool ash brown", "lab": {"L": (24, 50), "chroma": (None, 13)}},
    "honey-balayage": {"label": "Honey balayage", "cs": "hnědá s medovým balayage", "group": "Brown",
                       "phrase": "brown hair with soft honey blonde balayage highlights toward the ends",
                       "lab": {"spread": (25, None), "b": (10, None)}},
    # blacks & greys
    "jet-black": {"label": "Jet black", "cs": "uhlově černá", "group": "Black & grey",
                  "phrase": "glossy jet black", "lab": {"L": (None, 18), "chroma": (None, 9)}},
    "blue-black": {"label": "Blue black", "cs": "modročerná", "group": "Black & grey",
                   "phrase": "blue-black with a cool blue sheen", "lab": {"L": (None, 24), "b": (None, 2)}},
    "silver-grey": {"label": "Silver grey", "cs": "stříbrně šedá", "group": "Black & grey",
                    "phrase": "silver grey", "lab": {"L": (48, None), "chroma": (None, 9)}},
    # fashion
    "pastel-pink": {"label": "Pastel pink", "cs": "pastelově růžová", "group": "Fashion",
                    "phrase": "pastel pink", "lab": {"L": (50, None), "a": (12, None), "red_over_yellow": True}},
    "hot-pink": {"label": "Hot pink", "cs": "sytě růžová", "group": "Fashion",
                 "phrase": "vivid hot pink", "lab": {"L": (40, None), "chroma": (35, None), "hue": (335, 25)}},
    "lavender": {"label": "Lavender", "cs": "levandulová", "group": "Fashion",
                 "phrase": "pastel lavender purple", "lab": {"L": (45, None), "a": (4, None), "b": (None, -4)}},
    "violet": {"label": "Violet", "cs": "fialová", "group": "Fashion",
               "phrase": "vivid violet purple", "lab": {"L": (20, None), "chroma": (30, None), "hue": (290, 335)}},
    "pastel-blue": {"label": "Pastel blue", "cs": "pastelově modrá", "group": "Fashion",
                    "phrase": "pastel baby blue", "lab": {"L": (55, None), "chroma": (10, None), "hue": (220, 300)}},
    "electric-blue": {"label": "Electric blue", "cs": "elektricky modrá", "group": "Fashion",
                      "phrase": "vivid electric blue", "lab": {"L": (25, None), "chroma": (30, None), "hue": (245, 300)}},
    "teal": {"label": "Mermaid teal", "cs": "mořsky tyrkysová", "group": "Fashion",
             "phrase": "vivid mermaid teal, blue-green", "lab": {"L": (25, None), "chroma": (15, None), "hue": (160, 245)}},
}


def phrase(colour_id: str) -> str:
    return COLOURS[colour_id]["phrase"]


def matches(colour_id: str, lab: dict | None) -> bool | None:
    """Whether measured lit-strand Lab (hairmask.hair_lab) reads as the colour."""
    if lab is None:
        return None
    spec = COLOURS[colour_id]["lab"]
    values = {**lab, "chroma": math.hypot(lab["a"], lab["b"]), "hue": hue(lab["a"], lab["b"])}
    for key, rng in spec.items():
        if key == "red_over_yellow":
            if not values["a"] >= values["b"]:
                return False
            continue
        lo, hi = rng
        v = values[key]
        if key == "hue" and lo > hi:
            if hi < v < lo:
                return False
            continue
        if (lo is not None and v < lo) or (hi is not None and v > hi):
            return False
    return True


def hue(a: float, b: float) -> float:
    """CIELAB hue angle in degrees, 0–360: natural hair sits at 30–90, pink
    around 0, purple 300–335, blue 250–300, teal 180–240."""
    return math.degrees(math.atan2(b, a)) % 360
