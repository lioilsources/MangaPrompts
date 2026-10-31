import asyncio
import json
from pathlib import Path

import pytest

import hairmask
from comfy import (
    ComfyClient,
    ComfyError,
    execution_error_message,
    output_refs,
    pick_outputs,
    prepare_workflow,
    sign_outputs,
)

WORKFLOW_DIR = Path(__file__).resolve().parent.parent.parent / "assets" / "comfyui"
TXT2IMG_FILES = [
    "flux_manga_txt2img.api.json",
    "pony_txt2img.api.json",
    "juggernaut_lightning_txt2img.api.json",
    "wai_txt2img.api.json",
]
ALL_FILES = sorted(p.name for p in WORKFLOW_DIR.glob("*.api.json"))


def _load(filename: str) -> dict:
    return json.loads((WORKFLOW_DIR / filename).read_text())


def _placeholders_left(wf: dict) -> list[str]:
    dump = json.dumps(wf)
    return [p for p in ("__PROMPT__", "__NEGATIVE__", "__DRIVER__") if p in dump]


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


FLUX_RESTYLE_FILE = "flux_restyle.api.json"


def test_flux_restyle_template_is_fully_patched_without_a_checkpoint():
    template = json.loads((WORKFLOW_DIR / FLUX_RESTYLE_FILE).read_text())
    wf = prepare_workflow(
        template, prompt="a photorealistic photograph of a person, monet",
        negative="ignored at cfg 1", batch=1, image_name="ref.png", latent=(896, 1152),
    )
    dump = json.dumps(wf)
    for placeholder in ("__PROMPT__", "__IMAGE__"):
        assert placeholder not in dump
    assert "__CKPT__" not in json.dumps(template) and "__NEGATIVE__" not in json.dumps(template)
    by_cls = {n["class_type"]: n for n in wf.values()}
    assert (by_cls["EmptySD3LatentImage"]["inputs"]["width"], by_cls["EmptySD3LatentImage"]["inputs"]["height"]) == (896, 1152)
    assert (by_cls["ImageResizeKJv2"]["inputs"]["width"], by_cls["ImageResizeKJv2"]["inputs"]["height"]) == (896, 1152)


def test_flux_restyle_graph_wiring():
    """Face (PuLID) and pose (depth) read the same letterboxed reference; the
    InstantX ControlNet gets the VAE edge it encodes the hint through."""
    wf = json.loads((WORKFLOW_DIR / FLUX_RESTYLE_FILE).read_text())
    by_cls = {n["class_type"]: k for k, n in wf.items()}
    fit = by_cls["ImageResizeKJv2"]
    assert wf[by_cls["DepthAnythingV2Preprocessor"]]["inputs"]["image"] == [fit, 0]
    pulid = by_cls["ApplyPulidFlux"]
    assert wf[pulid]["inputs"]["image"] == [fit, 0]
    apply = wf[by_cls["ControlNetApplyAdvanced"]]["inputs"]
    assert apply["vae"] == [by_cls["VAELoader"], 0]
    assert apply["positive"] == [by_cls["FluxGuidance"], 0]
    assert apply["end_percent"] < 1.0
    sampler = wf[by_cls["KSampler"]]["inputs"]
    assert sampler["model"] == [pulid, 0]
    assert sampler["positive"] == [by_cls["ControlNetApplyAdvanced"], 0]
    assert sampler["latent_image"] == [by_cls["EmptySD3LatentImage"], 0]
    assert sampler["cfg"] == 1.0


@pytest.mark.parametrize("filename", ["flux_hair_inpaint.api.json", "sdxl_hair_inpaint.api.json"])
def test_hair_inpaint_templates_take_image_and_mask(filename):
    template = json.loads((WORKFLOW_DIR / filename).read_text())
    wf = prepare_workflow(
        template, prompt="a photo of the same person with a pixie cut", negative="hat",
        image_name="portrait.png", mask_name="mask.png", checkpoint="ckpt.safetensors",
        latent=(832, 1216),
    )
    dump = json.dumps(wf)
    for placeholder in ("__PROMPT__", "__NEGATIVE__", "__IMAGE__", "__MASK__", "__CKPT__"):
        assert placeholder not in dump
    loads = sorted(n["inputs"]["image"] for n in wf.values() if n["class_type"] == "LoadImage")
    assert loads == ["mask.png", "portrait.png"]
    # an inpaint keeps the photo's own size: no latent node for the override to touch
    assert not [n for n in wf.values() if n["class_type"] in ("EmptyLatentImage", "EmptySD3LatentImage")]
    # the face is a hole in the mask; filling holes would repaint it (round 0b)
    crop = next(n for n in wf.values() if n["class_type"] == "InpaintCropImproved")
    assert crop["inputs"]["mask_fill_holes"] is False
    # the result is stitched back into the full photo
    by_cls = {n["class_type"]: k for k, n in wf.items()}
    save = wf[by_cls["SaveImage"]]["inputs"]["images"]
    assert save == [by_cls["InpaintStitchImproved"], 0]


