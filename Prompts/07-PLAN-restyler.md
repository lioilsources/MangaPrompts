# PLAN — Restyler: nová mobilní appka, offline-first (selfie → vousy → brýle → vlasy → styly → fotobuňka)

> Pro Opuse. Nová **Flutter iOS/Android appka Restyler** (nové repo
> `lioilsources/Restyler`), ne Telegram Mini App. **Co nejvíc offline**:
> parsing tváře, masky, odhad barvy, prompty, katalogy s náhledy, projekty i
> pás fotobuňky se dělají v telefonu. Síť je potřeba na **jediný endpoint**
> `POST /api/render`, který na SPARKu vyrenderuje zadaný řetězec kroků a vrátí
> obrázky. Backend je `MangaPrompts/tgbot/` (tentýž kód, druhá instance bez
> bota, za Cloudflare Access). Staví na `04-PLAN-kadernik.md` (vlasy),
> `06-PLAN-bryle.md` (brýle), `08-PLAN-vousy.md` (vousy, nový),
> `03-PLAN-restyle-painters-flux.md` (styly + identita) a na Dart zrcadle
> masky z Ol1nLLM (`lib/models/hair_mask.dart`, `05-PLAN-ol1nllm-kadernik.md`).

## Zadání a rozhodnutí

Uživatel se vyfotí, (1) změní vousy (muži), (2) vybere brýle, (3) změní nebo
přebarví vlasy, (4) svůj nový vzhled prožene přes identitu tváře do několika
stylů — epochy, malíři, média — a dostane **mřížku jako z fotobuňky**:
rámeček 0 je nový vzhled jako fotka, rámečky 1..K jsou styly. Každý krok jde
přeskočit.

| rozhodnutí | důvod |
|---|---|
| **Analýza tváře běží v telefonu, stejným modelem jako na serveru** | dnes analýzu dělá ComfyUI (`hair_analyse.api.json`, `FaceSegment` = SegFormer na CelebAMask-HQ, 19 tříd: vlasy, kůže, oči, obočí, nos, rty, **brýle, uši, čepice, krk, oblečení**). Tenhle model se exportuje do ONNX a běží na telefonu; masky pak sedí na kalibraci benche. Jiný parser (MediaPipe) by znamenal novou kalibraci všech konstant |
| **Masky, barva vlasů, prompty a pás: Dart, offline** | `hair_mask.dart` v Ol1nLLM je hotové zrcadlo `hairmask.py` (541 řádků, stejné konstanty a fixtury); `package:image` dekóduje PNG i JPEG. Brýle a vousy dostanou totéž zrcadlo. Prompty jsou dnes v Dartu taky (`hairPrompt`), restyle věty v `restyle_styles.dart` |
| **Server je hloupý renderer: `POST /api/render` s řetězcem kroků** | nic z Restyleru (masky, prompty, pořadí) na serveru nežije. Krok = `{graph, input: "source" \| "<krok>", prompt, mask?}` z whitelistu grafů; server řetězec vyrenderuje (výstup kroku je vstup dalšího), vrátí obrázky. Tsumiki endpointy (`/api/hair`…) zůstávají pro Mini App |
| **Řetězec stále běží na serveru, ne po krocích z telefonu** | stupeň 2 potřebuje výstup stupně 1 jako **vstup ComfyUI**; posílat ho do telefonu a zpátky by stálo minuty na mobilních datech a iOS appku uspí do minuty. Server drží mezivýsledky v `/input` ComfyUI a telefon jen polluje. „Offline" znamená *logika* v telefonu, ne přenos obrázků sem a tam |
| **Všechny masky se počítají na originální selfie** | telefon nevidí mezivýsledky. Pořadí **vousy → brýle → vlasy → styly** je zvolené tak, aby maska počítaná na originálu platila i pro vstup svého kroku: vousy a brýle mění jen tvář, kterou maska vlasů chrání; brýle sedí na očích, které maska vlasů i vousů vynechává. Co se tím ztratí (nová ofina přes obočí, kam už brýle sedí), měří bench osou `order` (§6) |
| **Jen Kontext edit pro vousy/brýle/vlasy, restyle graf pro styly** | tři editační grafy jsou tentýž `flux_hair_kontext.api.json` s jiným promptem a maskou — server má jeden graf `kontext_edit`. Styly jedou přes `flux_restyle`/`sdxl_restyle` (depth + PuLID/InstantID), prompt nese vousy, brýle i vlasy, protože co není v promptu, restyle zahodí |
| **Soukromá distribuce (TestFlight/APK), CF Access token v `--dart-define`** jako Ol1nLLM | appka nese secret; store = účty + platby = Fáze 2 |
| **Auth `app <APP_TOKEN>` + `X-User`, kvóta per uživatel, žádné platby** | Stars nejsou; `FREE_DAILY_LIMIT` na instanci; záporná user id vypnou doručení do chatu (seam `job.user_id > 0` už existuje) |
| **Sdílený Dart balíček `tsumiki_shared` v MangaPrompts** (katalogy, masky, prompty, náhledy, klient) | katalogy generuje bench tam; masky musí mít Python i Dart verzi se stejnými fixturami; Restyler bere `git: {url, path, ref}` na tag. Ol1nLLM na balíček přejde později (Fáze 2), do té doby je jeho `hair_mask.dart` **zdroj**, ze kterého se do balíčku kopíruje |
| **Výsledky se stáhnou do telefonu a dál žijí offline** (Hive + soubory) | projekt jde otevřít, sdílet a skládat do pásu bez sítě; `jobId` zůstává jen na resume během renderu |

