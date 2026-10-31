"""POST /api/render and POST /api/live.

Restyler keeps its logic (masks, prompts, step order) on the phone; this is the
dumb renderer behind it. A request is a small DAG of steps from a whitelist of
graphs: a step runs when its input exists, its output is uploaded back into
ComfyUI as the input of the next one, and the phone only polls and downloads.

Money: every step owns its usage rows. A failed step refunds all of them, and
the steps that depended on it are `skipped` and refunded without rendering.

/api/live is the Telegram counterpart of a `live_portrait` step: same graph,
one image credit, the clip goes to the chat.

Lives apart from app.py, which binds itself here at import (see `bind`): the
globals are read through `_host` at request time, so app.py stays the one place
that owns the bot, the database and the clients.
"""

import asyncio
import base64
import io
import logging
import random
import time
from dataclasses import dataclass, field
from pathlib import Path
from types import ModuleType
from typing import Literal

import aiohttp
from aiogram.exceptions import TelegramForbiddenError
from aiogram.types import FSInputFile
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import FileResponse
from PIL import Image, ImageOps
from pydantic import BaseModel, Field

import config
import hairmask
from comfy import ComfyError, prepare_workflow
from imagesize import image_size, snap_to_sdxl_bucket
from jobs import Job
from video import VideoError, VideoJobGone

log = logging.getLogger("mangabot")

router = APIRouter()
_host: ModuleType | None = None

SOURCE = "source"
EXIF_ORIENTATION = 0x0112
# Orientations that swap width and height.
EXIF_TRANSPOSED = (5, 6, 7, 8)
# Graphs that output an mp4, which no later step can read.
VIDEO_GRAPHS = ("live_portrait", "wan_motion")
IMAGE_GRAPHS = ("kontext_edit", "restyle_flux", "restyle_sdxl")
_MEDIA_TYPES = {"image": "image/png", "video": "video/mp4"}

# Motion id → the name it has in ComfyUI's input folder. Filled on first use:
# ComfyUI need not be up when this service starts.
_driver_names: dict[str, str] = {}
_driver_locks: dict[str, asyncio.Lock] = {}
_tasks: set[asyncio.Task] = set()


def bind(host: ModuleType) -> None:
    global _host
    _host = host


def _user(request: Request) -> int:
    return _host.current_user_id(request)


def _spawn(coro) -> None:
    task = asyncio.create_task(coro)
    _tasks.add(task)
    task.add_done_callback(_tasks.discard)


# --- Contract ----------------------------------------------------------------

class RenderStep(BaseModel):
    id: str = Field(pattern=r"^[a-z0-9_-]{1,16}$")
    graph: Literal["kontext_edit", "restyle_flux", "restyle_sdxl", "live_portrait", "wan_motion"]
    input: str = Field(max_length=16)  # "source" | id of an earlier step
    # Required for the image graphs; a motion preset carries its own.
    prompt: str = Field(default="", max_length=config.MAX_PROMPT_CHARS)
    negative: str = Field(default="", max_length=config.MAX_PROMPT_CHARS)
    mask: str | None = Field(default=None, max_length=config.MAX_MASK_B64_CHARS)  # kontext_edit
    medium: Literal["photo", "illustration"] | None = None  # picks the restyle_sdxl checkpoint
    motion: str | None = Field(default=None, max_length=40)  # live_portrait, wan_motion


class RenderRequest(BaseModel):
    source: str = Field(min_length=1, max_length=config.MAX_RESTYLE_IMAGE_B64_CHARS)
    steps: list[RenderStep] = Field(min_length=1, max_length=config.RENDER_MAX_STEPS)


class LiveRequest(BaseModel):
    motion: str = Field(min_length=1, max_length=40)
    image: str = Field(min_length=1, max_length=config.MAX_RESTYLE_IMAGE_B64_CHARS)


@dataclass
class StepState:
    kind: str  # image | video
    status: str = "queued"  # queued | running | done | error | skipped
    error: str | None = None
    path: Path | None = None
    usage_ids: list[int] = field(default_factory=list)


