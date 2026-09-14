import pytest

import hairprompt as hp

SHORT = {"length": "short", "bangs": "none", "updo": False}


def test_description_engines_pin_the_sentence():
    text = hp.prompt("pixie cut, very short cropped women's haircut", "pixie", SHORT, "brown", "flux")
    assert text == (
        "a photo of the same person with a pixie cut, very short cropped women's haircut, "
        "short hair ending above the jaw with the neck clear of hair, brown hair, natural hair "
        "texture, realistic strands, same clothes, same lighting and background, photorealistic"
    )
    assert hp.prompt("pixie cut", "pixie", SHORT, "brown", "sdxl") == hp.prompt(
        "pixie cut", "pixie", SHORT, "brown", "flux")


def test_kontext_gets_an_instruction():
    text = hp.prompt("wolf cut", "wolf-cut", {"length": "medium", "bangs": "wispy", "updo": False}, None, "kontext")
    assert text.startswith("Change the person's hairstyle to a wolf cut. Hair ending between the chin")
    assert "Keep the natural hair colour." in text
    assert text.endswith("exactly the same.")


def test_length_clause_follows_shape():
    assert hp.length_clause("bun", {"length": "keep", "updo": True}).startswith("all hair gathered up")
    assert hp.length_clause("half-up", {"length": "keep", "updo": True}) == ""
    assert hp.length_clause("waves", {"length": "keep", "updo": False}) == ""
    no_clause = hp.prompt("beach waves", "beach-waves", {"length": "keep", "updo": False}, "blonde", "flux")
    assert "beach waves, blonde hair" in no_clause


def test_unknown_engine():
    with pytest.raises(ValueError):
        hp.prompt("x", "x", SHORT, None, "dalle")


def test_new_colour_replaces_the_read_one():
    import haircolours as hc

    fill = hp.prompt("bob cut", "bob", {"length": "medium", "updo": False}, "brown", "sdxl", new_colour="jet-black")
    assert "glossy jet black hair" in fill and "brown" not in fill
    kontext = hp.prompt("bob cut", "bob", {"length": "medium", "updo": False}, "brown", "kontext", new_colour="auburn")
    assert "Dye the hair deep auburn." in kontext and "Keep the brown" not in kontext
    keep = hp.prompt(hc.KEEP_CUT_BLOCK, hc.KEEP_CUT, {"length": "keep"}, "brown", "flux", new_colour="lavender")
    assert keep.startswith("a photo of the same person with the same haircut as in the photo, pastel lavender purple hair")


def test_colour_ranges_accept_their_own_colour():
    import haircolours as hc

    assert hc.matches("jet-black", {"L": 10, "a": 1, "b": 2, "spread": 12})
    assert not hc.matches("jet-black", {"L": 40, "a": 8, "b": 15, "spread": 20})
    assert hc.matches("copper-red", {"L": 45, "a": 30, "b": 35, "spread": 20})
    assert not hc.matches("burgundy", {"L": 35, "a": 20, "b": 30, "spread": 20})  # orange, not wine
    assert hc.matches("honey-balayage", {"L": 40, "a": 8, "b": 20, "spread": 35})
    assert hc.matches("platinum-blonde", None) is None
    for cid, c in hc.COLOURS.items():
        assert c["phrase"] and c["label"] and c["cs"] and c["group"], cid


def test_fashion_colours_by_hue_including_pink_across_zero():
    import haircolours as hc

    lab = lambda L, a, b: {"L": L, "a": a, "b": b, "spread": 30}  # noqa: E731
    assert hc.matches("hot-pink", lab(65, 45, -8))  # hue 350
    assert hc.matches("hot-pink", lab(65, 45, 7))  # hue 9
    assert not hc.matches("hot-pink", lab(35, 28, 26))  # copper
    assert hc.matches("violet", lab(56, 27, -28))  # round 1 "lavender" on Kontext
    assert hc.matches("electric-blue", lab(45, 10, -60))
    assert not hc.matches("electric-blue", lab(9, 7, -24))  # blue-black
    assert hc.matches("fox-red", lab(50, 40, 60))
    assert not hc.matches("fox-red", lab(14, 30, 12))  # burgundy
    assert hc.matches("teal", lab(50, -30, -9))
    # round 1: vivid copper on Kontext read L 27.7 and failed the old L ≥ 28
    assert hc.matches("copper-red", lab(27.7, 39.4, 36.5))
