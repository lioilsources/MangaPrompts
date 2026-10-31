"""Bench tasks `beard`, `pipeline`, `live`: planning, metrics, gates, exports and
the `/api/render` contract. No GPU, no insightface, no ComfyUI: what needs them
is behind lazy imports and runs only on the box."""

import argparse
import importlib.util
import io
import json
import sys
import types
from pathlib import Path

import numpy as np
import pytest
from PIL import Image

BENCH = Path(__file__).resolve().parent.parent / "tools" / "bench"
sys.path[:0] = [str(BENCH.parent), str(BENCH)]

import beardbench as bb  # noqa: E402
import beardmask as bm  # noqa: E402
import catalog  # noqa: E402
import export_catalog as ex  # noqa: E402
import gen_fixtures as gf  # noqa: E402
import hairmask as hm  # noqa: E402
import livebench as lb  # noqa: E402
import pipeline as pl  # noqa: E402
import run  # noqa: E402
import score  # noqa: E402
import sheet  # noqa: E402
from test_render_api import HEADERS, env  # noqa: E402, F401

MASKS = Path(__file__).resolve().parent / "fixtures" / "masks"
FACEBENCH = Path("/Volumes/YOTTA/Dev/Ol1nLLM/tools/facebench/vidbench.py")


def args_for(task, argv, *extra):
    ap = run.task_parser(task, engines="kontext")
    for flag in extra:
        ap.add_argument(flag)
    return ap.parse_args(argv)


# ── run.py registration ─────────────────────────────────────────────────────


def test_task_tables_name_the_same_tasks():
    assert set(run.CELL_PLANNERS) == set(run.SUBCOMMANDS) == set(score.TASK_SCORERS) == set(score.TASK_SUMMARIES)
    assert set(sheet.TASK_MODULES) == set(run.SUBCOMMANDS)
    assert (catalog.ASSETS / run.WORKFLOWS[("beard", "kontext")]).exists()


def test_sources_list_keeps_the_first_of_an_id():
    specs = {s["id"]: s for s in run.src_specs()}
    for sid in ("m-beard-full", "m-stubble", "m-goatee", "m-glasses", "w-selfie-close", "w-sunglasses"):
        assert specs[sid]["prompt"] and isinstance(specs[sid]["seed"], int)
    assert len({s["seed"] for s in specs.values()}) == len(specs)  # a seed names a face
    assert specs["w-long"]["seed"] == 101


def test_srcgen_plan_renders_nothing(tmp_path, capsys):
    run.srcgen(argparse.Namespace(out=str(tmp_path), plan=True, url="http://nowhere"))
    assert "render m-beard-full" in capsys.readouterr().out


def test_dry_run_needs_no_source_on_disk(tmp_path, capsys):
    args = args_for("beard", ["--out", str(tmp_path / "o"), "--srcs", "srcs/not-here.png", "--styles", "goatee",
                              "--dry-run"])
    run.run_matrix(args)
    assert "1 cells, 0 already finished, 1 to render" in capsys.readouterr().out


# ── beard ───────────────────────────────────────────────────────────────────


def test_beard_candidates_build_a_region_and_the_bots_prompt():
    import beardprompt

    cands = catalog.beards()
    assert len(cands) == 21
    for style in cands.values():
        assert isinstance(bb.region_of(style, {}), bm.BeardRegion)
        assert style["section"] in bb.SECTIONS
        assert catalog.beard_prompt(style, "brown") == beardprompt.prompt(style["block"], style["id"], "brown")
    assert bb.mode_of(cands["clean-shaven"]) == "shave" and bb.mode_of(cands["goatee"]) is None


def test_beard_plan_is_styles_times_portraits_times_seeds():
    args = args_for("beard", ["--out", "o", "--srcs", "a.png,b.png", "--styles", "goatee,chevron", "--seeds", "1,2"])
    assert len(run.plan_cells(args)) == 8
    args = args_for("beard", ["--out", "o", "--srcs", "a.png", "--styles", "all"])
    assert len(run.plan_cells(args)) == 21


@pytest.mark.parametrize("argv", [
    ["--styles", "nope"],
    ["--engines", "sdxl"],
    ["--styles", "goatee", "--sweep", "mask.NO_SUCH=1|2"],
])
def test_beard_plan_refuses_a_typo(argv):
    with pytest.raises(SystemExit):
        run.plan_cells(args_for("beard", ["--out", "o", "--srcs", "a.png", *argv]))


def test_beard_sweep_keys_change_the_mask_and_leave_nothing_behind():
    side = bm.FULL_SIDE_FW
    with bb.tunables({"mask.SIDE_fw": 0.2, "mask.CORNER_FW": 0.1, "mask.FEATHER_BLUR": 0.5, "10.guidance": 3}):
        assert bm.FULL_SIDE_FW == bm.JAW_SIDE_FW == 0.2 and bm.CORNER_FW == 0.1 and hm.FEATHER_BLUR == 0.5
    assert bm.FULL_SIDE_FW == side and hm.FEATHER_BLUR != 0.5
    style = catalog.beards()["full-beard"]
    assert bb.region_of(style, {"mask.BELOW_CHIN_full": 0.3}).below_chin == 0.3
    # a glasses size key next to it: the other module's namespace is not touched
    assert bb.region_of(catalog.beards()["goatee"], {"mask.BELOW_CHIN_full": 0.3}).below_chin == 0.1


def fixture_case():
    folder = MASKS / "man-short"
    face = np.asarray(Image.open(folder / "parse.png"))
    clothes = np.asarray(Image.open(folder / "clothes.png")) if (folder / "clothes.png").exists() else None
    return gf.analysis_from_parse(face, clothes), (folder / "photo.png").read_bytes()


