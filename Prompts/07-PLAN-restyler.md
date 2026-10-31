# PLAN — Restyler: nová mobilní appka (selfie → vlasy → brýle → styly → fotobuňka)

> Pro Opuse. Nová **Flutter iOS/Android appka Restyler** (nové repo
> `lioilsources/Restyler`), **ne Telegram Mini App**. Zabalí tři karty
> Tsumiki do jednoho průvodce a skončí mřížkou jako z fotobuňky. Backend
> zůstává `MangaPrompts/tgbot/` (tentýž kód, druhá instance **bez bota**,
> za Cloudflare Access jako služby Ol1nLLM). Staví na `04-PLAN-kadernik.md`
> (vlasy), `06-PLAN-bryle.md` (brýle, model jobu s víc obrázky) a
> `03-PLAN-restyle-painters-flux.md` (styly + identita). Pořadí
> závislostí: **06 §3 (Job s `image_paths`) musí být hotové dřív**, nebo se
> udělá tady.

## Zadání a rozhodnutí

Uživatel se vyfotí, (1) změní nebo přebarví vlasy, (2) vybere brýle, (3) svůj
nový vzhled prožene přes identitu tváře do několika stylů — epochy, malíři,
média — a dostane **mřížku jako z fotobuňky**: rámeček 0 je jeho nový vzhled
jako fotka, rámečky 1..K jsou styly.

Rozhodnutí, která plán dělá za uživatele (s důvodem — kdyby nesouhlasil,
mění se jen jedna věc):

| rozhodnutí | důvod |
|---|---|
| **Nativní appka, distribuce zatím soukromá (TestFlight / APK), jako Ol1nLLM** | appka nese CF Access service token v `--dart-define` (vzor Ol1nLLM `Makefile`). To je přijatelné pro appku pro sebe a známé, **ne pro store** — veřejná verze potřebuje účty a platby (§9), a to je jiný plán |
| **Pipeline běží na serveru (`tgbot`), appka jen zadá a polluje** | pipeline trvá 4–8 min a iOS appku do minuty uspí; stavový automat v telefonu by se obnovoval po každém stupni. Server má mezivýsledky v ruce, nahrává je rovnou do ComfyUI, skládá pás. A hlavně: `hairmask`, `glassesmask`, `hairprompt` a restyle grafy jsou **měřené** benchem právě v `tgbot` — appka měří to, co ships. Varianta „orchestrace v telefonu nad ComfyUI jako Ol1nLLM" je v §8 |
| **Druhá instance `tgbot` bez Telegramu**: `AUTH_MODE=app`, žádný `BOT_TOKEN`, žádné doručení do chatu | jeden codebase, jiný env. Backend už má seam `job.user_id > 0` = „pošli do chatu"; uživatelé appky dostanou záporná id a nic se neposílá |
| **Auth: CF Access service token (síť) + `Authorization: app <APP_TOKEN>` + `X-User` (kdo)** | CF Access drží dveře (policy `non_identity` jako `llm.ol1n.com`), `APP_TOKEN` drží, že volá naše appka, `X-User` rozlišuje lidi kvůli kvótě a historii. Žádný účet, žádné heslo — soukromá appka |
| **Účtování vypnuté, kvóta ano**: `FREE_DAILY_LIMIT` na instanci (např. 30 generací/den/uživatel), kredity se nekupují | Stars nejsou, IAP je Fáze 2. Ledger zůstává v kódu netknutý, jen nemá kde brát kredity; 402 appka ukáže jako „dnes už dost, zítra zas" |
| **Sdílený kód do Dart balíčku `tsumiki_shared` v MangaPrompts, bez Telegramu v jádru** | katalogy jsou **generované z benche** v MangaPrompts — kopie by zestárla do týdne. Backend klient dostane pluggable auth: Tsumiki web dosadí `tma <initData>`, Restyler `app <token>` + CF hlavičky. Restyler bere balíček jako `git: {url, path, ref}` pinnutý na tag |
| **Pořadí stupňů: vlasy → brýle → styly** | analýza brýlí (obočí, oči) běží na **výstupu vlasů**, protože nová ofina zakryje obočí; styly dostanou obrázek, kde už obojí je |
| **Styly přes restyle graf (depth + PuLID/InstantID) a prompt nese vlasy i brýle** | restyle generuje celý obraz znovu: hloubková mapa udrží siluetu nového účesu, ale barvu vlasů a tenké obruby ne. Co se nedostane do promptu, zmizí; server zná výběr a dosadí ho (§1). **Kontext stylizace** (instrukce bez ControlNetu) je druhý engine, který bench změří vedle (§5) |
| **Rámeček 0 = nový vzhled jako fotka** | pipeline ho stejně vyrobí a je to jediný rámeček, kde brýle a vlasy jsou jistě vidět |
| **Pás fotobuňky skládá server (Pillow)**, appka ukazuje mřížku živě a pás stáhne na sdílení | jeden PNG je to, co se sdílí; mřížka se plní po rámečcích |
| **Projekty se drží v telefonu (Hive + soubory), resume přes `jobId`** | vzor Ol1nLLM (`GenNode.jobId`, `follow()`): po uspání se appka napojí na běžící job a dotáhne rámečky, které mezitím dojely. Server drží výstupy v `DATA_DIR/outputs` |

