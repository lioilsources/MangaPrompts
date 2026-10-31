"""Composite mask for the beard step: the lower face.

The Kontext edit is pasted back through this mask, so eyes, nose, lips, hair and
clothes stay pixel-exact. The extent follows the style (`BeardRegion`): a
moustache needs the strip above the lip, a goatee the chin, a full beard the
cheeks, the jaw and room under the chin. A full-beard mask on a moustache would
repaint the cheeks for nothing, and cheeks carry identity.

The one exception is a photo that already has a beard: a goatee mask leaves the
old cheeks in place, so narrow regions grow to `full` there — shave and set in
one pass, the prompt says "shaved cheeks".

CelebAMask-HQ has no beard class (beards are `skin`), so `has_beard` reads the
photo instead: a lower face clearly darker than the upper face.

Built on the hairmask primitives and the same analysis pass. Pure numpy; the
constants are what bench round 3 sweeps. The Dart mirror is
`tsumiki_shared/lib/masks/beard_mask.dart`, pinned by `tests/fixtures/masks`.
"""

from __future__ import annotations

import io
from dataclasses import dataclass

import numpy as np
from PIL import Image, ImageOps

import hairmask as hm
from hairmask import HairAnalysis, HairMaskError, MaskResult

REGIONS = ("moustache", "chin", "jaw", "full")

# Units: face-box sizes.
MOUSTACHE_INSET_FW = 0.15  # the strip stops short of the cheeks
MOUSTACHE_OVER_LIP_FH = 0.03  # how far it runs past the top of the lips
CHIN_OVER_LIP_FH = 0.05  # how far above the lower edge of the lips the chin starts
JAW_SIDE_FW = 0.06
FULL_SIDE_FW = 0.08
CORNER_FW = 0.05
LIPS_GUARD_FH = 0.02
# Sideburns may run this far into the hair; the hair above the temples stays.
HAIR_ALLOWANCE_FH = 0.06
# Ears further than this from the face box are mislabelled pixels.
EAR_MAX_FW = 0.25
# Where a shave has to reach, and the least a narrow region grows to on a
# photo that already has a beard.
SHAVE_BELOW_CHIN = 0.1
# Below this many pixels the lips are hidden (hand, mask, profile).
MIN_LIPS_PX = 20
# Fewer readable skin pixels than this above or below the nose: no verdict.
MIN_SKIN_PX = 200
# has_beard, in CIELAB L: how much darker the lower face must be, how little
# darker counts as smooth, and how much spread on the upper face means the
# photo cannot be read at all. A first cut; bench round 1 measures it on
# m-beard-full / m-short.
BEARD_DARKER_L = 12.0
SMOOTH_DARKER_L = 5.0
NOISY_SPREAD_L = 12.0

MOUTH_NOT_VISIBLE = "mouth_not_visible"
NO_BEARD_TO_SHAVE = "no_beard_to_shave"

_MESSAGES = {
    hm.NO_FACE: "No face found — use a clear, front-facing portrait of one person.",
    hm.FACE_TOO_SMALL: "The face is too small — crop closer to the head and shoulders.",
    hm.MASK_TOO_SMALL: "Nothing to change in this photo.",
    MOUTH_NOT_VISIBLE: "The mouth must be visible — face the camera, no hand over the face.",
    NO_BEARD_TO_SHAVE: "There is no beard to shave in this photo.",
}


def _refuse(code: str) -> HairMaskError:
    return HairMaskError(code, _MESSAGES[code])


@dataclass(frozen=True)
class BeardRegion:
    kind: str
    below_chin: float = 0.0  # how many face heights the beard hangs under the chin
    moustache: bool = False  # chin or jaw plus the moustache strip (van dyke, anchor)
    chin_sides: bool = False  # moustache running down beside the mouth (horseshoe)

    def __post_init__(self):
        if self.kind not in REGIONS:
            raise ValueError(f"unknown region '{self.kind}'")


def _span(mask: np.ndarray) -> tuple[int, int, int, int] | None:
    """Box by the 1st/99th percentile, like hairmask.face_box."""
    ys, xs = np.nonzero(mask)
    if xs.size == 0:
        return None
    x0, x1 = np.percentile(xs, [1, 99])
    y0, y1 = np.percentile(ys, [1, 99])
    return int(x0), int(y0), int(x1), int(y1)


