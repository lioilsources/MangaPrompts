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
    assert cat["heads"]["photo"].startswith("a photorealistic photograph of a fully clothed person")
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
        sh = c["shape"]
        assert sh["length"] in ("keep", "short", "medium", "long")
        # `keep` = no envelope, the mask is the old hair's silhouette. Right for
        # a fringe or an updo, wrong for waves or braids on a tied-back source:
        # the new hair had no room and came back as a clipped bob.
        assert sh["length"] != "keep" or sh["bangs"] != "none" or sh["updo"], c["id"]
        assert "__HAIRCOLOR__" not in c["block"]


def test_an_entry_ships_as_soon_as_one_engine_accepts_it():
    """The gate is per engine, not an intersection.

    Demanding every engine threw away 20 measured, passing entries (most of
    the everyday haircuts), because the two disagree in both directions —
    Kontext knows platinum blonde, SDXL keeps a lob recognisable. An entry
    ships as soon as one accepts it and carries which; the app runs it there.
    """
    import export_catalog as ex

    v = {
        "both": {"verdict": "accept"},
        "kontext-only": {"verdict": {"kontext": "accept", "sdxl": "reject"}},
        "sdxl-only": {"verdict": {"kontext": "reject", "sdxl": "accept"}},
        "colour:platinum-blonde": {"verdict": {"kontext": "accept", "sdxl": "reject"}},
        "no": {"verdict": "reject"},
    }
    both = ["kontext", "sdxl"]
    # A flat "accept" predates per-engine verdicts: it means every engine asked.
    assert ex.engines_of(v, "both", both) == both
    assert ex.engines_of(v, "kontext-only", both) == ["kontext"]
    assert ex.engines_of(v, "sdxl-only", both) == ["sdxl"]
    assert ex.engines_of(v, "sdxl-only", ["kontext"]) == []
    assert ex.engines_of(v, "no", both) == [] and ex.engines_of(v, "missing", both) == []
    # …and the order is the caller's, so the app's preferred engine stays first.
    assert ex.engines_of(v, "both", ["sdxl", "kontext"]) == ["sdxl", "kontext"]

    assert ex.accepted(v, "kontext-only", both)
    assert not ex.accepted(v, "sdxl-only", ["kontext"])
    assert [(c, es) for c, _, es in ex.accepted_colours(v, both)] == [
        ("platinum-blonde", ["kontext"])
    ]
    assert ex.accepted_colours(v, ["sdxl"]) == []
