"""The lower-face mask, on the file fixtures the Dart mirror reads too
(`tools/gen_fixtures.py`; Dart asserts IoU 1.0 against the same PNGs)."""

import json
import sys
from pathlib import Path

import numpy as np
import pytest
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "tools"))

import beardmask as bm  # noqa: E402
import gen_fixtures as gf  # noqa: E402
import hairmask as hm  # noqa: E402

MASKS = Path(__file__).resolve().parent / "fixtures" / "masks"
CANDIDATES = gf.CANDIDATES / "beards.json"


def parse(case):
    folder = MASKS / case
    face = np.asarray(Image.open(folder / "parse.png"))
    clothes = np.asarray(Image.open(folder / "clothes.png")) if (folder / "clothes.png").exists() else None
    return gf.analysis_from_parse(face, clothes), face


def rgb(case):
    return np.asarray(Image.open(MASKS / case / "photo.png").convert("RGB"))


def beards():
    return {c["id"]: c for c in json.loads(CANDIDATES.read_text())}


def region(style_id):
    return bm.BeardRegion(**beards()[style_id]["region"])


def spot(a):
    """Landmarks of the portrait, as (y, x) of pixels that must be in or out."""
    x0, y0, x1, y1 = hm.face_box(a.face)
    lips = bm._span(a.lips)
    cx = (x0 + x1) // 2
    cy_lips = (lips[1] + lips[3]) // 2
    return {
        "chin": (y1 - 8, cx),
        "upper_lip": (lips[1] - 8, cx),
        "cheek_l": (cy_lips - 15, x0 + 16),
        "cheek_r": (cy_lips - 15, x1 - 16),
        "under_chin": (y1 + 8, cx),
    }


ALL = sorted(beards())


@pytest.mark.parametrize("sid", ALL)
@pytest.mark.parametrize("case", ["man-short", "man-bearded", "woman-long", "large-landscape"])
@pytest.mark.parametrize("beard", [None, True])
def test_lips_nose_and_eyes_are_never_in_the_mask(sid, case, beard):
    a, _ = parse(case)
    res = bm.build_mask(a, region(sid), has_beard=beard)
    assert not (res.mask & a.lips).any()
    assert not (res.mask & a.nose).any()
    assert not (res.mask & a.features).any()
    assert res.mask.any()


def test_regions_cover_what_they_are_for():
    a, _ = parse("man-short")
    p = spot(a)
    assert bm.build_mask(a, region("chevron")).mask[p["upper_lip"]]
    assert bm.build_mask(a, region("goatee")).mask[p["chin"]]
    jaw = bm.build_mask(a, region("chin-strap")).mask
    assert jaw[p["chin"]]
    full = bm.build_mask(a, region("full-beard")).mask
    for k in ("chin", "upper_lip", "cheek_l", "cheek_r", "under_chin"):
        assert full[p[k]], k


def test_narrow_regions_stay_narrow_on_a_clean_face():
    a, _ = parse("man-short")
    p = spot(a)
    moustache = bm.build_mask(a, region("chevron")).mask
    assert not moustache[p["chin"]] and not moustache[p["cheek_l"]]
    goatee = bm.build_mask(a, region("goatee")).mask
    assert not goatee[p["cheek_l"]] and not goatee[p["upper_lip"]]


def test_extras_add_the_moustache_and_the_mouth_sides():
    a, _ = parse("man-short")
    p = spot(a)
    assert bm.build_mask(a, region("circle-beard")).mask[p["upper_lip"]]
    assert bm.build_mask(a, region("anchor")).mask[p["upper_lip"]]
    assert not bm.build_mask(a, region("chin-strap")).mask[p["upper_lip"]]
    plain = bm.build_mask(a, region("chevron"))
    horseshoe = bm.build_mask(a, region("horseshoe"))
    assert horseshoe.area > plain.area
    lips = bm._span(a.lips)
    assert horseshoe.mask[lips[3] + 6, lips[0] - 8]  # beside the mouth, below the lip line
    assert (horseshoe.mask | ~plain.mask).all()


def test_full_reaches_further_with_a_longer_beard():
    a, _ = parse("man-short")
    low = [
        np.nonzero(bm.build_mask(a, region(s)).mask.any(axis=1))[0].max()
        for s in ("light-stubble", "short-boxed", "full-beard", "long-beard")
    ]
    assert low == sorted(low) and low[0] < low[-1]


