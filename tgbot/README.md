# Tsumiki Telegram bot backend

FastAPI + aiogram služba běžící na **NAS JODA**. Mini App (Flutter web na
Cloudflare Pages) sem posílá prompty; služba je pouští do **ComfyUI na SPARKu**
(SPARK dělá jen ComfyUI), hotový obrázek vrací appce **a zároveň** ho posílá
botem do chatu. Kredity a Telegram Stars platby drží v SQLite.

```
Mini App (Pages) ──POST /api/generate (Authorization: tma <initData>)──▶ mangabot @ JODA:8090
Mini App        ──POST /api/invoice → openInvoice(⭐)──▶ Telegram ──▶ successful_payment
                                                                        │
Telegram chat ◀──sendPhoto──┐                                           ▼
Mini App      ◀──job image──┴── mangabot ──HTTP(S)──▶ ComfyUI @ SPARK:8188
```

## Endpoints

| Endpoint | Popis |
|---|---|
| `POST /api/generate` | `{prompt, negative_prompt, workflow: flux\|pony}` → `{job_id, queue_position}`; **402** = došla free kvóta i kredity |
| `GET /api/jobs/{id}` | `{status: queued\|running\|done\|error, error}` |
| `GET /api/jobs/{id}/image` | PNG bytes hotového jobu |
| `GET /api/me` | `{credits, free_remaining, free_limit, packages}` |
| `POST /api/invoice` | `{package}` → `{link}` (Stars invoice, otevírá se přes `WebApp.openInvoice`) |
| `GET /healthz` | liveness pro monitoring |

Auth: `Authorization: tma <initData>` (oficiální HMAC validace proti
`BOT_TOKEN`; identita = Telegram user id). Pro vývoj mimo Telegram
`Authorization: dev <DEV_TOKEN>` (jen když je `DEV_TOKEN` v env).

## Platby (Telegram Stars)

- Balíčky v `config.PACKAGES` (10/50/250 kreditů za 25/100/400 ⭐).
- Free kvóta `FREE_DAILY_LIMIT` (default 3) za klouzavých 24 h, pak 1 kredit
  = 1 generování; spend je atomický v SQLite, neúspěšné generování se vrací.
- `pre_checkout_query` validuje payload/payera/cenu; `successful_payment`
  připisuje idempotentně dle `telegram_payment_charge_id`.
- Bot příkazy: `/paysupport` (povinná platební podpora),
  `/refund <charge_id>` (jen `ADMIN_USER_ID`; zavolá `refundStarPayment`
  a odečte kredity).
- DB: `data/mangabot.db` (WAL). **Zálohovat** — jsou v ní kredity i platby.
  `./backup.sh` (denní cron na NAS) dělá snapshot uvnitř kontejneru (`data/`
  vlastní root a `sqlite3` CLI není ani na hostu, ani v image) a zrcadlí ho na
  `/pool/Backup/tsumiki` — jiné disky než systémové SSD, kde leží databáze.
  Obě kopie jsou ale na jednom stroji; off-site cíl zatím chybí.

## Deploy na JODA (Docker)

```bash
# 1. checkout repa na NAS (kvůli assets/comfyui — mountuje se do kontejneru)
git clone <repo> MangaPrompts && cd MangaPrompts/tgbot

# 2. konfigurace (tokeny NIKDY do repa)
cp mangabot.env.example mangabot.env && vi mangabot.env

# 3. build + start
docker compose up -d --build
docker compose logs -f mangabot
```

### Konektivita JODA → ComfyUI na SPARKu

Dvě varianty, řídí se jen env proměnnými:
1. **LAN** (preferovaná): `COMFY_URL=http://<spark-ip>:8188` — ComfyUI musí
   poslouchat na LAN rozhraní (`--listen 0.0.0.0`), ideálně omezit firewallem
   na IP JODY.
2. **Přes Cloudflare**: `COMFY_URL=https://comfyui.ol1n.com` +
   `COMFY_CF_ID`/`COMFY_CF_SECRET` (Access service token).

### Veřejná HTTPS pro tg.ol1n.com

Dvě varianty:
1. **cloudflared na JODA** (preferovaná — nezávislé na SPARKu): odkomentovat
   sidecar v `docker-compose.yml`, tunnel token do `mangabot.env`, public
   hostname `tg.ol1n.com → http://mangabot:8090`.
2. **Ingress na existujícím tunelu SPARKu**: `service: http://<joda-ip>:8090`
   (funguje, ale výpadek SPARKu shodí i API).

Bez Cloudflare Access na `tg.ol1n.com` — auth řeší initData; volitelně WAF
rate-limit na `/api/generate` a `/api/invoice`.

Bare-metal alternativa bez Dockeru: `mangabot.service` (systemd + venv).

## Lokální vývoj

```bash
python3 -m venv venv && venv/bin/pip install -r requirements.txt
BOT_TOKEN=<dev bot token> DEV_TOKEN=devsecret \
ALLOWED_ORIGINS=http://localhost:5555 COMFY_URL=http://127.0.0.1:8188 \
venv/bin/uvicorn app:app --host 127.0.0.1 --port 8090 --reload
```

Flutter web proti tomu:

```bash
flutter run -d chrome \
  --dart-define=TG_BACKEND_URL=http://127.0.0.1:8090 \
  --dart-define=TG_DEV_TOKEN=devsecret
```

Platby naostro otestuješ jen v Telegramu (dev bot + Bot API test environment,
případně nejmenší balíček + `/refund`).

## Testy

```bash
venv/bin/pip install pytest
venv/bin/python -m pytest tests/ -q
```

## Poznámky

- `comfy.prepare_workflow` je port `ComfyImageService._prepare` z
  `lib/services/comfy_image_service.dart` — při změně placeholderů drž oba v synku.
- Joby jsou jen v paměti (obrázek stejně dorazí do chatu); kredity a platby
  jsou v SQLite a restart přežijí.
- Limity: 1 běžící job na uživatele; free kvóta + kredity viz Platby.
