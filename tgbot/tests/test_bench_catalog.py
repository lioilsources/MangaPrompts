"""The bench must build the prompts the app builds, or it measures something
that never ships. The Dart side pins the same strings (test/hairstyles_test.dart)."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "tools" / "bench"))

import catalog  # noqa: E402


def test_hair_prompt_matches_the_app():
    pixie = {"id": "pixie", "block": "pixie cut, very short cropped women's haircut",
             "shape": {"length": "short", "bangs": "none", "updo": False}}
    assert catalog.hair_prompt(pixie, None).replace("natural hair,", "__HAIRCOLOR__ hair,") == (
        "a photo of the same person with a pixie cut, very short cropped women's "
        "haircut, short hair ending above the jaw with the neck clear of hair, "
        "__HAIRCOLOR__ hair, natural hair texture, realistic strands, same "
        "clothes, same lighting and background, photorealistic"
    )
    assert catalog.HAIR_NEGATIVE.startswith("hat, cap, helmet")
    half = {"id": "half-up", "block": "x", "shape": {"length": "keep", "bangs": "none", "updo": True}}
    assert catalog.hair_length_clause(half) == ""


def test_restyle_catalog_is_read_from_the_dart_source():
    cat = catalog.restyle_catalog()
    assert cat["heads"]["photo"].startswith("a photorealistic photograph of a person")
    assert "bad anatomy" in cat["negatives"]["illustration"]
    painters = {k for k, v in cat["styles"].items() if v.get("group") == "kRestyleGroupPainters"}
    assert painters == set(catalog.painter_candidates())
    prompt, _ = catalog.restyle_prompt("vangogh-arles", "photo")
    assert prompt.startswith(cat["heads"]["photo"] + ", portrait painting by Vincent van Gogh")


def test_hairstyle_candidates_are_well_formed():
    cands = catalog.hairstyles()
    assert len(cands) >= 50
    for c in cands.values():
        assert c["group"] in ("Women", "Men")
        assert c["shape"]["length"] in ("keep", "short", "medium", "long")
        assert "__HAIRCOLOR__" not in c["block"]