def lower_face_box(
    face: np.ndarray, nose: np.ndarray, lips: np.ndarray
) -> tuple[int, int, int, int] | None:
    """(x0, y0, x1, y1): y0 = the bottom of the nose, y1 = the chin, the sides
    of the face box. Without a parsed nose the box starts just above the lips,
    without lips at 60 % of the face."""
    box = hm.face_box(face)
    if box is None:
        return None
    x0, y0, x1, y1 = box
    fh = y1 - y0 + 1
    nose_span, lips_span = _span(nose), _span(lips)
    if nose_span is not None:
        top = nose_span[3]
    elif lips_span is not None:
        top = max(y0, lips_span[1] - round(0.1 * fh))
    else:
        top = y0 + round(0.6 * fh)
    return x0, top, x1, y1


def has_beard(
    rgb: np.ndarray, face: np.ndarray, lower_box: tuple[int, int, int, int]
) -> bool | None:
    """Whether the lower face reads as bearded. `face` is the bare skin to look
    at (the caller leaves out lips, nose and eyes). None = cannot tell, and the
    callers then behave as "no beard, no refusal": a pointless render is better
    than refusing a real beard."""
    if face.shape != rgb.shape[:2]:
        raise ValueError("face mask and image differ in size")
    x0, y0, x1, y1 = lower_box
    upper, lower = face.copy(), face.copy()
    upper[y0:, :] = False
    lower[: y0, :] = False
    lower[y1 + 1 :, :] = False
    lower[:, : x0] = False
    lower[:, x1 + 1 :] = False
    if upper.sum() < MIN_SKIN_PX or lower.sum() < MIN_SKIN_PX:
        return None
    upper_l = hm._srgb_to_lab(rgb[upper].reshape(-1, 3))[:, 0]
    lower_l = hm._srgb_to_lab(rgb[lower].reshape(-1, 3))[:, 0]
    if float(upper_l.std()) > NOISY_SPREAD_L:
        return None
    darker = float(np.median(upper_l) - np.median(lower_l))
    if darker >= BEARD_DARKER_L:
        return True
    if darker <= SMOOTH_DARKER_L:
        return False
    return None


def detect_beard(rgb: np.ndarray, analysis: HairAnalysis) -> bool | None:
    """`has_beard` of a whole portrait; None when there is no face to read."""
    box = lower_face_box(analysis.face, analysis.nose, analysis.lips)
    if box is None:
        return None
    skin = analysis.face & ~analysis.lips & ~analysis.nose & ~analysis.features
    return has_beard(rgb, skin, box)


def _ear_sides(ears: np.ndarray, box: tuple[int, int, int, int]) -> tuple[float, float] | None:
    """Inner edge of each visible ear (None when an ear is not there), as
    (left, right); a sideburn ends at the ear, not on it."""
    x0, _, x1, _ = box
    fw = x1 - x0 + 1
    xs = np.nonzero(ears)[1]
    xs = xs[(xs >= x0 - EAR_MAX_FW * fw) & (xs <= x1 + EAR_MAX_FW * fw)]
    centre = (x0 + x1) / 2
    near, far = xs[xs < centre], xs[xs >= centre]
    return (
        float(np.percentile(near, 99)) if near.size >= 10 else None,
        float(np.percentile(far, 1)) if far.size >= 10 else None,
    )


