# Restyler backend: nasazení

`restyler-api` je tentýž kód jako `mangabot` s `AUTH_MODE=app`: bez bota, bez
pollingu, s vlastní databází a kvótou (`data-restyler/`), port 8091.

## Token a env

```bash
cd tgbot
cp restyler.env.example restyler.env
openssl rand -hex 32   # do APP_TOKEN; pod 32 znaků služba nenastartuje
```

`BOT_TOKEN` se v tomhle režimu nečte. Doplň `COMFY_URL`, `VIDEO_URL`.

## Start

```bash
docker compose --profile restyler up -d --build restyler-api
```

Služba je za profilem, aby `docker compose up -d` pro bota nepotřeboval
`restyler.env`. Ověřeno `docker compose config`; samotný build ani start
kontejneru zkoušené nejsou.

## Cloudflare

Public hostname `restyler-api.ol1n.com` → `http://restyler-api:8090`. Access app
s `non_identity` politikou na **novém** service tokenu, ať rotace nezasáhne
Ol1nLLM. Kontejner tunelu musí být ve stejné docker síti jako `restyler-api`.

## Deploy při běžících jobech

Joby jsou jen v paměti. Restart ztratí běžící řetězec **a neudělá refund**
(persistence je Fáze 2). Před deployem čekej na prázdno:

```bash
curl -s localhost:8091/healthz   # {"status":"ok","active_jobs":0}
```

Appka po ztrátě jobu dostane 404 a nabídne „Spustit znovu".

## Distribuce a rotace

TestFlight/APK; `APP_TOKEN` a CF Access pár jdou do `--dart-define` z `.env.local`
(viz Makefile Ol1nLLM).

Rotace: nový `APP_TOKEN` do `restyler.env`, `docker compose --profile restyler up
-d restyler-api`, nový build appky. Stará verze dostane 401, jeden token na
instanci, souběh dvou tokenů backend neumí. CF service token se rotuje zvlášť
v Zero Trust.

`X-User` není autentizace: kdo má `APP_TOKEN`, může se představit kýmkoli. Stačí
to pro soukromou distribuci, ne pro store.

## Kvóta

`FREE_DAILY_LIMIT=40` za 24 h na `X-User`. Krok stojí 1, `wan_motion` stojí
`RENDER_VIDEO_COST` (5). Platby tu nejsou, `/api/invoice` vrací 404.

## API

### Auth

`Authorization: app <APP_TOKEN>` a `X-User: ^[a-z0-9_-]{2,32}$`.
Špatný token 401, chybný `X-User` 400.

### POST /api/render

```json
{
  "source": "<base64 PNG/JPEG nebo data: URI, max 6 000 000 znaků>",
  "steps": [
    {"id": "hair", "graph": "kontext_edit", "input": "source", "prompt": "…", "negative": "", "mask": "<base64 PNG>"},
    {"id": "s1", "graph": "restyle_flux", "input": "hair", "prompt": "…", "negative": "…"},
    {"id": "s2", "graph": "restyle_sdxl", "input": "hair", "prompt": "…", "negative": "…", "medium": "illustration"},
    {"id": "v", "graph": "live_portrait", "input": "hair", "motion": "alive"},
    {"id": "w", "graph": "wan_motion", "input": "source", "motion": "hair-breeze"}
  ]
}
```

Odpověď 200: `{"job_id": "…", "steps_total": 5, "cost": 9}`. Chyby: 422 validace,
429 běží jiný render, 402 nedost kvóty. Nic z toho nic nestojí.

### GET /api/jobs/{id}

```json
{
  "status": "running",
  "done": 1,
  "total": 3,
  "steps": {
    "hair": {"status": "done", "kind": "image"},
    "s1": {"status": "error", "kind": "image", "error": "ComfyUI: no face"},
    "v": {"status": "skipped", "kind": "video"}
  }
}
```

`status`: `running|done|error`, `done` i s dílčími chybami, `error` když nevznikl
žádný výstup. `steps[].status`: `queued|running|done|error|skipped`. `done` =
počet hotových kroků; se skipem nedosáhne `total`, o konci rozhoduje `status`.

### GET /api/jobs/{id}/step/{step}

`image/png` nebo `video/mp4`. 404 dokud krok není `done`, i pro cizí job.