## Co je hotové a znovu se použije (ověřeno v kódu 2026-10-31)

| potřeba | kde | poznámka |
|---|---|---|
| Dart maska vlasů + barva | Ol1nLLM `lib/models/hair_mask.dart`: `BoolMask`, `HairAnalysis`, `buildHairMask`, `estimateHairColour`, `maskToPng`, `hairFeatherPx`, konstanty 1:1 s Pythonem | do `tsumiki_shared/lib/masks/` jako kanonická kopie; primitivy (`faceBox`, `dilate`, `roundedRect`) sdílí brýle i vousy |
| Dart prompt vlasů | Ol1nLLM `hairstyle_preset.dart::hairPrompt(style, colour, instruction:, newColour:)` = Tsumiki `hairprompt.py` | do balíčku; `instruction: true` je Kontext věta |
| katalogy | `hairstyles`, `hairstyle_catalog` (+ `cs` v kandidátech), `glasses_catalog` (06), `restyle_styles` (48 stylů, medium věty) | náhledy `assets/hair`, `assets/glasses`, nově `assets/beard` |
| Kontext edit graf | `flux_hair_kontext.api.json` (ReferenceLatent, maska → `GrowMaskWithBlur` → `ImageCompositeMasked`, `TsumikiAlignToReference`) | na serveru pod klíčem `kontext_edit`; feather z velikosti masky (`hairmask.apply_feather`) |
| restyle grafy + identita | `flux_restyle.api.json` (PuLID 0.9, InstantX depth 0.55), `sdxl_restyle` (InstantID), `latent_for` | klíče `restyle_flux`, `restyle_sdxl` |
| job s víc obrázky, průběh | `06-PLAN` §3 (`prompt_ids`, `image_paths`, `images_done/total`, `/image/{i}`) | `/api/render` ho používá, přidá `steps` |
| auth seam | `current_user_id` (`tma`, `dev`), `bot = Bot(...) if BOT_TOKEN else None`, `lifespan` bez tokenu padá | schéma `app`, lifespan bez bota |
| kvóta | `db.spend_generation`, `undo_usage` | `spend_generations(n)` v jedné transakci |
| CF Access z appky | Ol1nLLM `Makefile` (`.env.local`, `--dart-define`), hlavičky `CF-Access-Client-Id/Secret` | tentýž vzor |
| resume po uspání | Ol1nLLM `_resumeInFlightJob`, `WidgetsBindingObserver`, backoff | vzor pro `BoothProject.jobId` |
| bench | `run.py` (hair, restyle; glasses z 06; beard z 08), `score.py`, `sheet.py`, `verdicts.py`, `export_catalog.py` | nový task `pipeline` a nástroj parity (§2) |

