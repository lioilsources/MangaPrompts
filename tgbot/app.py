"""Tsumiki Telegram bot backend (runs on the JODA NAS).

One asyncio process serving both:
- FastAPI REST API for the Mini App (generate → poll → download image,
  credit balance, Stars invoices), and
- the aiogram bot (long polling; /start button opening the Mini App;
  sendPhoto of every finished image; Stars payment handling).

ComfyUI itself runs on the SPARK box and is reached over the network
(COMFY_URL + optional CF Access headers). Credits and payments live in
SQLite (db.py); jobs are in-memory only.

Run: uvicorn app:app --host 0.0.0.0 --port 8090  (see docker-compose.yml)
"""

import asyncio
import json
import logging
import random
import time
import uuid
from contextlib import asynccontextmanager

import aiohttp
from aiogram import Bot, Dispatcher, F
from aiogram.exceptions import TelegramForbiddenError
from aiogram.filters import Command, CommandStart
from aiogram.types import (
    FSInputFile,
    InlineKeyboardButton,
    InlineKeyboardMarkup,
    LabeledPrice,
    Message,
    PreCheckoutQuery,
    WebAppInfo,
)
from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field

import config
import payments
from auth import InvalidInitData, validate_init_data
from comfy import ComfyClient, ComfyError, prepare_workflow
from db import Database
from jobs import Job, JobStore
from video import VideoClient, VideoError, VideoJobGone, strip_data_uri

log = logging.getLogger("mangabot")
logging.basicConfig(level=logging.INFO)

bot = Bot(token=config.BOT_TOKEN) if config.BOT_TOKEN else None
dp = Dispatcher()
jobs = JobStore()
db = Database(config.DB_PATH)

_comfy_headers = (
    {"CF-Access-Client-Id": config.COMFY_CF_ID, "CF-Access-Client-Secret": config.COMFY_CF_SECRET}
    if config.COMFY_CF_ID and config.COMFY_CF_SECRET
    else None
)
comfy = ComfyClient(config.COMFY_URL, client_id=uuid.uuid4().hex, headers=_comfy_headers)
_workflow_cache: dict[str, dict] = {}

_video_headers = (
    {"CF-Access-Client-Id": config.VIDEO_CF_ID, "CF-Access-Client-Secret": config.VIDEO_CF_SECRET}
    if config.VIDEO_CF_ID and config.VIDEO_CF_SECRET
    else None
)
video = VideoClient(config.VIDEO_URL, headers=_video_headers)
_scenes_cache: tuple[float, list[dict]] | None = None


def _english(scene: dict) -> dict:
    """The catalog is shared with Ol1nLLM, whose UI is Czech: label/desc are
    Czech and label_en/desc_en carry the English copy. Tsumiki is sold to a
    global market, so serve English under the plain keys — that way neither
    the Mini App nor the chat caption needs to know about the split."""
    out = dict(scene)
    out["label"] = scene.get("label_en") or scene["label"]
    out["desc"] = scene.get("desc_en") or scene.get("desc", "")
    out.pop("label_en", None)
    out.pop("desc_en", None)
    return out


async def _get_scenes() -> list[dict]:
    """Scene catalog with a TTL cache; a stale copy beats an error while the
    video-api restarts."""
    global _scenes_cache
    if _scenes_cache is not None and time.time() - _scenes_cache[0] < config.VIDEO_SCENES_TTL:
        return _scenes_cache[1]
    try:
        async with aiohttp.ClientSession() as session:
            scenes = await video.fetch_scenes(session)
    except (VideoError, aiohttp.ClientError, asyncio.TimeoutError):
        if _scenes_cache is not None:
            return _scenes_cache[1]
        raise
    scenes = [_english(sc) for sc in scenes]
    _scenes_cache = (time.time(), scenes)
    return scenes


# --- Telegram bot handlers ---------------------------------------------------

@dp.message(CommandStart())
async def on_start(message: Message) -> None:
    keyboard = InlineKeyboardMarkup(
        inline_keyboard=[
            [
                InlineKeyboardButton(
                    text="🎨 Open Tsumiki",
                    web_app=WebAppInfo(url=config.MINIAPP_URL),
                )
            ]
        ]
    )
    await message.answer(
        "Hi! Snap a prompt together from building blocks and generate a manga image. "
        "I'll send the finished image right here in the chat.\n\n"
        f"You get {config.FREE_DAILY_LIMIT} free generations a day, "
        "beyond that they cost Telegram Stars ⭐ right inside the app.\n\n"
        "You can also animate a photo into a short video 🎬 — "
        f"{config.VIDEO_FREE_DAILY_LIMIT} free per day.",
        reply_markup=keyboard,
    )