def build_mask(
    analysis: HairAnalysis,
    region: BeardRegion,
    mode: str | None = None,
    has_beard: bool | None = None,
) -> MaskResult:
    """The composite mask for `region`. `mode="shave"` is the clean-shaven
    style: it refuses a photo that plainly has no beard. `has_beard` (from
    `detect_beard`) True grows a narrow region to `full`.
    Raises HairMaskError for a photo the step cannot use (before billing)."""
    full_h, full_w = analysis.face.shape
    scale = min(1.0, hm.WORK_SIDE / max(full_h, full_w))
    w, h = max(1, round(full_w * scale)), max(1, round(full_h * scale))

    def small(m):
        return m if scale == 1.0 else hm._resize(m, (w, h))

    face, hair, features, lips, nose, ears = map(
        small,
        (analysis.face, analysis.hair, analysis.features, analysis.lips, analysis.nose, analysis.ears),
    )

    box = hm.face_box(face)
    if box is None:
        raise _refuse(hm.NO_FACE)
    x0, y0, x1, y1 = box
    fw, fh = x1 - x0 + 1, y1 - y0 + 1
    if fh < hm.MIN_FACE_H * h:
        raise _refuse(hm.FACE_TOO_SMALL)
    if int(lips.sum()) < MIN_LIPS_PX:
        raise _refuse(MOUTH_NOT_VISIBLE)
    if mode == "shave" and has_beard is False:
        raise _refuse(NO_BEARD_TO_SHAVE)

    lx0, ly0, lx1, ly1 = lower_face_box(face, nose, lips)
    mx0, my0, mx1, my1 = _span(lips)

    kind, below = region.kind, region.below_chin
    with_moustache, with_sides = region.moustache, region.chin_sides
    if has_beard is True and kind != "full":
        kind, below = "full", max(below, SHAVE_BELOW_CHIN)
        with_moustache, with_sides = False, False

    def rect(rx0, ry0, rx1, ry1):
        return hm.rounded_rect(h, w, rx0, ry0, rx1, ry1, CORNER_FW * fw)

    moustache = rect(
        lx0 + MOUSTACHE_INSET_FW * fw, ly0, lx1 - MOUSTACHE_INSET_FW * fw, my0 + MOUSTACHE_OVER_LIP_FH * fh
    )
    third = (lx1 - lx0) / 3
    chin = rect(lx0 + third, my1 - CHIN_OVER_LIP_FH * fh, lx1 - third, ly1 + below * fh)

    if kind == "moustache":
        mask = moustache
        if with_sides:
            mask = mask | rect(lx0 + MOUSTACHE_INSET_FW * fw, ly0, mx0, ly1)
            mask = mask | rect(mx1, ly0, lx1 - MOUSTACHE_INSET_FW * fw, ly1)
    elif kind == "chin":
        mask = chin | moustache if with_moustache else chin
    elif kind == "jaw":
        jaw = rect(lx0 - JAW_SIDE_FW * fw, (ly0 + ly1) / 2, lx1 + JAW_SIDE_FW * fw, ly1 + below * fh)
        mask = chin | jaw
        if with_moustache:
            mask = mask | moustache
    else:
        left, right = lx0 - FULL_SIDE_FW * fw, lx1 + FULL_SIDE_FW * fw
        ear_left, ear_right = _ear_sides(ears, box)
        if ear_left is not None:
            left = min(left, ear_left)
        if ear_right is not None:
            right = max(right, ear_right)
        mask = rect(left, ly0, right, ly1 + below * fh) | moustache

    mask = mask & ~hm.dilate(lips, round(LIPS_GUARD_FH * fh))
    mask = mask & ~nose & ~features
    # Hair stays, bar the allowance at its edge where a sideburn meets it.
    mask = mask & ~(hair & ~hm.dilate(~hair, round(HAIR_ALLOWANCE_FH * fh)))

    area = float(mask.mean())
    if not mask.any():
        raise _refuse(hm.MASK_TOO_SMALL)

    if scale != 1.0:
        # Scaling can nudge the protected edges by a pixel; re-apply.
        mask = hm._resize(mask, (full_w, full_h)) & ~analysis.lips & ~analysis.nose & ~analysis.features
    inv = 1.0 / scale
    full_box = (int(x0 * inv), int(y0 * inv), int(x1 * inv), int(y1 * inv))
    return MaskResult(mask=mask, face_box=full_box, area=area)


def prepare(
    image: bytes, masks: dict[str, bytes], region: BeardRegion, mode: str | None = None
) -> tuple[bytes, str | None, bool | None]:
    """Analysis outputs (by SaveImage prefix) + the uploaded photo → (mask PNG,
    hair colour word or None, has_beard). Raises HairMaskError for an unusable
    photo. An unreadable photo or a size mismatch leaves colour and has_beard
    None rather than guessed, as in `hairmask.prepare`."""
    analysis = HairAnalysis(
        **{field: hm.decode_mask(masks[prefix]) for prefix, field in hm.ANALYSE_OUTPUTS.items()}
    )
    colour = beard = None
    try:
        with Image.open(io.BytesIO(image)) as im:
            rgb = np.asarray(ImageOps.exif_transpose(im).convert("RGB"))
        if rgb.shape[:2] == analysis.face.shape:
            colour = hm.estimate_colour(rgb, analysis.hair)
            beard = detect_beard(rgb, analysis)
    except (OSError, ValueError):
        colour, beard = None, None
    return hm.to_png(build_mask(analysis, region, mode, beard).mask), colour, beard