---

## Architektura

```
TELEFON (offline)                                                SÍŤ                 SERVER (restyler-api = tgbot, AUTH_MODE=app)
selfie (kamera/galerie, ≤1536 px)
  └─ FaceParser (ONNX, CelebAMask-HQ 19 tříd)  →  masky: hair, skin, brows, eyes, nose, lips, glasses, ears, hat, cloth
  └─ hairColour = estimateHairColour(rgb, hair)
kroky průvodce (každý „Nechat"):
  vousy  → beardMask(parse, style.region)   + beardPrompt(style, hairColour)
  brýle  → glassesMask(parse, style.fit)    + glassesPrompt(style, finish)
  vlasy  → hairMask(parse, style.shape)     + hairPrompt(style, hairColour, newColour)
  styly  → K × restylePrompt(style, medium, look{beard, glasses, hair})
RenderPlan = [ {id:"beard",   graph:"kontext_edit",  input:"source", prompt, mask},
               {id:"glasses", graph:"kontext_edit",  input:"beard",  prompt, mask},
               {id:"hair",    graph:"kontext_edit",  input:"glasses",prompt, mask},
               {id:"s1..sK",  graph:"restyle_flux",  input:"hair",   prompt, negative, medium} ]
                                                              ──▶ POST /api/render {source, steps}        (402/429/422)
                                                              ◀── {job_id, steps_total}                   usage = spend_generations(n)
                                                                                                          DAG: krok čeká na svůj input; nezávislé kroky
                                                              GET /api/jobs/{id} (poll 3 s)               (styly) rolling window RENDER_CONCURRENCY=2
                                                              ◀── {status, steps:{id:{status,error?}}, done, total}
                                                              GET /api/jobs/{id}/step/{id} → PNG         výstupy v DATA_DIR/outputs, vstupy v ComfyUI /input
Hive booth_projects + soubory: rámeček 0 = poslední editační krok (nebo selfie), 1..K styly
pás fotobuňky = package:image (grid 2 sloupce / strip 1 sloupec) → gal / share_plus
```

Na server jde **jedna** fotka (originál) a masky (PNG, ~kB). Nic jiného
Restyler na serveru nepotřebuje; server neví, co je účes.

---

## Kroky

### 0. `packages/tsumiki_shared` v MangaPrompts (Tsumiki zůstává zelená)

```
packages/tsumiki_shared/
  lib/catalogs/   hairstyles(+catalog), glasses(+catalog), beards(+catalog), restyle_styles  — Hairstyle.cs atd. z kandidátů
  lib/masks/      bool_mask.dart (BoolMask, faceBox, dilate, roundedRect, maskToPng, decodeMaskPng)   ← z Ol1nLLM hair_mask.dart
                  face_parse.dart (FaceParse: 19 tříd → BoolMask per třída; HairAnalysis z něj)
                  hair_mask.dart, glasses_mask.dart, beard_mask.dart, hair_colour.dart
  lib/prompts/    hair_prompt.dart, glasses_prompt.dart, beard_prompt.dart, restyle_prompt.dart (medium → look → styl)
  lib/backend/    backend_client.dart (baseUrl + AuthProvider), render_plan.dart (RenderStep, RenderPlan.toJson), job polling, Account
  lib/ui/         style_card.dart, quota_sheet.dart
  assets/hair/ assets/glasses/ assets/beard/
  test/           katalogy; masky nad SDÍLENÝMI fixturami (viz níž); prompty pinnuté na řetězce z Pythonu
```