@dp.message(Command("paysupport"))
async def on_paysupport(message: Message) -> None:
    await message.answer(
        "Payment trouble? Send the transaction id here (Settings → "
        "Telegram Stars → Transactions) and describe what happened — I'll get back to you shortly. "
        "Refunds are handled within 48 hours."
    )


@dp.pre_checkout_query()
async def on_pre_checkout(query: PreCheckoutQuery) -> None:
    error = payments.validate_pre_checkout(
        query.invoice_payload, query.from_user.id, query.total_amount
    )
    if error is None:
        await query.answer(ok=True)
    else:
        log.warning("pre_checkout rejected for user %s: %s", query.from_user.id, error)
        await query.answer(ok=False, error_message=error)


@dp.message(F.successful_payment)
async def on_successful_payment(message: Message) -> None:
    sp = message.successful_payment
    parsed = payments.parse_payload(sp.invoice_payload)
    if parsed is None:
        # Should be impossible after pre-checkout validation — keep the money
        # trail in the log and resolve manually via /paysupport.
        log.error("successful_payment with bad payload: %s", sp.invoice_payload)
        return
    user_id, package_id = parsed
    package = config.PACKAGES[package_id]
    is_video = package.get("video", False)
    credited = db.add_payment(
        charge_id=sp.telegram_payment_charge_id,
        user_id=user_id,
        stars=sp.total_amount,
        credits=package["credits"],
        package=package_id,
        video=is_video,
    )
    if not credited:
        log.info("duplicate successful_payment %s ignored", sp.telegram_payment_charge_id)
        return
    balance = db.video_credits(user_id) if is_video else db.credits(user_id)
    log.info(
        "payment %s: user %s +%d %s (%d⭐), balance %d",
        sp.telegram_payment_charge_id, user_id, package["credits"],
        "video credits" if is_video else "credits", sp.total_amount, balance,
    )
    if is_video:
        await message.answer(
            f"Thanks! {package['credits']} animation credit added. "
            f"Animation credits: {balance}."
        )
    else:
        await message.answer(
            f"Thanks! {package['credits']} credits added. Current balance: {balance}."
        )


@dp.message(Command("refund"))
async def on_refund(message: Message) -> None:
    if config.ADMIN_USER_ID == 0 or message.from_user.id != config.ADMIN_USER_ID:
        return
    parts = (message.text or "").split(maxsplit=1)
    if len(parts) != 2:
        await message.answer("Usage: /refund <telegram_payment_charge_id>")
        return
    charge_id = parts[1].strip()
    payment = db.get_payment(charge_id)
    if payment is None:
        await message.answer("Payment not found.")
        return
    if payment["status"] != "paid":
        await message.answer(f"That payment is already in state '{payment['status']}'.")
        return
    try:
        await bot.refund_star_payment(
            user_id=payment["user_id"], telegram_payment_charge_id=charge_id
        )
    except Exception as e:  # noqa: BLE001
        await message.answer(f"refundStarPayment failed: {e}")
        return
    is_video = config.PACKAGES.get(payment["package"], {}).get("video", False)
    db.mark_refunded(charge_id, video=is_video)
    await message.answer(
        f"Refunded {payment['stars']}⭐ to user {payment['user_id']}, "
        f"{payment['credits']} {'animation' if is_video else ''} credits deducted."
    )


# --- FastAPI -----------------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    if bot is None:
        raise RuntimeError("BOT_TOKEN is not set")
    config.DATA_DIR.joinpath("outputs").mkdir(parents=True, exist_ok=True)
    # Re-attach watchers for video renders that were in flight when the bot
    # last stopped — video-api keeps its own state across our restarts.
    for row in db.video_jobs_pending():
        job = Job(
            user_id=row["user_id"], prompt="", workflow="video",
            id=row["job_id"], status="running", kind="video",
            scene_label=row["scene_label"], remote_id=row["remote_id"],
            created=row["created"],
        )
        jobs.add(job)
        asyncio.create_task(_watch_video_job(job, row["usage_id"]))
        log.info("re-attached video job %s (remote %s)", job.id, job.remote_id)
    polling = asyncio.create_task(dp.start_polling(bot, handle_signals=False))
    yield
    polling.cancel()
    await bot.session.close()