class FakeBenchComfy:
    def __init__(self):
        self.uploads = {}

    def upload(self, data, name):
        self.uploads[name] = data
        return name


def build_cell(tmp_path, monkeypatch, style_id):
    analysis, photo = fixture_case()
    monkeypatch.setattr(bb, "full_analysis", lambda *a, **k: analysis)
    src = tmp_path / "s.png"
    src.write_bytes(photo)
    template = json.loads((catalog.ASSETS / "flux_hair_kontext.api.json").read_text())
    ctx = bb.CellContext(FakeBenchComfy(), tmp_path, tmp_path, "c.png", src, "up.png", template)
    row = {}
    return bb.build(ctx, {"style": style_id, "sweep": {}}, row), row, ctx


def test_beard_cell_sends_the_bots_mask_and_prompt(tmp_path, monkeypatch):
    wf, row, _ = build_cell(tmp_path, monkeypatch, "goatee")
    analysis, photo = fixture_case()
    mask_png, colour, _ = bm.prepare(photo, {p: hm.to_png(getattr(analysis, f)) for p, f in hm.ANALYSE_OUTPUTS.items()},
                                     bm.BeardRegion(**catalog.beards()["goatee"]["region"]))
    assert (tmp_path / "masks" / "c.png").read_bytes() == mask_png
    assert wf["8"]["inputs"]["text"] == row["prompt"] == catalog.beard_prompt(catalog.beards()["goatee"], colour)
    assert wf["4"]["inputs"]["image"] == "up.png"
    assert wf["15"]["inputs"]["image"].startswith("bench_mask_")
    assert wf["17"]["inputs"]["expand"] == hm.feather_px(*Image.open(io.BytesIO(photo)).size)[0]


def test_a_refused_photo_leaves_the_row_refused(tmp_path, monkeypatch):
    monkeypatch.setattr(bm, "detect_beard", lambda *a: False)
    with pytest.raises(hm.HairMaskError) as e:
        build_cell(tmp_path, monkeypatch, "clean-shaven")
    assert e.value.code == bm.NO_BEARD_TO_SHAVE


def test_beard_ok_is_top_label_plus_gain():
    i = bb.SECTIONS.index("Full")
    p = lambda t, v: np.array([v if k == t else (1 - v) / 5 for k in range(6)])  # noqa: E731
    assert bb.beard_ok(p(i, 0.6), p(0, 0.6), "Full")
    assert not bb.beard_ok(p(0, 0.6), p(0, 0.6), "Full")
    assert not bb.beard_ok(np.array([.34, 0, 0, .36, .3, 0]), np.array([.3, 0, 0, .3, .4, 0]), "Full")
    # the source already shows it: there is no gain to be had
    assert bb.beard_ok(p(i, 0.6), p(i, 0.7), "Full")
    assert bb.beard_ok(p(0, 0.6), p(0, 0.9), "Shave")


def test_outside_and_lips_measure_what_they_say():
    src = np.full((100, 100, 3), 100, np.uint8)
    out = src.copy()
    mask = np.zeros((100, 100), bool)
    mask[30:60] = True
    out[35:55] = 200
    assert bb.outside_diff(out, src, mask, 2) == 0.0
    out[80:] = 200
    assert bb.outside_diff(out, src, mask, 2) > 1
    lips = np.zeros((100, 100), bool)
    lips[40:42] = True
    assert bb.mean_diff(out, src, lips) == 100
    assert bb.mean_diff(out[:50], src, lips) is None
    assert bb.crop_box((10, 10, 19, 19), (100, 100, 3)) == (8, 8, 21, 21)


