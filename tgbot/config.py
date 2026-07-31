"""Environment-driven configuration for the MangaPrompts Telegram bot backend.

All values come from the environment (see mangabot.service EnvironmentFile);
BOT_TOKEN is the only required one.
"""

import os
from pathlib import Path

BOT_TOKEN = os.environ.get("BOT_TOKEN", "")

# ComfyUI reached over localhost on the SPARK box — no Cloudflare Access needed.
COMFY_URL = os.environ.get("COMFY_URL", "http://127.0.0.1:8188")

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

DAILY_LIMIT = int(os.environ.get("DAILY_LIMIT", "20"))
AUTH_MAX_AGE = int(os.environ.get("AUTH_MAX_AGE", "3600"))
MAX_PROMPT_CHARS = int(os.environ.get("MAX_PROMPT_CHARS", "4000"))
JOB_TIMEOUT = int(os.environ.get("JOB_TIMEOUT", "300"))

WORKFLOW_FILES = {
    "flux": "flux_manga_txt2img.api.json",
    "pony": "pony_txt2img.api.json",
}
