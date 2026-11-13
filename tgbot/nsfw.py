"""Nudity check on every image a Restyler render step returns.

FLUX reads no negative prompt, so "fully clothed" in the positive prompt is a
wish, not a guarantee: the `davinci-chalk` style drew a topless portrait from
a clothed selfie of a young person (2026-11-13). The prompt cannot be trusted
to hold, so the output is checked before it is stored or served.

NudeNet (ONNX detector, CPU, model inside the pip package, nothing is
downloaded at run time) finds exposed body parts. A step whose image shows
one is failed and refunded; its bytes are never written to DATA_DIR. Bare
chests of men count too: the photos are of anyone, children included, and a
false alarm costs one retry.
"""

from __future__ import annotations

import io
import threading

import numpy as np
from PIL import Image

import config

EXPOSED = frozenset(
    {
        "FEMALE_BREAST_EXPOSED",
        "FEMALE_GENITALIA_EXPOSED",
        "MALE_GENITALIA_EXPOSED",
        "MALE_BREAST_EXPOSED",
        "BUTTOCKS_EXPOSED",
        "ANUS_EXPOSED",
    }
)

MESSAGE = "nsfw: the result showed nudity and was thrown away, try another style"

_detector = None
_lock = threading.Lock()


def _get():
    global _detector
    with _lock:
        if _detector is None:
            from nudenet import NudeDetector

            _detector = NudeDetector()
        return _detector


def findings(png: bytes, threshold: float | None = None) -> list[tuple[str, float]]:
    """(label, score) of every exposed part found at or above `threshold`
    (default NSFW_THRESHOLD). Raises when the detector cannot run: a check
    that did not happen must not pass as clean."""
    limit = config.NSFW_THRESHOLD if threshold is None else threshold
    with Image.open(io.BytesIO(png)) as im:
        # NudeNet converts RGBA -> BGR itself; an RGB array would break it.
        rgba = np.asarray(im.convert("RGBA"))
    detector = _get()
    with _lock:  # one ONNX session, used from worker threads
        found = detector.detect(rgba)
    return [
        (d["class"], round(float(d["score"]), 3))
        for d in found
        if d["class"] in EXPOSED and d["score"] >= limit
    ]
