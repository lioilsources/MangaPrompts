"""POST /api/restyle through the FastAPI app with ComfyUI and the watcher
faked out: the contract that matters is that it is billed like a generation
and that nothing is spent when the request never reaches the queue."""

import asyncio
import base64
import struct

import pytest
from fastapi.testclient import TestClient

import app as appmod
from comfy import ComfyError
from db import Database
from jobs import JobStore

USER_HEADERS = {"Authorization": "dev secret"}


def _png(w: int, h: int) -> bytes:
    return (
        b"\x89PNG\r\n\x1a\n" + struct.pack(">I", 13) + b"IHDR"
        + struct.pack(">II", w, h) + b"\x08\x06" + b"\x00" * 64
    )


class FakeComfy:
    def __init__(self, fail_submit: bool = False):
        self.fail_submit = fail_submit
        self.uploads: list[tuple[bytes, str]] = []
        self.workflows: list[dict] = []

    async def upload_image(self, session, data, filename):
        self.uploads.append((data, filename))
        return f"clipspace/{filename}"

    async def queue_prompt(self, session, workflow):
        if self.fail_submit:
            raise ComfyError("boom")
        self.workflows.append(workflow)
        return "prompt-1", 3


@pytest.fixture
def client(tmp_path, monkeypatch):
    monkeypatch.setattr(appmod.config, "DEV_TOKEN", "secret")
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 1)
    monkeypatch.setattr(appmod, "db", Database(tmp_path / "t.db"))
    monkeypatch.setattr(appmod, "jobs", JobStore())
    appmod._workflow_cache.clear()

    async def no_watch(job, usage_id):
        return None

    monkeypatch.setattr(appmod, "_watch_job", no_watch)
    return TestClient(appmod.app)


def _body(**over):
    body = {
        "prompt": "a photorealistic photograph of a person, ukiyo-e style",
        "negative_prompt": "blurry",
        "medium": "photo",
        "style": "Ukiyo-e woodblock",
        "image": base64.b64encode(_png(434, 884)).decode(),
    }
    body.update(over)
    return body


def test_restyle_queues_an_image_job_billed_like_generate(client, monkeypatch):
    fake = FakeComfy()
    monkeypatch.setattr(appmod, "comfy", fake)

    resp = client.post("/api/restyle", json=_body(), headers=USER_HEADERS)
    assert resp.status_code == 200, resp.text
    job_id = resp.json()["job_id"]
    assert resp.json()["queue_position"] == 3

    # the free generation was spent (shared quota with /api/generate)
    assert appmod.db.free_used_today(0) == 1
    job = appmod.jobs.get(job_id)
    assert job.kind == "image" and job.status == "running"
    assert job.caption == "🖼 Ukiyo-e woodblock · photo"

    # one upload, per-job filename, and the workflow reads exactly that file
    assert len(fake.uploads) == 1
    assert fake.uploads[0][1] == f"tsumiki_restyle_{job_id}.png"
    wf = fake.workflows[0]
    assert wf["2"]["inputs"]["image"] == f"clipspace/tsumiki_restyle_{job_id}.png"
    assert wf["1"]["inputs"]["ckpt_name"] == appmod.config.RESTYLE_CHECKPOINTS["photo"]
    # 1:2 photo → 768×1344 bucket on both the latent and the reference fit
    assert (wf["14"]["inputs"]["width"], wf["14"]["inputs"]["height"]) == (768, 1344)
    assert (wf["3"]["inputs"]["width"], wf["3"]["inputs"]["height"]) == (768, 1344)
    assert wf["7"]["inputs"]["text"].startswith("a photorealistic photograph")


def test_restyle_illustration_routes_its_checkpoint(client, monkeypatch):
    fake = FakeComfy()
    monkeypatch.setattr(appmod, "comfy", fake)
    monkeypatch.setitem(appmod.config.RESTYLE_CHECKPOINTS, "illustration", "painterly.safetensors")
    resp = client.post("/api/restyle", json=_body(medium="illustration"), headers=USER_HEADERS)
    assert resp.status_code == 200, resp.text
    assert fake.workflows[0]["1"]["inputs"]["ckpt_name"] == "painterly.safetensors"


def test_restyle_unknown_medium_is_400_before_spending(client, monkeypatch):
    monkeypatch.setattr(appmod, "comfy", FakeComfy())
    resp = client.post("/api/restyle", json=_body(medium="hologram"), headers=USER_HEADERS)
    assert resp.status_code == 400
    assert appmod.db.free_used_today(0) == 0


def test_restyle_bad_image_is_400_before_spending(client, monkeypatch):
    monkeypatch.setattr(appmod, "comfy", FakeComfy())
    resp = client.post("/api/restyle", json=_body(image="not base64!!"), headers=USER_HEADERS)
    assert resp.status_code == 400
    assert appmod.db.free_used_today(0) == 0


def test_restyle_402_when_quota_and_credits_are_gone(client, monkeypatch):
    monkeypatch.setattr(appmod, "comfy", FakeComfy())
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 0)
    resp = client.post("/api/restyle", json=_body(), headers=USER_HEADERS)
    assert resp.status_code == 402


def test_restyle_refunds_when_comfy_is_down(client, monkeypatch):
    monkeypatch.setattr(appmod, "comfy", FakeComfy(fail_submit=True))
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 0)
    appmod.db.add_payment("ch1", 0, stars=25, credits=1, package="s")
    resp = client.post("/api/restyle", json=_body(), headers=USER_HEADERS)
    assert resp.status_code == 502
    assert appmod.db.credits(0) == 1  # the credit came back


def test_restyle_one_at_a_time_shares_the_image_lane(client, monkeypatch):
    fake = FakeComfy()
    monkeypatch.setattr(appmod, "comfy", fake)
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 5)
    assert client.post("/api/restyle", json=_body(), headers=USER_HEADERS).status_code == 200
    # a plain generation must wait for the restyle, and vice versa
    resp = client.post("/api/generate", json={"prompt": "x"}, headers=USER_HEADERS)
    assert resp.status_code == 429
    assert client.post("/api/restyle", json=_body(), headers=USER_HEADERS).status_code == 429


def test_restyle_requires_auth(client):
    resp = client.post("/api/restyle", json=_body())
    assert resp.status_code == 401


def test_restyle_caption():
    assert appmod.restyle_caption("  ", "illustration") == "🖼 Restyled · illustration"
