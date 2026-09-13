"""Mask geometry for the Hairdresser card, on synthetic face-parsing masks.

The fixture is plain numbers (not PNGs) so Ol1nLLM's Dart mirror
(`test/hair_mask_test.dart`) can build the very same masks and assert the
very same things: a 512² frame, face ellipse centred at (256, 280) with radii
50×65, eyes at y 265, brows at y 250, hair a disc of radius 85 around
(256, 250) above y 250 and outside the face.
"""

import numpy as np
import pytest

import hairmask as hm

SIZE = 512
CX, CY, RX, RY = 256, 280, 50, 65


def _ellipse(cx, cy, rx, ry, size=SIZE):
    ys, xs = np.mgrid[0:size, 0:size]
    return ((xs - cx) / rx) ** 2 + ((ys - cy) / ry) ** 2 <= 1.0


def synthetic(size=SIZE, scale=1.0, hair=True, hat=False):
    s = scale
    face = _ellipse(CX * s, CY * s, RX * s, RY * s, size)
    features = (
        _ellipse((CX - 20) * s, 265 * s, 9 * s, 5 * s, size)
        | _ellipse((CX + 20) * s, 265 * s, 9 * s, 5 * s, size)
        | _ellipse((CX - 20) * s, 250 * s, 13 * s, 3 * s, size)
        | _ellipse((CX + 20) * s, 250 * s, 13 * s, 3 * s, size)
    )
    ys, xs = np.mgrid[0:size, 0:size]
    hair_m = (
        ((xs - CX * s) ** 2 + (ys - 250 * s) ** 2 <= (85 * s) ** 2) & (ys < 250 * s) & ~face
        if hair
        else np.zeros((size, size), bool)
    )
    hat_m = _ellipse(CX * s, 150 * s, 70 * s, 25 * s, size) if hat else np.zeros((size, size), bool)
    return hm.HairAnalysis(hair=hair_m, face=face, hat=hat_m, features=features)


def _box(a):
    return hm.face_box(a.face)


def test_face_box_ignores_stray_pixels():
    a = synthetic()
    a.face[5, 5] = True  # one mislabelled pixel in the corner
    x0, y0, x1, y1 = hm.face_box(a.face)
    assert 204 <= x0 <= 210 and 302 <= x1 <= 308
    assert 213 <= y0 <= 220 and 340 <= y1 <= 347


@pytest.mark.parametrize("length", hm.LENGTHS)
@pytest.mark.parametrize("bangs", hm.BANGS)
def test_face_features_are_never_repainted(length, bangs):
    a = synthetic()
    res = hm.build_mask(a, hm.HairShape(length, bangs))
    assert not (res.mask & a.features).any()
    # nose and mouth sit in the lower face, well below any fringe band
    lower_face = a.face.copy()
    lower_face[: CY, :] = False
    assert not (res.mask & lower_face).any()


def test_old_hair_is_always_repainted_with_a_margin():
    a = synthetic()
    res = hm.build_mask(a, hm.HairShape("keep"))
    assert (res.mask | ~a.hair).all()
    # dilation reaches beyond the hair edge (but not into the face)
    assert res.mask[250 - 85 - 3, CX]


def test_short_envelope_ends_at_the_chin():
    a = synthetic()
    _, _, _, y1 = _box(a)
    res = hm.build_mask(a, hm.HairShape("short"))
    assert not res.mask[y1 + 2 :, :].any()
    assert res.mask[: 250 - 85].any()  # room above the head


def test_long_envelope_reaches_well_below_the_chin():
    a = synthetic()
    _, y0, _, y1 = _box(a)
    fh = y1 - y0 + 1
    res = hm.build_mask(a, hm.HairShape("long"))
    assert res.mask[min(SIZE - 1, y1 + int(1.5 * fh)), CX - RX - 10]
    medium = hm.build_mask(a, hm.HairShape("medium"))
    assert res.area > medium.area > hm.build_mask(a, hm.HairShape("short")).area


def test_forehead_band_only_with_a_fringe():
    a = synthetic()
    _, y0, _, _ = _box(a)
    forehead = (y0 + 6, CX)
    assert a.face[forehead]
    assert not hm.build_mask(a, hm.HairShape("keep", "none")).mask[forehead]
    for bangs in ("full", "side", "curtain", "wispy"):
        assert hm.build_mask(a, hm.HairShape("keep", bangs)).mask[forehead], bangs


def test_updo_makes_room_above_the_head():
    a = synthetic()
    _, y0, _, y1 = _box(a)
    fh = y1 - y0 + 1
    above = (max(0, y0 - int(0.7 * fh)), CX)
    assert not hm.build_mask(a, hm.HairShape("keep")).mask[above]
    assert hm.build_mask(a, hm.HairShape("keep", updo=True)).mask[above]


def test_hat_is_repainted():
    a = synthetic(hat=True)
    res = hm.build_mask(a, hm.HairShape("keep"))
    assert res.mask[150, CX]


