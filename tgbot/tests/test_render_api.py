"""POST /api/render end to end through the FastAPI app, with ComfyUI and
video-api faked. Runs in AUTH_MODE=app inside the app's lifespan, so the real
watcher runs on the real event loop."""

import asyncio
import base64
import io
import json
import time

import aiohttp
import pytest
from fastapi.testclient import TestClient
from PIL import Image

import app as appmod
import hairmask
import render
from comfy import ComfyError
from db import Database
from jobs import JobStore
from video import VideoError, VideoJobGone

TOKEN = "t" * 40
HEADERS = {"Authorization": f"app {TOKEN}", "X-User": "ol1n"}
SDXL_CKPT = appmod.config.RESTYLE_CHECKPOINTS["illustration"]


def png(w=64, h=96, shade=0) -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (w, h), (shade % 256, shade // 256, 90)).save(buf, "PNG")
    return buf.getvalue()


def b64(data: bytes) -> str:
    return base64.b64encode(data).decode()


class FakeComfy:
    def __init__(self):
        self.uploads: dict[str, bytes] = {}
        self.upload_log: list[str] = []
        self.prompts: list[dict] = []
        self.outputs: dict[str, bytes] = {}
        self.fail_on: dict[str, str] = {}  # prompt text → error
        self.fail_upload: set[str] = set()
        self.reject_next = False
        self.output_size = (64, 96)
        self.running = 0
        self.peak = 0
        self.delay = 0.0

    async def upload_image(self, session, data, filename):
        if any(part in filename for part in self.fail_upload):
            raise aiohttp.ClientError("connection refused")
        self.uploads[filename] = data
        self.upload_log.append(filename)
        return f"in/{filename}"

    async def queue_prompt(self, session, workflow, prompt=None):
        if self.reject_next:
            self.reject_next = False
            raise ComfyError("workflow error")
        self.prompts.append({"wf": workflow, "prompt": prompt})
        return str(len(self.prompts) - 1), 1

    async def wait_for_output(self, session, prompt_id, kind="image", timeout=300, poll_interval=2.0):
        self.running += 1
        self.peak = max(self.peak, self.running)
        await asyncio.sleep(self.delay)
        self.running -= 1
        entry = self.prompts[int(prompt_id)]
        error = self.fail_on.get(entry["prompt"])
        if error:
            raise ComfyError(error)
        if kind == "video":
            data = b"mp4-" + prompt_id.encode()
        else:
            data = png(*self.output_size, shade=int(prompt_id) + 1)
        self.outputs[entry["prompt"] or prompt_id] = data
        return data

    def input_of(self, prompt: str) -> bytes:
        """Bytes the graph with this prompt text reads as its image."""
        wf = next(p["wf"] for p in self.prompts if p["prompt"] == prompt)
        return self.uploads[_image_name(wf).removeprefix("in/")]


def _image_name(wf: dict) -> str:
    for node in wf.values():
        if node["class_type"] == "LoadImage" and "mask" not in node["inputs"]["image"]:
            return node["inputs"]["image"]
    raise AssertionError("no LoadImage")


class FakeVideo:
    def __init__(self, statuses=None):
        self.submitted: list[dict] = []
        self.statuses = list(statuses or [{"status": "running"}, {"status": "done"}])
        self.fail_submit = False

    async def submit_prompt(self, session, prompt, image_b64, seed, beats=1):
        if self.fail_submit:
            raise VideoError("/jobs HTTP 503")
        self.submitted.append({"prompt": prompt, "image": image_b64, "beats": beats})
        return {"job_id": "remote-1", "minutes_est": 20}

    async def status(self, session, job_id):
        item = self.statuses.pop(0)
        if isinstance(item, Exception):
            raise item
        return item

    async def download(self, session, job_id):
        return b"wan-mp4"


@pytest.fixture
def env(tmp_path, monkeypatch):
    drivers = tmp_path / "drivers"
    drivers.mkdir()
    (drivers / "smile.mp4").write_bytes(b"driver-bytes")
    motions = {
        "smile": {"driver": "smile.mp4", "seconds": 3, "engine": "live", "label": "Smile"},
        "blink": {"driver": "blink.mp4", "seconds": 3, "engine": "live"},  # not generated
        "hair-breeze": {"driver": None, "seconds": 5, "engine": "wan", "prompt": "a breeze"},
    }
    cfg = appmod.config
    monkeypatch.setattr(cfg, "AUTH_MODE", "app")
    monkeypatch.setattr(cfg, "APP_TOKEN", TOKEN)
    monkeypatch.setattr(cfg, "DATA_DIR", tmp_path)
    monkeypatch.setattr(cfg, "DRIVERS_DIR", drivers)
    monkeypatch.setattr(cfg, "MOTIONS", motions)
    monkeypatch.setattr(cfg, "FREE_DAILY_LIMIT", 40)
    monkeypatch.setattr(cfg, "RENDER_VIDEO_POLL", 0.0)
    monkeypatch.setattr(appmod, "bot", None)
    monkeypatch.setattr(appmod, "db", Database(tmp_path / "t.db"))
    monkeypatch.setattr(appmod, "jobs", JobStore())
    comfy, video = FakeComfy(), FakeVideo()
    monkeypatch.setattr(appmod, "comfy", comfy)
    monkeypatch.setattr(appmod, "video", video)
    appmod._workflow_cache.clear()
    render._driver_names.clear()
    render._driver_locks.clear()
    with TestClient(appmod.app) as client:
        yield client, comfy, video


def mask() -> str:
    return b64(png())


def edit(step_id, input_, **over):
    return {"id": step_id, "graph": "kontext_edit", "input": input_, "prompt": step_id, "mask": mask(), **over}


def style(step_id, input_="hair", **over):
    return {"id": step_id, "graph": "restyle_flux", "input": input_, "prompt": step_id, **over}


def chain():
    return [
        edit("beard", "source"), edit("glasses", "beard"), edit("hair", "glasses"),
        style("s1"), style("s2"), style("s3"), style("s4"),
    ]


def post(client, steps, source=None, headers=HEADERS):
    return client.post(
        "/api/render", json={"source": b64(source or png()), "steps": steps}, headers=headers
    )


def finish(client, job_id, headers=HEADERS) -> dict:
    deadline = time.time() + 5
    while time.time() < deadline:
        body = client.get(f"/api/jobs/{job_id}", headers=headers).json()
        if body["status"] in ("done", "error"):
            return body
        time.sleep(0.01)
    raise AssertionError(f"job stuck: {body}")


def spent() -> int:
    user = appmod.app_user_id("ol1n")
    return appmod.db.free_used_today(user)


def statuses(body) -> dict:
    return {k: v["status"] for k, v in body["steps"].items()}


def test_full_chain(env):
    client, comfy, _ = env
    source = png()
    r = post(client, chain(), source)
    assert r.status_code == 200
    assert r.json()["steps_total"] == 7 and r.json()["cost"] == 7
    assert spent() == 7
    body = finish(client, r.json()["job_id"])
    assert body["status"] == "done" and body["done"] == 7 and body["total"] == 7
    assert set(statuses(body).values()) == {"done"}
    assert all(v["kind"] == "image" for v in body["steps"].values())
    assert "error" not in body["steps"]["beard"]
    assert len(comfy.prompts) == 7
    assert comfy.input_of("beard") == source
    assert comfy.input_of("glasses") == comfy.outputs["beard"]
    assert comfy.input_of("hair") == comfy.outputs["glasses"]
    for s in ("s1", "s2", "s3", "s4"):
        assert comfy.input_of(s) == comfy.outputs["hair"]
    # the hair output went up once, however many styles read it
    job_id = r.json()["job_id"]
    assert comfy.upload_log.count(f"restyler_{job_id}_hair.png") == 1
    assert comfy.upload_log.count(f"restyler_{job_id}_source.png") == 1
    assert spent() == 7


def test_kontext_step_has_mask_and_feather_from_the_mask(env):
    client, comfy, _ = env
    the_mask = png(2000, 1000)
    r = post(client, [edit("hair", "source", mask=b64(the_mask))], png(2000, 1000))
    finish(client, r.json()["job_id"])
    wf = comfy.prompts[0]["wf"]
    assert wf["15"]["inputs"]["image"] == f"in/restylermask_{r.json()['job_id']}_hair.png"
    assert comfy.uploads[f"restylermask_{r.json()['job_id']}_hair.png"] == the_mask
    expand, blur = hairmask.feather_px(2000, 1000)
    grow = next(n for n in wf.values() if n["class_type"] == "GrowMaskWithBlur")
    assert grow["inputs"]["expand"] == expand and grow["inputs"]["blur_radius"] == blur
    assert wf["8"]["inputs"]["text"] == "hair"


def test_sdxl_step_has_checkpoint_and_latent_of_its_input(env):
    client, comfy, _ = env
    comfy.output_size = (120, 80)  # landscape, unlike the portrait source
    steps = [
        edit("hair", "source"),
        style("s1", graph="restyle_sdxl", medium="illustration", negative="ugly"),
    ]
    finish(client, post(client, steps).json()["job_id"])
    wf = comfy.prompts[1]["wf"]
    by_class = {n["class_type"]: n for n in wf.values()}
    assert by_class["CheckpointLoaderSimple"]["inputs"]["ckpt_name"] == SDXL_CKPT
    latent = by_class["EmptyLatentImage"]["inputs"]
    assert latent["width"] > latent["height"]
    assert "ugly" in json.dumps(wf)


def test_flux_step_ignores_medium(env):
    client, comfy, _ = env
    r = post(client, [style("s1", "source", medium="photo")])
    assert finish(client, r.json()["job_id"])["status"] == "done"
    assert "__CKPT__" not in json.dumps(comfy.prompts[0]["wf"])


def test_failed_edit_skips_dependents_and_refunds_them(env):
    client, comfy, _ = env
    comfy.fail_on["hair"] = "ComfyUI: no face"
    r = post(client, chain())
    body = finish(client, r.json()["job_id"])
    assert body["status"] == "done" and body["done"] == 2
    st = statuses(body)
    assert st["beard"] == st["glasses"] == "done"
    assert st["hair"] == "error" and body["steps"]["hair"]["error"] == "ComfyUI: no face"
    assert all(st[s] == "skipped" for s in ("s1", "s2", "s3", "s4"))
    assert "error" not in body["steps"]["s1"]
    assert len(comfy.prompts) == 3  # nothing rendered for the skipped ones
    assert spent() == 2


def test_failed_style_refunds_one(env):
    client, comfy, _ = env
    comfy.fail_on["s2"] = "boom"
    body = finish(client, post(client, chain()).json()["job_id"])
    assert body["status"] == "done"
    assert statuses(body)["s2"] == "error"
    assert sum(v == "done" for v in statuses(body).values()) == 6
    assert spent() == 6


def test_everything_failing_ends_in_error_and_refunds_all(env):
    client, comfy, _ = env
    comfy.fail_on["beard"] = "boom"
    body = finish(client, post(client, chain()).json()["job_id"])
    assert body["status"] == "error" and body["done"] == 0
    assert spent() == 0


def test_source_upload_failure_refunds_everything(env):
    client, comfy, _ = env
    comfy.fail_upload.add("_source.png")
    body = finish(client, post(client, chain()).json()["job_id"])
    assert body["status"] == "error"
    assert body["steps"]["beard"]["error"] == "the render server is unavailable"
    assert spent() == 0


def test_a_skip_cascades_through_a_chain(env):
    client, comfy, _ = env
    comfy.fail_on["a"] = "boom"
    steps = [edit("a", "source"), edit("b", "a"), edit("c", "b")]
    body = finish(client, post(client, steps).json()["job_id"])
    assert statuses(body) == {"a": "error", "b": "skipped", "c": "skipped"}
    assert spent() == 0


def test_concurrency_window_is_never_exceeded_and_is_used(env):
    client, comfy, _ = env
    comfy.delay = 0.02
    finish(client, post(client, [style(f"s{i}", "source") for i in range(8)]).json()["job_id"])
    assert comfy.peak == appmod.config.RENDER_CONCURRENCY == 2


def test_step_download_and_healthz(env, tmp_path):
    client, comfy, _ = env
    r = post(client, [style("s1", "source")])
    job_id = r.json()["job_id"]
    finish(client, job_id)
    res = client.get(f"/api/jobs/{job_id}/step/s1", headers=HEADERS)
    assert res.status_code == 200
    assert res.headers["content-type"] == "image/png"
    assert res.content == comfy.outputs["s1"]
    assert (tmp_path / "outputs" / f"{job_id}_s1.png").is_file()
    assert client.get("/healthz").json() == {"status": "ok", "active_jobs": 0}


def test_step_is_404_until_done(env):
    client, comfy, _ = env
    comfy.delay = 0.3
    job_id = post(client, [style("s1", "source")]).json()["job_id"]
    assert client.get(f"/api/jobs/{job_id}/step/s1", headers=HEADERS).status_code == 404
    assert client.get("/healthz").json()["active_jobs"] == 1
    finish(client, job_id)


def test_failed_and_unknown_step_are_404(env):
    client, comfy, _ = env
    comfy.fail_on["s1"] = "boom"
    steps = [style("s1", "source"), style("s2", "source")]
    job_id = post(client, steps).json()["job_id"]
    finish(client, job_id)
    assert client.get(f"/api/jobs/{job_id}/step/s1", headers=HEADERS).status_code == 404
    assert client.get(f"/api/jobs/{job_id}/step/nope", headers=HEADERS).status_code == 404
    assert client.get(f"/api/jobs/{job_id}/step/..%2F..%2Ft", headers=HEADERS).status_code == 404


def test_foreign_job_is_404(env):
    client, _, _ = env
    other = {**HEADERS, "X-User": "someone"}
    job_id = post(client, [style("s1", "source")]).json()["job_id"]
    finish(client, job_id)
    assert client.get(f"/api/jobs/{job_id}", headers=other).status_code == 404
    assert client.get(f"/api/jobs/{job_id}/step/s1", headers=other).status_code == 404


def test_other_job_kinds_keep_their_status_shape(env):
    client, _, _ = env
    job = appmod.Job(user_id=appmod.app_user_id("ol1n"), prompt="x", workflow="flux", status="running")
    appmod.jobs.add(job)
    body = client.get(f"/api/jobs/{job.id}", headers=HEADERS).json()
    assert set(body) == {"status", "error", "kind", "beat", "beats", "phase", "position"}
    assert client.get(f"/api/jobs/{job.id}/step/x", headers=HEADERS).status_code == 404


def test_402_spends_nothing_and_queues_nothing(env, monkeypatch):
    client, comfy, _ = env
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 6)
    r = post(client, chain())
    assert r.status_code == 402
    assert comfy.upload_log == [] and comfy.prompts == []
    assert spent() == 0