- **Fixtury masek jsou soubory**, ne kód: `tgbot/tests/fixtures/masks/<case>/{parse.png, expected-<style>.png}`
  generuje Python (`hairmask`, `glassesmask`, `beardmask`), Dart testy je čtou
  (balíček má `test/fixtures` jako symlink/kopii přes `tools/sync_fixtures.sh`).
  Dnešní `synthetic()` v obou jazycích je slabší pojistka — stejný vzorec
  napsaný dvakrát může být dvakrát stejně špatně.
- Prompty: `test/prompts_test.dart` čte `tgbot/tests/fixtures/prompts.json`
  (vstup → očekávaný řetězec, zapsaný Pythonem) — vzor `test_bench_catalog`.
- Balíček **bez** `dart:io`, `dart:js_interop`, bez Telegramu (test grepem).
  `TelegramAuth` a `telegram_webapp*` zůstávají v Tsumiki.
- `export_catalog.py` cílí do balíčku; `preview` →
  `'packages/tsumiki_shared/assets/<kind>/$id.jpg'`.
- Tsumiki `pubspec`: `path: packages/tsumiki_shared`; analyze + test zelené;
  commit sám; tag `shared-v1`.

### 1. Parsing tváře v telefonu (`tools/ondevice/` v MangaPrompts + `face_parse.dart`)

1. **Zjistit model**: na SPARKu `models/RMBG/` — co `FaceSegment` opravdu
   načítá (CLAUDE.md říká SegFormer na CelebAMask-HQ, plán 04 psal BiSeNet;
   rozhoduje soubor na disku). `export_parser.py`: HF/torch → ONNX, vstup
   512×512 (stejné `process_res` jako graf), výstup 19 logitů; `--fp16`;
   ověřit `onnxruntime` na SPARKu, že výstup == ComfyUI maska (IoU ≥ 0.98 na
   `srcs/`). Pokud je model SegFormer-B5 (85 M), změřit čas na iPhonu/Androidu
   v kroku 3 spike; strop **3 s**. Nad strop → menší člen rodiny
   (SegFormer-B0/B2 dotrénovaný na CelebAMask-HQ, nebo BiSeNet 13 M) **a
   parity gate**: IoU masek proti serverovému parseru ≥ 0.90 na `srcs/` per
   třída (hair, skin, brows, eyes, glasses); pod ním se přepočítává kalibrace
   a to je jiný plán.
2. **Druhý parser na dlouhé vlasy**: `ClothesSegment` (ATR) kvůli vlasům přes
   hruď (hair-matrix §1). Export stejnou cestou (`segformer_b2_clothes`),
   nebo — levněji — MediaPipe `selfie_multiclass_256x256` (třída hair, 256²,
   tflite→ONNX). Parita stejná metrika; vyhraje ten, co projde a je menší.
3. `face_parse.dart`: `onnxruntime` (pub `onnxruntime`, CoreML/NNAPI EP)
   — jeden runtime pro oba modely; modely jako assety balíčku (`assets/models/*.onnx`,
   velikost zapsat do README; nad 50 MB → stahovat při prvním startu a
   cachovat, ne bundlovat). Předzpracování = to, co dělá ComfyUI uzel
   (resize na 512 s poměrem? pad? — **přečíst z kódu uzlu**, ne hádat;
   `tools/ondevice/README.md` to zapíše). Výstup `FaceParse` → `HairAnalysis`
   (`hair = face∪clothes hair`, `face` = skin+nose+eyes+brows+lips+glasses,
   `hat`, `features`, `glasses`, `ears`, `lips`, `nose`).
4. `tools/ondevice/parity.py`: ComfyUI maska vs. ONNX maska per třída na
   `srcs/` + reálných selfie z telefonu (lokálně, mimo repo) → tabulka do
   `docs/ondevice-parity.md`. Běží na SPARKu i jako Dart integrační test
   (zlaté masky z Pythonu v fixtures).

### 2. Backend: `POST /api/render`, režim `app`

**Kontrakt** (`app.py`):

