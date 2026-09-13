"""POST /api/hair with ComfyUI and the watcher faked out. What matters: the
analysis refuses an unusable photo before anything is billed, the mask and the
colour read off the photo reach the inpaint graph, and a failed submit refunds."""

import base64
import io
import json

import numpy as np
import pytest
from fastapi.testclient import TestClient
from PIL import Image

import app as appmod
import hairmask as hm
from comfy import ComfyError
from db import Database
from jobs import JobStore
from test_hairmask import synthetic

USER_HEADERS = {"Authorization": "dev secret"}
PROMPT = (
    "a photo of the same person with a pixie cut, short hair ending above the jaw, "
    "__HAIRCOLOR__ hair, photorealistic"
)


def _png_array(arr: np.ndarray) -> bytes:
    buf = io.BytesIO()
    Image.fromarray(arr).save(buf, "PNG")
    return buf.getvalue()


def _portrait_and_masks(face: bool = True):
    a = synthetic()
    img = np.full((512, 512, 3), 190, np.uint8)
    img[a.face] = (224, 180, 150)
    ys, xs = np.nonzero(a.hair)
    img[ys, xs] = np.where((xs % 5 < 3)[:, None], (22, 15, 11), (85, 58, 38))
    if not face:
        a.face[:] = False
        a.features[:] = False
    masks = {
        prefix: hm.to_png(getattr(a, field)) for prefix, field in hm.ANALYSE_OUTPUTS.items()
    }
    return _png_array(img), masks


class FakeComfy:
    def __init__(self, masks, fail_analysis=False, fail_submit=False):
        self.masks = masks
        self.fail_analysis = fail_analysis
        self.fail_submit = fail_submit
        self.uploads: list[tuple[bytes, str]] = []
        self.workflows: list[dict] = []

    async def upload_image(self, session, data, filename):
        self.uploads.append((data, filename))
        return f"in/{filename}"

    async def queue_prompt(self, session, workflow):
        is_analysis = any(n["class_type"] == "FaceSegment" for n in workflow.values())
        if self.fail_submit and not is_analysis:
            raise ComfyError("boom")
        self.workflows.append(workflow)
        return f"prompt-{len(self.workflows)}", 2

    async def wait_for_images(self, session, prompt_id, prefixes, timeout=300, poll_interval=1.0):
        if self.fail_analysis:
            raise ComfyError("ComfyUI: model download failed")
        assert set(prefixes) == set(hm.ANALYSE_OUTPUTS)
        return self.masks


@pytest.fixture
def client(tmp_path, monkeypatch):
    monkeypatch.setattr(appmod.config, "DEV_TOKEN", "secret")
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 1)
    monkeypatch.setattr(appmod.config, "HAIR_ENGINE", "flux")
    monkeypatch.setattr(appmod, "db", Database(tmp_path / "t.db"))
    monkeypatch.setattr(appmod, "jobs", JobStore())
    appmod._workflow_cache.clear()
    appmod._hair_analysing.clear()

    async def no_watch(job, usage_id):
        return None

    monkeypatch.setattr(appmod, "_watch_job", no_watch)
    return TestClient(appmod.app)


def _body(photo: bytes, **over):
    body = {
        "prompt": PROMPT,
        "negative_prompt": "hat, blurry",
        "style": "Pixie Cut",
        "shape": {"length": "short", "bangs": "none", "updo": False},
        "image": base64.b64encode(photo).decode(),
    }
    body.update(over)
    return body


def test_hair_analyses_then_bills_and_queues_the_inpaint(client, monkeypatch):
    image, masks = _portrait_and_masks()
    fake = FakeComfy(masks)
    monkeypatch.setattr(appmod, "comfy", fake)

    resp = client.post("/api/hair", json=_body(image), headers=USER_HEADERS)
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["hair_colour"] == "brown"
    job = appmod.jobs.get(data["job_id"])
    assert job.workflow == "hair-flux" and job.status == "running"
    assert job.caption == "💇 Pixie Cut"
    assert appmod.db.free_used_today(0) == 1

    analysis, inpaint = fake.workflows
    assert analysis["1"]["inputs"]["image"].startswith("in/tsumiki_hair_src_")
    # the inpaint reads the same upload and the mask made for this job
    src_upload, mask_upload = fake.uploads
    assert mask_upload[1] == f"tsumiki_hair_mask_{job.id}.png"
    loads = {n["inputs"]["image"] for n in inpaint.values() if n["class_type"] == "LoadImage"}
    assert loads == {f"in/{src_upload[1]}", f"in/{mask_upload[1]}"}
    mask = hm.decode_mask(mask_upload[0])
    assert mask.shape == (512, 512) and mask.any()
    # colour substituted, token gone
    dump = json.dumps(inpaint)
    assert "__HAIRCOLOR__" not in dump and "brown hair" in dump
    assert "__MASK__" not in dump and "__IMAGE__" not in dump