app = FastAPI(title="Tsumiki bot backend", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=config.ALLOWED_ORIGINS,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "Authorization"],
)


def current_user_id(request: Request) -> int:
    """Auth: `Authorization: tma <initData>` (validated) or `dev <token>` (opt-in)."""
    header = request.headers.get("Authorization", "")
    scheme, _, value = header.partition(" ")
    if scheme == "tma" and value:
        try:
            user = validate_init_data(value, config.BOT_TOKEN, config.AUTH_MAX_AGE)
        except InvalidInitData as e:
            raise HTTPException(status_code=401, detail=f"invalid initData: {e}") from e
        return int(user["id"])
    if scheme == "dev" and config.DEV_TOKEN and value == config.DEV_TOKEN:
        return 0  # dev user: no chat delivery
    raise HTTPException(status_code=401, detail="missing or invalid Authorization")


class GenerateRequest(BaseModel):
    prompt: str = Field(min_length=1, max_length=config.MAX_PROMPT_CHARS)
    negative_prompt: str = Field(default="", max_length=config.MAX_PROMPT_CHARS)
    workflow: str = "flux"


class AnimateRequest(BaseModel):
    scene: str
    image: str = Field(min_length=1, max_length=config.MAX_IMAGE_B64_CHARS)


class InvoiceRequest(BaseModel):
    package: str


def _load_template(workflow: str) -> dict:
    filename = config.WORKFLOW_FILES.get(workflow)
    if filename is None:
        raise HTTPException(status_code=400, detail=f"unknown workflow '{workflow}'")
    cached = _workflow_cache.get(workflow)
    if cached is None:
        path = config.WORKFLOW_DIR / filename
        cached = json.loads(path.read_text())
        _workflow_cache[workflow] = cached
    return cached


@app.get("/healthz")
async def healthz():
    return {"status": "ok"}


@app.get("/api/me")
async def me(user_id: int = Depends(current_user_id)):
    db.ensure_user(user_id)
    free_used = db.free_used_today(user_id)
    video_free_used = db.free_used_today(user_id, "video_free")
    return {
        "credits": db.credits(user_id),
        "free_remaining": max(0, config.FREE_DAILY_LIMIT - free_used),
        "free_limit": config.FREE_DAILY_LIMIT,
        "packages": [
            {"id": pid, "credits": p["credits"], "stars": p["stars"], "label": p["label"]}
            for pid, p in config.PACKAGES.items()
            if not p.get("video")
        ],
        "video_credits": db.video_credits(user_id),
        "video_free_remaining": max(0, config.VIDEO_FREE_DAILY_LIMIT - video_free_used),
        "video_free_limit": config.VIDEO_FREE_DAILY_LIMIT,
        "video_packages": [
            {"id": pid, "credits": p["credits"], "stars": p["stars"], "label": p["label"]}
            for pid, p in config.PACKAGES.items()
            if p.get("video")
        ],
    }


@app.post("/api/invoice")
async def create_invoice(req: InvoiceRequest, user_id: int = Depends(current_user_id)):
    package = config.PACKAGES.get(req.package)
    if package is None:
        raise HTTPException(status_code=400, detail="unknown package")
    description = (
        "One photo animation in Tsumiki."
        if package.get("video")
        else "Credits for generating images in Tsumiki."
    )
    link = await bot.create_invoice_link(
        title=package["label"],
        description=description,
        payload=payments.build_payload(user_id, req.package),
        currency="XTR",
        prices=[LabeledPrice(label=package["label"], amount=package["stars"])],
    )
    return {"link": link}


@app.post("/api/generate")
async def generate(req: GenerateRequest, user_id: int = Depends(current_user_id)):
    if jobs.active_count(user_id, "image") >= 1:
        raise HTTPException(status_code=429, detail="wait for your previous generation to finish")

    spend = db.spend_generation(user_id, config.FREE_DAILY_LIMIT)
    if spend is None:
        raise HTTPException(
            status_code=402,
            detail="your free daily limit is used up and you have no credits",
        )
    _, usage_id = spend

    template = _load_template(req.workflow)
    wf = prepare_workflow(template, prompt=req.prompt, negative=req.negative_prompt, batch=1)

    job = Job(user_id=user_id, prompt=req.prompt, workflow=req.workflow)
    async with aiohttp.ClientSession() as session:
        try:
            prompt_id, queue_number = await comfy.queue_prompt(session, wf)
        except (ComfyError, aiohttp.ClientError) as e:
            db.undo_usage(usage_id)
            log.error("queue_prompt failed: %s", e)
            raise HTTPException(status_code=502, detail="ComfyUI is unavailable") from e
    job.prompt_id = prompt_id
    job.status = "running"
    jobs.add(job)
    asyncio.create_task(_watch_job(job, usage_id))
    log.info("job %s queued for user %s (prompt_id=%s)", job.id, user_id, prompt_id)
    return {"job_id": job.id, "queue_position": queue_number}