```python
class RenderStep(BaseModel):
    id: str = Field(pattern=r"^[a-z0-9_-]{1,16}$")
    graph: Literal["kontext_edit", "restyle_flux", "restyle_sdxl"]
    input: str                      # "source" | id dřívějšího kroku
    prompt: str = Field(min_length=1, max_length=MAX_PROMPT_CHARS)
    negative: str = ""
    mask: str | None = None         # b64 PNG, povinná pro kontext_edit, zakázaná jinde
    medium: Literal["photo", "illustration"] | None = None   # jen restyle_sdxl → RESTYLE_CHECKPOINTS
class RenderRequest(BaseModel):
    source: str                     # b64, ≤ MAX_RESTYLE_IMAGE_B64_CHARS
    steps: list[RenderStep] = Field(min_length=1, max_length=RENDER_MAX_STEPS)   # 12
```

Validace před čímkoli: id unikátní, `input` ukazuje na `source` nebo na
dřívější krok (DAG bez cyklu z definice), maska má rozměr zdroje
(`imagesize`), `kontext_edit` bez masky → 422. `RENDER_GRAPHS = {"kontext_edit":
"flux_hair_kontext.api.json", "restyle_flux": "flux_restyle.api.json",
"restyle_sdxl": "sdxl_restyle.api.json"}` v `config.py` — graf se vybírá jen
z této mapy, appka nikdy neposílá JSON grafu.

**Běh** (`_watch_render`): `usage = spend_generations(user, limit, len(steps))`
(402 → nic). Upload `source` jako `restyler_<job>_source.png`; kroky v
topologickém pořadí; krok startuje, až má vstup (výstup předchozího kroku
se nahraje do ComfyUI jako `restyler_<job>_<id>.png` — bytes už server má);
nezávislé kroky (styly) `RENDER_CONCURRENCY = 2`. `kontext_edit`:
`prepare_workflow(mask_name=…)` + `hairmask.apply_feather(wf, mask_png)`
(geometrie masky, ne účesu — zůstává na serveru, protože graf je tam).
`restyle_*`: `latent=latent_for(input_bytes)`, `checkpoint` jen pro sdxl.
Chyba kroku → `steps[id].status=error`, refund 1, **kroky závislé na něm**
se označí `skipped` s refundem (nic se nerenderuje). Konec: aspoň jeden
výstup → `done`. Výstupy `outputs/<job>_<id>.png`.

`GET /api/jobs/{id}` → `{status, done, total, steps: {id: {status: queued|running|done|error|skipped, error?}}}`;
`GET /api/jobs/{id}/step/{id}` → PNG (404 dokud není `done`). Job patří
uživateli. Žádný strip, žádná caption, žádný chat — to vše dělá telefon.

**Auth** (`config.py`, `app.py`): `AUTH_MODE = telegram | app`;
`APP_TOKEN ≥ 32` znaků v režimu `app`, `BOT_TOKEN` povinný jen v `telegram`.
Schéma `app`: `compare_digest(value, APP_TOKEN)` + `X-User`
(`^[a-z0-9_-]{2,32}$`, jinak 400) → `user_id = -(int.from_bytes(sha256(user)[:6]) + 1)`.
`lifespan`: polling a `bot.session.close()` jen s botem; test grepem, že
`bot.` se nikde nevolá bez `user_id > 0`. `tma` v režimu `app` → 401.

**`db.spend_generations(user_id, free_limit, n) -> list[int] | None`**:
jedna transakce, rollback při nedostatku.