def test_no_face_is_refused():
    a = synthetic()
    a.face[:] = False
    with pytest.raises(hm.HairMaskError) as e:
        hm.build_mask(a, hm.HairShape("short"))
    assert e.value.code == hm.NO_FACE


def test_tiny_face_is_refused():
    face = _ellipse(256, 256, 8, 10)
    a = hm.HairAnalysis(hair=np.zeros_like(face), face=face, hat=np.zeros_like(face))
    with pytest.raises(hm.HairMaskError) as e:
        hm.build_mask(a, hm.HairShape("long"))
    assert e.value.code == hm.FACE_TOO_SMALL


def test_nothing_to_repaint_is_refused():
    a = synthetic(hair=False)
    with pytest.raises(hm.HairMaskError) as e:
        hm.build_mask(a, hm.HairShape("keep"))
    assert e.value.code == hm.MASK_TOO_SMALL
    # …but a new cut still has an envelope to grow into
    assert hm.build_mask(a, hm.HairShape("short")).area > hm.MIN_MASK_AREA


def test_large_photos_are_processed_scaled_and_returned_full_size():
    a = synthetic(size=1536, scale=3.0)
    res = hm.build_mask(a, hm.HairShape("medium", "full"))
    assert res.mask.shape == (1536, 1536)
    assert not (res.mask & a.features).any()
    x0, y0, x1, y1 = res.face_box
    assert abs(x0 - 3 * (CX - RX)) < 24 and abs(y1 - 3 * (CY + RY)) < 24  # percentile trim


def test_png_round_trip():
    a = synthetic()
    res = hm.build_mask(a, hm.HairShape("short"))
    assert (hm.decode_mask(hm.to_png(res.mask)) == res.mask).all()


def test_shape_validation_and_key():
    assert hm.HairShape("long", "curtain", True).key == "long-curtain-updo"
    with pytest.raises(ValueError):
        hm.HairShape("huge")
    with pytest.raises(ValueError):
        hm.HairShape("short", "mohawk")


@pytest.mark.parametrize(
    "rgb, name",
    [
        ((20, 18, 16), "black"),
        ((60, 40, 28), "dark brown"),
        ((85, 58, 38), "brown"),
        ((125, 90, 58), "light brown"),
        ((190, 155, 100), "blonde"),
        ((235, 225, 200), "platinum blonde"),
        ((150, 148, 146), "grey"),
        ((235, 235, 235), "white"),
        ((170, 80, 40), "auburn"),
    ],
)
def test_colour_from_hair_pixels(rgb, name):
    a = synthetic()
    img = np.full((SIZE, SIZE, 3), 200, np.uint8)
    img[a.hair] = rgb
    assert hm.estimate_colour(img, a.hair) == name


def test_colour_ignores_the_edge_and_needs_enough_hair():
    a = synthetic()
    img = np.full((SIZE, SIZE, 3), 240, np.uint8)
    img[a.hair] = (20, 18, 16)
    edge = a.hair & hm.dilate(~a.hair, 2)
    img[edge] = (250, 250, 250)  # a bright halo where hair meets background
    assert hm.estimate_colour(img, a.hair) == "black"
    assert hm.estimate_colour(img, np.zeros_like(a.hair)) is None


def test_colour_reads_lit_strands_not_the_shadows_between_them():
    """Brown hair photographed is mostly shadow: bench round 0 read the plain
    median as black. Most strands in shadow, the rest lit brown → brown."""
    a = synthetic()
    img = np.full((SIZE, SIZE, 3), 200, np.uint8)
    ys, xs = np.nonzero(a.hair)
    img[ys, xs] = np.where((xs % 5 < 3)[:, None], (22, 15, 11), (85, 58, 38))
    assert hm.estimate_colour(img, a.hair) == "brown"


def test_medium_cut_leaves_most_of_a_portrait_alone(monkeypatch):
    """Round 0 regression: a medium envelope must not swallow the frame."""
    monkeypatch.setattr(hm, "MASK_MODE", "hair")
    a = synthetic()
    assert hm.build_mask(a, hm.HairShape("medium")).area < 0.35


def test_fringe_band_keeps_clear_of_the_brows():
    a = synthetic()
    res = hm.build_mask(a, hm.HairShape("keep", "full"))
    guard = hm.dilate(a.features, 3)
    assert not (res.mask & guard & a.face).any()


def test_blob_mode_hides_the_old_silhouette(monkeypatch):
    a = synthetic()
    assert hm.MASK_MODE == "blob"  # the shipped default
    blob = hm.build_mask(a, hm.HairShape("short"))
    monkeypatch.setattr(hm, "MASK_MODE", "hair")
    hair_mode = hm.build_mask(a, hm.HairShape("short"))
    assert blob.area > hair_mode.area
    assert (blob.mask | ~hair_mode.mask).all()  # a superset
    assert not (blob.mask & a.features).any()
