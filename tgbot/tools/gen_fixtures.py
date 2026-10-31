#!/usr/bin/env python3
"""Write the file fixtures that pin the Dart masks and prompts to the Python.

    tools/gen_fixtures.py          # rewrites tests/fixtures/{masks,prompts.json}
    tools/gen_fixtures.py --out D  # writes elsewhere

`tests/fixtures/masks/<case>/`:
  parse.png            indexed: the 19 classes of the face parser (FACE_CLASSES)
  clothes.png          indexed: the ATR clothes parser (CLOTHES_CLASSES), optional
  photo.png            synthetic RGB portrait, optional (colour, has_beard)
  expected-<style>.png the mask Python builds for that style (white = repaint)
`tests/fixtures/masks/cases.json` says what each file is, plus refusals.

Portraits are drawn class by class, nothing here is a person. A Dart test reads
the same parse.png through `FaceParse`, so a formula wrong on both sides cannot
hide the way it could in two copies of a synthetic() function.

Glasses come in when `glassesmask.py`/`glassesprompt.py` exist; until then the
fixtures have none and the Dart tests say so.
"""

from __future__ import annotations

import argparse
import dataclasses
import json
import shutil
import sys
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
TGBOT = HERE.parent
sys.path.insert(0, str(TGBOT))
sys.path.insert(0, str(HERE / "bench"))

import beardmask as bm  # noqa: E402
import beardprompt  # noqa: E402
import haircolours  # noqa: E402
import hairmask as hm  # noqa: E402
import hairprompt  # noqa: E402

try:
    import glassesmask as gm
    import glassesprompt
except ImportError:
    gm = glassesprompt = None

FIXTURES = TGBOT / "tests" / "fixtures"
CANDIDATES = HERE / "bench" / "candidates"

# Class ids of the two parsers. They have to match hair_analyse.api.json: hair is
# Hair of both parsers, hat comes from the clothes parser (the graph takes it
# from ClothesSegment, not from class 14), face and features as its nodes 5, 11.
FACE_CLASSES = (
    "background", "skin", "nose", "eyeglasses", "l_eye", "r_eye", "l_brow", "r_brow", "l_ear",
    "r_ear", "mouth", "u_lip", "l_lip", "hair", "hat", "earring", "necklace", "neck", "cloth",
)
CLOTHES_CLASSES = (
    "background", "hat", "hair", "sunglasses", "upper_clothes", "skirt", "pants", "dress", "belt",
    "left_shoe", "right_shoe", "face", "left_leg", "right_leg", "left_arm", "right_arm", "bag", "scarf",
)
F = {name: i for i, name in enumerate(FACE_CLASSES)}
C = {name: i for i, name in enumerate(CLOTHES_CLASSES)}
FACE_IDS = [F[n] for n in ("skin", "nose", "l_eye", "r_eye", "l_brow", "r_brow", "mouth", "u_lip", "l_lip", "eyeglasses")]
FEATURE_IDS = [F[n] for n in ("l_eye", "r_eye", "l_brow", "r_brow", "eyeglasses")]
LIP_IDS = [F[n] for n in ("mouth", "u_lip", "l_lip")]
EAR_IDS = [F["l_ear"], F["r_ear"]]


def analysis_from_parse(face: np.ndarray, clothes: np.ndarray | None = None) -> hm.HairAnalysis:
    """What hair_analyse.api.json saves, from the raw class maps. The Dart side
    is `FaceParse.toAnalysis`."""
    hair = face == F["hair"]
    hat = np.zeros_like(hair)
    if clothes is not None:
        hair = hair | (clothes == C["hair"])
        hat = clothes == C["hat"]
    masks = {
        "hair": hair,
        "face": np.isin(face, FACE_IDS),
        "hat": hat,
        "features": np.isin(face, FEATURE_IDS),
        "lips": np.isin(face, LIP_IDS),
        "nose": face == F["nose"],
        "ears": np.isin(face, EAR_IDS),
        # What the glasses card reads; the fields exist once its module does.
        "glasses": face == F["eyeglasses"],
        "mouth": np.isin(face, LIP_IDS),
    }
    known = {f.name for f in dataclasses.fields(hm.HairAnalysis)}
    return hm.HairAnalysis(**{k: v for k, v in masks.items() if k in known})