@pytest.mark.parametrize("sid", [s for s in ALL if beards()[s]["region"]["kind"] != "full"])
def test_an_existing_beard_grows_narrow_regions_to_full(sid):
    """Otherwise the old cheeks survive a goatee: shave and set in one pass."""
    a, _ = parse("man-bearded")
    p = spot(a)
    narrow = bm.build_mask(a, region(sid))
    grown = bm.build_mask(a, region(sid), has_beard=True)
    assert grown.area > narrow.area
    assert grown.mask[p["cheek_l"]] and grown.mask[p["cheek_r"]]
    assert (grown.mask | ~narrow.mask).all()
    assert not (grown.mask & a.lips).any()


def test_a_full_region_does_not_change_with_has_beard():
    a, _ = parse("man-bearded")
    same = [bm.build_mask(a, region("full-beard"), has_beard=b).mask for b in (None, False, True)]
    assert (same[0] == same[1]).all() and (same[1] == same[2]).all()


def test_has_beard_false_leaves_narrow_regions_alone():
    a, _ = parse("man-short")
    assert (bm.build_mask(a, region("goatee"), has_beard=False).mask == bm.build_mask(a, region("goatee")).mask).all()


def test_has_beard_reads_dark_lower_face_smooth_skin_and_noise():
    assert bm.detect_beard(rgb("man-bearded"), parse("man-bearded")[0]) is True
    assert bm.detect_beard(rgb("man-short"), parse("man-short")[0]) is False
    assert bm.detect_beard(rgb("noisy-face"), parse("noisy-face")[0]) is None


def test_has_beard_needs_enough_skin_and_matching_sizes():
    a, _ = parse("man-short")
    box = bm.lower_face_box(a.face, a.nose, a.lips)
    assert bm.has_beard(rgb("man-short"), np.zeros_like(a.face), box) is None
    with pytest.raises(ValueError):
        bm.has_beard(rgb("man-short"), np.zeros((4, 4), bool), box)


def test_lower_box_starts_at_the_bottom_of_the_nose():
    a, _ = parse("man-short")
    x0, y0, x1, y1 = bm.lower_face_box(a.face, a.nose, a.lips)
    box = hm.face_box(a.face)
    assert (x0, x1, y1) == (box[0], box[2], box[3])
    assert abs(y0 - np.nonzero(a.nose)[0].max()) <= 2


def test_lower_box_falls_back_without_a_parsed_nose():
    a, _ = parse("no-ears-no-nose")
    _, y0, _, _ = bm.lower_face_box(a.face, a.nose, a.lips)
    assert y0 < bm._span(a.lips)[1]
    _, fy0, _, fy1 = hm.face_box(a.face)
    _, y0_no_lips, _, _ = bm.lower_face_box(a.face, a.nose, np.zeros_like(a.lips))
    assert y0_no_lips == fy0 + round(0.6 * (fy1 - fy0 + 1))
    assert bm.lower_face_box(np.zeros_like(a.face), a.nose, a.lips) is None


def test_refusals():
    with pytest.raises(hm.HairMaskError) as e:
        bm.build_mask(parse("no-face")[0], region("goatee"))
    assert e.value.code == hm.NO_FACE
    with pytest.raises(hm.HairMaskError) as e:
        bm.build_mask(parse("tiny-face")[0], region("goatee"))
    assert e.value.code == hm.FACE_TOO_SMALL
    with pytest.raises(hm.HairMaskError) as e:
        bm.build_mask(parse("mouth-covered")[0], region("goatee"))
    assert e.value.code == bm.MOUTH_NOT_VISIBLE


def test_shaving_is_refused_only_on_a_clear_negative():
    a, _ = parse("man-short")
    with pytest.raises(hm.HairMaskError) as e:
        bm.build_mask(a, region("clean-shaven"), "shave", has_beard=False)
    assert e.value.code == bm.NO_BEARD_TO_SHAVE
    # Unclear or positive: render, a pointless shave beats refusing a real beard.
    assert bm.build_mask(a, region("clean-shaven"), "shave", has_beard=None).mask.any()
    assert bm.build_mask(a, region("clean-shaven"), "shave", has_beard=True).mask.any()
    # Only the shave refuses: a beard on a smooth face is the point.
    assert bm.build_mask(a, region("full-beard"), has_beard=False).mask.any()


def test_hair_above_the_temples_stays_and_sideburns_may_enter_it():
    a, _ = parse("woman-long")  # hair falls beside the face
    res = bm.build_mask(a, region("full-beard"))
    grown_in = res.mask & a.hair
    assert grown_in.any()  # the allowance at the edge
    core = a.hair & ~hm.dilate(~a.hair, round(bm.HAIR_ALLOWANCE_FH * (hm.face_box(a.face)[3] - hm.face_box(a.face)[1] + 1)) + 2)
    assert not (res.mask & core).any()