## Co je hotové a znovu se použije (ověřeno v kódu 2026-10-31)

| potřeba | kde | poznámka |
|---|---|---|
| vlasy | `POST /api/hair` tělo: analýza → `hairmask.prepare` → `hairprompt.prompt` → Kontext graf | vytáhnout do `stages.hair(session, image, spec) -> (bytes, colour)` |
| brýle | `06-PLAN` `/api/glasses` | `stages.glasses(session, image, spec) -> bytes` — v pipeline **jedno** provedení |
| styly + identita | `POST /api/restyle`: `RESTYLE_ENGINES[medium]`, `flux_restyle.api.json` (PuLID 0.9, InstantX depth 0.55), `sdxl_restyle` (InstantID), `latent_for` | `stages.restyle(session, image, prompt, negative, medium) -> bytes` |
| katalog stylů | `lib/config/restyle_styles.dart`: 48 stylů / 6 skupin, `restylePrompt(style, medium)` = medium věta + blok | medium věty se stanou kontraktem i pro server (§1) |
| job s víc obrázky, průběh | `06-PLAN` §3 (`Job.prompt_ids`, `image_paths`, `images_done/total`, `/image/{i}`) | pipeline přidá `stage`, `frames`, `strip` |
| auth seam | `app.current_user_id`: schémata `tma` a `dev`; `bot = Bot(...) if BOT_TOKEN else None`, `lifespan` dnes bez tokenu padá | přidat schéma `app`, lifespan bez bota |
| kvóta | `db.spend_generation` (volné napřed, pak kredity), `undo_usage` | zobecnit na N v jedné transakci |
| CF Access z appky | Ol1nLLM: `CF-Access-Client-Id/Secret` hlavičky z `--dart-define`, `Makefile` s `.env.local` | tentýž vzor; **nikdy web build** (CLAUDE.md Tsumiki: dart-define secrets by do bundlu protekly) |
| resume po uspání | Ol1nLLM `_resumeInFlightJob`, `GenInterrupted`, backoff, `WidgetsBindingObserver` | vzor pro `BoothProject.jobId` |
| bench | `run.py restyle`, `score.py` (identita, reakce, `worn` z 06, délka/barva vlasů), `sheet.py` | nový task `pipeline` |

---

## Architektura

```
Restyler (Flutter iOS/Android)                    CF Access (service token)      JODA: restyler-api (tgbot, AUTH_MODE=app)
  1 Selfie   camera/gallery ≤1536 px                                              │
  2 Vlasy    HairPicker (tsumiki_shared)                                          │
  3 Brýle    GlassesPicker (typ + provedení / nechat / sundat)                    │
  4 Styly    K = 4|6|8, mixy Epochy/Malíři/Média/Překvapení, medium per rámeček   │
  5 Booth    POST /api/pipeline ─────────────────────────────────────────────────▶ 1. validace, 429, dekódování                 (400/429)
             {image, hair?, glasses?, frames[]}                                   2. usage = db.spend_generations(user, limit, n) (402)
             ◀── {job_id, frames_total} ──────────────────────────────────────────  3. Job(stage="hair") → _watch_pipeline
             GET /api/jobs/{id}  (poll 3 s; po resume totéž)                          a. hair:    analýza → maska → Kontext → A
             ◀── {status, stage, frames_done, frames_total, failed[]}                 b. glasses: analýza(A) → maska → Kontext → B
             GET /api/jobs/{id}/frame/{k}  → PNG do app support dir                   c. frame 0 = B (| A | originál)
             GET /api/jobs/{id}/strip      → pás na sdílení                           d. frames 1..K: restyle(B, prompt_k), window 2, selhaný = refund 1
                                                                                      e. strip.compose → outputs/<job>_strip.png
  Hive `booth_projects`: BoothProject{id, jobId, selfie, hair, glasses, frames[], framePaths[], status}
```