def test_429_while_a_render_runs(env):
    client, comfy, _ = env
    comfy.delay = 0.2
    first = post(client, [style("s1", "source")])
    assert post(client, [style("s1", "source")]).status_code == 429
    assert spent() == 1
    finish(client, first.json()["job_id"])


@pytest.mark.parametrize(
    "steps",
    [
        pytest.param([style("a", "b"), style("b", "source")], id="forward-reference"),
        pytest.param([style("a", "a")], id="self-cycle"),
        pytest.param([style("a", "nope")], id="unknown-input"),
        pytest.param([style("a", "source"), style("a", "source")], id="duplicate-id"),
        pytest.param([style("source", "source")], id="reserved-id"),
        pytest.param([style("a", "source", mask=b64(png()))], id="mask-on-restyle"),
        pytest.param([{**edit("a", "source"), "mask": None}], id="kontext-without-mask"),
        pytest.param([edit("a", "source", mask=b64(png(10, 10)))], id="mask-size"),
        pytest.param([edit("a", "source", mask="%%%")], id="mask-not-base64"),
        pytest.param([edit("a", "source", mask=b64(b"\xff\xd8jpeg"))], id="mask-not-png"),
        pytest.param([style("a", "source", graph="flux_manga")], id="graph-not-whitelisted"),
        pytest.param([style("a", "source", prompt="")], id="empty-prompt"),
        pytest.param([style("a", "source", prompt="x" * 4001)], id="long-prompt"),
        pytest.param([style("a", "source", negative="x" * 4001)], id="long-negative"),
        pytest.param([style("a", "source", graph="restyle_sdxl")], id="sdxl-without-medium"),
        pytest.param([style("../x", "source")], id="step-id-traversal"),
        pytest.param([style("a/b", "source")], id="step-id-slash"),
        pytest.param([style("a\n", "source")], id="step-id-newline"),
        pytest.param([style("A", "source")], id="step-id-upper"),
        pytest.param([style("x" * 17, "source")], id="step-id-long"),
        pytest.param([style(f"s{i}", "source") for i in range(13)], id="13-steps"),
        pytest.param([], id="no-steps"),
        pytest.param([style("a", "source"), edit("b", "a")], id="edit-after-restyle"),
        pytest.param([style("a", "source", motion="smile")], id="motion-on-restyle"),
    ],
)
def test_invalid_plans_are_422_and_free(env, steps):
    client, comfy, _ = env
    assert post(client, steps).status_code == 422
    assert comfy.upload_log == [] and spent() == 0