# ── Drawing ─────────────────────────────────────────────────────────────────


def _ellipse(w, h, cx, cy, rx, ry):
    ys, xs = np.mgrid[0:h, 0:w]
    return ((xs - cx) / rx) ** 2 + ((ys - cy) / ry) ** 2 <= 1.0


def _box(w, h, x0, y0, x1, y1):
    ys, xs = np.mgrid[0:h, 0:w]
    return (xs >= x0) & (xs <= x1) & (ys >= y0) & (ys <= y1)


def draw(w, h, s=1.0, cx=None, cy=None, hair="short", ears=True, nose=True, lips=True, eyes=True,
         glasses=False, face=True, decoys=False, clothes=None):
    """Face parse (and the clothes parse, when `clothes` is one of "plain",
    "long", "hat") of a head-and-shoulders portrait, 2×radii 140×180 at s=1."""
    cx = w / 2 if cx is None else cx
    cy = h * 0.47 if cy is None else cy
    E = lambda dx, dy, rx, ry: _ellipse(w, h, cx + dx * s, cy + dy * s, rx * s, ry * s)  # noqa: E731
    B = lambda dx0, dy0, dx1, dy1: _box(w, h, cx + dx0 * s, cy + dy0 * s, cx + dx1 * s, cy + dy1 * s)  # noqa: E731
    m = np.zeros((h, w), np.uint8)
    m[E(0, 300, 210, 170)] = F["cloth"]
    m[B(-38, 60, 38, 170)] = F["neck"]
    if hair == "short":
        m[E(0, -40, 92, 108)] = F["hair"]
    elif hair == "long":
        m[E(0, -40, 100, 110)] = F["hair"]
        m[B(-120, -40, -60, 150)] = F["hair"]
        m[B(60, -40, 120, 150)] = F["hair"]
    if decoys:
        # Classes that must not leak anywhere: a hat FaceSegment "saw", jewellery.
        m[E(0, -135, 60, 18)] = F["hat"]
        m[E(0, 165, 30, 5)] = F["necklace"]
    if face:
        if ears:
            m[E(-74, -5, 12, 26)] = F["l_ear"]
            m[E(74, -5, 12, 26)] = F["r_ear"]
            if decoys:
                m[E(-74, 24, 4, 5)] = F["earring"]
                m[E(74, 24, 4, 5)] = F["earring"]
        m[E(0, 0, 70, 90)] = F["skin"]
        if eyes:
            m[E(-29, -28, 13, 7)] = F["l_eye"]
            m[E(29, -28, 13, 7)] = F["r_eye"]
            m[E(-29, -46, 18, 4)] = F["l_brow"]
            m[E(29, -46, 18, 4)] = F["r_brow"]
        if glasses:
            frame = E(-29, -28, 25, 18) | E(29, -28, 25, 18)
            m[frame & ~(E(-29, -28, 19, 12) | E(29, -28, 19, 12))] = F["eyeglasses"]
        if nose:
            m[E(0, 5, 11, 22)] = F["nose"]
        if lips:
            m[E(0, 45, 28, 4)] = F["mouth"]
            m[E(0, 40, 28, 5)] = F["u_lip"]
            m[E(0, 51, 26, 6)] = F["l_lip"]
    if clothes is None:
        return m, None
    c = np.zeros((h, w), np.uint8)
    c[E(0, 300, 210, 170)] = C["upper_clothes"]
    if face:
        c[E(0, 0, 70, 90)] = C["face"]
    if clothes == "long":
        # FaceSegment stops at the chest; the strands below exist only here.
        c[B(-120, 100, -60, 300)] = C["hair"]
        c[B(60, 100, 120, 300)] = C["hair"]
    if clothes == "hat":
        c[E(0, -105, 95, 42)] = C["hat"]
        c[E(-29, -28, 16, 9)] = C["sunglasses"]  # not a class any mask reads
    return m, c