Mezivýsledky A, B jdou do ComfyUI pod jménem per job (`restyler_<job>_a.png`);
telefon je vidí až jako rámeček 0.

---

## Kroky

### 0. `packages/tsumiki_shared` v MangaPrompts (refaktor, Tsumiki musí zůstat zelená)

Přesunout beze změny chování:

```
packages/tsumiki_shared/
  lib/catalogs/   hairstyles.dart, hairstyle_catalog.dart, glasses.dart, glasses_catalog.dart, restyle_styles.dart
  lib/backend/    backend_client.dart   (dnešní TelegramBackendService bez Telegramu: baseUrl + AuthProvider → Map<String,String> hlaviček)
                  image_generation_service.dart (GeneratedImage, PaymentRequiredException), job polling, /api/me model (TgAccount → Account)
  lib/ui/         style_card.dart (dnešní `_StyleCard` s náhledem — zveřejnit), paywall_sheet.dart (text přes parametr: Tsumiki „Buy credits", Restyler „Limit for today")
  assets/hair/ assets/glasses/
  test/           hairstyles_test, restyle_styles_test, glasses_test (přesun)
```

- **Telegram zůstává v Tsumiki**: `platform/telegram_webapp*.dart`,
  `TelegramAuth implements AuthProvider` (vrací `Authorization: tma …`),
  `account_provider` nad klientem. Balíček **nesmí** importovat `dart:io`
  ani `dart:js_interop` (test grepem — CLAUDE.md pravidlo o seamech).
- `preview` gettery → `'packages/tsumiki_shared/assets/hair/$id.jpg'`;
  `export_catalog.py` cílí do balíčku (`TARGET`, `PREVIEW_DIR`);
  `catalog.py`/`test_bench_catalog.py` čtou `restyle_styles.dart` z nové cesty.
- Tsumiki `pubspec.yaml`: `tsumiki_shared: {path: packages/tsumiki_shared}`;
  importy přepsat; `flutter analyze` + `flutter test` zelené **před** čímkoli
  dalším; commit sám. Tag `shared-v1`; Restyler pinuje `ref:`.

### 1. Backend: `stages.py`, `restyleprompt.py`, `db.py`, `strip.py`, `app.py`, `config.py`

**`stages.py`** (nový): tři čisté funkce, které dnešní endpointy jen volají.

```python
async def hair(session, image: bytes, spec: HairSpec, tag: str) -> tuple[bytes, str | None]
async def glasses(session, image: bytes, spec: GlassesSpec, tag: str) -> bytes
async def restyle(session, image: bytes, prompt: str, negative: str, medium: str, tag: str) -> bytes
```

Každá: upload → (analýza → maska) → `prepare_workflow` → `queue_prompt` →
`wait_for_image`. Chyby: `StageRefused(code, message)` (fotka bez tváře,
bez očí, bez brýlí k sundání — chyba uživatele) vs. `ComfyError` (server).
`/api/hair`, `/api/glasses`, `/api/restyle` se přepíšou na tyhle funkce —
jejich testy musí procházet beze změny, to je důkaz refaktoru.

**`restyleprompt.py`** (nový — prompt stupně 3 skládá server, protože zná
vzhled):

