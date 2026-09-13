"""The bench must build the prompts the app builds, or it measures something
that never ships. The Dart side pins the same strings (test/hairstyles_test.dart)."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "tools" / "bench"))

import catalog  # noqa: E402


def test_bench_hair_prompt_is_the_bots():
    import hairprompt

    pixie = {"id": "pixie", "block": "pixie cut", "shape": {"length": "short", "bangs": "none", "updo": False}}
    for engine in hairprompt.ENGINES:
        assert catalog.hair_prompt(pixie, "brown", engine) == hairprompt.prompt(
            "pixie cut", "pixie", pixie["shape"], "brown", engine)


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
