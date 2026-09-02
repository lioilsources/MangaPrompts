"""Environment-driven configuration for the Tsumiki Telegram bot backend.

All values come from the environment (see mangabot.service EnvironmentFile);
BOT_TOKEN is the only required one.
"""

import os
from pathlib import Path


def _int_env(name: str, default: int) -> int:
    """An env_file line with no value (`ADMIN_USER_ID=`) must read as unset."""
    raw = os.environ.get(name, "").strip()
    return int(raw) if raw else default


BOT_TOKEN = os.environ.get("BOT_TOKEN", "")

# ComfyUI runs on the SPARK box; this service runs on the JODA NAS. Reach
# ComfyUI either over the LAN (http://<spark-ip>:8188) or through the public
# hostname (https://comfyui.ol1n.com) — the latter needs the CF Access
# service-token pair below.
COMFY_URL = os.environ.get("COMFY_URL", "http://spark:8188")
COMFY_CF_ID = os.environ.get("COMFY_CF_ID", "")
COMFY_CF_SECRET = os.environ.get("COMFY_CF_SECRET", "")

# video-api (video-stack/serve.py) also runs on the SPARK box — photo→video
# rendering (Wan 2.2 I2V). Reach it over the LAN (http://<spark-ip>:8096/v1/video)
# or through the public hostname (https://llm.ol1n.com/v1/video) with the CF
# Access service-token pair below.
VIDEO_URL = os.environ.get("VIDEO_URL", "http://spark:8096/v1/video")
VIDEO_CF_ID = os.environ.get("VIDEO_CF_ID", "")
VIDEO_CF_SECRET = os.environ.get("VIDEO_CF_SECRET", "")

# Directory with the *.api.json workflow templates (the repo's assets/comfyui).
WORKFLOW_DIR = Path(
    os.environ.get("WORKFLOW_DIR", Path(__file__).resolve().parent.parent / "assets" / "comfyui")
)

# Where finished images are cached for /api/jobs/{id}/image.
DATA_DIR = Path(os.environ.get("DATA_DIR", Path(__file__).resolve().parent / "data"))

# Exact web origins allowed by CORS (comma-separated), e.g. the Pages domain.
ALLOWED_ORIGINS = [
    o.strip() for o in os.environ.get("ALLOWED_ORIGINS", "").split(",") if o.strip()
]

# Non-empty DEV_TOKEN enables the `Authorization: dev <token>` bypass for
# browser testing outside Telegram. Leave unset in production.
DEV_TOKEN = os.environ.get("DEV_TOKEN", "")

# URL of the hosted Mini App, used for the /start button.
MINIAPP_URL = os.environ.get("MINIAPP_URL", "https://app.ol1n.com")

# Free generations per rolling 24 h; beyond that 1 generation = 1 credit.
FREE_DAILY_LIMIT = _int_env("FREE_DAILY_LIMIT", 3)
# Free photo animations per rolling 24 h; beyond that 1 animation = 1 video credit.
VIDEO_FREE_DAILY_LIMIT = _int_env("VIDEO_FREE_DAILY_LIMIT", 1)
AUTH_MAX_AGE = _int_env("AUTH_MAX_AGE", 3600)
MAX_PROMPT_CHARS = _int_env("MAX_PROMPT_CHARS", 4000)
JOB_TIMEOUT = _int_env("JOB_TIMEOUT", 300)
# Render deadline. One fixed value cannot fit both a 1-beat scene (~6 min) and
# a 12-beat one (~40 min) on the single GPU worker, so the deadline is derived
# per job from the estimate video-api returns on submit (minutes_est, which
# runs 10-60 % short): max(VIDEO_JOB_TIMEOUT, minutes_est * 60 * FACTOR),
# capped at _MAX. VIDEO_JOB_TIMEOUT is only the floor now — as the whole
# deadline it cut long renders off minutes before they finished, and the mp4
# then never left the render box.
VIDEO_JOB_TIMEOUT = _int_env("VIDEO_JOB_TIMEOUT", 1800)
VIDEO_JOB_TIMEOUT_MAX = _int_env("VIDEO_JOB_TIMEOUT_MAX", 4 * 3600)
VIDEO_TIMEOUT_FACTOR = 2.0
VIDEO_SCENES_TTL = _int_env("VIDEO_SCENES_TTL", 300)
# Uploaded photo cap in base64 chars; video-api itself caps bodies at 32 MB.
MAX_IMAGE_B64_CHARS = _int_env("MAX_IMAGE_B64_CHARS", 24_000_000)
# Bot API ceiling for an uploaded sendVideo file. A longer scene can render
# past it, and the chat is the animation's only delivery channel, so the size
# is checked before the upload instead of failing it.
TELEGRAM_VIDEO_LIMIT = 50 * 1024 * 1024

# Telegram user id allowed to run admin commands (/refund). 0 = disabled.
ADMIN_USER_ID = _int_env("ADMIN_USER_ID", 0)

DB_PATH = DATA_DIR / "mangabot.db"

# Credit packages sold for Telegram Stars (XTR).
PACKAGES = {
    "s": {"credits": 10, "stars": 25, "label": "10 credits"},
    "m": {"credits": 50, "stars": 100, "label": "50 credits"},
    "l": {"credits": 250, "stars": 400, "label": "250 credits"},
    # video: True routes the credit to users.video_credits (photo animations).
    "v1": {"credits": 1, "stars": 10, "label": "1 animation", "video": True},
}

WORKFLOW_FILES = {
    "flux": "flux_manga_txt2img.api.json",
    "pony": "pony_txt2img.api.json",
    "juggernaut": "juggernaut_lightning_txt2img.api.json",
    "wai": "wai_txt2img.api.json",
}