def test_hair_analyse_saves_every_mask_the_bot_waits_for():
    wf = json.loads((WORKFLOW_DIR / "hair_analyse.api.json").read_text())
    prefixes = sorted(n["inputs"]["filename_prefix"] for n in wf.values() if n["class_type"] == "SaveImage")
    assert prefixes == sorted(hairmask.ANALYSE_OUTPUTS)
    assert not [n for n in wf.values() if n["class_type"] == "KSampler"]
    # The hair mask is FaceSegment ∪ ClothesSegment: the face parser stops at
    # the chest on a phone selfie and whatever it misses survives the repaint.
    save = next(n for n in wf.values()
                if n["class_type"] == "SaveImage" and n["inputs"]["filename_prefix"] == "tsumiki_hair_mask")
    union = wf[wf[save["inputs"]["images"][0]]["inputs"]["mask"][0]]
    assert union["class_type"] == "MaskComposite" and union["inputs"]["operation"] == "or"
    face, body = wf[union["inputs"]["destination"][0]], wf[union["inputs"]["source"][0]]
    assert (face["class_type"], face["inputs"]["Hair"]) == ("FaceSegment", True)
    assert (body["class_type"], body["inputs"]["Hair"]) == ("ClothesSegment", True)


def test_mask_placeholder_left_alone_without_a_mask():
    template = {"1": {"class_type": "LoadImage", "inputs": {"image": "__MASK__"}}}
    assert prepare_workflow(template, prompt="p")["1"]["inputs"]["image"] == "__MASK__"


def test_pick_outputs_matches_by_prefix_not_order():
    from comfy import output_refs, pick_outputs

    hist = {"outputs": {
        "13": {"images": [{"filename": "tsumiki_features_mask_00003_.png", "type": "output"}]},
        "4": {"images": [{"filename": "tsumiki_hair_mask_00003_.png", "type": "output"},
                          {"filename": "preview.png", "type": "temp"}]},
        "7": {"images": [{"filename": "tsumiki_face_mask_00003_.png", "type": "output"}]},
    }}
    refs = output_refs(hist)
    assert len(refs) == 3
    found = pick_outputs(refs, ("tsumiki_hair_mask", "tsumiki_face_mask", "tsumiki_hat_mask"))
    assert found["tsumiki_hair_mask"]["filename"].startswith("tsumiki_hair_mask_")
    assert found["tsumiki_face_mask"]["filename"].startswith("tsumiki_face_mask_")
    assert "tsumiki_hat_mask" not in found


def test_sign_outputs_swaps_every_save_and_keeps_its_contract():
    from comfy import AILINEAGE_NODE, sign_outputs
    for path in sorted(WORKFLOW_DIR.glob("*.api.json")):
        wf = json.loads(path.read_text())
        saves = {k: dict(n["inputs"]) for k, n in wf.items() if n.get("class_type") == "SaveImage"}
        sign_outputs(wf, "a manga fox")
        assert not [n for n in wf.values() if n.get("class_type") == "SaveImage"], path.name
        for k, before in saves.items():
            node = wf[k]
            assert node["class_type"] == AILINEAGE_NODE
            # pick_outputs and the bench tools match on these two
            assert node["inputs"]["images"] == before["images"]
            assert node["inputs"]["filename_prefix"] == before["filename_prefix"]
            assert node["inputs"]["prompt_text"] == "a manga fox"
            assert node["inputs"]["prompt_storage"] == "none"


def test_queue_prompt_signs_only_with_a_prompt():
    import asyncio
    from comfy import AILINEAGE_NODE, ComfyClient

    class Resp:
        status = 200

        def __init__(self, body):
            self.body = body

        async def json(self):
            return self.body

        async def text(self):
            return json.dumps(self.body)

        async def __aenter__(self):
            return self

        async def __aexit__(self, *a):
            return False

    class Session:
        def __init__(self):
            self.sent = []

        def get(self, url, **kw):
            return Resp({AILINEAGE_NODE: {}})

        def post(self, url, json=None, **kw):
            self.sent.append(json["prompt"])
            return Resp({"prompt_id": "p", "number": 1})

    def graph():
        return {"9": {"class_type": "SaveImage", "inputs": {"images": ["8", 0], "filename_prefix": "t"}}}

    s, c = Session(), ComfyClient("http://x", "cid")
    asyncio.run(c.queue_prompt(s, graph(), prompt="fox"))
    asyncio.run(c.queue_prompt(s, graph()))  # analysis graphs: no prompt, unsigned
    assert s.sent[0]["9"]["class_type"] == AILINEAGE_NODE
    assert s.sent[1]["9"]["class_type"] == "SaveImage"


