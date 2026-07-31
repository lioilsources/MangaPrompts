import json
from pathlib import Path

import pytest

from comfy import prepare_workflow

WORKFLOW_DIR = Path(__file__).resolve().parent.parent.parent / "assets" / "comfyui"
TXT2IMG_FILES = ["flux_manga_txt2img.api.json", "pony_txt2img.api.json"]
ALL_FILES = sorted(p.name for p in WORKFLOW_DIR.glob("*.api.json"))


def _placeholders_left(wf: dict) -> list[str]:
    dump = json.dumps(wf)
    return [p for p in ("__PROMPT__", "__NEGATIVE__") if p in dump]


@pytest.mark.parametrize("filename", TXT2IMG_FILES)
def test_txt2img_substitution(filename):
    template = json.loads((WORKFLOW_DIR / filename).read_text())
    wf = prepare_workflow(template, prompt="a manga hero", negative="blurry", batch=1)

    assert _placeholders_left(wf) == []
    assert "a manga hero" in json.dumps(wf)
    # template itself must stay untouched (deep copy)
    assert "__PROMPT__" in json.dumps(template)


@pytest.mark.parametrize("filename", ALL_FILES)
def test_batch_forced_and_seed_randomized(filename):
    template = json.loads((WORKFLOW_DIR / filename).read_text())
    wf = prepare_workflow(
        template,
        prompt="p",
        negative="n",
        batch=1,
        image_name="in.png",
        pose_name="pose.png",
        checkpoint="ckpt.safetensors",
    )
    for node in wf.values():
        inputs = node.get("inputs", {})
        cls = node.get("class_type")
        if cls in ("EmptySD3LatentImage", "EmptyLatentImage") and "batch_size" in inputs:
            assert inputs["batch_size"] == 1
        if cls == "RepeatLatentBatch" and "amount" in inputs:
            assert inputs["amount"] == 1
        if "seed" in inputs:
            assert isinstance(inputs["seed"], int)
        if "noise_seed" in inputs:
            assert isinstance(inputs["noise_seed"], int)

    # no placeholder of any kind may survive when all params are supplied
    dump = json.dumps(wf)
    for placeholder in ("__PROMPT__", "__NEGATIVE__", "__IMAGE__", "__POSE__", "__CKPT__"):
        assert placeholder not in dump


def test_seed_consistent_within_run():
    template = {
        "1": {"class_type": "KSampler", "inputs": {"seed": 0, "text": "__PROMPT__"}},
        "2": {"class_type": "SamplerCustom", "inputs": {"noise_seed": 0}},
    }
    wf = prepare_workflow(template, prompt="x", negative="", batch=1)
    assert wf["1"]["inputs"]["seed"] == wf["2"]["inputs"]["noise_seed"]