PHOTO_COLOURS = {
    "background": (196, 200, 204), "skin": (212, 170, 142), "nose": (206, 162, 136),
    "eyeglasses": (30, 30, 34), "l_eye": (60, 50, 44), "r_eye": (60, 50, 44), "l_brow": (70, 50, 38),
    "r_brow": (70, 50, 38), "l_ear": (206, 162, 136), "r_ear": (206, 162, 136), "mouth": (120, 50, 50),
    "u_lip": (170, 90, 88), "l_lip": (176, 96, 92), "hair": (85, 58, 38), "hat": (40, 60, 90),
    "earring": (210, 180, 90), "necklace": (210, 180, 90), "neck": (200, 158, 132), "cloth": (60, 70, 90),
}


def photo(face_map, lower="smooth", hair_rgb=None):
    """RGB portrait for a class map. `lower` is the skin below the nose:
    "smooth", "beard" (dark and textured), or "noise" (the whole face)."""
    h, w = face_map.shape
    rgb = np.zeros((h, w, 3), np.uint8)
    for name, colour in PHOTO_COLOURS.items():
        rgb[face_map == F[name]] = colour
    if hair_rgb:
        rgb[face_map == F["hair"]] = hair_rgb
    ys, xs = np.mgrid[0:h, 0:w]
    skin = face_map == F["skin"]
    if lower == "beard" and (face_map == F["nose"]).any():
        top = int(np.nonzero(face_map == F["nose"])[0].max())
        region = skin & (ys > top)
        stripes = ((xs * 7 + ys * 13) % 11).astype(np.int16) - 5
        rgb[region] = np.clip(np.array([70, 52, 40]) + stripes[region][:, None] * 3, 0, 255)
    elif lower == "noise":
        chaos = (xs * xs * 3 + ys * ys * 5 + xs * ys * 7) % 211
        rgb[skin] = np.stack([chaos[skin] + 30] * 3, axis=1)
    return rgb


# ── What gets built ─────────────────────────────────────────────────────────

HAIR_SHAPES = [
    ("keep", "none", False, None), ("short", "none", False, None), ("medium", "none", False, None),
    ("long", "none", False, None), ("short", "full", False, None), ("medium", "side", False, None),
    ("keep", "curtain", True, None), ("keep", "none", True, None), ("long", "none", False, "hair"),
]
BEARD_SAMPLE = (
    "clean-shaven", "light-stubble", "short-boxed", "full-beard", "long-beard", "goatee", "circle-beard",
    "anchor", "chin-strap", "soul-patch", "mutton-chops", "chevron", "horseshoe",
)

CASES = {
    "man-short": dict(w=512, h=640, photo="smooth"),
    "man-bearded": dict(w=512, h=640, photo="beard"),
    "man-glasses": dict(w=512, h=640, glasses=True, photo="smooth"),
    "woman-long": dict(w=512, h=640, s=0.8, cy=240, hair="long", clothes="long", photo="smooth", hair_rgb=(190, 155, 100)),
    "hat-and-decoys": dict(w=512, h=640, s=0.9, cy=300, decoys=True, clothes="hat"),
    "no-ears-no-nose": dict(w=512, h=640, ears=False, nose=False),
    "bald": dict(w=512, h=640, hair="none", photo="smooth"),
    "noisy-face": dict(w=320, h=400, s=0.62, photo="noise"),
    "mouth-covered": dict(w=512, h=640, lips=False),
    "eyes-covered": dict(w=512, h=640, eyes=False),
    "no-face": dict(w=512, h=640, face=False),
    "tiny-face": dict(w=1024, h=1024, s=0.3),
    # Over WORK_SIDE, scales that do not divide evenly: nearest-neighbour
    # rounding is what these are for.
    "large-landscape": dict(w=1601, h=1283, s=2.3, hair="long", clothes="long"),
    "large-portrait": dict(w=1000, h=1537, s=2.1),
    "large-ratio": dict(w=1237, h=1711, s=2.7, glasses=True, decoys=True, clothes="plain"),
}


def _png(path: Path, im: Image.Image) -> None:
    im.save(path, "PNG", optimize=True)


def _indexed(path: Path, m: np.ndarray, n: int) -> None:
    im = Image.fromarray(m, "P")
    palette = []
    for i in range(n):
        palette += [(i * 67) % 256, (i * 131) % 256, (i * 199) % 256]
    im.putpalette(palette)
    _png(path, im)