@pytest.mark.parametrize(
    "source",
    [b"not an image", png()[:20], b"RIFF....WEBPVP8 "],
    ids=["garbage", "truncated", "webp"],
)
def test_unusable_source_is_422(env, source):
    client, _, _ = env
    assert post(client, [style("a", "source")], source).status_code == 422


def test_source_over_the_base64_limit_is_422(env):
    client, _, _ = env
    body = {"source": "A" * (appmod.config.MAX_RESTYLE_IMAGE_B64_CHARS + 1), "steps": [style("a", "source")]}
    assert client.post("/api/render", json=body, headers=HEADERS).status_code == 422


def test_mask_over_the_base64_limit_is_422(env):
    client, _, _ = env
    assert post(client, [edit("a", "source", mask="A" * 2_000_001)]).status_code == 422


def bomb_png(w, h) -> bytes:
    """A valid header claiming w×h pixels, no pixels behind it."""
    import struct
    import zlib

    ihdr = struct.pack(">IIBBBBB", w, h, 8, 0, 0, 0, 0)
    chunk = b"IHDR" + ihdr
    return (
        b"\x89PNG\r\n\x1a\n" + struct.pack(">I", 13) + chunk
        + struct.pack(">I", zlib.crc32(chunk)) + b"\x00" * 16
    )


