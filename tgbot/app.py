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
        "beyond that they cost Telegram Stars ⭐ right inside the app.",
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
    credited = db.add_payment(
        charge_id=sp.telegram_payment_charge_id,
        user_id=user_id,
        stars=sp.total_amount,
        credits=package["credits"],
        package=package_id,
    )
    if not credited:
        log.info("duplicate successful_payment %s ignored", sp.telegram_payment_charge_id)
        return
    balance = db.credits(user_id)
    log.info(
        "payment %s: user %s +%d credits (%d⭐), balance %d",
        sp.telegram_payment_charge_id, user_id, package["credits"], sp.total_amount, balance,
    )
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
    db.mark_refunded(charge_id)
    await message.answer(
        f"Refunded {payment['stars']}⭐ to user {payment['user_id']}, "
        f"{payment['credits']} credits deducted."
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
    return {
        "credits": db.credits(user_id),
        "free_remaining": max(0, config.FREE_DAILY_LIMIT - free_used),
        "free_limit": config.FREE_DAILY_LIMIT,
        "packages": [
            {"id": pid, "credits": p["credits"], "stars": p["stars"], "label": p["label"]}
            for pid, p in config.PACKAGES.items()
        ],
    }


@app.post("/api/invoice")
async def create_invoice(req: InvoiceRequest, user_id: int = Depends(current_user_id)):
    package = config.PACKAGES.get(req.package)
    if package is None:
        raise HTTPException(status_code=400, detail="unknown package")
    link = await bot.create_invoice_link(
        title=package["label"],
        description="Credits for generating images in Tsumiki.",
        payload=payments.build_payload(user_id, req.package),
        currency="XTR",
        prices=[LabeledPrice(label=package["label"], amount=package["stars"])],
    )
    return {"link": link}


@app.post("/api/generate")
async def generate(req: GenerateRequest, user_id: int = Depends(current_user_id)):
    if jobs.active_count(user_id) >= 1:
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
    return {"status": job.status, "error": job.error}


@app.get("/api/jobs/{job_id}/image")
async def job_image(job_id: str, user_id: int = Depends(current_user_id)):
    job = jobs.get(job_id)
    if job is None or job.user_id != user_id:
        raise HTTPException(status_code=404, detail="job not found")
    if job.status != "done" or job.image_path is None:
        raise HTTPException(status_code=409, detail="job not finished")
    return FileResponse(job.image_path, media_type="image/png")


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