```python
MEDIUM = {"photo": "...", "illustration": "..."}   # doslova věty z restyle_styles.dart; test je pinuje proti Dartu (vzor test_bench_catalog)
def prompt(style_block, medium, hair: HairSpec | None, hair_colour: str | None, glasses: GlassesSpec | None) -> str:
    look = []
    if hair:    look.append(f"with {hair.block}, {colour_phrase} hair")      # nová barva, jinak barva z analýzy stupně 1
    if glasses: look.append(f"wearing {'dark ' if glasses.tinted else ''}{glasses.finish} {glasses.block}")
    return ", ".join([MEDIUM[medium], *look, style_block])
```

Pořadí **medium → vzhled → styl**: medium je to, s čím se nesmí hádat
(CLAUDE.md), vzhled je obsah, styl jde poslední jako dnes. Kam patří vzhled,
je laboratorní osa `param.lookPosition=middle|end` (§5), ne rozhodnutí od
stolu. `restyle_styles.dart` dostane `restylePrompt(style, medium, {look})`,
aby Tsumiki a bench skládaly tentýž řetězec.

**Auth** (`app.py`, `config.py`):

```python
AUTH_MODE = os.environ.get("AUTH_MODE", "telegram")     # telegram | app
APP_TOKEN = os.environ.get("APP_TOKEN", "")
if AUTH_MODE == "telegram" and not BOT_TOKEN: raise RuntimeError(...)
if AUTH_MODE == "app" and len(APP_TOKEN) < 32: raise RuntimeError(...)
```

`current_user_id`: schéma `app` — `value == APP_TOKEN` (`hmac.compare_digest`)
a hlavička `X-User` (`^[a-z0-9_-]{2,32}$`, 400 bez ní) →
`user_id = -(int.from_bytes(sha256(X-User)[:6]) + 1)` (záporné, stabilní,
bez kolize s Telegram id; `user_id > 0` seam vypne chat). `tma` se v režimu
`app` odmítá a naopak. `lifespan`: polling a `bot.session.close()` jen když
`bot is not None`; `_watch_job`/`_watch_video_job`/`_tell_user` už mají
podmínku `user_id > 0` — ověřit, že nikde není `bot.` bez ní (grep v testu).
CORS v režimu `app` zbytečný, nevadí.

**`db.spend_generations(user_id, free_limit, n) -> list[int] | None`**:
jedna transakce, smyčka dnešní logiky (volné napřed, pak kredity);
nedostatek → rollback a `None`. Test: 3 volné + 2 kredity, n=5 → 5 usage;
n=6 → None a stav nezměněn.

**`strip.py`**: `compose(frames: list[bytes], labels: list[str], layout) -> bytes`.
Rámečky na stejný poměr (ořez na střed podle rámečku 0), bílý rám 3 %
kratší strany, mezera 2 %, popisek stylu pod rámečkem (font
`tgbot/assets/Inter-Regular.ttf`, `python:3.12-slim` žádný TTF nemá —
`COPY` v Dockerfile, test ověří existenci). Layout `grid` (2 sloupce) a
`strip` (1 sloupec, klasická fotobuňka). Pillow v `requirements.txt` je.
Test: 5 rámečků různých velikostí → jeden PNG, poměr 2:3 ± 1 % u všech.

**`config.py`**: `PIPELINE_MAX_FRAMES = 8`, `RESTYLE_CONCURRENCY = 2`,
`PIPELINE_TIMEOUT = 2400`, `MAX_PIPELINE_IMAGE_B64_CHARS`, `AUTH_MODE`,
`APP_TOKEN`, `APP_NAME` („Tsumiki" | „Restyler" — logy, `/start` tam, kde bot je).

**`jobs.py`**: `Job.stage: str | None`, `Job.failed_frames: list[int]`,
`Job.strip_path`, `Job.frames_total`. Zbytek z 06. Joby zůstávají v paměti
(restart = ztráta běžící pipeline); persistovat jako video joby (`db.video_jobs`)
je Fáze 2 — appka to pozná jako 404 na `jobId` a nabídne „Spustit znovu".

**`app.py` — `POST /api/pipeline`**:

- `PipelineRequest`: `image`, `hair: HairSpec | None` (= `HairRequest` bez
  `image`), `glasses: GlassesSpec | None` (= `GlassesRequest` bez `image`,
  `finish: str` jedno provedení), `frames: list[FrameSpec{style_id, block ≤ 600, label ≤ 80, medium}]`,
  `len(frames) ≤ PIPELINE_MAX_FRAMES`, aspoň jeden stupeň.