@dataclass
class RenderJob(Job):
    steps: dict[str, StepState] = field(default_factory=dict)


@dataclass
class _Plan:
    source: bytes
    masks: dict[str, bytes]
    cost: int


def job_payload(job: RenderJob) -> dict:
    steps = {}
    for step_id, state in job.steps.items():
        steps[step_id] = {"status": state.status, "kind": state.kind}
        if state.error is not None:
            steps[step_id]["error"] = state.error
    return {
        "status": job.status,
        "done": sum(1 for s in job.steps.values() if s.status == "done"),
        "total": len(job.steps),
        "steps": steps,
    }


def step_cost(graph: str) -> int:
    return config.RENDER_VIDEO_COST if graph == "wan_motion" else 1


# --- Validation: nothing is spent or uploaded before all of this passes -------

def _refuse(detail: str) -> HTTPException:
    return HTTPException(status_code=422, detail=detail)


def _decode(b64: str, what: str) -> bytes:
    try:
        return _host._decode_image(b64)
    except HTTPException as e:
        raise _refuse(f"{what}: {e.detail}") from e


def photo_size(data: bytes, what: str = "source") -> tuple[int, int]:
    """(width, height) as ComfyUI's LoadImage will see the photo.

    LoadImage applies the EXIF orientation and imagesize reads the container,
    so a phone JPEG stored as 4032x3024 with orientation 6 really is 3024x4032
    — and that is the size a mask made on the upright photo has. The pixel cap
    runs on the header alone, before Pillow touches the file."""
    size = image_size(data)
    if size is None:
        raise _refuse(f"{what} must be a PNG or JPEG")
    if size[0] * size[1] > config.RENDER_MAX_PIXELS:
        raise _refuse(f"{what} is too large")
    try:
        with Image.open(io.BytesIO(data)) as im:
            orientation = im.getexif().get(EXIF_ORIENTATION, 1)
    except (OSError, ValueError, SyntaxError, Image.DecompressionBombError) as e:
        raise _refuse(f"{what} is not a readable image") from e
    return (size[1], size[0]) if orientation in EXIF_TRANSPOSED else size


def _check_mask(step: RenderStep, source_size: tuple[int, int]) -> bytes:
    what = f"step {step.id}: mask"
    if step.mask is None:
        raise _refuse(f"{what} is required for kontext_edit")
    mask = _decode(step.mask, what)
    size = image_size(mask)
    if size is None or mask[:4] != b"\x89PNG":
        raise _refuse(f"{what} must be a PNG")
    if size != source_size:
        raise _refuse(f"{what} is {size[0]}x{size[1]}, the source is {source_size[0]}x{source_size[1]}")
    try:
        with Image.open(io.BytesIO(mask)) as im:
            im.verify()
    except (OSError, ValueError, SyntaxError, Image.DecompressionBombError) as e:
        raise _refuse(f"{what} is not a readable PNG") from e
    return mask


def _check_motion(motion: str | None, engine: str) -> dict:
    preset = config.MOTIONS.get(motion or "")
    if preset is None or preset.get("engine") != engine:
        raise _refuse(f"unknown motion '{motion}'")
    if engine == "live" and _driver_path(preset) is None:
        raise _refuse("motion not available")
    if engine == "wan" and not preset.get("prompt"):
        raise _refuse("motion not available")
    return preset


def _driver_path(preset: dict) -> Path | None:
    """The driver clip, or None when it has not been generated yet. `.name`:
    the manifest is ours, but it should not be able to name a path."""
    name = Path(preset.get("driver") or "").name
    path = config.DRIVERS_DIR / name
    return path if name and path.is_file() else None


