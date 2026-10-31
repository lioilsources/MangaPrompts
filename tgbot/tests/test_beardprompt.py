"""Beard prompts. The Dart mirror reads the same strings from fixtures/prompts.json."""

import json
from pathlib import Path

import beardprompt as bp

PROMPTS = Path(__file__).resolve().parent / "fixtures" / "prompts.json"
KEEP = "Keep the face, eyes, nose, lips, expression, skin tone, hair, clothes, lighting and background exactly the same."


def test_shave_ignores_block_and_colour():
    assert bp.prompt("anything", bp.CLEAN, "black") == (
        "Shave off the beard and moustache completely so the man is clean-shaven with smooth bare skin. " + KEEP
    )


def test_beard_takes_the_hair_colour():
    assert bp.prompt("goatee", "goatee", "dark brown") == (
        "Give the man a goatee, dark brown, matching his hair, with realistic individual hairs "
        "and natural density. " + KEEP
    )


def test_no_hair_on_the_photo_means_natural():
    assert ", natural, matching his hair" in bp.prompt("goatee", "goatee", None)


def test_grey_overrides_the_colour():
    p = bp.prompt("goatee", "goatee", "blonde", grey=True)
    assert "salt-and-pepper grey" in p and "blonde" not in p


def test_every_prompt_keeps_the_lips_and_the_hair():
    for colour in ("brown", None):
        for sid in (bp.CLEAN, "goatee"):
            assert bp.prompt("goatee", sid, colour).endswith(KEEP)


def test_fixture_is_current():
    fixtures = json.loads(PROMPTS.read_text())["beard"]
    assert len(fixtures) == 21 * 3
    for f in fixtures:
        assert bp.prompt(f["block"], f["style_id"], f["colour"], f["grey"]) == f["expected"]
