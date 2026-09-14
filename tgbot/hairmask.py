"""Inpaint mask for the Hairdresser card, from face-parsing masks.

`hair_analyse.api.json` runs face parsing on the portrait and saves four
binary masks (hair, face, hat, eyes+brows). This module turns them into the
one mask the inpaint workflow repaints (white = repaint):

1. the old hair and any hat, dilated so no stray strands survive;
2. a forehead band when the new style has a fringe;
3. an *envelope* where the new hair is allowed to grow — a pixie needs no
   room below the chin, long layers need a lot — because a mask made only of
   the old hair cannot hold a longer cut;
4. minus the face, so the pixels that carry identity are never touched.

Pure numpy + Pillow, no ComfyUI: the numbers below are what the bench
(`tools/bench`) calibrates, and they have to be testable without a GPU.
Ol1nLLM keeps a Dart mirror in `lib/models/hair_mask.dart` — change both
together, the shared fixtures in the tests keep them honest.
"""

from __future__ import annotations

import io
import math
from dataclasses import dataclass, field

import numpy as np
from PIL import Image, ImageOps

LENGTHS = ("keep", "short", "medium", "long")
BANGS = ("none", "full", "side", "curtain", "wispy")

# ── Tunables (bench round 3 sweeps these; units are face-box sizes) ─────────
# How far the old hair is grown before it is repainted.
DILATE_FH = 0.06
# Forehead band for a fringe, measured down from the top of the face box, and
# how far the eyes and brows are kept clear of it. Bench round 0: at 0.33 with a
# 2 px guard the fringe ate the top of the brows on a head-and-shoulders shot
# (brows sat at 0.34 face heights).
BANG_BAND_FH = 0.28
FEATURE_GUARD_FH = 0.04
# Envelope per length: (sideways past the face in face widths, above the face
# top in face heights, below the chin in face heights). None = no envelope,
# the new style lives where the old hair was. Round 0 started from twice these
# and a medium cut repainted 85 % of a portrait — clothes and backdrop included.
ENVELOPES: dict[str, tuple[float, float, float] | None] = {
    "keep": None,
    "short": (0.35, 0.35, 0.0),
    "medium": (0.5, 0.35, 0.7),
    "long": (0.6, 0.35, 1.8),
}
# Shape of the repaint area. "hair": exactly the union above. "blob": its
# bounding rounded rectangle (still minus the face). FLUX Fill paints the mask's
# *shape*: in bench round 0b a pixie masked as the old long-hair silhouette
# came back as long hair, and SDXL left old strands on the shoulders; with the
# rectangle both cut to length (bench round 0c). Cost: clothes and backdrop
# inside the rectangle are repainted too.
MASK_MODE = "blob"
# Room above the head for a bun / ponytail, and how wide it may be.
UPDO_ABOVE_FH = 0.8
UPDO_SIDE_FW = 0.3
CORNER_FW = 0.3
# Refusals: a face smaller than this share of the image height is too small to
# tell hair from background; a mask smaller than this share of the image has
# nothing to repaint.
MIN_FACE_H = 0.08
MIN_MASK_AREA = 0.02
# Masks are processed at this long side, then scaled back.
WORK_SIDE = 768
# Below this share of the image there is no hair to take a colour from.
MIN_HAIR_FOR_COLOUR = 0.005


class HairMaskError(ValueError):
    """A photo the card cannot work with; `message` is shown to the user."""

    def __init__(self, code: str, message: str):
        super().__init__(message)
        self.code = code
        self.message = message


NO_FACE = "no_face"
FACE_TOO_SMALL = "face_too_small"
MASK_TOO_SMALL = "mask_too_small"

_MESSAGES = {
    NO_FACE: "No face found — use a clear, front-facing portrait of one person.",
    FACE_TOO_SMALL: "The face is too small — crop closer to the head and shoulders.",
    MASK_TOO_SMALL: "Not enough hair to restyle in this photo.",
}


@dataclass(frozen=True)
class HairShape:
    length: str = "keep"
    bangs: str = "none"
    updo: bool = False

    def __post_init__(self):
        if self.length not in LENGTHS:
            raise ValueError(f"unknown length '{self.length}'")
        if self.bangs not in BANGS:
            raise ValueError(f"unknown bangs '{self.bangs}'")

    @property
    def key(self) -> str:
        """Stable name for caching one mask per shape."""
        return f"{self.length}-{self.bangs}-{'updo' if self.updo else 'down'}"