def _validate_plan(req: RenderRequest) -> _Plan:
    source = _decode(req.source, SOURCE)
    size = photo_size(source)
    seen: dict[str, RenderStep] = {}
    masks: dict[str, bytes] = {}
    for step in req.steps:
        if step.id == SOURCE:
            raise _refuse("'source' is reserved and cannot be a step id")
        if step.id in seen:
            raise _refuse(f"duplicate step id '{step.id}'")
        parent = seen.get(step.input)
        if parent is None and step.input != SOURCE:
            raise _refuse(f"step {step.id}: input '{step.input}' is not an earlier step")
        if parent is not None and parent.graph in VIDEO_GRAPHS:
            raise _refuse(f"step {step.id}: input '{step.input}' is a video")
        if step.graph == "kontext_edit":
            # Masks are made on the source; only an edit keeps its geometry.
            if parent is not None and parent.graph != "kontext_edit":
                raise _refuse(f"step {step.id}: the mask does not fit the output of '{parent.id}'")
            masks[step.id] = _check_mask(step, size)
        elif step.mask is not None:
            raise _refuse(f"step {step.id}: mask is only for kontext_edit")
        if step.graph in IMAGE_GRAPHS:
            if not step.prompt.strip():
                raise _refuse(f"step {step.id}: prompt is required")
            if step.motion is not None:
                raise _refuse(f"step {step.id}: motion is only for live_portrait and wan_motion")
        if step.graph == "restyle_sdxl" and step.medium is None:
            raise _refuse(f"step {step.id}: medium is required for restyle_sdxl")
        if step.graph == "live_portrait":
            _check_motion(step.motion, "live")
        if step.graph == "wan_motion":
            _check_motion(step.motion, "wan")
        seen[step.id] = step
    return _Plan(source, masks, sum(step_cost(s.graph) for s in req.steps))


def fit_for_video(data: bytes) -> bytes:
    """The photo a clip starts from: upright, long side ≤ LIVE_MAX_SIDE, even
    sides (h264 yuv420p needs them; VHS would pad a black line otherwise).
    Returns `data` itself when it already is all of that."""
    with Image.open(io.BytesIO(data)) as im:
        upright = im.getexif().get(EXIF_ORIENTATION, 1) in (0, 1)
        w, h = im.size if upright else ImageOps.exif_transpose(im).size
        scale = min(1.0, config.LIVE_MAX_SIDE / max(w, h))
        target = (max(2, round(w * scale)) & ~1, max(2, round(h * scale)) & ~1)
        if upright and target == (w, h):
            return data
        out = ImageOps.exif_transpose(im).convert("RGB").resize(target, Image.Resampling.LANCZOS)
    buf = io.BytesIO()
    out.save(buf, "PNG")
    return buf.getvalue()


async def _ensure_driver(session: aiohttp.ClientSession, motion: str) -> str:
    """Uploads the driver clip on first use; one upload however many steps ask."""
    lock = _driver_locks.setdefault(motion, asyncio.Lock())
    async with lock:
        name = _driver_names.get(motion)
        if name is None:
            path = _driver_path(config.MOTIONS[motion])
            if path is None:
                raise ComfyError("motion not available")
            name = await _host.comfy.upload_image(
                session, path.read_bytes(), f"tsumiki_driver_{motion}.mp4"
            )
            _driver_names[motion] = name
        return name


def _live_workflow(image_name: str, driver_name: str) -> dict:
    template = _host._load_template_file("live_portrait", config.RENDER_GRAPHS["live_portrait"])
    return prepare_workflow(template, prompt="", image_name=image_name, driver_name=driver_name)


async def _queue_live(session: aiohttp.ClientSession, wf: dict, motion: str) -> tuple[str, int]:
    """A rejected graph may mean the clip is gone from ComfyUI's input folder;
    forget it, so the next attempt uploads it again."""
    try:
        return await _host.comfy.queue_prompt(session, wf)
    except ComfyError:
        _driver_names.pop(motion, None)
        raise


# --- POST /api/render --------------------------------------------------------