def test_sideburns_reach_a_visible_ear():
    a = gf.analysis_from_parse(*gf.draw(512, 640, hair="none"))  # hair would clip the sides
    mid = a.ears.shape[1] // 2
    left, right = a.ears.copy(), a.ears.copy()
    left[:, mid:] = False
    right[:, :mid] = False
    a.ears = np.roll(left, -20, axis=1) | np.roll(right, 20, axis=1)  # wider than the side margin
    bare = gf.analysis_from_parse(*gf.draw(512, 640, hair="none", ears=False))
    with_ears = np.nonzero(bm.build_mask(a, bm.BeardRegion("full")).mask.any(axis=0))[0]
    without = np.nonzero(bm.build_mask(bare, bm.BeardRegion("full")).mask.any(axis=0))[0]
    assert with_ears.min() < without.min() and with_ears.max() > without.max()
    assert not (bm.build_mask(a, bm.BeardRegion("full")).mask & a.ears).any()  # ends at the ear


def test_prepare_returns_mask_colour_and_verdict():
    a, _ = parse("man-bearded")
    masks = {prefix: hm.to_png(getattr(a, f)) for prefix, f in hm.ANALYSE_OUTPUTS.items()}
    image = (MASKS / "man-bearded" / "photo.png").read_bytes()
    png, colour, beard = bm.prepare(image, masks, region("goatee"))
    assert beard is True and colour == "brown"
    # The goatee grew to full, because prepare read the beard off the photo.
    assert (hm.decode_mask(png) == bm.build_mask(a, region("goatee"), has_beard=True).mask).all()


def test_prepare_skips_the_photo_when_it_cannot_read_it():
    a, _ = parse("man-short")
    masks = {prefix: hm.to_png(getattr(a, f)) for prefix, f in hm.ANALYSE_OUTPUTS.items()}
    png, colour, beard = bm.prepare(b"not an image", masks, region("goatee"))
    assert colour is None and beard is None
    assert (hm.decode_mask(png) == bm.build_mask(a, region("goatee")).mask).all()


def test_prepare_shave_refuses_a_smooth_face_read_off_the_photo():
    a, _ = parse("man-short")
    masks = {prefix: hm.to_png(getattr(a, f)) for prefix, f in hm.ANALYSE_OUTPUTS.items()}
    with pytest.raises(hm.HairMaskError) as e:
        bm.prepare((MASKS / "man-short" / "photo.png").read_bytes(), masks, region("clean-shaven"), "shave")
    assert e.value.code == bm.NO_BEARD_TO_SHAVE


def test_large_photo_returns_full_size():
    a, _ = parse("large-portrait")
    res = bm.build_mask(a, region("full-beard"))
    assert res.mask.shape == a.face.shape
    assert not (res.mask & a.lips).any()


def test_region_validation():
    with pytest.raises(ValueError):
        bm.BeardRegion("sideburns")


def test_candidates_are_well_formed():
    cands = json.loads(CANDIDATES.read_text())
    assert len(cands) == 21 and len({c["id"] for c in cands}) == 21
    for c in cands:
        assert c["section"] in ("Shave", "Stubble", "Short", "Full", "Goatee", "Moustache"), c["id"]
        assert c["cs"].strip() and c["label"].strip(), c["id"]
        assert bool(c["block"]) == (c["id"] != "clean-shaven"), c["id"]
        bm.BeardRegion(**c["region"])
    assert beards()["clean-shaven"]["region"] == {"kind": "full", "below_chin": 0.1}


def test_analysis_masks_come_from_the_graph():
    """The prefixes the bot waits for and the graph that saves them must agree."""
    graph = json.loads((gf.TGBOT.parent / "assets" / "comfyui" / "hair_analyse.api.json").read_text())
    saved = {n["inputs"]["filename_prefix"] for n in graph.values() if n["class_type"] == "SaveImage"}
    assert set(hm.ANALYSE_OUTPUTS) <= saved
    wanted = {"30": {"Upper-lip", "Lower-lip", "Mouth"}, "33": {"Nose"}, "36": {"Left-ear", "Right-ear"}}
    for node, classes in wanted.items():
        inputs = graph[node]["inputs"]
        assert graph[node]["class_type"] == "FaceSegment"
        assert {k for k, v in inputs.items() if v is True} == classes
