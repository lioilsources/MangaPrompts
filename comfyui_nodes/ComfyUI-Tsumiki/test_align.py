"""Run in ComfyUI's venv (needs cv2, which the bot's venv lacks): each test_* is plain.

import cv2
import numpy as np

from align import MAX_SCALE_DEV, estimate, warp


def portrait(h=608, w=416, seed=3):
    """Textured synthetic frame: SIFT needs corners, flat colour has none."""
    rng = np.random.default_rng(seed)
    img = cv2.resize(rng.integers(0, 255, (h // 8, w // 8, 3), dtype=np.uint8), (w, h), interpolation=cv2.INTER_CUBIC)
    for _ in range(60):
        x, y = int(rng.integers(0, w)), int(rng.integers(0, h))
        cv2.circle(img, (x, y), int(rng.integers(4, 20)), tuple(int(c) for c in rng.integers(0, 255, 3)), -1)
    return img


def shifted(img, scale, tx, ty):
    h, w = img.shape[:2]
    m = cv2.getRotationMatrix2D((w / 2, h / 2), 0, scale)
    m[:, 2] += (tx, ty)
    return cv2.warpAffine(img, m, (w, h), borderMode=cv2.BORDER_REPLICATE)


def test_undoes_a_kontext_like_reframing():
    ref = portrait()
    edit = shifted(ref, 1.04, 0, -60)  # higher and larger, as measured
    keep = np.ones(ref.shape[:2], bool)
    keep[:200] = False  # the "hair": excluded from matching
    a = estimate(edit, ref, keep)
    assert a.applied, a.describe()
    assert abs(a.scale - 1 / 1.04) < 0.01
    out = warp(edit, ref, a)
    core = (slice(250, 550), slice(60, 356))
    assert np.abs(out[core].astype(int) - ref[core].astype(int)).mean() < 12


def test_already_aligned_stays_put():
    ref = portrait()
    a = estimate(ref.copy(), ref)
    assert a.applied and abs(a.scale - 1) < 0.002 and abs(a.matrix[1, 2]) < 1


def test_unrelated_image_passes_through():
    ref, other = portrait(seed=1), portrait(seed=2)
    a = estimate(other, ref)
    assert not a.applied
    assert warp(other, ref, a) is other


def test_implausible_scale_is_refused():
    ref = portrait()
    a = estimate(shifted(ref, 1 + 2 * MAX_SCALE_DEV, 0, 0), ref)
    assert not a.applied