@router.post("/api/render")
async def post_render(req: RenderRequest, user_id: int = Depends(_user)):
    plan = await asyncio.to_thread(_validate_plan, req)
    # No await from here to jobs.add, so two requests cannot both pass the
    # one-at-a-time check.
    h = _host
    if h.jobs.active_count(user_id, "render") >= 1:
        raise HTTPException(status_code=429, detail="wait for your previous render to finish")
    usage = h.db.spend_generations(user_id, config.FREE_DAILY_LIMIT, plan.cost)
    if usage is None:
        raise HTTPException(
            status_code=402,
            detail="your free daily limit is used up and you have no credits",
        )
    job = RenderJob(user_id=user_id, prompt="", workflow="render", kind="render", status="running")
    position = 0
    for step in req.steps:
        cost = step_cost(step.graph)
        job.steps[step.id] = StepState(
            kind="video" if step.graph in VIDEO_GRAPHS else "image",
            usage_ids=usage[position : position + cost],
        )
        position += cost
    h.jobs.add(job)
    _spawn(_watch_render(job, req.steps, plan))
    log.info("render job %s for user %s: %d steps, cost %d", job.id, user_id, len(req.steps), plan.cost)
    return {"job_id": job.id, "steps_total": len(req.steps), "cost": plan.cost}


class _StepFailed(Exception):
    """A failure the user may read."""


def _abandon(state: StepState, status: str, error: str | None = None) -> None:
    """The one way a step ends unsuccessfully; refunds exactly once."""
    state.status = status
    state.error = error
    usage_ids, state.usage_ids = state.usage_ids, []
    for usage_id in usage_ids:
        _host.db.undo_usage(usage_id)