@dataclass
class HairAnalysis:
    """Boolean HxW masks of one portrait, all the same shape."""

    hair: np.ndarray
    face: np.ndarray
    hat: np.ndarray
    features: np.ndarray = field(default=None)  # eyes + brows (+ glasses)

    def __post_init__(self):
        if self.features is None:
            self.features = np.zeros_like(self.face)
        shapes = {m.shape for m in (self.hair, self.face, self.hat, self.features)}
        if len(shapes) != 1:
            raise ValueError(f"analysis masks differ in size: {shapes}")


@dataclass
class MaskResult:
    mask: np.ndarray  # bool HxW, True = repaint
    face_box: tuple[int, int, int, int]  # x0, y0, x1, y1 in image pixels
    area: float  # share of the image repainted


def decode_mask(png: bytes) -> np.ndarray:
    """A saved ComfyUI mask image → bool array (white = inside)."""
    with Image.open(io.BytesIO(png)) as im:
        return np.asarray(im.convert("L")) >= 128


def to_png(mask: np.ndarray) -> bytes:
    """Bool mask → black/white PNG, the `__MASK__` convention (white = repaint)."""
    buf = io.BytesIO()
    Image.fromarray(np.where(mask, 255, 0).astype(np.uint8), "L").save(buf, "PNG")
    return buf.getvalue()


def face_box(face: np.ndarray) -> tuple[int, int, int, int] | None:
    """Box of the face mask from the 1st/99th percentile of its pixels — a few
    mis-labelled pixels elsewhere in the frame must not stretch it."""
    ys, xs = np.nonzero(face)
    if xs.size < 50:
        return None
    x0, x1 = np.percentile(xs, [1, 99])
    y0, y1 = np.percentile(ys, [1, 99])
    return int(x0), int(y0), int(x1), int(y1)


def _resize(mask: np.ndarray, size: tuple[int, int]) -> np.ndarray:
    """Nearest-neighbour resize of a bool mask to (width, height)."""
    im = Image.fromarray(mask.astype(np.uint8) * 255, "L")
    return np.asarray(im.resize(size, Image.Resampling.NEAREST)) >= 128


def dilate(mask: np.ndarray, radius: int) -> np.ndarray:
    """Grow a mask by about `radius` pixels. Alternating 4- and 8-neighbour
    steps approximate a disc without scipy."""
    out = mask.copy()
    for i in range(max(0, int(radius))):
        grown = out.copy()
        grown[1:, :] |= out[:-1, :]
        grown[:-1, :] |= out[1:, :]
        grown[:, 1:] |= out[:, :-1]
        grown[:, :-1] |= out[:, 1:]
        if i % 2:
            grown[1:, 1:] |= out[:-1, :-1]
            grown[1:, :-1] |= out[:-1, 1:]
            grown[:-1, 1:] |= out[1:, :-1]
            grown[:-1, :-1] |= out[1:, 1:]
        out = grown
    return out


def rounded_rect(
    height: int, width: int, x0: float, y0: float, x1: float, y1: float, radius: float
) -> np.ndarray:
    """Bool mask of a rounded rectangle (inclusive bounds, clipped to the image)."""
    ys, xs = np.mgrid[0:height, 0:width]
    inside = (xs >= x0) & (xs <= x1) & (ys >= y0) & (ys <= y1)
    r = max(0.0, min(radius, (x1 - x0) / 2, (y1 - y0) / 2))
    if r <= 0:
        return inside
    dx = np.maximum(np.maximum(x0 + r - xs, 0), xs - (x1 - r))
    dy = np.maximum(np.maximum(y0 + r - ys, 0), ys - (y1 - r))
    return inside & (dx * dx + dy * dy <= r * r)