- `_watch_pipeline`: `StageRefused`/`ComfyError` ve stupni 1/2 → `status=error`,
  `error=message`, refund **všech** usage (nic nevzniklo). Rámeček k selže →
  `failed_frames.append(k)`, refund jedné usage, jede dál. Konec:
  `frames_done ≥ 1` → `done`, strip z hotových.
- `GET /api/jobs/{id}` + `stage`, `frames_done`, `frames_total`, `failed`;
  `GET /api/jobs/{id}/frame/{k}` (404 nad `frames_done`); `GET /api/jobs/{id}/strip`.
  Job patří uživateli (`job.user_id == user_id`, jako dnes).

Testy `tgbot/tests/test_pipeline_api.py` (FakeComfy z 06, navíc počítá, **který
obrázek** šel do kterého promptu) + `test_auth.py` rozšířený o režim `app`:
happy path hair+glasses+4 → 6 usage, 6 promptů, analýza brýlí dostala výstup
vlasů, restyle dostal výstup brýlí, prompt rámečku = medium→vzhled→styl,
`frames_total 5`, rámeček 0 = výstup brýlí, strip vznikl, **žádné** volání
bota; bez tváře → error + 6 refundů; rámeček 2 spadne → `done`, `failed [2]`,
1 refund; jen styly → rámeček 0 = originál; 402 bez jediného promptu; 429;
cizí `job_id` → 404; `app` bez `X-User` → 400, špatný token → 401, `tma`
v režimu `app` → 401; `RESTYLE_CONCURRENCY` nikdy překročena; lifespan bez
`BOT_TOKEN` v režimu `app` nastartuje.

### 2. Nasazení druhé instance (JODA, Cloudflare)

```yaml
  restyler-api:
    build: .
    container_name: restyler-api
    restart: unless-stopped
    env_file: restyler.env      # AUTH_MODE=app, APP_TOKEN=<64 hex>, APP_NAME=Restyler, FREE_DAILY_LIMIT=30,
                                # COMFY_URL=…, DATA_DIR=/app/data; žádný BOT_TOKEN, MINIAPP_URL, ALLOWED_ORIGINS
    volumes:
      - ../assets/comfyui:/app/workflows:ro
      - ./data-restyler:/app/data
    ports: ["8091:8090"]
```

`restyler.env.example` vedle `mangabot.env.example`. Cloudflare: public
hostname `restyler-api.ol1n.com` → `http://restyler-api:8090`, **Access
aplikace** s policy `non_identity` na service token (nový pár jen pro
Restyler — ne ten z `llm.ol1n.com`, aby šel rotovat sám). Appka posílá
`CF-Access-Client-Id/Secret` + `Authorization: app …` + `X-User`.
Oba backendy sdílí ComfyUI frontu; `jobs.active_count` je per instance.
`docs/telegram-release.md` dostane sestru `docs/restyler-release.md`: CF
Access app + token, `restyler.env`, TestFlight/APK, rotace.

### 3. Repo `Restyler` (Flutter iOS/Android)

Vzor Ol1nLLM: `Makefile` s `-include .env.local` a `--dart-define`
(`CF_ACCESS_CLIENT_ID`, `CF_ACCESS_CLIENT_SECRET`, `RESTYLER_APP_TOKEN`,
`RESTYLER_USER`, volitelně `RESTYLER_API_URL`, LAN jen `make debug`), cíle
`run / debug / build-ios / build-android`. **Žádný web target** (secrets by
protekly do bundlu; `flutter create --platforms ios,android`).