class _RenderRun:
    def __init__(self, job: RenderJob, plan: _Plan, session: aiohttp.ClientSession):
        self.job = job
        self.plan = plan
        self.session = session
        self.window = asyncio.Semaphore(config.RENDER_CONCURRENCY)
        self.outputs: dict[str, bytes] = {SOURCE: plan.source}
        self.comfy_names: dict[str, str] = {}
        self.upload_lock = asyncio.Lock()

    async def _comfy_name(self, key: str) -> str:
        """An output (or the source) in ComfyUI's input folder, uploaded once
        however many steps read it."""
        async with self.upload_lock:
            if key not in self.comfy_names:
                self.comfy_names[key] = await _host.comfy.upload_image(
                    self.session, self.outputs[key], f"restyler_{self.job.id}_{key}.png"
                )
            return self.comfy_names[key]

    async def _edit_or_restyle(self, step: RenderStep) -> bytes:
        h = _host
        image_name = await self._comfy_name(step.input)
        template = h._load_template_file(step.graph, config.RENDER_GRAPHS[step.graph])
        if step.graph == "kontext_edit":
            mask = self.plan.masks[step.id]
            # Prefix of its own: a step called `x_mask` must not overwrite this.
            mask_name = await h.comfy.upload_image(
                self.session, mask, f"restylermask_{self.job.id}_{step.id}.png"
            )
            wf = prepare_workflow(
                template, prompt=step.prompt, negative=step.negative,
                image_name=image_name, mask_name=mask_name,
            )
            hairmask.apply_feather(wf, mask)
        else:
            width, height = photo_size(self.outputs[step.input])
            wf = prepare_workflow(
                template, prompt=step.prompt, negative=step.negative, image_name=image_name,
                checkpoint=config.RESTYLE_CHECKPOINTS[step.medium] if step.graph == "restyle_sdxl" else None,
                latent=snap_to_sdxl_bucket(width, height),
            )
        prompt_id, _ = await h.comfy.queue_prompt(self.session, wf, prompt=step.prompt)
        return await h.comfy.wait_for_output(
            self.session, prompt_id, kind="image", timeout=config.JOB_TIMEOUT
        )

    async def _live_portrait(self, step: RenderStep) -> bytes:
        h = _host
        original = self.outputs[step.input]
        fitted = await asyncio.to_thread(fit_for_video, original)
        if fitted is original:
            image_name = await self._comfy_name(step.input)
        else:
            image_name = await h.comfy.upload_image(
                self.session, fitted, f"restylerlive_{self.job.id}_{step.id}.png"
            )
        driver = await _ensure_driver(self.session, step.motion)
        prompt_id, _ = await _queue_live(self.session, _live_workflow(image_name, driver), step.motion)
        return await h.comfy.wait_for_output(
            self.session, prompt_id, kind="video", timeout=config.LIVE_TIMEOUT
        )

    async def _wan_motion(self, step: RenderStep) -> bytes:
        """_watch_video_job without the chat: the same poll, in the DAG."""
        h = _host
        fitted = await asyncio.to_thread(fit_for_video, self.outputs[step.input])
        resp = await h.video.submit_prompt(
            self.session, config.MOTIONS[step.motion]["prompt"],
            base64.b64encode(fitted).decode(), random.randrange(1 << 31), beats=1,
        )
        remote_id = resp["job_id"]
        deadline = time.time() + h._video_timeout(resp)
        failures = 0
        while True:
            await asyncio.sleep(config.RENDER_VIDEO_POLL)
            if time.time() > deadline:
                raise _StepFailed("the render timed out, please try again")
            try:
                status = await h.video.status(self.session, remote_id)
            except VideoJobGone as e:
                raise _StepFailed("the render server restarted, please try again") from e
            except (VideoError, aiohttp.ClientError, asyncio.TimeoutError) as e:
                failures += 1
                if failures >= 6:
                    raise _StepFailed("lost contact with the render server") from e
                log.warning("render %s/%s poll failed (%d/6): %s", self.job.id, step.id, failures, e)
                continue
            failures = 0
            if status.get("status") == "error":
                log.error("render %s/%s: video-api said %s", self.job.id, step.id, status.get("error"))
                raise _StepFailed("the render server could not finish it, please try again")
            if status.get("status") == "done":
                return await h.video.download(self.session, remote_id)

    async def _execute(self, step: RenderStep) -> bytes:
        if step.graph == "wan_motion":
            return await self._wan_motion(step)
        if step.graph == "live_portrait":
            return await self._live_portrait(step)
        return await self._edit_or_restyle(step)

    async def run_step(self, step: RenderStep, parent: asyncio.Task | None) -> None:
        if parent is not None:
            await parent
            if self.job.steps[step.input].status != "done":
                _abandon(self.job.steps[step.id], "skipped")
                return
        state = self.job.steps[step.id]
        async with self.window:
            state.status = "running"
            try:
                data = await self._execute(step)
                suffix = "mp4" if state.kind == "video" else "png"
                path = config.DATA_DIR / "outputs" / f"{self.job.id}_{step.id}.{suffix}"
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(data)
            except (_StepFailed, ComfyError) as e:
                log.error("render %s/%s failed: %s", self.job.id, step.id, e)
                _abandon(state, "error", str(e)[:200])
                return
            except (VideoError, aiohttp.ClientError, asyncio.TimeoutError) as e:
                log.error("render %s/%s failed: %s", self.job.id, step.id, e)
                _abandon(state, "error", "the render server is unavailable")
                return
            except Exception as e:  # noqa: BLE001 — a crash must still refund
                log.exception("render %s/%s crashed: %s", self.job.id, step.id, e)
                _abandon(state, "error", "internal error")
                return
        self.outputs[step.id] = data
        state.path = path
        state.usage_ids = []
        state.status = "done"


async def _watch_render(job: RenderJob, steps: list[RenderStep], plan: _Plan) -> None:
    tasks: dict[str, asyncio.Task] = {}
    try:
        async with aiohttp.ClientSession() as session:
            run = _RenderRun(job, plan, session)
            # A step's input is always an earlier step, so this is topological.
            for step in steps:
                tasks[step.id] = asyncio.create_task(run.run_step(step, tasks.get(step.input)))
            await asyncio.gather(*tasks.values())
    except Exception as e:  # noqa: BLE001 — watcher must never crash silently
        log.exception("render job %s crashed: %s", job.id, e)
        for task in tasks.values():
            task.cancel()
        for state in job.steps.values():
            if state.status in ("queued", "running"):
                _abandon(state, "error", "internal error")
    done = sum(1 for s in job.steps.values() if s.status == "done")
    job.status = "done" if done else "error"
    log.info("render job %s finished: %d/%d steps", job.id, done, len(job.steps))


