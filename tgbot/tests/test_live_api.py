"""POST /api/live, the Tsumiki side of the living portrait: one image
generation, the clip in the chat, a refund when ComfyUI fails."""

import asyncio
import base64

import pytest
from aiogram.exceptions import TelegramForbiddenError
from fastapi.testclient import TestClient

import app as appmod
import render
from comfy import ComfyError
from db import Database
from jobs import Job, JobStore
from test_render_api import FakeComfy, png

HEADERS = {"Authorization": "dev secret"}


class FakeBot:
    def __init__(self, error=None):
        self.error = error
        self.sent: list[tuple[int, str]] = []

    async def send_animation(self, chat_id, animation, caption=None):
        if self.error:
            raise self.error
        self.sent.append((chat_id, caption))


@pytest.fixture
def client(tmp_path, monkeypatch):
    drivers = tmp_path / "drivers"
    drivers.mkdir()
    (drivers / "smile.mp4").write_bytes(b"driver")
    cfg = appmod.config
    monkeypatch.setattr(cfg, "DEV_TOKEN", "secret")
    monkeypatch.setattr(cfg, "FREE_DAILY_LIMIT", 1)
    monkeypatch.setattr(cfg, "DATA_DIR", tmp_path)
    monkeypatch.setattr(cfg, "DRIVERS_DIR", drivers)
    monkeypatch.setattr(cfg, "MOTIONS", {
        "smile": {"driver": "smile.mp4", "engine": "live", "label": "Smile"},
        "blink": {"driver": "blink.mp4", "engine": "live"},
        "hair-breeze": {"driver": None, "engine": "wan", "prompt": "a breeze"},
    })
    monkeypatch.setattr(appmod, "db", Database(tmp_path / "t.db"))
    monkeypatch.setattr(appmod, "jobs", JobStore())
    monkeypatch.setattr(appmod, "comfy", FakeComfy())
    appmod._workflow_cache.clear()
    appmod._hair_analysing.clear()
    render._driver_names.clear()
    render._driver_locks.clear()

    async def no_watch(job, usage_id):
        return None

    monkeypatch.setattr(render, "_watch_live", no_watch)
    return TestClient(appmod.app)


def body(**over):
    return {"motion": "smile", "image": base64.b64encode(png()).decode(), **over}


def test_live_queues_the_graph_and_bills_one_generation(client):
    r = client.post("/api/live", json=body(), headers=HEADERS)
    assert r.status_code == 200
    assert set(r.json()) == {"job_id", "queue_position"}
    wf = appmod.comfy.prompts[0]["wf"]
    by_class = {n["class_type"]: n for n in wf.values()}
    assert by_class["VHS_LoadVideo"]["inputs"]["video"] == "in/tsumiki_driver_smile.mp4"
    assert by_class["LoadImage"]["inputs"]["image"] == f"in/tsumiki_live_{r.json()['job_id']}.png"
    assert appmod.db.free_used_today(0) == 1
    job = appmod.jobs.get(r.json()["job_id"])
    assert job.caption == "🎞 Smile"


@pytest.mark.parametrize("motion", ["nope", "hair-breeze", "blink"])
def test_unavailable_motion_is_422_and_free(client, motion):
    r = client.post("/api/live", json=body(motion=motion), headers=HEADERS)
    assert r.status_code == 422
    assert appmod.db.free_used_today(0) == 0


def test_mask_is_not_part_of_the_request(client):
    """Extra fields are ignored, the graph has no mask slot."""
    r = client.post("/api/live", json=body(mask="x"), headers=HEADERS)
    assert r.status_code == 200
    assert "__MASK__" not in str(appmod.comfy.prompts[0]["wf"])


def test_garbage_image_is_400_and_free(client):
    r = client.post("/api/live", json=body(image="%%%"), headers=HEADERS)
    assert r.status_code == 400
    assert appmod.db.free_used_today(0) == 0


def test_non_image_is_422(client):
    image = base64.b64encode(b"not an image").decode()
    assert client.post("/api/live", json=body(image=image), headers=HEADERS).status_code == 422


def test_402_without_quota(client, monkeypatch):
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 0)
    assert client.post("/api/live", json=body(), headers=HEADERS).status_code == 402
    assert appmod.comfy.upload_log == []


def test_429_with_an_image_job_running(client):
    appmod.jobs.add(Job(user_id=0, prompt="x", workflow="flux", status="running"))
    assert client.post("/api/live", json=body(), headers=HEADERS).status_code == 429


def test_rejected_submit_refunds(client, monkeypatch):
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 1)
    appmod.comfy.reject_next = True
    assert client.post("/api/live", json=body(), headers=HEADERS).status_code == 502
    assert appmod.db.free_used_today(0) == 0
    # the failed job must not hold the one-at-a-time slot
    assert client.post("/api/live", json=body(), headers=HEADERS).status_code == 200


def _watch(monkeypatch, tmp_path, user_id, bot, fail=False):
    monkeypatch.undo()
    monkeypatch.setattr(appmod.config, "DATA_DIR", tmp_path)
    db = Database(tmp_path / "w.db")
    monkeypatch.setattr(appmod, "db", db)
    monkeypatch.setattr(appmod, "bot", bot)

    class Comfy:
        async def wait_for_output(self, session, prompt_id, kind="image", timeout=300):
            assert kind == "video"
            if fail:
                raise ComfyError("ComfyUI: no face")
            return b"mp4"

    monkeypatch.setattr(appmod, "comfy", Comfy())
    _, usage_id = db.spend_generation(user_id, 1)
    job = Job(user_id=user_id, prompt="", workflow="live", status="running", caption="🎞 Smile")
    job.prompt_id = "p"
    asyncio.run(render._watch_live(job, usage_id))
    return job, db


def test_watch_sends_an_animation(client, monkeypatch, tmp_path):
    bot = FakeBot()
    job, _ = _watch(monkeypatch, tmp_path, 42, bot)
    assert job.status == "done" and job.video_path.read_bytes() == b"mp4"
    assert job.video_path.name == f"{job.id}.mp4"
    assert bot.sent == [(42, "🎞 Smile")]


def test_watch_keeps_the_clip_when_the_user_blocked_the_bot(client, monkeypatch, tmp_path):
    bot = FakeBot(TelegramForbiddenError(method=None, message="blocked"))
    job, db = _watch(monkeypatch, tmp_path, 42, bot)
    assert job.status == "done" and db.free_used_today(42) == 1


def test_watch_sends_nothing_to_an_app_user(client, monkeypatch, tmp_path):
    bot = FakeBot()
    job, _ = _watch(monkeypatch, tmp_path, -5, bot)
    assert job.status == "done" and bot.sent == []


def test_watch_refunds_a_failed_render(client, monkeypatch, tmp_path):
    bot = FakeBot()
    job, db = _watch(monkeypatch, tmp_path, 42, bot, fail=True)
    assert job.status == "error" and job.error == "ComfyUI: no face"
    assert db.free_used_today(42) == 0 and bot.sent == []


def test_finished_clip_is_served_from_the_video_route(client, tmp_path):
    path = tmp_path / "x.mp4"
    path.write_bytes(b"mp4")
    job = Job(user_id=0, prompt="", workflow="live", status="done", video_path=path)
    appmod.jobs.add(job)
    r = client.get(f"/api/jobs/{job.id}/video", headers=HEADERS)
    assert r.status_code == 200 and r.headers["content-type"] == "video/mp4"