@app.get("/api/jobs/{job_id}")
async def job_status(job_id: str, user_id: int = Depends(current_user_id)):
    job = jobs.get(job_id)
    if job is None or job.user_id != user_id:
        raise HTTPException(status_code=404, detail="job not found")
    return {
        "status": job.status, "error": job.error, "kind": job.kind,
        "beat": job.beat, "beats": job.beats, "phase": job.phase,
        "position": job.position,
    }


@app.get("/api/jobs/{job_id}/image")
async def job_image(job_id: str, user_id: int = Depends(current_user_id)):
    job = jobs.get(job_id)
    if job is None or job.user_id != user_id:
        raise HTTPException(status_code=404, detail="job not found")
    if job.status != "done" or job.image_path is None:
        raise HTTPException(status_code=409, detail="job not finished")
    return FileResponse(job.image_path, media_type="image/png")


@app.get("/api/video/scenes")
async def video_scenes(user_id: int = Depends(current_user_id)):
    try:
        return {"scenes": await _get_scenes()}
    except (VideoError, aiohttp.ClientError, asyncio.TimeoutError) as e:
        log.warning("scene catalog unavailable: %s", e)
        raise HTTPException(status_code=502, detail="video server is unavailable") from e


@app.post("/api/animate")
async def animate(req: AnimateRequest, user_id: int = Depends(current_user_id)):
    if jobs.active_count(user_id, "video") >= 1:
        raise HTTPException(status_code=429, detail="wait for your previous animation to finish")

    # Resolve the scene before spending anything.
    try:
        scenes = await _get_scenes()
    except (VideoError, aiohttp.ClientError, asyncio.TimeoutError) as e:
        raise HTTPException(status_code=502, detail="video server is unavailable") from e
    scene = next((sc for sc in scenes if sc["id"] == req.scene), None)
    if scene is None:
        raise HTTPException(status_code=400, detail=f"unknown scene '{req.scene}'")

    spend = db.spend_video(user_id, config.VIDEO_FREE_DAILY_LIMIT)
    if spend is None:
        raise HTTPException(
            status_code=402,
            detail="your free animation for today is used up and you have no animation credits",
        )
    _, usage_id = spend

    seed = random.randrange(1 << 31)
    async with aiohttp.ClientSession() as session:
        try:
            resp = await video.submit(session, scene["id"], strip_data_uri(req.image), seed)
        except (VideoError, aiohttp.ClientError, asyncio.TimeoutError) as e:
            db.undo_usage(usage_id)
            log.error("video submit failed: %s", e)
            raise HTTPException(status_code=502, detail="video server is unavailable") from e

    job = Job(
        user_id=user_id, prompt="", workflow="video",
        kind="video", scene_label=scene["label"],
        remote_id=resp["job_id"], beats=int(resp.get("beats", 0)),
    )
    jobs.add(job)
    db.video_job_add(job.id, job.remote_id, user_id, usage_id, job.scene_label)
    asyncio.create_task(_watch_video_job(job, usage_id))
    log.info("video job %s queued for user %s (remote %s)", job.id, user_id, job.remote_id)
    return {
        "job_id": job.id,
        "beats": resp.get("beats"),
        "seconds": resp.get("seconds"),
        "minutes_est": resp.get("minutes_est"),
    }


@app.get("/api/jobs/{job_id}/video")
async def job_video(job_id: str, user_id: int = Depends(current_user_id)):
    job = jobs.get(job_id)
    if job is None or job.user_id != user_id:
        raise HTTPException(status_code=404, detail="job not found")
    if job.status != "done" or job.video_path is None:
        raise HTTPException(status_code=409, detail="job not finished")
    return FileResponse(job.video_path, media_type="video/mp4")


