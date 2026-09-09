import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "tools"))

from check_workflow import check_workflow  # noqa: E402

WORKFLOW_DIR = Path(__file__).resolve().parent.parent.parent / "assets" / "comfyui"

# Minimal /object_info shape: {"required": {name: [type_or_options, meta]}}.
OBJECT_INFO = {
    "CheckpointLoaderSimple": {
        "input": {"required": {"ckpt_name": [["a.safetensors", "b.safetensors"]]}}
    },
    "KSampler": {
        "input": {
            "required": {
                "model": ["MODEL"],
                "seed": ["INT", {"default": 0}],
                "sampler_name": [["euler", "dpmpp_2m"]],
                "steps": ["INT", {"default": 20}],
            }
        }
    },
}


def _wf(**over):
    wf = {
        "1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "a.safetensors"}},
        "2": {
            "class_type": "KSampler",
            "inputs": {"model": ["1", 0], "seed": 5, "sampler_name": "euler"},
        },
    }
    wf.update(over)
    return wf


def test_clean_workflow_has_no_problems():
    assert check_workflow(_wf(), OBJECT_INFO) == []


def test_missing_node_class_is_reported():
    wf = _wf(**{"3": {"class_type": "FaceDetailer", "inputs": {}}})
    problems = check_workflow(wf, OBJECT_INFO)
    assert len(problems) == 1
    assert "not installed" in problems[0]


def test_missing_model_file_is_reported():
    wf = _wf(**{"1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "gone.safetensors"}}})
    problems = check_workflow(wf, OBJECT_INFO)
    assert len(problems) == 1
    assert "model file 'gone.safetensors'" in problems[0]


def test_renamed_input_is_reported():
    wf = _wf(**{"2": {"class_type": "KSampler", "inputs": {"model": ["1", 0], "sampler": "euler"}}})
    problems = check_workflow(wf, OBJECT_INFO)
    assert any("unknown input 'sampler'" in p for p in problems)


def test_unwired_required_link_is_reported():
    wf = _wf(**{"2": {"class_type": "KSampler", "inputs": {"seed": 1}}})
    problems = check_workflow(wf, OBJECT_INFO)
    # `model` has no default and is not a combo → must be wired; seed/sampler
    # both have a default or options, so they are not flagged.
    assert [p for p in problems if "required input 'model'" in p]
    assert not [p for p in problems if "'steps'" in p]


def test_placeholders_are_never_flagged():
    wf = _wf(**{"1": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "__CKPT__"}}})
    assert check_workflow(wf, OBJECT_INFO) == []


def test_shipped_restyle_workflow_against_a_server_that_has_everything():
    """The checker must pass the graph we actually ship when the server does
    offer every class and file — otherwise it would cry wolf on SPARK."""
    wf = json.loads((WORKFLOW_DIR / "sdxl_restyle.api.json").read_text())
    info: dict = {}
    for node in wf.values():
        required = info.setdefault(node["class_type"], {"input": {"required": {}}})[
            "input"
        ]["required"]
        for key, value in node["inputs"].items():
            if isinstance(value, list):
                required[key] = ["LINK"]
            elif isinstance(value, str) and not value.startswith("__"):
                # Two nodes of one class can name different files (the graph
                # loads two ControlNets) — the enum has to hold both.
                options = required.setdefault(key, [[]])[0]
                if value not in options:
                    options.append(value)
            else:
                required[key] = ["ANY", {"default": value}]
    assert check_workflow(wf, info) == []