def test_decompression_bomb_source_is_refused_from_the_header(env):
    client, comfy, _ = env
    assert post(client, [style("a", "source")], bomb_png(30000, 30000)).status_code == 422
    assert comfy.upload_log == []


def test_decompression_bomb_mask_is_refused_by_the_size_check(env):
    client, _, _ = env
    assert post(client, [edit("a", "source", mask=b64(bomb_png(30000, 30000)))]).status_code == 422


def test_mask_with_the_right_size_but_broken_body_is_422(env):
    client, _, _ = env
    assert post(client, [edit("a", "source", mask=b64(bomb_png(64, 96)))]).status_code == 422


def exif_jpeg(w, h, orientation) -> bytes:
    exif = Image.Exif()
    exif[0x0112] = orientation
    buf = io.BytesIO()
    Image.new("RGB", (w, h), (120, 90, 60)).save(buf, "JPEG", exif=exif)
    return buf.getvalue()


def test_rotated_jpeg_takes_a_mask_of_the_upright_size(env):
    client, _, _ = env
    source = exif_jpeg(400, 300, 6)  # stored landscape, displayed portrait
    r = post(client, [edit("a", "source", mask=b64(png(300, 400)))], source)
    assert r.status_code == 200
    assert finish(client, r.json()["job_id"])["status"] == "done"