Testy `tgbot/tests/test_render_api.py` (FakeComfy počítá uploady a páruje
vstup kroku s výstupem předchozího): řetězec beard→glasses→hair→4 styly →
7 usage, 7 promptů, krok `glasses` dostal výstup `beard` (ne source), styly
dostaly výstup `hair`, `kontext_edit` má `__MASK__` a feather podle masky,
`restyle_sdxl` má checkpoint a latent podle vstupu; krok `hair` spadne →
styly `skipped`, 5 refundů, `done` s 2 výstupy; styl 2 spadne → 1 refund,
ostatní `done`; cyklus/neznámý `input` → 422; maska u restyle → 422;
`kontext_edit` bez masky → 422; 13 kroků → 422; 402 bez promptu; 429;
cizí job → 404; `RENDER_CONCURRENCY` nikdy překročena; `test_auth.py`
režim `app` (bez `X-User` 400, špatný token 401, `tma` 401, lifespan bez
`BOT_TOKEN` nastartuje).

### 3. Nasazení (JODA, Cloudflare)

```yaml
  restyler-api:
    build: .
    container_name: restyler-api
    restart: unless-stopped
    env_file: restyler.env   # AUTH_MODE=app, APP_TOKEN=<64 hex>, APP_NAME=Restyler, FREE_DAILY_LIMIT=40, COMFY_URL=…
    volumes: [ "../assets/comfyui:/app/workflows:ro", "./data-restyler:/app/data" ]
    ports: ["8091:8090"]
```

`restyler.env.example`; CF public hostname `restyler-api.ol1n.com` →
`http://restyler-api:8090`, Access app s `non_identity` na **novém** service
tokenu (rotace nezasáhne Ol1nLLM). `docs/restyler-release.md` (token, env,
TestFlight/APK, rotace).

### 4. Repo `Restyler` (Flutter iOS/Android)

`Makefile` jako Ol1nLLM (`.env.local`: `CF_ACCESS_CLIENT_ID/SECRET`,
`RESTYLER_APP_TOKEN`, `RESTYLER_USER`, volitelně `RESTYLER_API_URL` pro LAN
jen `make debug`). **Žádný web target.**

```
lib/
  main.dart                        Hive.initFlutter; FaceParser.load() (ONNX sessions, lazy při prvním selfie); BackendClient(AppAuth)
  models/booth_project.dart        {id, createdAt, selfiePath, parsePath?, beard?, glasses?, hair{styleId,colourId}?, frames[{styleId,medium}],
                                   plan (RenderPlan JSON — co se poslalo), jobId?, stepPaths{id: path}, status, failed[], error?}
  providers/booth_provider.dart    draft → analyse (isolate: FaceParser + masky + barva; chyby česky dřív než se cokoli pošle)
                                   → plan → start → poll 3 s → stáhnout hotové kroky → Hive; resume při startu / resumed / po výpadku;
                                   404 na jobId → `lost` + „Spustit znovu" (plán je uložený, nic se nepřepočítává)
  services/render_service.dart     start(source, plan) → jobId; status; step(jobId, id) → bytes
  services/strip.dart              package:image: grid/strip, bílý rám, popisky (font jako asset)
  screens/ home (projekty), selfie_step, beard_step, glasses_step, hair_step, styles_step (K 4/6/8, mixy, kvóta z /api/me), booth_screen
  widgets/ frame_tile, stage_banner („Upravuji vousy…", „Nasazuji brýle…", „Stříhám…", „Maluji 3/4")
test/  booth_project_test, render_plan_test (pořadí kroků, input odkazy, přeskočené kroky se do plánu nedostanou, cena = počet kroků),
       strip_test (poměr rámečků), analyse_test (zlaté masky z fixtures → stejný plán jako Python), mixes_test
```

- Analýza běží **hned po selfie** (isolate, ~1–3 s) a hned řekne „tvář
  nenalezena / oči nejsou vidět / na fotce nejsou vousy k oholení" — bez
  sítě a bez kvóty. Náhled masky (volitelný, debug chip) ukáže pás, který se
  přemaluje.
- Rámeček 0 = výstup posledního editačního kroku, který byl v plánu (jinak
  selfie). Mixy nad `kRestyleStyles` (`mixes_test` hlídá id). Jazyk UI
  česky; `cs` popisky z kandidátů, styly Restyle zatím anglicky.
