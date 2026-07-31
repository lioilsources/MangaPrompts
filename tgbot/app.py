"""MangaPrompts Telegram bot backend.

One asyncio process serving both:
- FastAPI REST API for the Mini App (generate → poll → download image), and
- the aiogram bot (long polling; /start button opening the Mini App;
  sendPhoto of every finished image into the user's chat).

Run: uvicorn app:app --host 127.0.0.1 --port 8090  (see mangabot.service)
"""

import asyncio
import json
import logging
import uuid
from contextlib import asynccontextmanager

import aiohttp
from aiogram import Bot, Dispatcher
from aiogram.exceptions import TelegramForbiddenError
from aiogram.filters import CommandStart
from aiogram.types import (
    FSInputFile,
    InlineKeyboardButton,
    InlineKeyboardMarkup,
    Message,
    WebAppInfo,
)
from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field

import config
from auth import InvalidInitData, validate_init_data
from comfy import ComfyClient, ComfyError, prepare_workflow
from jobs import Job, JobStore

log = logging.getLogger("mangabot")
logging.basicConfig(level=logging.INFO)

bot = Bot(token=config.BOT_TOKEN) if config.BOT_TOKEN else None
dp = Dispatcher()
jobs = JobStore()
comfy = ComfyClient(config.COMFY_URL, client_id=uuid.uuid4().hex)
_workflow_cache: dict[str, dict] = {}


# --- Telegram bot handlers ---------------------------------------------------

@dp.message(CommandStart())
async def on_start(message: Message) -> None:
    keyboard = InlineKeyboardMarkup(
        inline_keyboard=[
            [
                InlineKeyboardButton(
                    text="🎨 Otevřít MangaPrompts",
                    web_app=WebAppInfo(url=config.MINIAPP_URL),
                )
            ]
        ]
    )
    await message.answer(
        "Ahoj! Poskládej si prompt z LEGO bloků a vygeneruj manga obrázek. "
        "Hotový obrázek ti pošlu sem do chatu.",
        reply_markup=keyboard,
    )


# --- FastAPI -----------------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    if bot is None:
        raise RuntimeError("BOT_TOKEN is not set")
    config.DATA_DIR.joinpath("outputs").mkdir(parents=True, exist_ok=True)
    polling = asyncio.create_task(dp.start_polling(bot, handle_signals=False))
    yield
    polling.cancel()
    await bot.session.close()


app = FastAPI(title="MangaPrompts bot backend", lifespan=lifespan)

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


@app.post("/api/generate")
async def generate(req: GenerateRequest, user_id: int = Depends(current_user_id)):
    if jobs.active_count(user_id) >= 1:
        raise HTTPException(status_code=429, detail="počkej, až doběhne předchozí generování")
    if jobs.today_count(user_id) >= config.DAILY_LIMIT:
        raise HTTPException(status_code=429, detail="denní limit generování vyčerpán")

    template = _load_template(req.workflow)
    wf = prepare_workflow(template, prompt=req.prompt, negative=req.negative_prompt, batch=1)

    job = Job(user_id=user_id, prompt=req.prompt, workflow=req.workflow)
    async with aiohttp.ClientSession() as session:
        try:
            prompt_id, queue_number = await comfy.queue_prompt(session, wf)
        except (ComfyError, aiohttp.ClientError) as e:
            log.error("queue_prompt failed: %s", e)
            raise HTTPException(status_code=502, detail="ComfyUI není dostupné") from e
    job.prompt_id = prompt_id
    job.status = "running"
    jobs.add(job)
    asyncio.create_task(_watch_job(job))
    log.info("job %s queued for user %s (prompt_id=%s)", job.id, user_id, prompt_id)
    return {"job_id": job.id, "queue_position": queue_number}


@app.get("/api/jobs/{job_id}")
async def job_status(job_id: str, user_id: int = Depends(current_user_id)):
    job = jobs.get(job_id)
    if job is None or job.user_id != user_id:
        raise HTTPException(status_code=404, detail="job not found")
    return {"status": job.status, "error": job.error}


@app.get("/api/jobs/{job_id}/image")
async def job_image(job_id: str, user_id: int = Depends(current_user_id)):
    job = jobs.get(job_id)
    if job is None or job.user_id != user_id:
        raise HTTPException(status_code=404, detail="job not found")
    if job.status != "done" or job.image_path is None:
        raise HTTPException(status_code=409, detail="job not finished")
    return FileResponse(job.image_path, media_type="image/png")


async def _watch_job(job: Job) -> None:
    try:
        async with aiohttp.ClientSession() as session:
            image = await comfy.wait_for_image(
                session, job.prompt_id, timeout=config.JOB_TIMEOUT
            )
    except ComfyError as e:
        job.status = "error"
        job.error = str(e)
        log.error("job %s failed: %s", job.id, e)
        return
    except Exception as e:  # noqa: BLE001 — watcher must never crash silently
        job.status = "error"
        job.error = "internal error"
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
