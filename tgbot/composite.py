"""Pastes the kept part of the source back over a Kontext edit, in Python.

FLUX Kontext redraws the whole frame, mask or not. `flux_hair_kontext.api.json`
aligns the edit to the source (TsumikiAlignToReference) and then pastes the
source back outside the mask. That paste is only right where the edit still
looks like the source: Kontext sometimes rescales the face or moves the
hairline, the align node can only correct one global similarity transform
(and passes the image through when it cannot), and the paste then lays the old
face over the new one — doubled brows, a skin smear across a new fringe, a
seam along the mask (bench round 3, 13 of 104 hair cells).

So the graph stops at the aligned edit (`raw_output`) and `paste_back` pastes
here, gated per pixel: the source comes back only where it agrees with the
edit at low frequency (same colours, same shapes, just Kontext's re-rendered
texture), and fades out where they disagree. Wherever the two differ, the
result is the edit as drawn, so the paste can sharpen detail but never draw
a second face. Pure numpy + Pillow, testable without a GPU.
"""

from __future__ import annotations

import io
from dataclasses import dataclass

import numpy as np
from PIL import Image, ImageFilter

# Seam of the paste, as a share of the photo's long side: the edit region is
# grown by RAMP and blurred by SIGMA, so the blend runs inside the kept area
# and the edit's own pixels stay whole up to the mask edge.
SIGMA = 0.008
RAMP = 2.0 * SIGMA
# Agreement is judged on both images blurred by AGREE_BLUR (share of the long
# side), so texture does not count but a moved brow or a new strand does.
# A colour distance (RGB, 0–255) up to AGREE_FULL pastes fully, from AGREE_NONE
# not at all; the gate itself is smoothed by GATE_BLUR so it has no edges.
AGREE_BLUR = 0.005
AGREE_FULL = 14.0
AGREE_NONE = 32.0
GATE_BLUR = 0.006
# Work resolution of the gate (long side); it is smooth, so scaling it up
# costs nothing visible and keeps a 1536 px photo fast.
GATE_SIDE = 768


@dataclass(frozen=True)
class PasteResult:
    png: bytes
    # Share of the kept area where the source was refused (the edit stayed).
    drift: float

    @property
    def pasted(self) -> bool:
        return self.drift < 0.999


def raw_output(workflow: dict) -> bool:
    """Point every SaveImage at what the composite would have pasted onto
    (the aligned edit) instead of the composite. False when the graph has no
    ImageCompositeMasked, i.e. nothing for `paste_back` to do."""
    comp = next((n for n in workflow.values() if n.get("class_type") == "ImageCompositeMasked"), None)
    if comp is None:
        return False
    source = comp["inputs"]["source"]
    for node in workflow.values():
        if node.get("class_type") == "SaveImage":
            node["inputs"]["images"] = source
    return True


def _rgb(png: bytes) -> Image.Image:
    with Image.open(io.BytesIO(png)) as im:
        return im.convert("RGB")


def _edit_mask(png: bytes, size: tuple[int, int]) -> Image.Image:
    """The mask as L, 255 = edited, at `size`."""
    with Image.open(io.BytesIO(png)) as im:
        m = im.convert("L")
    if m.size != size:
        m = m.resize(size, Image.Resampling.BILINEAR)
    return m.point(lambda v: 255 if v >= 128 else 0)


def _grow(mask: Image.Image, px: float) -> Image.Image:
    """Dilate a binary L mask by about `px` pixels (blur, low threshold)."""
    if px < 1:
        return mask
    soft = mask.filter(ImageFilter.GaussianBlur(px / 2))
    return soft.point(lambda v: 255 if v >= 6 else 0)


def agreement(source: Image.Image, edited: Image.Image) -> np.ndarray:
    """0–1 per pixel at the source's size: 1 where the two look the same
    once texture is blurred away, 0 where they show different things."""
    w, h = source.size
    scale = min(1.0, GATE_SIDE / max(w, h))
    size = (max(1, round(w * scale)), max(1, round(h * scale)))
    side = max(size)

    def low(im: Image.Image) -> np.ndarray:
        small = im.resize(size, Image.Resampling.BILINEAR) if scale < 1.0 else im
        return np.asarray(small.filter(ImageFilter.GaussianBlur(AGREE_BLUR * side)), dtype=np.float32)

    dist = np.sqrt(((low(source) - low(edited)) ** 2).sum(axis=2))
    gate = np.clip((AGREE_NONE - dist) / (AGREE_NONE - AGREE_FULL), 0.0, 1.0)
    g = Image.fromarray((gate * 255).round().astype(np.uint8), "L")
    # Min-then-blur: a refused spot grows a little before it is softened, so
    # the source cannot creep back into the edge of a moved feature.
    g = g.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(GATE_BLUR * side))
    if g.size != (w, h):
        g = g.resize((w, h), Image.Resampling.BILINEAR)
    return np.asarray(g, dtype=np.float32) / 255.0


def paste_back(source_png: bytes, edited_png: bytes, mask_png: bytes) -> PasteResult:
    """The edit with the source pasted back outside the mask, through a soft
    seam and only where the two agree (see the module doc)."""
    src = _rgb(source_png)
    ed = _rgb(edited_png)
    if ed.size != src.size:
        ed = ed.resize(src.size, Image.Resampling.LANCZOS)
    mask = _edit_mask(mask_png, src.size)
    side = max(src.size)
    edit_soft = _grow(mask, RAMP * side).filter(ImageFilter.GaussianBlur(SIGMA * side))
    keep = 1.0 - np.asarray(edit_soft, dtype=np.float32) / 255.0
    gate = agreement(src, ed)
    w = (keep * gate)[..., None]
    out = np.asarray(ed, dtype=np.float32) * (1.0 - w) + np.asarray(src, dtype=np.float32) * w
    kept = np.asarray(mask) < 128
    drift = float(1.0 - gate[kept].mean()) if kept.any() else 0.0
    buf = io.BytesIO()
    Image.fromarray(out.round().clip(0, 255).astype(np.uint8), "RGB").save(buf, format="PNG")
    return PasteResult(png=buf.getvalue(), drift=round(drift, 3))