- `pubspec`: `tsumiki_shared` (git ref), `onnxruntime`, `flutter_riverpod`,
  `hive_flutter`, `image_picker`, `image`, `http`, `path_provider`, `gal`,
  `share_plus`, `uuid`. iOS 14+, `NSCameraUsageDescription`,
  `NSPhotoLibraryAddUsageDescription`.

### 5. Vousy

Samostatný plán `08-PLAN-vousy.md`: maska dolní části tváře (nos → brada,
spánky → ucho), Kontext instrukce, kandidáti (strniště, plnovous, bradka,
kníry, oholit), bench gate, katalog `beard_catalog.dart` + náhledy na
`m-short`. Restyler ho bere jako krok 1 průvodce (`beard_mask.dart`,
`beard_prompt.dart` v balíčku); Tsumiki může dostat kartu nad týmž kódem.

### 6. Tuning feedback loop — bench

Tři měření, každé svoje:

**a) Parita parseru** (§1.4): IoU per třída, serverový vs. on-device model;
gate ≥ 0.90 (hair, skin, brows, eyes, glasses), `docs/ondevice-parity.md`.

**b) Řetězec** — `run.py pipeline --order beard,glasses,hair --looks looks.json
--styles … --engines flux,sdxl,kontext --srcs … --seeds …`: stupně se
renderují **přes `/api/render` běžící instance** (ne přes `prepare_workflow`
přímo) — bench tím měří i kontrakt; masky z Pythonu (stejné jako Dart díky
fixturám). Osa `order` (`beard,glasses,hair` vs. `hair,glasses,beard`)
ukáže, co stojí masky počítané na originálu.

| metrika | jak | práh |
|---|---|---|
| `identity` | ArcFace výstup × **původní selfie** | ≥ 0.50 (tři Kontext skoky + restyle; kalibrovat na baseline bez úprav) |
| `beard_kept`, `glasses_kept`, `hair_kept` | metriky z 08 / 06 / `score.py` proti **cíli svého kroku**, měřené na výstupu *každého dalšího* kroku — kde se změna ztratila | ≥ 2/3 |
| `style_reaction`, `clothed`, `clean` | stávající | 0.10 / 100 % / 100 % |

Osy: `param.lookPosition=middle|end`, `15.weight=0.7|0.9` (PuLID),
`11.strength=0.45|0.55|0.7` (depth), `graph.pulid_from=original|look`
(PuLID embedding ze selfie místo z výstupu kroku — řetězec identit se sčítá).
Engine `kontext` pro styly = `flux_restyle_kontext.api.json` (instrukce bez
ControlNetu) jako kandidát.

**Gate per styl**: `RestyleStyle.carries {hair, glasses, beard}` exportem;
Restyler u stylu varuje („brýle tenhle styl většinou neudrží"). Kola:
0 = 2 looks × 4 styly × 3 enginy × 1 src (40 min); 1 = 4 looks × 48 stylů ×
2 enginy × 1 src (~7 h); 2 = přeživší × 3 srcs × 2 seedy + sweepy (~6 h).
Výstup `docs/pipeline-matrix.md`.

**c) Vousy** — kola v 08.

### 7. Dokumentace a rollout

- MangaPrompts `CLAUDE.md`: `packages/tsumiki_shared` (jádro bez Telegramu a
  `dart:io`; masky a prompty mají Python originál a Dart zrcadlo pinnuté
  **souborovými** fixturami; katalogy exportuje bench), `/api/render`
  (whitelist grafů, DAG, refund per krok, `skipped`), `AUTH_MODE=app`,
  `tools/ondevice/` (export, parita). `tgbot/README.md`, `CHANGELOG.md`.
- Restyler `CLAUDE.md`: offline-first, co běží v telefonu, jediný endpoint,
  `make run`, posun `ref` balíčku, žádný web build, modely ONNX (odkud, velikost).