def test_shaved_cheeks_reads_the_cheeks_not_the_style():
    a, photo = fixture_case()
    rgb = np.array(Image.open(io.BytesIO(photo)).convert("RGB"))
    box = bm.lower_face_box(a.face, a.nose, a.lips)
    x0, y0, x1, y1 = box
    narrow = np.zeros_like(a.face)
    narrow[y0:, x0 + (x1 - x0) // 3 : x1 - (x1 - x0) // 3] = True
    rgb[y0:y1 + 1, x0 + (x1 - x0) // 3 : x1 - (x1 - x0) // 3] = 10  # a dark goatee: not a cheek
    assert bb.shaved_cheeks(rgb, a, narrow) is True
    rgb[y0:y1 + 1, x0:x1] = 10  # dark everywhere: the old beard is still there
    assert bb.shaved_cheeks(rgb, a, narrow) is False


def good_cell(**over):
    return {"status": "done", "identity": 0.7, "beard_ok": True, "lips_ok": True, "outside_ok": True,
            "clean": True, **over}


def test_beard_gate_is_per_portrait():
    s, reasons = bb.gate({"a": [good_cell()], "b": [good_cell()], "c": [good_cell(identity=0.4)]})
    assert s == {"srcs_passed": 2, "srcs": 3} and reasons == []
    _, reasons = bb.gate({"a": [good_cell(identity=0.4)], "b": [good_cell(lips_ok=False)], "c": [good_cell()]})
    assert reasons == ["a: identity 0.40", "b: lips"]
    assert bb.gate({"a": [good_cell(identity=None)]})[1] == ["a: face lost"]
    assert bb.gate({"a": [good_cell(shaved_cheeks=False)]})[1] == ["a: shaved_cheeks 0%"]
    assert bb.gate({"a": [good_cell(shaved_cheeks=None)]})[1] == []
    assert bb.gate({"a": [good_cell(beard_ok=False), good_cell(), good_cell()]})[1] == []
    assert bb.gate({"a": [{"status": "error"}]})[1] == ["a: nothing rendered"]
    assert bb.gate({})[1] == ["no portraits"]


def test_beard_summary_leaves_refused_portraits_out():
    manifest = {"cells": {
        "1": {"style": "clean-shaven", "engine": "kontext", "sweep": {}, "src": "m-short.png", "status": "refused"},
        "2": {"style": "clean-shaven", "engine": "kontext", "sweep": {}, "src": "m-beard-full.png", "status": "done"},
    }}
    s = bb.summarise(manifest, {"1": {"status": "refused"}, "2": good_cell(scored_file="x")})
    entry = s["clean-shaven|kontext||{}"]
    assert entry["auto"] == "pass" and entry["refused"] == 1 and entry["srcs"] == 1


def test_beard_export_fits_the_dart_classes():
    lines = "\n".join(ex.beard_lines([catalog.beards()["van-dyke"], catalog.beards()["clean-shaven"]]))
    assert "BeardRegion(BeardRegionKind.chin, belowChin: 0.15, moustache: true)" in lines
    assert "BeardRegion(BeardRegionKind.full, belowChin: 0.1)" in lines
    assert "cs: 'hladce oholený'" in lines and "block:\n        ''," in lines
    assert "BeardRegion(BeardRegionKind.moustache)" in "\n".join(ex.beard_lines([catalog.beards()["chevron"]]))
    assert "chinSides: true" in "\n".join(ex.beard_lines([catalog.beards()["horseshoe"]]))
    empty = "\n".join(ex.beard_lines([]))
    assert "const kBeards = <Beard>[" in empty and empty.endswith("];")


def test_beard_previews_come_from_the_men_primary_portrait():
    cells = {
        "1": {"style": "goatee", "engine": "kontext", "status": "done", "src": "m-beard-full.png"},
        "2": {"style": "goatee", "engine": "kontext", "status": "done", "src": "m-short.png"},
    }
    style = {**catalog.beards()["goatee"], "group": "Men"}
    assert ex.preview_cell((cells, {"1": {"identity": 0.9}}), style, ["kontext"])["src"] == "m-short.png"


# ── pipeline ────────────────────────────────────────────────────────────────


def pipeline_args(*argv):
    ap = run.task_parser("pipeline", engines="flux")
    ap.add_argument("--api", default="http://x")
    ap.add_argument("--looks", default=str(BENCH / "candidates" / "looks.json"))
    ap.add_argument("--look-ids")
    ap.add_argument("--order", nargs="*")
    return ap.parse_args(["--out", "o", "--srcs", "m.png", "--styles", "ukiyoe,anime", *argv])


def test_looks_name_real_candidates():
    looks = pl.load_looks(BENCH / "candidates" / "looks.json")
    hair, beards = catalog.hairstyles(), catalog.beards()
    assert looks["none"] == {"id": "none"}
    for look in looks.values():
        assert "beard" not in look or look["beard"]["style"] in beards
        assert "hair" not in look or look["hair"]["style"] in hair


def test_pipeline_plan_has_the_order_axis_and_a_baseline():
    cells = run.plan_cells(pipeline_args("--look-ids", "goatee-quiff,none", "--order", "beard,glasses,hair",
                                         "hair,glasses,beard", "--engines", "flux,sdxl"))
    two_edits = [c for c in cells if c["look"] == "goatee-quiff"]
    assert len(two_edits) == 2 * 2 * 3  # orders × engines × (baseline + 2 styles)
    assert len([c for c in cells if c["look"] == "none"]) == 2 * 3  # no edits: order means nothing
    assert {c["restyle"] for c in cells} == {catalog.BASELINE, "ukiyoe", "anime"}
    assert len({c["key"] for c in cells}) == len(cells)
    assert len({pl.chain_key(c) for c in cells}) == 3


@pytest.mark.parametrize("argv", [
    ["--look-ids", "nope"],
    ["--engines", "kontext"],  # flux_restyle_kontext.api.json is not in assets
    ["--engines", "gpt"],
    ["--look-ids", "none", "--sweep", "param.nope=1"],
])
def test_pipeline_plan_refuses(argv):
    with pytest.raises(SystemExit):
        run.plan_cells(pipeline_args(*argv))


def test_look_with_glasses_says_why_it_cannot_run_here(monkeypatch):
    monkeypatch.setitem(sys.modules, "glassesmask", None)
    with pytest.raises(SystemExit, match="glasses"):
        run.plan_cells(pipeline_args("--look-ids", "stubble-round-crew"))


def test_axes_the_api_cannot_carry_go_direct():
    cells = run.plan_cells(pipeline_args("--look-ids", "none", "--sweep", "15.weight=0.7|0.9",
                                         "param.lookPosition=middle|end"))
    assert all(pl.is_direct(c) for c in cells)
    assert not any(pl.is_direct(c) for c in run.plan_cells(pipeline_args(
        "--look-ids", "none", "--sweep", "param.lookPosition=middle|end")))
    node = run.plan_cells(pipeline_args("--look-ids", "none", "--sweep", "graph.pulid_from=original|look"))
    assert pl.direct_keys(node[0]["sweep"]) == ["graph.pulid_from"]


def test_jobs_never_exceed_the_servers_step_limit():
    import config

    assert pl.MAX_STEPS == config.RENDER_MAX_STEPS
    cells = [{"engine": "flux", "sweep": {"param.order": "x"}} for _ in range(25)]
    jobs = pl.jobs_for(cells, 3)
    assert [len(j) for j in jobs] == [9, 12, 4]
    assert pl.jobs_for([], 3) == [[]]


def test_look_prompt_matches_the_apps_sentence():
    look = {"beard": {"style": "goatee"}, "hair": {"style": "m-crew"}}
    prompt, negative = pl.style_prompt(
        {"sweep": {"param.order": pl.DEFAULT_ORDER}, "restyle": "ukiyoe", "medium": "photo"}, look, "brown")
    cat = catalog.restyle_catalog()
    beard, hair = catalog.beards()["goatee"]["block"], catalog.hairstyles()["m-crew"]["block"]
    block = cat["styles"]["ukiyoe"]["block"]
    assert prompt == f"{cat['heads']['photo']}, with a {beard}, with a {hair}, brown hair, {block}"
    assert negative == cat["negatives"]["photo"]
    end, _ = pl.style_prompt({"sweep": {"param.order": pl.DEFAULT_ORDER, "param.lookPosition": "end"},
                              "restyle": "ukiyoe", "medium": "photo"}, look, "brown")
    assert end == f"{cat['heads']['photo']}, {block}, with a {beard}, with a {hair}, brown hair"


def test_baseline_prompt_is_the_medium_plus_the_look():
    prompt, _ = catalog.restyle_look_prompt(catalog.BASELINE, "photo", ["with a goatee"])
    assert prompt == catalog.restyle_catalog()["heads"]["photo"] + ", with a goatee"


def test_pulid_from_rewires_only_the_identity_node():
    for name in ("flux_restyle.api.json", "sdxl_restyle.api.json"):
        wf = json.loads((catalog.ASSETS / name).read_text())
        pl.apply_pulid_from(wf, "orig.png")
        node = next(n for n in wf.values() if n["class_type"] in pl.PULID_NODES)
        assert node["inputs"]["image"] == ["200", 0] and wf["200"]["inputs"]["image"] == "orig.png"
        depth = next(n for n in wf.values() if n["class_type"] == "DepthAnythingV2Preprocessor")
        assert depth["inputs"]["image"] != ["200", 0]


def test_edit_steps_are_masked_on_the_original_in_order():
    analysis, photo = fixture_case()
    rgb = bb.rgb_of(photo)
    look = {"beard": {"style": "goatee"}, "hair": {"style": "m-crew"}}
    steps, targets = pl.edit_steps(look, "beard,glasses,hair", analysis, rgb)
    assert [(s["id"], s["input"]) for s in steps] == [("beard", "source"), ("hair", "beard")]
    assert targets["beard"]["section"] == "Goatee" and targets["hair"]["shape"]["length"] == "short"
    reverse, _ = pl.edit_steps(look, "hair,glasses,beard", analysis, rgb)
    assert [(s["id"], s["input"]) for s in reverse] == [("hair", "source"), ("beard", "hair")]
    # same masks whichever order: they are computed on the original
    assert {s["id"]: s["mask"] for s in steps} == {s["id"]: s["mask"] for s in reverse}


def test_carries_vote_only_on_default_axes():
    looks = {"a": {"beard": {}, "hair": {}}, "b": {"beard": {}, "glasses": {}}}
    row = lambda look, order=pl.DEFAULT_ORDER, **sweep: {  # noqa: E731
        "look": look, "engine": "flux", "restyle": "ukiyoe", "sweep": {"param.order": order, **sweep}}
    rows = [
        (row("a"), {"beard_kept": True, "hair_kept": False}),
        (row("a"), {"beard_kept": True, "hair_kept": False}),
        (row("b"), {"beard_kept": False, "glasses_kept": None}),
        (row("a", order="hair,glasses,beard"), {"hair_kept": True}),
        (row("a", **{"15.weight": 0.7}), {"hair_kept": True}),
    ]
    # 2 of 3 is the bar; the sweep and the reverse order did not rescue `hair`
    assert pl.carries(rows, looks) == {"flux": {"ukiyoe": {"hair": False, "glasses": None, "beard": True}}}
    rows.append((row("b"), {"beard_kept": False}))
    assert pl.carries(rows, looks)["flux"]["ukiyoe"]["beard"] is False
    base = {**row("a"), "restyle": catalog.BASELINE}
    assert pl.carries([(base, {"beard_kept": True})], looks) == {}


def test_pipeline_summary_reasons():
    row = {"style": "a/ukiyoe", "engine": "flux", "medium": "photo", "sweep": {"param.order": "x"}, "status": "done"}
    m = {"status": "done", "identity": 0.55, "clean": True, "clothed": True, "reaction": 0.2,
         "beard_kept": True, "hair_kept": None}
    s = pl.summarise({"cells": {"1": row}}, {"1": m})
    assert next(iter(s.values()))["auto"] == "pass"
    s = pl.summarise({"cells": {"1": row}}, {"1": {**m, "identity": 0.4, "reaction": 0.01, "clothed": False, "beard_kept": False}})
    assert next(iter(s.values()))["reasons"] == ["identity 0.40", "beard_kept 0%", "clothed", "style_reaction 0.01"]
    base = {**row, "style": f"a/{catalog.BASELINE}"}
    s = pl.summarise({"cells": {"1": base}}, {"1": {**m, "reaction": None}})
    assert next(iter(s.values()))["auto"] == "pass"


def test_scale_box_follows_the_output_size():
    assert pl.scale_box([10, 20, 30, 40], (100, 100), (200, 50)) == (5, 40, 15, 80)


@pytest.fixture
def api(env):
    """The real /api/render through the FastAPI app, ComfyUI faked."""
    client, comfy, _ = env
    comfy.output_size = (256, 256)
    return client, comfy


class Http:
    """requests.Session's `post`/`get` over the TestClient."""

    def __init__(self, client):
        self.client = client

    def post(self, url, headers=None, json=None):
        return self.client.post(url.removeprefix("http://x"), headers=headers, json=json)

    def get(self, url, headers=None):
        return self.client.get(url.removeprefix("http://x"), headers=headers)


def chain_run(tmp_path, monkeypatch, client, cells, manifest=None):
    analysis, photo = fixture_case()
    monkeypatch.setattr(bb, "full_analysis", lambda *a, **k: analysis)
    src = tmp_path / "m.png"
    src.write_bytes(photo)
    rc = pl.RenderClient("http://x", HEADERS, Http(client), poll=0.01)
    out = tmp_path / "run"
    out.mkdir(exist_ok=True)
    manifest = manifest if manifest is not None else {"cells": {}}
    args = argparse.Namespace(timeout=5, cache=str(tmp_path))
    looks = pl.load_looks(BENCH / "candidates" / "looks.json")
    return pl.ChainRun(args, run, rc, FakeBenchComfy(), out, manifest, cells, looks, src, lambda: None), manifest


def test_chain_goes_through_the_real_contract(api, tmp_path, monkeypatch):
    client, comfy = api
    cells = run.plan_cells(pipeline_args("--look-ids", "goatee-quiff", "--styles", "ukiyoe"))
    chain, manifest = chain_run(tmp_path, monkeypatch, client, cells)
    chain.run()
    assert {c["status"] for c in manifest["cells"].values()} == {"done"}
    assert {c["path"] for c in manifest["cells"].values()} == {"api"}
    assert len(comfy.prompts) == 4  # two edits, baseline, one style
    # each step read the previous output: the contract's DAG, not the source
    edits = manifest["chains"][chain.key]["steps"]
    assert edits["beard"]["status"] == edits["hair"]["status"] == "done"
    hair_prompt = next(p["prompt"] for p in comfy.prompts[1:2])
    assert comfy.input_of(hair_prompt) == (chain.dir / "beard.png").read_bytes()
    style_prompt = comfy.prompts[3]["prompt"]
    assert comfy.input_of(style_prompt) == (chain.dir / "hair.png").read_bytes()
    assert (chain.dir / "beard_mask.png").exists()
    assert all((chain.out / c["file"]).exists() for c in manifest["cells"].values())


def test_a_long_chain_splits_and_keeps_its_edits(api, tmp_path, monkeypatch):
    client, comfy = api
    styles = ",".join(list(catalog.restyle_catalog()["styles"])[:12])
    cells = run.plan_cells(pipeline_args("--look-ids", "goatee-quiff", "--styles", styles))
    chain, manifest = chain_run(tmp_path, monkeypatch, client, cells)
    chain.run()
    assert sum(c["status"] == "done" for c in manifest["cells"].values()) == 13
    assert len(comfy.prompts) == 2 + 13  # the edits ran once
    last = comfy.prompts[-1]["prompt"]
    assert comfy.input_of(last) == (chain.dir / "hair.png").read_bytes()


def test_a_failed_edit_fails_its_styles_and_retries(api, tmp_path, monkeypatch):
    client, comfy = api
    cells = run.plan_cells(pipeline_args("--look-ids", "goatee-quiff", "--styles", "ukiyoe"))
    chain, manifest = chain_run(tmp_path, monkeypatch, client, cells)
    analysis, _ = fixture_case()
    hair_prompt = pl.edit_steps(chain.look, chain.order, analysis, chain.rgb)[0][1]["prompt"]
    comfy.fail_on[hair_prompt] = "boom"
    chain.run()
    assert {c["status"] for c in manifest["cells"].values()} == {"error"}
    assert "skipped" in next(iter(manifest["cells"].values()))["error"]
    comfy.fail_on.clear()
    chain.run()
    assert {c["status"] for c in manifest["cells"].values()} == {"done"}


def test_quota_stops_the_run_instead_of_failing_the_cells(api, tmp_path, monkeypatch):
    client, _ = api
    import app as appmod

    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 0)
    cells = run.plan_cells(pipeline_args("--look-ids", "goatee-quiff", "--styles", "ukiyoe"))
    chain, manifest = chain_run(tmp_path, monkeypatch, client, cells)
    with pytest.raises(pl.QuotaExhausted):
        chain.run()
    assert manifest["cells"] == {}


def test_plan_description_costs_a_plan_without_a_server():
    looks = pl.load_looks(BENCH / "candidates" / "looks.json")
    cells = run.plan_cells(pipeline_args("--look-ids", "goatee-quiff,none", "--engines", "flux,sdxl",
                                         "--order", "beard,glasses,hair", "hair,glasses,beard"))
    d = pl.describe(cells, looks)
    assert d == {"cells": 18, "chains": 3, "render_jobs": 3, "api_generations": 2 * (2 + 6) + 6, "direct_cells": 0}


def test_token_comes_from_the_environment(monkeypatch):
    monkeypatch.delenv("RESTYLER_APP_TOKEN", raising=False)
    monkeypatch.delenv("RESTYLER_DEV_TOKEN", raising=False)
    with pytest.raises(SystemExit):
        pl.RenderClient.from_env("http://x")
    monkeypatch.setenv("RESTYLER_APP_TOKEN", "abc")
    c = pl.RenderClient.from_env("http://x")
    assert c.headers == {"Authorization": "app abc", "X-User": pl.USER}
    import auth

    assert auth.app_user_id(pl.USER) is not None


def test_with_carries_is_idempotent_and_leaves_the_catalog_readable(tmp_path):
    src = ex.RESTYLE_TARGET.read_text()
    carried = {"anime": {"hair": True, "glasses": False, "beard": None}}
    once = ex.with_carries(src, carried)
    assert ex.with_carries(once, carried) == once
    assert "    carries: RestyleCarries(hair: true, glasses: false, beard: null),\n  ),\n  RestyleStyle(" in once
    assert once.count("carries: RestyleCarries(") == 1 and "class RestyleCarries" in once
    assert "this.carries = const RestyleCarries()," in once and "final RestyleCarries carries;" in once
    # a style that left the measurement loses the line, the class stays
    assert ex.with_carries(once, {}).count("carries: RestyleCarries(") == 0
    dart = tmp_path / "restyle_styles.dart"
    dart.write_text(once)
    before = catalog.restyle_catalog()
    original, catalog.RESTYLE_DART = catalog.RESTYLE_DART, dart
    try:
        assert catalog.restyle_catalog() == before
    finally:
        catalog.RESTYLE_DART = original


# ── live ────────────────────────────────────────────────────────────────────


def face(open_eye=1.0, smile=0.0) -> np.ndarray:
    """A 106-point face with only the points the metrics read."""
    lmk = np.zeros((106, 2))
    for left, right, pairs, x in (*[(*lb.LEFT_EYE, 30.0)], *[(*lb.RIGHT_EYE, 70.0)]):
        lmk[left], lmk[right] = (x - 10, 40), (x + 10, 40)
        for i, (a, b) in enumerate(pairs):
            lmk[a], lmk[b] = (x - 5 + 5 * i, 40 - 3 * open_eye), (x - 5 + 5 * i, 40 + 3 * open_eye)
    lmk[lb.MOUTH_LEFT], lmk[lb.MOUTH_RIGHT] = (40 - 5 * smile, 80 - 3 * smile), (60 + 5 * smile, 80 - 3 * smile)
    lmk[lb.MOUTH_TOP], lmk[lb.MOUTH_BOTTOM] = (50, 78), (50, 82)
    return lmk


def test_ear_blink_and_smile_on_landmarks():
    assert lb.ear(face(1.0)) == pytest.approx(0.3)
    assert lb.ear(face(0.2)) == pytest.approx(0.06)
    ears = [0.3] * 10 + [0.05, 0.05, 0.05] + [0.3] * 10 + [0.05, 0.05] + [0.3] * 5
    assert lb.blinks(ears) == 2
    assert lb.blinks([0.3] * 10 + [0.05] + [0.3] * 10) == 0  # one frame is noise
    assert lb.blinks([0.3] * 10 + [0.05] + [0.3] * 10, every=2) == 1  # …unless a frame is two
    assert lb.blinks([0.3, 0.3]) == 0
    assert lb.smile_gain([lb.mouth_shape(face(smile=s)) for s in (0, 0.5, 1, 0.5, 0)]) > 0.15
    assert lb.smile_gain([lb.mouth_shape(face())] * 5) == pytest.approx(0)
    assert lb.smile_gain([]) is None


def test_yaw_loop_and_still():
    assert lb.yaw_range([2, 10, -5, 2]) == (8, -7)
    a = np.zeros((10, 10), np.uint8)
    assert lb.loop_error(a, a + 50) == 0  # a brightness drift is not a jump
    b = a.copy()
    b[:5] = 100
    assert lb.loop_error(a, b) > 4
    keep = np.ones((10, 10), bool)
    moved = a.copy()
    moved[0] = 255
    assert lb.still_error([a, a, a], keep) == 0
    assert lb.still_error([a, moved], keep) == 25.5
    assert lb.still_error([a], keep) is None


@pytest.mark.parametrize("motion,numbers,expected", [
    ("blink", {"blinks": 2, "smile": 0.0, "yaw_max": 1, "yaw_min": -1}, {"blink_ok": True, "smile_ok": True, "look_ok": True}),
    ("blink", {"blinks": 0}, {"blink_ok": False}),
    ("smile", {"blinks": 1, "smile": 0.3}, {"blink_ok": False, "smile_ok": True}),
    ("look-around", {"yaw_max": 8, "yaw_min": -7}, {"look_ok": True}),
    ("look-around", {"yaw_max": 8, "yaw_min": -2}, {"look_ok": False}),
    ("glance", {"yaw_max": 1, "yaw_min": -1, "pupil": 0.1}, {"look_ok": True, "pupil_ok": True}),
    ("glance", {"yaw_max": 1, "yaw_min": -1}, {"look_ok": True, "pupil_ok": None}),  # no MediaPipe: not gated
    ("smile", {"yaw_max": 5, "yaw_min": 0}, {"look_ok": False}),
    ("nod", {"yaw_max": 30, "yaw_min": -30}, {}),
    ("hair-breeze", {"hair_flow": 2.5}, {"hair_ok": True}),
])
def test_preset_expectations(motion, numbers, expected):
    assert lb.verdicts(motion, numbers, False, "live") == expected


def test_engine_changes_the_limits():
    assert lb.verdicts("blink", {"still": 2.0}, False, "live") == {"still_ok": False}
    assert lb.verdicts("blink", {"still": 2.0}, False, "wan") == {"still_ok": True}
    assert lb.verdicts("blink", {"hair_flow": 2.0}, False, "live") == {"hair_ok": False}
    assert lb.verdicts("blink", {"hair_flow": 1.0}, False, "live") == {"hair_ok": True}
    assert lb.verdicts("blink", {"loop": 9}, False, "live") == {}
    assert lb.verdicts("blink", {"loop": 9}, True, "live") == {"loop_ok": False}


def test_every_preset_has_an_expectation_and_a_czech_name():
    motions = catalog.motions()
    assert set(motions) == set(lb.EXPECT) == set(lb.MOTION_CS)


def test_live_plan_runs_each_preset_on_its_engine():
    args = args_for("live", ["--out", "o", "--srcs", "a.png,b.png", "--engines", "live,wan", "--seeds", "1,2", "--styles", "all"])
    cells = run.plan_cells(args)
    live = [c for c in cells if c["engine"] == "live"]
    wan = [c for c in cells if c["engine"] == "wan"]
    assert len(live) == 6 * 2 and {c["seed"] for c in live} == {0}  # the seed changes nothing there
    assert len(wan) == 1 * 2 * 2 and {c["style"] for c in wan} == {"hair-breeze"}
    with pytest.raises(SystemExit):
        run.plan_cells(args_for("live", ["--out", "o", "--srcs", "a.png", "--engines", "sora", "--styles", "all"]))
    drivers = run.plan_cells(args_for("live", ["--out", "o", "--srcs", "a.png", "--engines", "driver", "--styles", "all"]))
    assert {c["style"] for c in drivers} == set(catalog.motions()) - {"hair-breeze"}


def test_missing_drivers_are_named_before_the_gpu():
    cells = run.plan_cells(args_for("live", ["--out", "o", "--srcs", "a.png", "--engines", "live", "--styles", "smile"]))
    assert lb.missing_drivers(cells) == ([] if (lb.DRIVERS / "smile.mp4").exists() else ["smile.mp4"])


def test_live_dry_run_prints_the_plan_and_renders_nothing(tmp_path, capsys):
    args = argparse.Namespace(**vars(args_for("live", ["--out", str(tmp_path / "o"), "--srcs", "a.png", "--engines", "live",
                                                       "--styles", "smile", "--plan"])))
    lb.run(args, run)
    assert "1 cells" in capsys.readouterr().out
    assert not (tmp_path / "o" / "manifest.json").exists()


def test_fit_for_video_is_the_servers():
    import render

    png = io.BytesIO()
    Image.new("RGB", (832, 1216), (9, 9, 9)).save(png, "PNG")
    assert lb.fit_for_video(png.getvalue()) == render.fit_for_video(png.getvalue())
    jpg = io.BytesIO()
    im = Image.new("RGB", (1000, 601), (9, 9, 9))
    exif = Image.Exif()
    exif[lb.EXIF_ORIENTATION] = 6
    im.save(jpg, "JPEG", exif=exif)
    assert lb.fit_for_video(jpg.getvalue()) == render.fit_for_video(jpg.getvalue())
    small = io.BytesIO()
    Image.new("RGB", (64, 96)).save(small, "PNG")
    assert lb.fit_for_video(small.getvalue()) == small.getvalue()


def test_live_variants_land_on_the_graph():
    wf = json.loads((catalog.ASSETS / "live_portrait.api.json").read_text())
    lb.apply_live_variants(wf, {"graph.driving_multiplier": 0.8, "graph.relative_motion": "off",
                                "graph.stitching": "off", "graph.cropper": "mediapipe"})
    assert wf["6"]["inputs"]["delta_multiplier"] == 0.8
    assert wf["6"]["inputs"]["relative_motion_mode"] == "off" and wf["6"]["inputs"]["stitching"] is False
    assert wf["3"]["class_type"] == "LivePortraitLoadMediaPipeCropper"
    lb.set_video_prefix(wf, "bench_x")
    assert wf["8"]["inputs"]["filename_prefix"] == "bench_x"


def test_live_summary_gates_on_identity_and_the_preset():
    row = {"style": "blink", "engine": "live", "sweep": {}, "status": "done"}
    m = {"status": "done", "identity": 0.8, "blink_ok": True, "still_ok": True, "clean": True}
    s = lb.summarise({"cells": {"1": row}}, {"1": m})
    assert s["blink|live||{}"]["auto"] == "pass"
    s = lb.summarise({"cells": {"1": row}}, {"1": {**m, "identity": 0.5, "blink_ok": False, "still_ok": False}})
    assert s["blink|live||{}"]["reasons"] == ["identity 0.50", "blink 0%", "still 0%"]
    s = lb.summarise({"cells": {"1": row}}, {"1": {**m, "identity": None}})
    assert "face lost" in s["blink|live||{}"]["reasons"]


def test_identity_goes_through_vidbench_itself():
    """Real vidbench.py, `bench` stubbed (it imports video-stack's chain): the
    tracks and the p10 gate are its own."""
    if not FACEBENCH.exists():
        pytest.skip("Ol1nLLM not next to this repo")
    stub = types.ModuleType("bench")
    stub.analyser = stub.embedding = None
    stub.sim = lambda a, b: float(a @ b)
    spec = importlib.util.spec_from_file_location("vidbench_under_test", FACEBENCH)
    vb = importlib.util.module_from_spec(spec)
    saved = sys.modules.get("bench")
    sys.modules["bench"] = stub
    try:
        spec.loader.exec_module(vb)
    finally:
        if saved is None:
            del sys.modules["bench"]
        else:
            sys.modules["bench"] = saved

    ref = np.array([1.0, 0.0])
    near = np.array([0.9, np.sqrt(1 - 0.81)])
    def det(emb, ear=0.3, yaw=0.0):
        return {"bbox": (10.0, 10.0, 60.0, 60.0), "emb": emb, "det": 0.9, "yaw": yaw, "size": 50.0, "ear": ear}

    frames = [(i, [det(near)]) for i in range(20)]
    frames[5] = (5, [det(np.array([0.0, 1.0]), ear=0.05)])  # eyes shut: another "face" that must not count
    frames[6] = (6, [det(np.array([0.0, 1.0]), yaw=50.0)])  # past 30°
    track = vb.track(frames)[0]
    rows = lb.identity_rows(track, ref, "blink", vb.sim, vb.MIN_DET, vb.MIN_FACE, 0.3)
    assert sum(r["clean"] for r in rows) == 18
    import tempfile

    with tempfile.TemporaryDirectory() as d:
        path = Path(d) / "f.csv"
        lb.write_frames_csv(path, rows)
        result = vb.summary(str(path), 0.6)
    assert result["persons"]["person"]["p10"] == pytest.approx(0.9) and result["pass"]


def test_scoring_imports_stay_lazy():
    """On a machine without insightface and cv2 these modules still import: that
    is what the three lines at the top of this file just did."""
    assert "insightface" not in sys.modules and "cv2" not in sys.modules


def test_live_export_ships_a_preset_on_its_own_engine():
    manifest = catalog.motions()
    v = {"smile": {"verdict": {"live": "accept"}}, "blink": {"verdict": {"live": "reject"}},
         "glance": {"verdict": {"driver": "accept"}}, "hair-breeze": {"verdict": {"wan": "accept"}}}
    got = ex.accepted_motions(v, manifest, lb.MOTION_CS)
    assert [m for m, _, _ in got] == ["smile", "hair-breeze"]
    lines = "\n".join(ex.motion_lines(got))
    assert "engine: MotionEngine.wan," in lines and "seconds: 3.0," in lines and "loop: true," in lines
    assert "cs: 'úsměv'," in lines
    assert "<Motion>[" in "\n".join(ex.motion_lines([]))


def test_sheet_shows_the_new_tasks(tmp_path):
    run_dir = tmp_path / "r"
    (run_dir / "srcs").mkdir(parents=True)
    (run_dir / "img").mkdir()
    (run_dir / "frames" / "x").mkdir(parents=True)
    img = Image.new("RGB", (64, 96), (100, 100, 100))
    img.save(run_dir / "srcs" / "m.png")
    img.save(run_dir / "img" / "c.png")
    for i in range(4):
        img.save(run_dir / "frames" / "x" / f"{i:04d}.jpg")
    beard_row = {"style": "goatee", "engine": "kontext", "src": "m.png", "seed": 1, "sweep": {}, "status": "done", "file": "img/c.png"}
    live_row = {"style": "blink", "engine": "live", "src": "m.png", "seed": 0, "sweep": {}, "status": "done",
                "file": "frames/x/0000.jpg", "video": "clips/x.mp4", "frames": "frames/x"}
    for task, row, m, needle in (
        ("beard", beard_row, {"status": "done", "identity": 0.7, "beard_ok": True, "beard_top": "Goatee"}, "Goatee"),
        ("live", live_row, {"status": "done", "identity": 0.7, "blink_ok": False, "blinks": 0}, "<video"),
        ("pipeline", {**beard_row, "style": "a/ukiyoe", "medium": "photo"},
         {"status": "done", "identity": 0.7, "hair_kept": True, "reaction": 0.2}, "react 0.2"),
    ):
        (run_dir / "manifest.json").write_text(json.dumps({"task": task, "srcs": {"m.png": "srcs/m.png"}, "cells": {"k": row}}))
        (run_dir / "metrics.json").write_text(json.dumps({"cells": {"k": m}, "summary": {}}))
        assert needle in sheet.build(run_dir, False, "t")


def test_score_dispatches_to_the_task_module(tmp_path, monkeypatch):
    (tmp_path / "manifest.json").write_text(json.dumps({"task": "beard", "cells": {}}))
    monkeypatch.setitem(score.TASK_SCORERS, "beard", lambda run, manifest, url, cache: {"run": manifest["task"]})
    assert score.score(tmp_path, "http://x", tmp_path) == {"run": "beard"}


def test_summaries_write_without_a_gpu(tmp_path):
    for module, manifest, summary in (
        (bb, {"cells": {}}, {"goatee|kontext||{}": {
            "srcs_passed": 1, "srcs": 1, "cells": 2, "done": 2, "refused": 0, "identity_min": 0.7, "identity_mean": 0.7,
            "beard_ok": 1.0, "shaved_cheeks": None, "lips": 0.0, "outside": 0.1, "clean": 1.0, "auto": "pass", "reasons": []}}),
        (lb, {"cells": {}}, lb.summarise({"cells": {"1": {"style": "blink", "engine": "live", "sweep": {}, "status": "done"}}},
                                         {"1": {"status": "done", "identity": 0.8, "clean": True}})),
        (pl, {"cells": {}}, {}),
    ):
        module.write_summary_md(tmp_path, manifest, {"summary": summary})
        assert (tmp_path / "summary.md").read_text().startswith(f"# {tmp_path.name}")


def test_export_task_routes_before_the_hair_parser(tmp_path, monkeypatch):
    seen = {}
    monkeypatch.setitem(ex.TASK_EXPORTS, "beard", lambda a: seen.update(source=a.source))
    monkeypatch.setattr(sys, "argv", ["export_catalog.py", "--task", "beard", str(tmp_path / "v.json")])
    ex.main()
    assert seen["source"] == tmp_path / "v.json"