def test_rotated_jpeg_refuses_a_mask_of_the_stored_size(env):
    client, _, _ = env
    source = exif_jpeg(400, 300, 6)
    assert post(client, [edit("a", "source", mask=b64(png(400, 300)))], source).status_code == 422


def test_unrotated_jpeg_keeps_its_size(env):
    client, _, _ = env
    source = exif_jpeg(400, 300, 1)
    assert post(client, [edit("a", "source", mask=b64(png(400, 300)))], source).status_code == 200


def test_rotated_jpeg_picks_the_latent_of_the_upright_photo(env):
    client, comfy, _ = env
    r = post(client, [style("a", "source", graph="restyle_sdxl", medium="photo")], exif_jpeg(1200, 800, 6))
    finish(client, r.json()["job_id"])
    latent = next(
        n for n in comfy.prompts[0]["wf"].values() if n["class_type"] == "EmptyLatentImage"
    )["inputs"]
    assert latent["height"] > latent["width"]


# --- live_portrait -----------------------------------------------------------

def live(step_id="v", input_="source", motion="smile"):
    return {"id": step_id, "graph": "live_portrait", "input": input_, "motion": motion}


def wan(step_id="w", input_="source", motion="hair-breeze"):
    return {"id": step_id, "graph": "wan_motion", "input": input_, "motion": motion}