```
lib/
  main.dart                      Hive.initFlutter, ProviderScope, BackendClient(baseUrl, AppAuth(token, user))
  app.dart                       MaterialApp, vlastní téma (ne klon Tsumiki ani Ol1nLLM)
  models/booth_project.dart      BoothProject{id, createdAt, jobId?, selfiePath, hair{styleId,colourId}?, glasses{styleId,finish}?,
                                 frames[{styleId, medium, label}], framePaths[], stripPath?, status, failed[], error?}  — Hive JSON, soubory relativně (vzor GenImage.baseDir)
  providers/booth_provider.dart  StateNotifier + WidgetsBindingObserver: start(draft) → jobId → poll 3 s → stáhnout nové rámečky → Hive;
                                 resume při startu, `resumed` a 5 s po výpadku (vzor music/story providerů); 404 na jobId → status `lost` + „Spustit znovu"
  services/pipeline_service.dart start(draft) → jobId; status(jobId); frame(jobId,k) → bytes; strip(jobId); chyby česky z těla (`detail`)
  screens/
    home_screen.dart             seznam projektů (náhled rámečku 0, datum, počet stylů) + FAB „Nová fotobuňka"
    selfie_step.dart             image_picker camera (přední) / galerie, ≤1536 px, tipy (čelně, oči vidět, bez čepice)
    hair_step.dart               HairPicker (shared, náhledy), barvy, „Nechat vlasy"
    glasses_step.dart            GlassesPicker, provedení jako chipy, „Bez brýlí" / „Sundat brýle"
    styles_step.dart             K volič 4/6/8 (zbývající kvóta z /api/me: „dnes ještě 12"), mixy, ruční výběr, medium per rámeček
    booth_screen.dart            mřížka 2 sloupce, rámeček 0 nahoře přes šířku; stage text („Stříhám…", „Nasazuji brýle…", „Maluji 3/4");
                                 klepnutí → detail (uložit `gal`, sdílet `share_plus`); „Sdílet pás" → /strip
  widgets/                       frame_tile (placeholder / hotový / selhal s ikonou), stage_banner
test/  booth_project_test (serializace, cena = počet stupňů, prázdný draft nejde odeslat), pipeline_service_test (status parsování nad fixturou),
       booth_widget_test (plnění, selhaný rámeček), mixes_test (každé id mixu existuje v kRestyleStyles)
```

- Mixy: `kBoothMixes = {'Epochy': [...], 'Malíři': [...], 'Média': [...]}`
  nad id z `kRestyleStyles`. **„Média"** (akvarel, tužka, olej, dřevořez,
  komiks) dnešní katalog jako skupinu nemá — Popular a tradice část
  pokryjí; chybějící bloky jsou kandidáti pro `run.py restyle`, ne ruční
  zápis do appky.
- Jazyk UI: **česky** (jako Ol1nLLM; soukromá appka). Popisky účesů a
  barev mají `cs` v kandidátském JSONu — `export_catalog.py` ho vypíše do
  katalogu (`Hairstyle.cs`), styly Restyle `cs` nemají → Fáze 2, do té doby
  anglický label.
- Pozadí: iOS appku uspí, provider se po `resumed` napojí a dotáhne
  rámečky; server pipeline dojede sám. Lokální notifikace „Fotobuňka je
  hotová" = Fáze 2 (vyžaduje push nebo BG fetch).
- `pubspec`: `tsumiki_shared` (git, ref), `flutter_riverpod`, `hive_flutter`,
  `image_picker`, `http`, `path_provider`, `gal`, `share_plus`, `uuid`.
  iOS target podle `image_picker` (14+), `NSCameraUsageDescription`,
  `NSPhotoLibraryAddUsageDescription`.

### 4. Co se mění v Tsumiki

Funkčně nic. Po §0 jen importy a `TelegramAuth`; `/api/hair|glasses|restyle`
jedou přes `stages.py`. Karta „Fotobuňka" v Tsumiki nad týmž `/api/pipeline`
je jeden `TsumikiScreen` navíc — mimo tento plán.

### 5. Tuning feedback loop — bench task `pipeline`

Otázka, kterou nikdo neměřil: **přežije nový účes a brýle průchod přes
restyle?** Dnešní restyle měřil identitu a reakci na styl, ne obsah.

`run.py pipeline --engines flux,sdxl,kontext --styles <restyle ids> --looks
looks.json --srcs … --seeds 1,2` — `looks.json` = `{hair, colour, glasses,
finish}` kombinace; stupně 1–2 se renderují jednou per (src, look) a cachují
(`out/<run>/looks/`), stupeň 3 per (look, style, engine, seed). Engine
`kontext` = nový graf `flux_restyle_kontext.api.json`: instrukce „Turn this
photo into {style block}. Keep the person, their hairstyle, glasses, pose and
clothes." bez ControlNetu a bez PuLID — **kandidát**; `restyle-flux-results`
ukázal, že Kontext s depth ControlNetem pózu nedrží, bez něj to nikdo nezkoušel.

