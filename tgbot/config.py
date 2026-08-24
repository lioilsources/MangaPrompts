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
AUTH_MAX_AGE = _int_env("AUTH_MAX_AGE", 3600)
MAX_PROMPT_CHARS = _int_env("MAX_PROMPT_CHARS", 4000)
JOB_TIMEOUT = _int_env("JOB_TIMEOUT", 300)

# Telegram user id allowed to run admin commands (/refund). 0 = disabled.
ADMIN_USER_ID = _int_env("ADMIN_USER_ID", 0)

DB_PATH = DATA_DIR / "mangabot.db"

# Credit packages sold for Telegram Stars (XTR).
PACKAGES = {
    "s": {"credits": 10, "stars": 25, "label": "10 kreditů"},
    "m": {"credits": 50, "stars": 100, "label": "50 kreditů"},
    "l": {"credits": 250, "stars": 400, "label": "250 kreditů"},
}

WORKFLOW_FILES = {
    "flux": "flux_manga_txt2img.api.json",
    "pony": "pony_txt2img.api.json",
    "juggernaut": "juggernaut_lightning_txt2img.api.json",
    "wai": "wai_txt2img.api.json",
}