def _attempt(out: Path, style: str, build) -> dict:
    """Run a mask builder; a refusal is an expected outcome too."""
    try:
        res = build()
    except hm.HairMaskError as e:
        return {"file": None, "error": e.code}
    name = f"expected-{style}.png"
    _png(out / name, Image.fromarray(np.where(res.mask, 255, 0).astype(np.uint8), "L"))
    return {"file": name, "error": None, "area": res.area, "face_box": list(res.face_box)}


def _beard_styles() -> dict:
    cands = json.loads((CANDIDATES / "beards.json").read_text())
    return {c["id"]: c for c in cands}


def _case(name: str, spec: dict, root: Path) -> dict:
    spec = dict(spec)
    lower, hair_rgb = spec.pop("photo", None), spec.pop("hair_rgb", None)
    w, h = spec.pop("w"), spec.pop("h")
    face_map, clothes_map = draw(w, h, **spec)
    out = root / name
    out.mkdir(parents=True)
    _indexed(out / "parse.png", face_map, len(FACE_CLASSES))
    if clothes_map is not None:
        _indexed(out / "clothes.png", clothes_map, len(CLOTHES_CLASSES))
    a = analysis_from_parse(face_map, clothes_map)

    colour = has_beard = None
    if lower:
        rgb = photo(face_map, lower, hair_rgb)
        _png(out / "photo.png", Image.fromarray(rgb, "RGB"))
        colour = hm.estimate_colour(rgb, a.hair)
        has_beard = bm.detect_beard(rgb, a)

    expected = []
    for length, bangs, updo, mode in HAIR_SHAPES:
        shape = hm.HairShape(length, bangs, updo)
        style = f"hair-{shape.key}" + (f"-{mode}" if mode else "")
        expected.append({
            "kind": "hair", "style": style,
            "shape": {"length": length, "bangs": bangs, "updo": updo}, "mode": mode,
            **_attempt(out, style, lambda: hm.build_mask(a, shape, mode)),
        })
    beards = _beard_styles()
    for sid in BEARD_SAMPLE:
        c = beards[sid]
        region = bm.BeardRegion(**c["region"])
        mode = "shave" if sid == beardprompt.CLEAN else None
        expected.append({
            "kind": "beard", "style": f"beard-{sid}", "region": c["region"], "mode": mode,
            **_attempt(out, f"beard-{sid}", lambda: bm.build_mask(a, region, mode, has_beard)),
        })
    if gm is not None:
        for size in gm.SIZES:
            expected.append({
                "kind": "glasses", "style": f"glasses-{size}", "fit": {"size": size, "tinted": False},
                "remove": False,
                **_attempt(out, f"glasses-{size}", lambda: gm.build_mask(a, gm.GlassesFit(size))),
            })
        expected.append({
            "kind": "glasses", "style": "glasses-remove", "fit": {"size": "regular", "tinted": False},
            "remove": True,
            **_attempt(out, "glasses-remove", lambda: gm.build_mask(a, gm.GlassesFit(), remove=True)),
        })
    return {
        "case": name, "width": w, "height": h, "clothes": clothes_map is not None,
        "photo": lower is not None, "colour": colour, "has_beard": has_beard, "expected": expected,
    }