| metrika | jak | práh |
|---|---|---|
| `identity` | ArcFace výstup × **původní selfie** (řetězec identit se sčítá) | ≥ 0.50 (jeden skok měl 0.6; kalibrovat na baseline bez vlasů a brýlí) |
| `hair_kept` | `length_ok` + `colour_ok` ze `score.py` proti **cíli stupně 1** | ≥ 2/3 |
| `glasses_kept` | `worn` z 06 (face parsing `Eyeglasses`); u malířských stylů parsing selhává → CLIP „wearing glasses" vs „without glasses", zisk ≥ 0.1 proti rámečku bez brýlí | ≥ 2/3 |
| `style_reaction` | histogram vůči baseline bez stylu (stávající) | ≥ 0.10 |
| `clothed`, `clean` | stávající | 100 % |

Osy sweepu: `param.lookPosition=middle|end`, `15.weight=0.7|0.9` (PuLID —
drží tvář, přebíjí styl), `11.strength=0.45|0.55|0.7` (depth — silueta účesu
vs. volnost stylu), `9.guidance=3.0|3.5`, `graph.pulid_from=original|look`
(§7.2).

**Gate per styl, ne per katalog**: mapa styl → `{carries_hair,
carries_glasses, engine}`. Export do `restyle_styles.dart` jako
`RestyleStyle.carries` (`export_catalog.py --task restyle-carry`); Restyler
v kroku 4 u stylu, který brýle neudrží, ukáže „brýle tenhle styl většinou
neudrží" (nebo ho při zvolených brýlích zašedne — rozhodne oko na archu).
Odmítnout věrohodný požadavek je horší než varovat — totéž pravidlo jako
u enginů Kadeřníka.

Kola (~60–90 s/rámeček stupně 3 vč. fronty; kolo 0 změří):

| kolo | rozsah | buňky | čas |
|---|---|---|---|
| 0 | 2 looks × 4 styly (ukiyoe, vangogh-arles, hopper, art-deco) × 3 enginy × 1 src × 1 seed | 24 + 2 | 40 min |
| 1 | 4 looks (krátké/dlouhé × čiré/sluneční) × 48 stylů × 2 enginy (flux, kontext) × 1 src × 1 seed | ~400 | ~7 h |
| 2 | přeživší × 3 srcs (`w-long`, `m-short`, `w-glasses`) × 2 seedy + sweep PuLID/depth na 6 stylech, kde `glasses_kept` padalo | ~350 | ~6 h |

Výstup `docs/pipeline-matrix.md`, export `carries`, teprve pak TestFlight
pro víc lidí. Do té doby appka funguje bez varování — pipeline je
testovatelná s fake ComfyUI od prvního dne.

### 6. Dokumentace a rollout

- MangaPrompts `CLAUDE.md`: „`packages/tsumiki_shared`" (co tam je, bench
  exportuje katalogy tam, Restyler pinuje tag, žádný Telegram ani `dart:io`
  v jádru), „`stages.py` + `/api/pipeline`" (pořadí, účtování N, refund per
  stupeň, strip), „`AUTH_MODE=app`" (druhá instance bez bota, záporná user id).
  `tgbot/README.md`: Pipeline, režim `app`, instance `restyler-api`. `CHANGELOG.md`.
- Restyler `CLAUDE.md` (krátké): co appka je, `make run` s `.env.local`,
  závislost na `tsumiki_shared` a jak posunout `ref`, backend URL, **žádný
  web build**, katalogy a bench žijí v MangaPrompts.
- Rollout: §0 merge (Tsumiki zelená) → §1 + testy → `restyler-api` na JODĚ
  s dev tokenem → Restyler repo, `make debug` proti LAN (`RESTYLER_API_URL=http://joda:8091`,
  jen debug — release manifest nemá cleartext) → kolo 0–1 → `carries` →
  TestFlight / APK. E2E: selfie → vlasy + brýle + 4 styly → mřížka se plní,
  pás sdílený z telefonu, kvóta −6; bez tváře → chyba hned, kvóta 0; jen
  styly K=4 → rámeček 0 = selfie; shodit ComfyUI uprostřed → díra + 1
  refund; uspat appku na 3 min → po návratu dotažené rámečky; restart
  backendu během jobu → „Spustit znovu"; 402 před odesláním; špatný
  `APP_TOKEN` → 401; Tsumiki po §0 beze změny.