def test_live_step_gets_driver_and_returns_mp4(env):
    client, comfy, _ = env
    r = post(client, [live()])
    assert r.json()["cost"] == 1
    job_id = r.json()["job_id"]
    body = finish(client, job_id)
    assert body["steps"]["v"] == {"status": "done", "kind": "video"}
    wf = comfy.prompts[0]["wf"]
    by_class = {n["class_type"]: n for n in wf.values()}
    assert by_class["VHS_LoadVideo"]["inputs"]["video"] == "in/tsumiki_driver_smile.mp4"
    assert comfy.uploads["tsumiki_driver_smile.mp4"] == b"driver-bytes"
    res = client.get(f"/api/jobs/{job_id}/step/v", headers=HEADERS)
    assert res.headers["content-type"] == "video/mp4" and res.content == b"mp4-0"
    assert spent() == 1


def test_driver_is_uploaded_once_and_only_when_used(env):
    client, comfy, _ = env
    assert not any("driver" in n for n in comfy.upload_log)  # nothing at startup
    finish(client, post(client, [live("a"), live("b")]).json()["job_id"])
    job = post(client, [live("c")]).json()["job_id"]
    finish(client, job)
    assert comfy.upload_log.count("tsumiki_driver_smile.mp4") == 1


def test_rejected_graph_forgets_the_driver(env):
    client, comfy, _ = env
    comfy.reject_next = True
    body = finish(client, post(client, [live()]).json()["job_id"])
    assert body["status"] == "error" and spent() == 0
    finish(client, post(client, [live()]).json()["job_id"])
    assert comfy.upload_log.count("tsumiki_driver_smile.mp4") == 2


def test_live_input_is_the_previous_step(env):
    client, comfy, _ = env
    steps = [edit("hair", "source"), live("v", "hair")]
    finish(client, post(client, steps).json()["job_id"])
    wf = comfy.prompts[1]["wf"]
    assert comfy.uploads[_image_name(wf).removeprefix("in/")] == comfy.outputs["hair"]


def test_live_input_is_scaled_to_1080_and_even(env):
    client, comfy, _ = env
    job_id = post(client, [live()], png(2001, 1001)).json()["job_id"]
    finish(client, job_id)
    with Image.open(io.BytesIO(comfy.uploads[f"restylerlive_{job_id}_v.png"])) as im:
        assert im.size == (1080, 540)


def test_fit_for_video_leaves_a_fitting_photo_alone():
    data = png(64, 96)
    assert render.fit_for_video(data) is data


def test_fit_for_video_rotates_upright():
    with Image.open(io.BytesIO(render.fit_for_video(exif_jpeg(400, 300, 6)))) as im:
        assert im.size == (300, 400)


def test_video_output_cannot_be_an_input(env):
    client, _, _ = env
    assert post(client, [live("v"), style("s", "v")]).status_code == 422
    assert post(client, [wan("w"), edit("e", "w")]).status_code == 422
    assert post(client, [live("v"), live("x", "v")]).status_code == 422


@pytest.mark.parametrize(
    "step",
    [
        pytest.param(live(motion="nope"), id="unknown"),
        pytest.param(live(motion="hair-breeze"), id="wan-preset-on-live"),
        pytest.param(wan(motion="smile"), id="live-preset-on-wan"),
        pytest.param({**live(), "motion": None}, id="live-without-motion"),
        pytest.param({**wan(), "motion": None}, id="wan-without-motion"),
        pytest.param({**live(), "mask": b64(png())}, id="mask-on-live"),
        pytest.param({**wan(), "mask": b64(png())}, id="mask-on-wan"),
    ],
)
def test_invalid_motion_steps_are_422(env, step):
    client, _, _ = env
    assert post(client, [step]).status_code == 422
    assert spent() == 0


