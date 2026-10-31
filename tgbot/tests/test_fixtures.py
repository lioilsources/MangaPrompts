"""The committed fixtures are what the code builds today: change a constant in
hairmask/beardmask and this fails until gen_fixtures.py is rerun, which is also
what puts the change in front of the Dart mirror."""

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "tools"))

import gen_fixtures as gf  # noqa: E402

FIXTURES = Path(__file__).resolve().parent / "fixtures"


def test_fixtures_are_current(tmp_path):
    gf.generate(tmp_path)
    assert json.loads((tmp_path / "prompts.json").read_text()) == json.loads((FIXTURES / "prompts.json").read_text())
    fresh = json.loads((tmp_path / "masks" / "cases.json").read_text())
    assert fresh == json.loads((FIXTURES / "masks" / "cases.json").read_text())
    names = sorted(p.relative_to(tmp_path / "masks") for p in (tmp_path / "masks").rglob("*.png"))
    assert names == sorted(p.relative_to(FIXTURES / "masks") for p in (FIXTURES / "masks").rglob("*.png"))
    for name in names:
        a = np.asarray(Image.open(tmp_path / "masks" / name))
        b = np.asarray(Image.open(FIXTURES / "masks" / name))
        assert (a == b).all(), name


def test_parse_maps_are_indexed_and_stay_in_range():
    for case in (FIXTURES / "masks").iterdir():
        if not case.is_dir():
            continue
        im = Image.open(case / "parse.png")
        assert im.mode == "P"
        assert np.asarray(im).max() < len(gf.FACE_CLASSES)
        if (case / "clothes.png").exists():
            assert np.asarray(Image.open(case / "clothes.png")).max() < len(gf.CLOTHES_CLASSES)


def test_hat_comes_from_the_clothes_parser_like_in_the_graph():
    face = np.full((4, 4), gf.F["hat"], np.uint8)
    assert not gf.analysis_from_parse(face).hat.any()
    clothes = np.full((4, 4), gf.C["hat"], np.uint8)
    assert gf.analysis_from_parse(face, clothes).hat.all()


def test_hair_is_the_union_of_both_parsers():
    face = np.zeros((2, 2), np.uint8)
    face[0, 0] = gf.F["hair"]
    clothes = np.zeros((2, 2), np.uint8)
    clothes[1, 1] = gf.C["hair"]
    a = gf.analysis_from_parse(face, clothes)
    assert a.hair[0, 0] and a.hair[1, 1] and a.hair.sum() == 2


def test_face_and_features_match_the_graph_nodes():
    graph = json.loads((gf.TGBOT.parent / "assets" / "comfyui" / "hair_analyse.api.json").read_text())
    names = {"Skin": "skin", "Nose": "nose", "Left-eye": "l_eye", "Right-eye": "r_eye", "Left-eyebrow": "l_brow",
             "Right-eyebrow": "r_brow", "Mouth": "mouth", "Upper-lip": "u_lip", "Lower-lip": "l_lip",
             "Eyeglasses": "eyeglasses"}

    def classes(node):
        return {gf.F[names[k]] for k, v in graph[node]["inputs"].items() if v is True}

    assert classes("5") == set(gf.FACE_IDS)
    assert classes("11") == set(gf.FEATURE_IDS)