def build_mask(analysis: HairAnalysis, shape: HairShape, mode: str | None = None) -> MaskResult:
    """The repaint mask for `shape` on this portrait. Raises HairMaskError
    for a photo the card cannot use (the caller refuses before billing).

    `mode` overrides MASK_MODE: a colour change on the same cut uses "hair",
    because there the old silhouette is exactly the shape to keep."""
    mode = mode or MASK_MODE
    full_h, full_w = analysis.face.shape
    scale = min(1.0, WORK_SIDE / max(full_h, full_w))
    w, h = max(1, round(full_w * scale)), max(1, round(full_h * scale))

    def small(m):
        return m if scale == 1.0 else _resize(m, (w, h))

    face, hair, hat, features = map(
        small, (analysis.face, analysis.hair, analysis.hat, analysis.features)
    )

    box = face_box(face)
    if box is None:
        raise HairMaskError(NO_FACE, _MESSAGES[NO_FACE])
    x0, y0, x1, y1 = box
    fw, fh = x1 - x0 + 1, y1 - y0 + 1
    if fh < MIN_FACE_H * h:
        raise HairMaskError(FACE_TOO_SMALL, _MESSAGES[FACE_TOO_SMALL])

    mask = dilate(hair | hat, round(DILATE_FH * fh))

    band = np.zeros_like(mask)
    if shape.bangs != "none":
        band[y0 : y0 + round(BANG_BAND_FH * fh), x0 : x1 + 1] = True
        band &= ~dilate(features, max(2, round(FEATURE_GUARD_FH * fh)))
        mask |= band

    envelope = ENVELOPES[shape.length]
    if envelope is not None:
        side, above, below = envelope
        mask |= rounded_rect(
            h, w,
            x0 - side * fw, y0 - above * fh,
            x1 + side * fw, y1 + below * fh,
            CORNER_FW * fw,
        )
    if shape.updo:
        mask |= rounded_rect(
            h, w,
            x0 - UPDO_SIDE_FW * fw, y0 - UPDO_ABOVE_FH * fh,
            x1 + UPDO_SIDE_FW * fw, y0 + 0.2 * fh,
            CORNER_FW * fw,
        )

    if mode == "blob" and mask.any():
        ys, xs = np.nonzero(mask)
        mask |= rounded_rect(h, w, xs.min(), ys.min(), xs.max(), ys.max(), CORNER_FW * fw)

    # The face stays untouched; only a fringe may cover the forehead.
    mask &= ~(face & ~band)

    area = float(mask.mean())
    if area < MIN_MASK_AREA:
        raise HairMaskError(MASK_TOO_SMALL, _MESSAGES[MASK_TOO_SMALL])

    if scale != 1.0:
        mask = _resize(mask, (full_w, full_h))
        # Scaling can nudge the protected edge inwards by a pixel; re-apply.
        mask &= ~(analysis.face & ~_resize(band, (full_w, full_h)))
    inv = 1.0 / scale
    full_box = (int(x0 * inv), int(y0 * inv), int(x1 * inv), int(y1 * inv))
    return MaskResult(mask=mask, face_box=full_box, area=area)


# ── Hair colour ─────────────────────────────────────────────────────────────


def _srgb_to_lab(rgb: np.ndarray) -> np.ndarray:
    """(N, 3) uint8 sRGB → (N, 3) CIELAB, D65 white."""
    c = rgb.astype(np.float64) / 255.0
    lin = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    m = np.array(
        [
            [0.4124564, 0.3575761, 0.1804375],
            [0.2126729, 0.7151522, 0.0721750],
            [0.0193339, 0.1191920, 0.9503041],
        ]
    )
    xyz = lin @ m.T / np.array([0.95047, 1.0, 1.08883])
    eps = 216 / 24389
    kappa = 24389 / 27
    f = np.where(xyz > eps, np.cbrt(xyz), (kappa * xyz + 16) / 116)
    lab = np.empty_like(f)
    lab[:, 0] = 116 * f[:, 1] - 16
    lab[:, 1] = 500 * (f[:, 0] - f[:, 1])
    lab[:, 2] = 200 * (f[:, 1] - f[:, 2])
    return lab


