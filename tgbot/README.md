# MangaPrompts Telegram bot backend

Malá FastAPI + aiogram služba pro SPARK box. Mini App (Flutter web na
Cloudflare Pages) sem posílá prompty; služba je pouští do lokálního ComfyUI,
hotový obrázek vrací appce **a zároveň** ho posílá botem do chatu uživatele.

```
Mini App (Pages) ──POST /api/generate (Authorization: tma <initData>)──▶ tgbot (127.0.0.1:8090)
                                                                          │  localhost
Telegram chat ◀──sendPhoto───────────────────────────────────────────────┤  ComfyUI :8188
Mini App      ◀──GET /api/jobs/{id}/image────────────────────────────────┘
```

## Endpoints

| Endpoint | Popis |
|---|---|
| `POST /api/generate` | `{prompt, negative_prompt, workflow: flux\|pony}` → `{job_id, queue_position}` |
| `GET /api/jobs/{id}` | `{status: queued\|running\|done\|error, error}` |
| `GET /api/jobs/{id}/image` | PNG bytes hotového jobu |

Auth: hlavička `Authorization: tma <initData>` — validace oficiálním HMAC
algoritmem proti `BOT_TOKEN`; identita = Telegram user id. Pro vývoj mimo
Telegram `Authorization: dev <DEV_TOKEN>` (funguje jen když je `DEV_TOKEN`
nastaven v env; dev uživateli se neposílá nic do chatu).

## Deploy na SPARK

```bash
# 1. checkout repa (nebo rsync tgbot/ + assets/comfyui/)
cd ~/Code && git clone <repo> MangaPrompts && cd MangaPrompts/tgbot

# 2. venv
python3 -m venv venv && venv/bin/pip install -r requirements.txt

# 3. env soubor (tokeny NIKDY do repa)
sudo mkdir -p /etc/mangabot && sudo tee /etc/mangabot/env >/dev/null <<'EOF'
BOT_TOKEN=<token od @BotFather>
COMFY_URL=http://127.0.0.1:8188
WORKFLOW_DIR=/home/ol1n/Code/MangaPrompts/assets/comfyui
DATA_DIR=/home/ol1n/Code/MangaPrompts/tgbot/data
ALLOWED_ORIGINS=https://app.ol1n.com
MINIAPP_URL=https://app.ol1n.com
DAILY_LIMIT=20
# DEV_TOKEN=<jen na dev instanci>
EOF
sudo chmod 600 /etc/mangabot/env

# 4. systemd
sudo cp mangabot.service /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now mangabot
journalctl -u mangabot -f
```

## Cloudflare Tunnel

Do existující tunnel konfigurace (stejný tunel jako comfyui.ol1n.com) přidat
ingress **bez Cloudflare Access** — auth řeší initData:

```yaml
# ~/.cloudflared/config.yml — PŘED závěrečné http_status:404 pravidlo
  - hostname: tg.ol1n.com
    service: http://localhost:8090
```

```bash
cloudflared tunnel route dns <tunnel-name> tg.ol1n.com
sudo systemctl restart cloudflared
```

Volitelně: v Cloudflare dashboardu WAF rate-limit na `/api/generate`.

## Lokální vývoj

```bash
BOT_TOKEN=<dev bot token> DEV_TOKEN=devsecret \
ALLOWED_ORIGINS=http://localhost:5555 \
venv/bin/uvicorn app:app --host 127.0.0.1 --port 8090 --reload
```

Flutter web proti tomu:

```bash
flutter run -d chrome \
  --dart-define=TG_BACKEND_URL=http://127.0.0.1:8090 \
  --dart-define=TG_DEV_TOKEN=devsecret
```

## Testy

```bash
venv/bin/pip install pytest
venv/bin/python -m pytest tests/ -q
```

## Poznámky

- `comfy.prepare_workflow` je port `ComfyImageService._prepare` z
  `lib/services/comfy_image_service.dart` — při změně placeholderů drž oba v synku.
- Joby jsou jen v paměti; obrázek stejně dorazí do chatu, restart služby
  rozgenerované joby zahodí (appka ukáže timeout/chybu).
- Limity: 1 běžící job na uživatele, `DAILY_LIMIT` za 24 h.