- Rollout: §0 → §1 spike (čas parseru na telefonu, parita) **před** §2 —
  kdyby model na telefonu neběžel do 3 s a parita nevyšla, mění se §1, ne
  zbytek → §2 + testy → `restyler-api` → appka proti LAN → 08 kolo 0–1 →
  §6b kolo 0–1 → `carries` → TestFlight/APK. E2E: selfie bez sítě → masky,
  chyby a plán hned; síť → 7 kroků, mřížka se plní, pás ze telefonu, kvóta
  −7; shodit ComfyUI u kroku `hair` → styly `skipped`, −2; uspat appku 3
  min → dotaženo; restart backendu → „Spustit znovu" stejným plánem;
  špatný token 401; Tsumiki po §0 beze změny; Ol1nLLM beze změny.

### 8. Rizika

1. **Model na telefonu je jiný než na serveru** → masky nesedí na
   kalibraci. Proto export *téhož* modelu, parita jako gate, menší model jen
   s přepočtem. Čas: SegFormer-B5 na 512² může být 2–6 s na starším
   Androidu — strop 3 s, jinak menší člen rodiny.
2. **Masky z originálu vs. vstup kroku**: nová ofina může přepsat obočí,
   kde brýle sedí; dlouhý plnovous může zasáhnout obálku vlasů `long`.
   Pořadí vousy→brýle→vlasy to minimalizuje, osa `order` to měří. Záloha:
   krok `reparse` na serveru (analýza mezivýsledku) — ale to je přesně ta
   logika, která nemá na serveru být; až když to oko na archu vyžádá.
3. **Styl smaže vzhled** → `carries` a varování; Kontext engine jako záloha.
4. **Identita přes čtyři skoky** → `pulid_from=original`.
5. **Secrets v binárce** → soukromá distribuce, token jen pro Restyler,
   kvóta per `X-User`; store = Fáze 2.
6. **Joby v paměti**: restart `restyler-api` ztratí běžící řetězec; appka
   má uložený plán a nabídne „Spustit znovu"; persistence jobů = Fáze 2;
   deploy při prázdné frontě (`/healthz` vrací `active_jobs`).
7. **Generický endpoint** = kdo má token, renderuje cokoli z whitelistu.
   Prompty mají délkový strop, grafy jsou tři, kvóta platí; víc ochrany
   soukromá appka nepotřebuje.
8. **Tři kopie masek** (Python, balíček, Ol1nLLM) do Fáze 2 — souborové
   fixtury ve všech třech testech; Ol1nLLM přejde na balíček.
9. **Velikost appky**: dva ONNX modely (desítky až stovky MB). Nad 50 MB se
   stahují při prvním startu z `restyler-api.ol1n.com/models/` (statické,
   za Access) — jediná výjimka z „jen render", a jen jednou.

### 9. Co nedělat (a proč)

- **Ne analýza na serveru pro Restyler** (dnešní `hair_analyse` graf): celé
  zadání je offline; graf zůstává jen pro Tsumiki Mini App.
- **Ne mezivýsledky do telefonu a zpět**: minuty přenosu, uspaná appka,
  nic z toho uživatel nepotřebuje vidět dřív než hotové rámečky.
- **Ne MediaPipe/ML Kit jako hlavní parser**: jiné třídy (bez brýlí, uší,
  čepice), jiná kalibrace. Nejvýš jako druhý parser na dlouhé vlasy, s paritou.
- **Ne kopie katalogů do Restyleru**; **ne web build**; **ne účty a platby v v1**.

### 10. Fáze 2

- Ol1nLLM přejde na `tsumiki_shared` (jedno Dart zrcadlo).
- Veřejná verze: Sign in with Apple/Google, IAP, bez CF Access.
- Persistence render jobů na serveru (vzor `video_jobs`), refund při pádu.
- Krok `reparse` jen pokud to arch vyžádá (riziko 2).
- Lokální notifikace po dokončení; „Média" jako měřená skupina stylů; české
  popisky stylů; karta „Fotobuňka" a „Vousy" v Tsumiki nad týmž kódem.