async def _watch_job(job: Job, usage_id: int) -> None:
    try:
        async with aiohttp.ClientSession() as session:
            image = await comfy.wait_for_image(
                session, job.prompt_id, timeout=config.JOB_TIMEOUT
            )
    except ComfyError as e:
        job.status = "error"
        job.error = str(e)
        db.undo_usage(usage_id)  # failed generation must not cost anything
        log.error("job %s failed: %s", job.id, e)
        return
    except Exception as e:  # noqa: BLE001 — watcher must never crash silently
        job.status = "error"
        job.error = "internal error"
        db.undo_usage(usage_id)
        log.exception("job %s crashed: %s", job.id, e)
        return

    path = config.DATA_DIR / "outputs" / f"{job.id}.png"
    path.write_bytes(image)
    job.image_path = path
    job.status = "done"
    log.info("job %s done (%d bytes)", job.id, len(image))

    if job.user_id > 0:
        caption = job.prompt if len(job.prompt) <= 1000 else job.prompt[:997] + "…"
        try:
            await bot.send_photo(job.user_id, FSInputFile(path), caption=caption)
        except TelegramForbiddenError:
            # User opened the Mini App without ever /start-ing the bot — the
            # image still shows inside the app, so just log it.
            log.info("job %s: user %s has not started the bot", job.id, job.user_id)
        except Exception as e:  # noqa: BLE001
            log.warning("job %s: send_photo failed: %s", job.id, e)


def _fail_video_job(job: Job, usage_id: int, message: str) -> None:
    """Single terminal-failure path so the refund can never run twice."""
    if job.status == "error":
        return
    job.status = "error"
    job.error = message
    db.undo_usage(usage_id)  # a failed render must not cost anything
    db.video_job_delete(job.id)
    log.error("video job %s failed: %s", job.id, message)


async def _watch_video_job(job: Job, usage_id: int) -> None:
    """Polls the video-api until the render finishes, then downloads the mp4
    and delivers it to the user's chat. Every terminal failure goes through
    _fail_video_job (refund exactly once)."""
    deadline = job.created + config.VIDEO_JOB_TIMEOUT
    failures = 0
    try:
        async with aiohttp.ClientSession() as session:
            while True:
                await asyncio.sleep(5)
                if time.time() > deadline:
                    _fail_video_job(job, usage_id, "the render timed out, please try again")
                    return
                try:
                    st = await video.status(session, job.remote_id)
                except VideoJobGone:
                    _fail_video_job(
                        job, usage_id, "the render server restarted, please try again"
                    )
                    return
                except (VideoError, aiohttp.ClientError, asyncio.TimeoutError) as e:
                    failures += 1
                    if failures >= 6:
                        _fail_video_job(job, usage_id, "lost contact with the render server")
                        return
                    log.warning("video job %s poll failed (%d/6): %s", job.id, failures, e)
                    continue
                failures = 0
                status = st.get("status")
                if status == "queued":
                    job.position = st.get("position")
                elif status == "running":
                    job.status = "running"
                    job.beat = int(st.get("beat", 0))
                    job.beats = int(st.get("beats", job.beats))
                    job.phase = st.get("phase")
                    job.position = None
                elif status == "error":
                    _fail_video_job(job, usage_id, st.get("error") or "render failed")
                    return
                elif status == "done":
                    break

            try:
                mp4 = await video.download(session, job.remote_id)
            except (VideoError, aiohttp.ClientError, asyncio.TimeoutError) as e:
                _fail_video_job(job, usage_id, f"downloading the video failed: {e}")
                return
    except Exception as e:  # noqa: BLE001 — watcher must never crash silently
        log.exception("video job %s crashed: %s", job.id, e)
        _fail_video_job(job, usage_id, "internal error")
        return

    path = config.DATA_DIR / "outputs" / f"{job.id}.mp4"
    path.write_bytes(mp4)
    job.video_path = path
    job.status = "done"
    db.video_job_delete(job.id)
    log.info("video job %s done (%d bytes)", job.id, len(mp4))

    if job.user_id > 0:
        try:
            await bot.send_video(
                job.user_id, FSInputFile(path), caption=f"🎬 {job.scene_label}"
            )
        except TelegramForbiddenError:
            # Unlike images, the chat is the video's only delivery channel —
            # nothing was delivered, so the spend is reverted.
            job.status = "error"
            job.error = "open the bot chat and press Start so I can send you the video"
            db.undo_usage(usage_id)
            log.info("video job %s: user %s has not started the bot", job.id, job.user_id)
        except Exception as e:  # noqa: BLE001
            # Transient send failure: keep "done" — the file stays fetchable
            # via GET /api/jobs/{id}/video.
            log.warning("video job %s: send_video failed: %s", job.id, e)
