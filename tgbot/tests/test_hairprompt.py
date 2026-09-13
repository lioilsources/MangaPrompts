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