def test_missing_driver_is_422_motion_not_available(env):
    client, comfy, _ = env
    r = post(client, [live(motion="blink")])
    assert r.status_code == 422 and r.json()["detail"] == "motion not available"
    assert comfy.upload_log == []


def test_no_manifest_means_no_motions(tmp_path):
    assert appmod.config.load_motions(tmp_path) == {}
    (tmp_path / "manifest.json").write_text("{broken")
    assert appmod.config.load_motions(tmp_path) == {}


def test_repo_manifest_loads_and_tolerates_missing_clips():
    motions = appmod.config.load_motions(appmod.config.DRIVERS_DIR)
    assert set(motions) >= {"blink", "glance", "look-around", "smile", "nod", "alive", "hair-breeze"}
    assert motions["hair-breeze"]["engine"] == "wan" and motions["hair-breeze"]["prompt"]
    assert all({"driver", "seconds", "engine", "loop"} <= set(m) for m in motions.values())


# --- wan_motion --------------------------------------------------------------

def test_wan_step_costs_five_and_returns_mp4(env):
    client, _, video = env
    r = post(client, [wan()], png(64, 96))
    assert r.json()["cost"] == 5 and r.json()["steps_total"] == 1
    assert spent() == 5
    job_id = r.json()["job_id"]
    body = finish(client, job_id)
    assert body["steps"]["w"]["kind"] == "video" and body["status"] == "done"
    assert video.submitted[0]["prompt"] == "a breeze" and video.submitted[0]["beats"] == 1
    res = client.get(f"/api/jobs/{job_id}/step/w", headers=HEADERS)
    assert res.content == b"wan-mp4" and res.headers["content-type"] == "video/mp4"
    assert spent() == 5


def test_wan_failure_refunds_all_five(env):
    client, _, video = env
    video.statuses = [{"status": "error", "error": "Traceback…"}]
    body = finish(client, post(client, [wan()]).json()["job_id"])
    assert body["steps"]["w"]["error"] == "the render server could not finish it, please try again"
    assert spent() == 0


def test_wan_submit_failure_refunds_all_five(env):
    client, _, video = env
    video.fail_submit = True
    body = finish(client, post(client, [wan()]).json()["job_id"])
    assert body["status"] == "error" and spent() == 0


def test_wan_server_restart_refunds(env):
    client, _, video = env
    video.statuses = [VideoJobGone("remote-1")]
    finish(client, post(client, [wan()]).json()["job_id"])
    assert spent() == 0


def test_wan_survives_a_blip_in_polling(env):
    client, _, video = env
    video.statuses = [aiohttp.ClientError("blip"), {"status": "done"}]
    assert finish(client, post(client, [wan()]).json()["job_id"])["status"] == "done"
    assert spent() == 5


def test_refund_returns_only_the_failed_steps_price(env):
    client, comfy, video = env
    video.statuses = [{"status": "error"}]
    steps = [style("s", "source"), wan("w", "source"), live("v", "source")]
    r = post(client, steps)
    assert r.json()["cost"] == 7
    body = finish(client, r.json()["job_id"])
    assert statuses(body) == {"s": "done", "w": "error", "v": "done"}
    assert spent() == 2


def test_wan_after_a_failed_edit_is_skipped_with_full_refund(env):
    client, comfy, video = env
    comfy.fail_on["hair"] = "boom"
    body = finish(client, post(client, [edit("hair", "source"), wan("w", "hair")]).json()["job_id"])
    assert statuses(body) == {"hair": "error", "w": "skipped"}
    assert video.submitted == [] and spent() == 0


def test_cost_counts_against_the_quota(env, monkeypatch):
    client, comfy, _ = env
    monkeypatch.setattr(appmod.config, "FREE_DAILY_LIMIT", 4)
    assert post(client, [wan()]).status_code == 402