def test_hair_without_a_face_is_refused_before_billing(client, monkeypatch):
    image, masks = _portrait_and_masks(face=False)
    fake = FakeComfy(masks)
    monkeypatch.setattr(appmod, "comfy", fake)
    resp = client.post("/api/hair", json=_body(image), headers=USER_HEADERS)
    assert resp.status_code == 400
    assert "No face" in resp.json()["detail"]
    assert appmod.db.free_used_today(0) == 0
    assert len(fake.workflows) == 1  # only the analysis ran


def test_hair_analysis_outage_is_502_and_free(client, monkeypatch):
    image, masks = _portrait_and_masks()
    monkeypatch.setattr(appmod, "comfy", FakeComfy(masks, fail_analysis=True))
    resp = client.post("/api/hair", json=_body(image), headers=USER_HEADERS)
    assert resp.status_code == 502
    assert appmod.db.free_used_today(0) == 0
    assert appmod._hair_analysing == set()


def test_hair_refunds_when_the_inpaint_cannot_be_queued(client, monkeypatch):
    image, masks = _portrait_and_masks()
    monkeypatch.setattr(appmod, "comfy", FakeComfy(masks, fail_submit=True))
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 0)
    appmod.db.add_payment("ch1", 0, stars=25, credits=1, package="s")
    resp = client.post("/api/hair", json=_body(image), headers=USER_HEADERS)
    assert resp.status_code == 502
    assert appmod.db.credits(0) == 1


def test_hair_402_after_a_successful_analysis(client, monkeypatch):
    image, masks = _portrait_and_masks()
    monkeypatch.setattr(appmod, "comfy", FakeComfy(masks))
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 0)
    resp = client.post("/api/hair", json=_body(image), headers=USER_HEADERS)
    assert resp.status_code == 402


def test_hair_sdxl_engine_gets_its_checkpoint(client, monkeypatch):
    image, masks = _portrait_and_masks()
    fake = FakeComfy(masks)
    monkeypatch.setattr(appmod, "comfy", fake)
    monkeypatch.setattr(appmod.config, "HAIR_ENGINE", "sdxl")
    monkeypatch.setattr(appmod.config, "HAIR_CHECKPOINT", "jugg.safetensors")
    resp = client.post("/api/hair", json=_body(image), headers=USER_HEADERS)
    assert resp.status_code == 200, resp.text
    inpaint = fake.workflows[1]
    assert inpaint["1"]["inputs"]["ckpt_name"] == "jugg.safetensors"
    assert inpaint["3"]["inputs"]["text"] == "hat, blurry"
    assert appmod.jobs.get(resp.json()["job_id"]).workflow == "hair-sdxl"


def test_hair_one_at_a_time_shares_the_image_lane(client, monkeypatch):
    image, masks = _portrait_and_masks()
    monkeypatch.setattr(appmod, "comfy", FakeComfy(masks))
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 5)
    assert client.post("/api/hair", json=_body(image), headers=USER_HEADERS).status_code == 200
    assert client.post("/api/hair", json=_body(image), headers=USER_HEADERS).status_code == 429
    appmod.jobs = JobStore()
    appmod._hair_analysing.add(0)  # an analysis in flight counts too
    assert client.post("/api/hair", json=_body(image), headers=USER_HEADERS).status_code == 429


@pytest.mark.parametrize(
    "over, status",
    [
        ({"prompt": "a photo with a pixie cut"}, 400),  # no colour token
        ({"shape": {"length": "huge"}}, 422),
        ({"shape": {"length": "short", "bangs": "mohawk"}}, 422),
        ({"image": "not base64!!"}, 400),
    ],
)
def test_hair_bad_requests_cost_nothing(client, monkeypatch, over, status):
    image, masks = _portrait_and_masks()
    fake = FakeComfy(masks)
    monkeypatch.setattr(appmod, "comfy", fake)
    resp = client.post("/api/hair", json=_body(image, **over), headers=USER_HEADERS)
    assert resp.status_code == status
    assert fake.workflows == []
    assert appmod.db.free_used_today(0) == 0


def test_hair_requires_auth(client):
    image, _ = _portrait_and_masks()
    assert client.post("/api/hair", json=_body(image)).status_code == 401


def test_hair_caption():
    assert appmod.hair_caption("  ") == "💇 New haircut"
    assert appmod.hair_caption("Wolf Cut") == "💇 Wolf Cut"
