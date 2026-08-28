# Tsumiki Telegram bot backend

FastAPI + aiogram služba běžící na **NAS JODA**. Mini App (Flutter web na
Cloudflare Pages) sem posílá prompty; služba je pouští do **ComfyUI na SPARKu**
(SPARK dělá jen inference), hotový obrázek vrací appce **a zároveň** ho posílá
botem do chatu. Druhá cesta je **animace fotky**: Mini App nahraje fotku
a preset, služba ji pošle na **video-api na SPARKu** (Wan 2.2 I2V,
video-stack/serve.py) a hotové mp4 doručí botem do chatu. Kredity a Telegram
Stars platby drží v SQLite.

```
Mini App (Pages) ──POST /api/generate (Authorization: tma <initData>)──▶ mangabot @ JODA:8090
Mini App        ──POST /api/animate {scene, image b64}──▶ mangabot
Mini App        ──POST /api/invoice → openInvoice(⭐)──▶ Telegram ──▶ successful_payment
                                                                        │
Telegram chat ◀──sendPhoto/sendVideo──┐                                 ▼
Mini App      ◀──job image/status─────┴── mangabot ──HTTP(S)──▶ ComfyUI @ SPARK:8188
                                                    ──HTTP────▶ video-api @ SPARK:8096
```

## Endpoints

| Endpoint | Popis |
|---|---|
| `POST /api/generate` | `{prompt, negative_prompt, workflow: flux\|pony}` → `{job_id, queue_position}`; **402** = došla free kvóta i kredity |
| `GET /api/jobs/{id}` | `{status: queued\|running\|done\|error, error, kind, beat, beats, phase, position}` |
| `GET /api/jobs/{id}/image` | PNG bytes hotového jobu |
| `POST /api/animate` | `{scene, image: base64}` → `{job_id, beats, seconds, minutes_est}`; **402** = došla denní animace i video kredity |
| `GET /api/video/scenes` | `{scenes}` — proxy katalogu presetů z video-api (TTL cache); 502 když video-api neběží |
| `GET /api/jobs/{id}/video` | mp4 bytes hotové animace (video jde primárně botem do chatu; tohle je fallback/dev) |
| `GET /api/me` | `{credits, free_remaining, free_limit, packages, video_credits, video_free_remaining, video_free_limit, video_packages}` |
| `POST /api/invoice` | `{package}` → `{link}` (Stars invoice, otevírá se přes `WebApp.openInvoice`) |
| `GET /healthz` | liveness pro monitoring |

Auth: `Authorization: tma <initData>` (oficiální HMAC validace proti
`BOT_TOKEN`; identita = Telegram user id). Pro vývoj mimo Telegram
`Authorization: dev <DEV_TOKEN>` (jen když je `DEV_TOKEN` v env).

## Platby (Telegram Stars)

- Balíčky v `config.PACKAGES` (10/50/250 kreditů za 25/100/400 ⭐; navíc
  `v1` = 1 animace za 10 ⭐ s flagem `video: True`).
- Free kvóta `FREE_DAILY_LIMIT` (default 3) za klouzavých 24 h, pak 1 kredit
  = 1 generování; spend je atomický v SQLite, neúspěšné generování se vrací.
- Animace mají **oddělený ledger**: `users.video_credits` + free kvóta
  `VIDEO_FREE_DAILY_LIMIT` (default 1/24 h, usage kind `video_free`).
  Ledger `payments` je společný — řádek s `package='v1'` připisuje video
  kredit; `/refund` podle balíčku pozná, který sloupec vrátit.
- `pre_checkout_query` validuje payload/payera/cenu; `successful_payment`
  připisuje idempotentně dle `telegram_payment_charge_id`.
- Bot příkazy: `/paysupport` (povinná platební podpora),
  `/refund <charge_id>` (jen `ADMIN_USER_ID`; zavolá `refundStarPayment`
  a odečte kredity).
- DB: `data/mangabot.db` (WAL). **Zálohovat** — jsou v ní kredity i platby.
  `./backup.sh` (denní cron na NAS) dělá tři kopie:
  1. snapshot uvnitř kontejneru (`data/` vlastní root a `sqlite3` CLI není ani
     na hostu, ani v image) — 14 denních,
  2. zrcadlo na `/pool/Backup/tsumiki` (raidz1, jiné disky než systémové SSD,
     kde leží databáze) — 30 denních, ověřené `cmp`,
  3. off-site na Cloudflare R2 přes `rclone` — 90 dní, ověřené MD5.

  R2 krok se přeskočí s hláškou, pokud remote `r2:` není nastavený, takže
  nedodělaná konfigurace degraduje na dvě lokální kopie místo selhání.
  Nastavení remote: `~/bin/rclone config create r2 s3 provider=Cloudflare
  access_key_id=… secret_access_key=… endpoint=https://<acct>.r2.cloudflarestorage.com
  region=auto`.

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

Stejně video-api (animace fotek): `VIDEO_URL=http://<spark-ip>:8096/v1/video`
po LAN, nebo `https://llm.ol1n.com/v1/video` + `VIDEO_CF_ID`/`VIDEO_CF_SECRET`.
Server poslouchá na `0.0.0.0:8096` (video-stack/serve.py, systemd
`video-api.service`).

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
- Obrázkové joby jsou jen v paměti (obrázek stejně dorazí do chatu); kredity
  a platby jsou v SQLite a restart přežijí.
- **Video joby restart bota přežijí**: tabulka `video_jobs` drží
  (job_id, remote_id, usage_id) a `lifespan` na startu znovu pověsí watcher —
  video-api si render drží nezávisle na nás, takže se jen znovu připojíme.
  10⭐/12min artefakt nechceme zahodit při každém deployi. Pozor: restart
  **video-api** naopak rozběhnuté rendery force-failne (bot pak vrací spend).
- Limity: 1 běžící job na uživatele **per druh** (1 obrázek + 1 video
  souběžně — render videa trvá ~7–13 min a nesmí blokovat obrázky);
  free kvóta + kredity viz Platby.
- Selhané doručení videa kvůli neexistujícímu chatu (`TelegramForbiddenError`,
  uživatel nikdy nedal /start) **vrací spend** — u obrázků se jen loguje,
  protože obrázek se zobrazí v appce; video má chat jako jediný kanál.