# Reconstructed from VideoHelperSuite's combine_video (`{"ui": {"gifs": [preview]}}`,
# videohelpersuite/nodes.py), not captured from SPARK: the shape of a history
# entry for a saved h264-mp4, next to a SaveImage from the same graph.
VHS_HISTORY = {
    "status": {"status_str": "success", "completed": True, "messages": []},
    "outputs": {
        "8": {
            "gifs": [
                {
                    "filename": "tsumiki_live_00001.mp4",
                    "subfolder": "",
                    "type": "output",
                    "format": "video/h264-mp4",
                    "frame_rate": 25.0,
                    "workflow": "tsumiki_live_00001.png",
                    "fullpath": "/home/ol1n/Code/ComfyUI/output/tsumiki_live_00001.mp4",
                }
            ]
        },
        "9": {"images": [{"filename": "still_00001_.png", "subfolder": "", "type": "output"}]},
    },
}


def test_output_refs_reads_vhs_gifs():
    assert [r["filename"] for r in output_refs(VHS_HISTORY, "video")] == ["tsumiki_live_00001.mp4"]
    assert [r["filename"] for r in output_refs(VHS_HISTORY, "image")] == ["still_00001_.png"]
    assert len(output_refs(VHS_HISTORY)) == 2


def test_output_refs_drops_a_temp_preview_and_non_mp4():
    hist = {"outputs": {"8": {"gifs": [
        {"filename": "a_00001.mp4", "type": "temp"},
        {"filename": "b_00001.gif", "type": "output"},
    ]}}}
    assert output_refs(hist, "video") == []


def test_pick_outputs_matches_vhs_by_prefix():
    found = pick_outputs(output_refs(VHS_HISTORY), ("tsumiki_live",))
    assert found["tsumiki_live"]["filename"].endswith(".mp4")


def _client_with_history(hist):
    client = ComfyClient("http://x", "id")

    async def history(session, prompt_id):
        return hist

    async def view(session, filename, subfolder, type_):
        return filename.encode()

    client.get_history = history
    client.view = view
    return client


def test_wait_for_output_downloads_the_requested_kind():
    client = _client_with_history(VHS_HISTORY)
    video = asyncio.run(client.wait_for_output(None, "p", "video", poll_interval=0))
    image = asyncio.run(client.wait_for_image(None, "p", poll_interval=0))
    assert video == b"tsumiki_live_00001.mp4"
    assert image == b"still_00001_.png"


def test_wait_for_output_refuses_the_wrong_kind():
    hist = {"outputs": {"9": {"images": [{"filename": "a.png", "type": "output"}]}}}
    with pytest.raises(ComfyError, match="no output videos"):
        asyncio.run(_client_with_history(hist).wait_for_output(None, "p", "video", poll_interval=0))


def test_sign_outputs_leaves_vhs_alone():
    wf = _load("live_portrait.api.json")
    before = json.dumps(wf, sort_keys=True)
    sign_outputs(wf, "a prompt")
    assert json.dumps(wf, sort_keys=True) == before


def test_live_portrait_graph_substitution_and_wiring():
    wf = prepare_workflow(
        _load("live_portrait.api.json"), prompt="", image_name="in.png", driver_name="d.mp4"
    )
    assert not _placeholders_left(wf)
    by_class = {n["class_type"]: n for n in wf.values()}
    assert by_class["LoadImage"]["inputs"]["image"] == "in.png"
    assert by_class["VHS_LoadVideo"]["inputs"]["video"] == "d.mp4"
    assert by_class["VHS_LoadVideo"]["inputs"]["force_rate"] == 25
    out = by_class["VHS_VideoCombine"]["inputs"]
    # save_output false would land in `temp`, which output_refs drops.
    assert out["save_output"] is True and out["format"] == "video/h264-mp4"
    # every link points at a node of the graph
    for node in wf.values():
        for value in node["inputs"].values():
            if isinstance(value, list):
                assert value[0] in wf


def test_driver_placeholder_left_alone_without_a_driver():
    wf = prepare_workflow(_load("live_portrait.api.json"), prompt="", image_name="in.png")
    assert "__DRIVER__" in _placeholders_left(wf)