### 7. Rizika

1. **Styl smaže vzhled.** Depth drží siluetu, prompt barvu a brýle; malířské
   styly s volnou kresbou brýle nejspíš ztratí. Proto `carries` per styl a
   varování; Kontext engine jako záloha.
2. **Identita přes dva skoky.** PuLID dostane embedding z B, ne ze selfie.
   Alternativa k měření: PuLID číst z **originálu** (druhý `LoadImage` do
   `ApplyPulidFlux.image`), hloubku z B — bez nového uzlu; osa
   `graph.pulid_from=original|look`.
3. **Secrets v appce.** CF token + `APP_TOKEN` jsou v binárce; kdo appku má,
   může volat backend. Proto soukromá distribuce, kvóta per `X-User`, token
   jen pro Restyler (rotace nezasáhne Ol1nLLM) a `docs/restyler-release.md`
   s rotací. Store = účty + IAP (§9).
4. **`X-User` je sebeidentifikace.** Dva lidé se stejným jménem sdílí kvótu;
   pro soukromou appku přijatelné, zapsat do README.
5. **Délka.** ~1 min vlasy + ~1 min brýle + K×~70 s / 2 → K=4 ≈ 4–5 min.
   Appka usne; resume to řeší, notifikace je Fáze 2.
6. **Dva backendy, jedna fronta.** `RESTYLE_CONCURRENCY=2`, stupně 1–2
   sériově; kdyby Tsumiki uživatelé čekali, snížit env na 1.
7. **Joby v paměti.** Restart `restyler-api` uprostřed pipeline ji ztratí;
   appka ukáže „Spustit znovu", kvóta za nedoběhlé rámečky se **nevrací**
   (není komu — usage je zapsaná, job pryč). Persistovat joby jako video
   joby je Fáze 2; do té doby deploy jen při prázdné frontě (`/healthz`
   může vracet `active_jobs`).
8. **Refaktor §0 rozbije web import graph Tsumiki** — balíček bez `dart:io`
   (test grepem), `comfy_image_service` zůstává v Tsumiki.
9. **Katalog v balíčku, bench v MangaPrompts, appka jinde.** Katalog se mění
   jen exportem v MangaPrompts; Restyler jen posune `ref`. Do obou `CLAUDE.md`.

### 8. Co nedělat (a proč)

- **Ne orchestrace v telefonu nad ComfyUI (model Ol1nLLM)**: tři stupně a K
  renderů = 4–8 min, iOS uspí po minutě; stavový automat s resume per stupeň
  je víc kódu než celý `stages.py`, a hlavně by appka skládala masky a
  prompty znovu v Dartu — druhé zrcadlo `hairmask`/`glassesmask`, které by
  bench neměřil. Ol1nLLM zrcadlo existuje z jiného důvodu (Image Studio nemá
  backend); Restyler backend má.
- **Ne kopie katalogů do Restyleru**: do týdne by lhaly o tom, co bench změřil.
- **Ne web build Restyleru**: dart-define secrets v bundlu (pravidlo
  z Tsumiki `deploy-web.yml`).
- **Ne účty a platby v v1**: soukromá appka, kvóta stačí; store je jiný plán.

### 9. Fáze 2

- **Veřejná verze**: Sign in with Apple / Google → backend vydává per-user
  token, IAP balíčky místo Stars (`PACKAGES` zůstává, mění se zdroj kreditu),
  CF Access pryč (veřejná doména + rate limit). To je samostatný plán.
- Lokální notifikace „Fotobuňka je hotová" (BG fetch / push).
- Persistence pipeline jobů na serveru (vzor `video_jobs`), refund při pádu.
- Karta „Fotobuňka" v Tsumiki nad týmž endpointem.
- „Média" jako měřená skupina stylů (`run.py restyle` → `restyle_styles.dart`).
- České popisky stylů Restyle (`cs` do katalogu), animace rámečku (Animate umí).
