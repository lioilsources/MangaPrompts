import json
from pathlib import Path

import pytest

from comfy import execution_error_message, prepare_workflow

WORKFLOW_DIR = Path(__file__).resolve().parent.parent.parent / "assets" / "comfyui"
TXT2IMG_FILES = [
    "flux_manga_txt2img.api.json",
    "pony_txt2img.api.json",
    "juggernaut_lightning_txt2img.api.json",
    "wai_txt2img.api.json",
]
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


RESTYLE_FILE = "sdxl_restyle.api.json"


def test_restyle_template_is_fully_patched():
    template = json.loads((WORKFLOW_DIR / RESTYLE_FILE).read_text())
    wf = prepare_workflow(
        template,
        prompt="a photorealistic photograph of a person, ukiyo-e style",
        negative="blurry",
        batch=1,
        image_name="tsumiki_restyle_abc.png",
        checkpoint="Juggernaut-XL_v9.safetensors",
        latent=(768, 1344),
    )
    dump = json.dumps(wf)
    for placeholder in ("__PROMPT__", "__NEGATIVE__", "__IMAGE__", "__CKPT__"):
        assert placeholder not in dump
    # no pose template in this graph: the reference photo *is* the pose
    assert "__POSE__" not in json.dumps(template)
    assert wf["1"]["inputs"]["ckpt_name"] == "Juggernaut-XL_v9.safetensors"
    assert wf["2"]["inputs"]["image"] == "tsumiki_restyle_abc.png"


def test_restyle_latent_drives_canvas_and_reference_fit():
    template = json.loads((WORKFLOW_DIR / RESTYLE_FILE).read_text())
    wf = prepare_workflow(template, prompt="p", negative="n", batch=1, latent=(1344, 768))
    latents = [n for n in wf.values() if n["class_type"] == "EmptyLatentImage"]
    fits = [n for n in wf.values() if n["class_type"] == "ImageResizeKJv2"]
    assert latents and fits
    for node in latents + fits:
        assert (node["inputs"]["width"], node["inputs"]["height"]) == (1344, 768)
    # without an override the template's own bucket stays
    plain = prepare_workflow(template, prompt="p", negative="n", batch=1)
    assert plain["14"]["inputs"]["width"] == template["14"]["inputs"]["width"]


def test_restyle_graph_reads_face_and_depth_from_one_upload():
    """Identity and pose must come from the same (letterboxed) reference, and
    the face keypoints must sit upstream of the depth ControlNet."""
    wf = json.loads((WORKFLOW_DIR / RESTYLE_FILE).read_text())
    by_cls = {n["class_type"]: k for k, n in wf.items()}
    fit = by_cls["ImageResizeKJv2"]
    assert wf[by_cls["DepthAnythingV2Preprocessor"]]["inputs"]["image"] == [fit, 0]
    face = by_cls["ApplyInstantIDAdvanced"]
    assert wf[face]["inputs"]["image"] == [fit, 0]
    depth_apply = by_cls["ControlNetApplyAdvanced"]
    assert wf[depth_apply]["inputs"]["positive"] == [face, 1]
    assert wf[depth_apply]["inputs"]["negative"] == [face, 2]
    sampler = wf[by_cls["KSampler"]]["inputs"]
    assert sampler["model"] == [face, 0]
    assert sampler["positive"] == [depth_apply, 0]
    # the detail pass conditions from before the depth hint (it works on a crop)
    detailer = wf[by_cls["FaceDetailer"]]["inputs"]
    assert detailer["positive"] == [face, 1] and detailer["model"] == [face, 0]


def test_execution_error_message_surfaces_node_exception():
    status = {
        "status_str": "error",
        "messages": [
            ["execution_start", {"prompt_id": "x"}],
            ["execution_error", {
                "node_type": "ApplyInstantIDAdvanced",
                "exception_message": "No face detected in the reference image\nTraceback…",
            }],
        ],
    }
    assert execution_error_message(status) == "ComfyUI: No face detected in the reference image"


def test_execution_error_message_falls_back():
    assert execution_error_message({"status_str": "error"}) == "generation failed on the ComfyUI side"
    assert execution_error_message({"messages": [["execution_error", {}]]}).startswith("generation failed")