def _prompts() -> dict:
    hair = []
    samples = [
        ("pixie cut, very short", "pixie", {"length": "short", "bangs": "none", "updo": False}),
        ("long waves", "long-waves", {"length": "long", "bangs": "none", "updo": False}),
        ("curtain bangs", "curtain", {"length": "keep", "bangs": "curtain", "updo": False}),
        ("high ponytail", "ponytail", {"length": "keep", "bangs": "none", "updo": True}),
        ("half-up half-down hairstyle", "half-up", {"length": "keep", "bangs": "none", "updo": True}),
        (haircolours.KEEP_CUT_BLOCK, haircolours.KEEP_CUT, {"length": "keep", "bangs": "none", "updo": False}),
    ]
    for engine in hairprompt.ENGINES:
        for block, sid, shape in samples:
            for colour, new in (("brown", None), (None, None), ("brown", "copper-red"), (None, "honey-balayage")):
                if sid == haircolours.KEEP_CUT and new is None:
                    continue
                hair.append({
                    "block": block, "style_id": sid, "shape": shape, "colour": colour, "engine": engine,
                    "new_colour": new, "new_colour_phrase": haircolours.phrase(new) if new else None,
                    "expected": hairprompt.prompt(block, sid, shape, colour, engine, new),
                })
    beard = []
    for c in _beard_styles().values():
        for colour, grey in (("dark brown", False), (None, False), ("black", True)):
            beard.append({
                "block": c["block"], "style_id": c["id"], "colour": colour, "grey": grey,
                "expected": beardprompt.prompt(c["block"], c["id"], colour, grey),
            })

    import catalog

    cat = catalog.restyle_catalog()
    restyle = []
    for sid in ("ukiyoe", "vangogh-arles"):
        for medium in ("photo", "illustration"):
            positive, negative = catalog.restyle_prompt(sid, medium)
            restyle.append({"style_id": sid, "medium": medium, "expected": positive, "negative": negative})
    assert cat["heads"]

    out = {
        "hair": hair, "beard": beard, "restyle": restyle,
        "colour_names": [
            {"lab": [L, a, b], "name": hm.colour_name((L, a, b))}
            for L in (15.0, 21.0, 30.0, 40.0, 60.0, 80.0)
            for a, b in ((0.0, 0.0), (5.0, 15.0), (25.0, 12.0), (-20.0, -5.0), (10.0, -40.0), (40.0, -30.0))
        ],
        "feather": [
            {"width": w, "height": h, "expand": hm.feather_px(w, h)[0], "blur": hm.feather_px(w, h)[1]}
            for w, h in ((832, 1216), (1450, 2576), (2576, 1450), (10, 10))
        ],
        "hair_negative": hairprompt.NEGATIVE,
        "beard_negative": beardprompt.NEGATIVE,
    }
    if glassesprompt is not None:
        out["glasses"] = [
            {"block": b, "finish": f, "style_id": sid, "tinted": t,
             "expected": glassesprompt.prompt(b, f, sid, t)}
            for b, f, sid, t in (
                ("round eyeglasses with thin circular rims", "tortoiseshell", "round", False),
                ("round eyeglasses with thin circular rims", None, "round", False),
                ("aviator sunglasses with dark teardrop lenses", "gold with green lenses", "aviator-sun", True),
                ("", None, glassesprompt.NO_GLASSES, False),
            )
        ]
    return out


# Sizes hm._resize is pinned at: down to the working size and back, where
# rounding of the sampling position decides whole rows. A fine pattern shows
# every misplaced sample, which a face mask does only by luck.
RESIZES = ((1000, 1537, 500, 768), (1601, 1283, 768, 615), (1237, 1711, 555, 768))


def resize_pattern(w: int, h: int) -> np.ndarray:
    ys, xs = np.mgrid[0:h, 0:w]
    return (xs * 3 + ys * 5) % 7 < 3


def _resizes(root: Path) -> list[dict]:
    out = []
    for w, h, sw, sh in RESIZES:
        down = hm._resize(resize_pattern(w, h), (sw, sh))
        up = hm._resize(down, (w, h))
        name = f"resize-{w}x{h}-{sw}x{sh}"
        _png(root / f"{name}-down.png", Image.fromarray(np.where(down, 255, 0).astype(np.uint8), "L"))
        _png(root / f"{name}-up.png", Image.fromarray(np.where(up, 255, 0).astype(np.uint8), "L"))
        out.append({"width": w, "height": h, "small_width": sw, "small_height": sh,
                    "down": f"{name}-down.png", "up": f"{name}-up.png"})
    return out


def generate(root: Path) -> None:
    masks = root / "masks"
    if masks.exists():
        shutil.rmtree(masks)
    masks.mkdir(parents=True)
    cases = [_case(name, spec, masks) for name, spec in CASES.items()]
    doc = {"cases": cases, "resizes": _resizes(masks)}
    (masks / "cases.json").write_text(json.dumps(doc, indent=1) + "\n")
    (root / "prompts.json").write_text(json.dumps(_prompts(), indent=1, ensure_ascii=False) + "\n")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--out", type=Path, default=FIXTURES)
    args = ap.parse_args()
    generate(args.out)
    n = sum(1 for _ in (args.out / "masks").rglob("expected-*.png"))
    print(f"{args.out}: {len(CASES)} cases, {n} expected masks"
          + ("" if gm else " (no glasses: glassesmask.py not here yet)"))


if __name__ == "__main__":
    main()