def colour_name(lab: tuple[float, float, float]) -> str:
    """CIELAB of the lit hair → a colour word the prompt understands.
    Calibrated on the eight bench portraits (tools/bench/srcs): brown hair
    reads L≈26, dark blond ≈39, blonde ≈61, grey has chroma < 4, auburn a*≈21."""
    L, a, b = lab
    chroma = math.hypot(a, b)
    if L < 22 and chroma < 10:
        return "black"
    if chroma < 8 and L > 75:
        return "white"
    if chroma < 8 and L > 38:
        return "grey"
    # Dyed colours sit outside natural hair's 30–90° hue: read as auburn, a
    # pink or purple head asked for a new cut came back auburn.
    if chroma >= 15:
        hue = math.degrees(math.atan2(b, a)) % 360
        if 160 <= hue < 245:
            return "teal"
        if 245 <= hue < 295:
            return "blue-black" if L < 22 else "blue"
        if 295 <= hue < 335:
            return "purple"
        if (hue >= 335 or hue < 25) and L >= 40 and a > 20:
            return "pink"
    if a > 16:
        return "auburn"
    if L < 22:
        return "dark brown"
    if L < 33:
        return "brown"
    if L < 48:
        return "light brown"
    if L < 72:
        return "blonde"
    return "platinum blonde"


def hair_lab(rgb: np.ndarray, hair: np.ndarray) -> dict | None:
    """CIELAB of the lit strands (the 50th–90th luminance rank of the hair
    core) plus the luminance spread (90th − 10th percentile, which is what
    tells a balayage from a solid colour). None with too little hair.

    The plain median lands in the shadows between strands: brown hair measured
    L 18 there and came out as "black" in bench round 0, while the brightest
    10 % are specular highlights."""
    if hair.shape != rgb.shape[:2]:
        raise ValueError("hair mask and image differ in size")
    if hair.mean() < MIN_HAIR_FOR_COLOUR:
        return None
    # Skip the edge, where hair blends into skin and background.
    core = hair & ~dilate(~hair, 3)
    pixels = rgb[core if core.sum() >= 50 else hair]
    lab = _srgb_to_lab(pixels.reshape(-1, 3))
    # By rank, not by value: a luminance threshold would keep every pixel of
    # a two-tone mask and let the shadows win again.
    order = np.argsort(lab[:, 0], kind="stable")
    n = len(order)
    lit = lab[order[int(0.5 * n) : max(int(0.9 * n), int(0.5 * n) + 1)]]
    L, a, b = (float(v) for v in np.median(lit, axis=0))
    p10, p90 = np.percentile(lab[:, 0], [10, 90])
    return {"L": L, "a": a, "b": b, "spread": float(p90 - p10)}


def estimate_colour(rgb: np.ndarray, hair: np.ndarray) -> str | None:
    """Colour word for the hair in `rgb` (HxWx3 uint8), or None when the photo
    has too little hair to read one (the prompt then says "natural")."""
    lab = hair_lab(rgb, hair)
    return None if lab is None else colour_name((lab["L"], lab["a"], lab["b"]))


# ── One call for the bot ────────────────────────────────────────────────────

# SaveImage prefixes of hair_analyse.api.json → HairAnalysis fields.
ANALYSE_OUTPUTS = {
    "tsumiki_hair_mask": "hair",
    "tsumiki_face_mask": "face",
    "tsumiki_hat_mask": "hat",
    "tsumiki_features_mask": "features",
}


def prepare(
    image: bytes, masks: dict[str, bytes], shape: HairShape, mode: str | None = None
) -> tuple[bytes, str | None]:
    """Analysis outputs (by SaveImage prefix) + the uploaded photo → (mask PNG,
    hair colour word or None). Raises HairMaskError for an unusable photo.

    The colour is read from the photo after EXIF rotation, which is what
    ComfyUI's LoadImage sees and so what the masks were made on; if the sizes
    still disagree the colour is skipped rather than guessed."""
    analysis = HairAnalysis(**{field: decode_mask(masks[prefix]) for prefix, field in ANALYSE_OUTPUTS.items()})
    result = build_mask(analysis, shape, mode)
    colour = None
    try:
        with Image.open(io.BytesIO(image)) as im:
            rgb = np.asarray(ImageOps.exif_transpose(im).convert("RGB"))
        if rgb.shape[:2] == analysis.hair.shape:
            colour = estimate_colour(rgb, analysis.hair)
    except (OSError, ValueError):
        colour = None
    return to_png(result.mask), colour
