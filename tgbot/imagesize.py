"""Pixel size of an uploaded photo from its header, and the SDXL latent
bucket that best fits it.

No Pillow in the image: the two formats a phone gallery hands over (JPEG,
PNG) both carry their dimensions in the first few hundred bytes, so a header
walk is enough — and cheaper than decoding a 2000-px photo on the API
thread. Mirrors Ol1nLLM's lib/models/latent_bucket.dart.
"""

import math
import struct

# Standard SDXL training buckets (≈1 MP, multiples of 64). Rendering in the
# bucket closest to the reference's aspect keeps the depth hint (and the face
# keypoints) from being center-cropped by ControlNetApplyAdvanced.
SDXL_BUCKETS: tuple[tuple[int, int], ...] = (
    (1024, 1024),
    (896, 1152),
    (1152, 896),
    (832, 1216),
    (1216, 832),
    (768, 1344),
    (1344, 768),
)


def image_size(data: bytes) -> tuple[int, int] | None:
    """(width, height) for PNG or JPEG bytes; None when neither / truncated."""
    return _png_size(data) or _jpeg_size(data)


def _png_size(data: bytes) -> tuple[int, int] | None:
    if len(data) < 24 or data[:8] != b"\x89PNG\r\n\x1a\n" or data[12:16] != b"IHDR":
        return None
    w, h = struct.unpack(">II", data[16:24])
    return (w, h) if w > 0 and h > 0 else None


def _jpeg_size(data: bytes) -> tuple[int, int] | None:
    if len(data) < 4 or data[:2] != b"\xff\xd8":
        return None
    i = 2
    n = len(data)
    while i + 4 <= n:
        if data[i] != 0xFF:
            return None
        marker = data[i + 1]
        if marker == 0xFF:  # fill byte
            i += 1
            continue
        if marker in (0xD8, 0x01) or 0xD0 <= marker <= 0xD7:  # standalone
            i += 2
            continue
        if marker == 0xD9:  # EOI before any frame header
            return None
        seg_len = struct.unpack(">H", data[i + 2 : i + 4])[0]
        # SOF0..SOF15 minus the DHT/JPG/DAC markers that share the range.
        if 0xC0 <= marker <= 0xCF and marker not in (0xC4, 0xC8, 0xCC):
            if i + 9 > n:
                return None
            h, w = struct.unpack(">HH", data[i + 5 : i + 9])
            return (w, h) if w > 0 and h > 0 else None
        i += 2 + seg_len
    return None


def snap_to_sdxl_bucket(width: int, height: int) -> tuple[int, int]:
    """Closest bucket by aspect, compared in log space so portrait and
    landscape deviations weigh the same. Ties keep the earlier bucket."""
    if width <= 0 or height <= 0:
        return SDXL_BUCKETS[0]
    target = math.log(width / height)
    best, best_dist = SDXL_BUCKETS[0], math.inf
    for w, h in SDXL_BUCKETS:
        d = abs(math.log(w / h) - target)
        if d < best_dist:
            best, best_dist = (w, h), d
    return best


def latent_for(data: bytes, fallback: tuple[int, int] = (832, 1216)) -> tuple[int, int]:
    """Latent bucket for a reference photo; `fallback` when the header is
    unreadable (the bucket is then the portrait default, which is what most
    phone photos of a person are anyway)."""
    size = image_size(data) or fallback
    return snap_to_sdxl_bucket(*size)