@router.get("/api/jobs/{job_id}/step/{step_id}")
async def job_step(job_id: str, step_id: str, user_id: int = Depends(_user)):
    job = _host.jobs.get(job_id)
    if not isinstance(job, RenderJob) or job.user_id != user_id:
        raise HTTPException(status_code=404, detail="job not found")
    state = job.steps.get(step_id)
    if state is None or state.status != "done" or state.path is None:
        raise HTTPException(status_code=404, detail="step not available")
    return FileResponse(state.path, media_type=_MEDIA_TYPES[state.kind])


# --- POST /api/live (Tsumiki) ------------------------------------------------

def live_caption(motion: str, preset: dict) -> str:
    return f"🎞 {preset.get('label') or motion.replace('-', ' ').capitalize()}"


@router.post("/api/live")
async def post_live(req: LiveRequest, user_id: int = Depends(_user)):
    """Photo + preset → a short clip in the chat. One image generation, under
    the same one-at-a-time rule; the Mini App fetches it from /api/jobs/{id}/video."""
    h = _host
    preset = _check_motion(req.motion, "live")
    image = h._decode_image(req.image)
    photo_size(image, "image")
    image = await asyncio.to_thread(fit_for_video, image)
    if user_id in h._hair_analysing or h.jobs.active_count(user_id, "image") >= 1:
        raise HTTPException(status_code=429, detail="wait for your previous generation to finish")

    spend = h.db.spend_generation(user_id, config.FREE_DAILY_LIMIT)
    if spend is None:
        raise HTTPException(
            status_code=402,
            detail="your free daily limit is used up and you have no credits",
        )
    _, usage_id = spend
    job = Job(
        user_id=user_id, prompt="", workflow="live", status="running",
        caption=live_caption(req.motion, preset),
    )
    # Registered before the awaits below, which would otherwise let a second
    # request through the one-at-a-time check.
    h.jobs.add(job)
    async with aiohttp.ClientSession() as session:
        try:
            image_name = await h.comfy.upload_image(session, image, f"tsumiki_live_{job.id}.png")
            driver = await _ensure_driver(session, req.motion)
            wf = _live_workflow(image_name, driver)
            prompt_id, queue_number = await _queue_live(session, wf, req.motion)
        except (ComfyError, aiohttp.ClientError, asyncio.TimeoutError) as e:
            job.status = "error"
            job.error = "ComfyUI is unavailable"
            h.db.undo_usage(usage_id)
            log.error("live submit failed: %s", e)
            raise HTTPException(status_code=502, detail="ComfyUI is unavailable") from e
    job.prompt_id = prompt_id
    _spawn(_watch_live(job, usage_id))
    log.info("live job %s queued for user %s (%s)", job.id, user_id, req.motion)
    return {"job_id": job.id, "queue_position": queue_number}


async def _watch_live(job: Job, usage_id: int) -> None:
    h = _host
    try:
        async with aiohttp.ClientSession() as session:
            mp4 = await h.comfy.wait_for_output(
                session, job.prompt_id, kind="video", timeout=config.LIVE_TIMEOUT
            )
        path = config.DATA_DIR / "outputs" / f"{job.id}.mp4"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(mp4)
    except ComfyError as e:
        job.status = "error"
        job.error = str(e)
        h.db.undo_usage(usage_id)
        log.error("live job %s failed: %s", job.id, e)
        return
    except Exception as e:  # noqa: BLE001 — watcher must never crash silently
        job.status = "error"
        job.error = "internal error"
        h.db.undo_usage(usage_id)
        log.exception("live job %s crashed: %s", job.id, e)
        return
    job.video_path = path
    job.status = "done"
    log.info("live job %s done (%d bytes)", job.id, len(mp4))

    if job.user_id > 0 and h.bot is not None and len(mp4) <= config.TELEGRAM_VIDEO_LIMIT:
        try:
            await h.bot.send_animation(job.user_id, FSInputFile(path), caption=job.caption)
        except TelegramForbiddenError:
            # Same as an image: it still shows inside the app.
            log.info("live job %s: user %s has not started the bot", job.id, job.user_id)
        except Exception as e:  # noqa: BLE001
            log.warning("live job %s: send_animation failed: %s", job.id, e)
