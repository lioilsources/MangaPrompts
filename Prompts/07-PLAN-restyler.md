# PLAN — Restyler: nová appka (selfie → vlasy → brýle → styly → fotobuňka)

> Pro Opuse. Nová Telegram Mini App **Restyler** (nové repo
> `lioilsources/Restyler`, vlastní bot, vlastní Pages projekt), která zabalí
> tři karty Tsumiki do jednoho průvodce a skončí mřížkou jako z fotobuňky.
> Backend zůstává `MangaPrompts/tgbot/` (tentýž kód, druhá instance). Staví
> na `04-PLAN-kadernik.md` (vlasy), `06-PLAN-bryle.md` (brýle, model jobu
> s víc obrázky) a `03-PLAN-restyle-painters-flux.md` (styly + identita).
> Pořadí závislostí: **06 §3 (Job s `image_paths`) musí být hotové dřív**, nebo
> se udělá tady.

## Zadání a rozhodnutí

Uživatel se vyfotí, (1) změní nebo přebarví vlasy, (2) vybere brýle, (3) svůj
nový vzhled prožene přes identitu tváře do několika stylů — epochy, malíři,
média — a dostane **mřížku jako z fotobuňky**: rámeček 0 je jeho nový vzhled
jako fotka, rámečky 1..K jsou styly.

Rozhodnutí, která plán dělá za uživatele (s důvodem — kdyby nesouhlasil,
mění se jen jedna věc):

| rozhodnutí | důvod |
|---|---|
| **Nové repo + nový bot + nová Pages doména, ale tentýž backend kód** | „nová appka" v Telegramu = nový bot s vlastním popisem, ikonou a Stars účtem. Backend `tgbot/` už umí všechny tři kroky; druhá instance téhož image s jiným `BOT_TOKEN`/`DATA_DIR`/`MINIAPP_URL` je jeden blok v compose, ne druhý codebase |
| **Sdílený kód do Dart balíčku `tsumiki_shared` v MangaPrompts**, Restyler ho bere jako git dependency | katalogy (účesy, barvy, brýle, styly) jsou **generované z benche** v MangaPrompts — kopie by zestárla do týdne. Tsumiki na balíček přejde přes `path:`, Restyler přes `git: {url, path, ref}` pinnutý na tag |
| **Pipeline = jeden job na serveru**, ne tři volání z appky | mezivýsledky nesmí chodit telefon → server → telefon (Mini App WebView usne při přepnutí); server je má v ruce a nahrává je rovnou do ComfyUI. Jeden job = jedno účtování, jeden progress, jedno album v chatu |
| **Pořadí stupňů: vlasy → brýle → styly** | analýza brýlí (obočí, oči) běží na **výstupu vlasů**, protože nová ofina zakryje obočí; styly dostanou obrázek, kde už obojí je |
| **Styly jedou přes restyle graf (depth + PuLID/InstantID) a prompt nese vlasy i brýle** | restyle generuje celý obraz znovu: hloubková mapa udrží siluetu nového účesu, ale barvu vlasů a tenké obruby brýlí ne. Co se nedostane do promptu, zmizí. Appka ví, co uživatel vybral, server to do promptu dosadí (§3). **Kontext stylizace** (instrukce bez ControlNetu) je druhý engine, který bench změří vedle (§5) |
| **Účtování: pipeline = N generací, strženo atomicky předem** | N = (vlasy ? 1) + (brýle ? 1) + K. Jedno `spend_generations(n)` v jedné transakci (volná kvóta napřed, pak kredity), 402 dřív než se sáhne na GPU; selhaný stupeň vrací svůj díl. Žádný nový balíček Stars — ledger je stejný |
| **Rámeček 0 = nový vzhled jako fotka** | ten obrázek pipeline stejně vyrobí a je to jediný rámeček, kde brýle a vlasy jsou jistě vidět; bez něj by uživatel neuměl posoudit, co styly udělaly |
| **Pás fotobuňky skládá server (Pillow)**, appka ukazuje mřížku živě | jeden PNG do chatu je to, co se sdílí; mřížka v appce se plní po rámečcích a klepnutím otevře detail |
| **Vlastní DB a kredity per bot** | oddělený produkt, oddělené Stars; refund `/refund` zůstává per bot. Sdílený ledger by znamenal sdílený `BOT_TOKEN` pro validaci initData, což nejde |

## Co je hotové a znovu se použije (ověřeno v kódu 2026-10-31)

| potřeba | kde | poznámka |
|---|---|---|
| vlasy | `POST /api/hair` tělo: analýza → `hairmask.prepare` → `hairprompt.prompt` → Kontext graf | vytáhnout do funkce `stages.hair(session, image, req) -> bytes`, endpoint ji zavolá |
| brýle | `06-PLAN` `/api/glasses` | `stages.glasses(session, image, req) -> bytes` — v pipeline **jedno** provedení, ne sada |
| styly + identita | `POST /api/restyle`: `RESTYLE_ENGINES[medium]`, `flux_restyle.api.json` (PuLID 0.9, InstantX depth 0.55), `sdxl_restyle` (InstantID), `latent_for` | `stages.restyle(session, image, prompt, negative, medium) -> bytes`; prompt skládá server (§3) |
| katalog stylů | `lib/config/restyle_styles.dart`: 48 stylů v 6 skupinách, `restylePrompt(style, medium)` = medium věta + blok | medium věty: `a photorealistic photograph of a fully clothed person wearing the clothes from the photo…` / `a painted illustration of a fully clothed person, artwork` |
| job s víc obrázky, průběh, album | `06-PLAN` §3 (`Job.prompt_ids`, `image_paths`, `images_done/total`, `/image/{i}`, `send_media_group`) | pipeline přidá `stage` a `frames` |
| účtování | `db.spend_generation`, `undo_usage` | zobecnit na N v jedné transakci |
| auth, paywall, account, Telegram seam | `tgbot/auth.py`, `paywall_sheet.dart`, `account_provider.dart`, `platform/telegram_webapp*.dart`, `TelegramBackendService` | jdou do `tsumiki_shared` |
| deploy | `.github/workflows/deploy-web.yml` (Pages, secret-scan), `tgbot/docker-compose.yml`, `docs/telegram-release.md` | Restyler dostane kopii workflow s jiným Pages projektem; compose druhou službu |
| bench | `run.py restyle` (styly, baseline, sweep), `score.py` (identita, reakce na baseline, `worn` z 06, délka/ofina vlasů), `sheet.py` | nový task `pipeline` = stupeň 3 nad výstupy stupňů 1–2 |

---

## Architektura

```
Restyler (Flutter web, Telegram Mini App)
  1 Selfie      ImagePicker camera/gallery, ≤1536 px
  2 Vlasy       HairPicker z tsumiki_shared (účes, barva, „nechat")
  3 Brýle       GlassesPicker (typ + jedno provedení, „nechat", „sundat")
  4 Styly       K = 4 | 6 | 8 rámečků: ruční výběr z kRestyleStyles, nebo mix („Epochy", „Malíři", „Média", „Překvapení");
                médium per rámeček (photo | illustration), výchozí podle skupiny
  5 Fotobuňka   mřížka 2×(K/2)+1 s rámečkem 0 = nový vzhled; plní se živě; „Sdílet pás" / „Uložit"
     └──▶ POST /api/pipeline {image, hair?: {style_id, block, shape, colour}, glasses?: {style_id, block, finish, fit},
                               frames: [{style_id, medium}, …]}
tgbot /api/pipeline
   1. validace, 429 při běžícím jobu, dekódování                                  (400/429)
   2. n = stupně; usage_ids = db.spend_generations(user, FREE_DAILY_LIMIT, n)      (402 — nic se nespustilo)
   3. Job(kind="image", pipeline=True, stage="hair", frames_total=K+1) → _watch_pipeline
      a. hair:    analýza → maska → Kontext → bytes A        (chyba analýzy = 400-ekvivalent: job error, refund všeho)
      b. glasses: analýza(A) → maska → Kontext → bytes B
      c. frame 0 = B (nebo A, nebo originál, když oba stupně přeskočené) → outputs/<job>_0.png
      d. frames 1..K: restyle(B, prompt_k) — rolling window RESTYLE_CONCURRENCY (2), selhaný rámeček = refund 1, pokračuje se
      e. strip.compose(frames) → outputs/<job>_strip.png; chat: send_photo(strip) + send_media_group(frames)
   GET /api/jobs/{id}      → {status, stage: hair|glasses|restyle|done, frames_done, frames_total, failed: [k…]}
   GET /api/jobs/{id}/frame/{k}, GET /api/jobs/{id}/strip
```

Mezivýsledky A, B se do ComfyUI nahrávají pod jménem per job
(`restyler_<job>_a.png`), telefon je nevidí dřív než jako rámeček 0.

---

## Kroky

### 0. `packages/tsumiki_shared` v MangaPrompts (refaktor, Tsumiki musí zůstat zelená)

Přesunout beze změny chování:

```
packages/tsumiki_shared/
  lib/catalogs/   hairstyles.dart, hairstyle_catalog.dart, glasses.dart, glasses_catalog.dart, restyle_styles.dart
  lib/backend/    telegram_backend_service.dart, image_generation_service.dart (GeneratedImage, PaymentRequiredException)
  lib/platform/   telegram_webapp.dart (+ _stub, _web)
  lib/providers/  account_provider.dart
  lib/ui/         paywall_sheet.dart, style_card.dart (dnešní `_StyleCard` s náhledem — zveřejnit)
  assets/hair/ assets/glasses/
  test/           hairstyles_test, restyle_styles_test, glasses_test (přesun)
```

- `preview` gettery → `'packages/tsumiki_shared/assets/hair/$id.jpg'`
  (Flutter balíčkové assety), `export_catalog.py` cílí do balíčku
  (`TARGET`, `PREVIEW_DIR`). `test_bench_catalog.py` a `catalog.py` čtou
  `restyle_styles.dart` z nové cesty.
- Tsumiki `pubspec.yaml`: `tsumiki_shared: {path: packages/tsumiki_shared}`;
  importy přepsat (`sed`), CI beze změny. `flutter analyze` + `flutter test`
  zelené **před** čímkoli dalším; commit sám.
- `TelegramBackendService._baseUrl` dnes čte `TG_BACKEND_URL` dart-define
  s defaultem Tsumiki — default se stane **parametrem** (`TelegramBackend.configure(baseUrl:)`
  v `main`), aby Restyler nemusel dart-define a web deploy bez secretů
  zůstal (viz `deploy-web.yml`: „TG_BACKEND_URL has a safe default").
- Tag `shared-v1` po merge; Restyler pinuje `ref:`.

### 1. Backend: `tgbot/stages.py`, `db.py`, `strip.py`, `app.py`

**`stages.py`** (nový): tři čisté funkce, které dnešní endpointy jen volají.

```python
async def hair(session, image: bytes, req: HairSpec, job_tag: str) -> tuple[bytes, str | None]   # (obrázek, barva z fotky)
async def glasses(session, image: bytes, req: GlassesSpec, job_tag: str) -> bytes
async def restyle(session, image: bytes, prompt: str, negative: str, medium: str, job_tag: str) -> bytes
```

Každá: upload → (analýza → maska) → `prepare_workflow` → `queue_prompt` →
`wait_for_image`. Chyby: `StageRefused(code, message)` (fotka bez tváře,
bez očí, bez brýlí k sundání — chyba uživatele) vs. `ComfyError` (server).
`/api/hair`, `/api/glasses`, `/api/restyle` se přepíšou na tyhle funkce
(testy jim musí dál procházet — to je důkaz, že refaktor nic nezměnil).

**Prompt stupně 3** (`restyleprompt.py`, nový — dnes ho skládá appka,
pipeline ho musí skládat server, protože zná vzhled):

```python
def prompt(style_block: str, medium: str, hair: HairSpec | None, hair_colour: str | None, glasses: GlassesSpec | None) -> str:
    head = MEDIUM[medium]                       # tytéž věty jako restyle_styles.dart — test je pinuje proti Dartu (vzor test_bench_catalog)
    look = []
    if hair:    look.append(f"with {hair.block}, {colour_phrase} hair")      # colour_phrase = nová barva, jinak barva z analýzy stupně 1
    if glasses: look.append(f"wearing {glasses.finish} {glasses.block}")
    return ", ".join([head, *look, style_block])
```

Pořadí **medium → vzhled → styl**: medium je to, s čím se nesmí hádat
(CLAUDE.md), vzhled je obsah, styl je vzhled obrazu a jde poslední jako
dnes. Kde má jít vzhled, je laboratorní osa `param.lookPosition=middle|end`
(§5) — ne rozhodnutí od stolu. Sluneční brýle: „wearing dark {block}".
`restyle_styles.dart` dostane `restylePrompt(style, medium, {look})`, aby
Tsumiki a bench skládaly stejný řetězec.

**`db.spend_generations(user_id, free_limit, n) -> list[int] | None`**:
jedna transakce, smyčka dnešní logiky (volné napřed, pak kredity);
nedostatek → rollback a `None`. `undo_usage` per položka beze změny.
Test: 3 volné + 2 kredity, n=5 → 5 usage; n=6 → None a stav nezměněn.

**`strip.py`**: `compose(frames: list[bytes], labels: list[str], layout) -> bytes`.
Rámečky na stejný poměr (ořez na střed podle rámečku 0), bílý rám 3 %
kratší strany, mezera 2 %, pod každým popisek stylu (font
`assets/fonts/Inter-Regular.ttf` v repu — `python:3.12-slim` žádný TTF
nemá); layout `grid` (2 sloupce) pro appku/chat a `strip` (1 sloupec,
klasická fotobuňka) na „Sdílet pás". Pillow už v `requirements.txt` je.
Test: 5 rámečků různých velikostí → jeden PNG, rozměr podle layoutu, žádný
rámeček deformovaný (poměr 2:3 ± 1 %).

**`config.py`**: `PIPELINE_MAX_FRAMES = _int_env(…, 8)`,
`RESTYLE_CONCURRENCY = 2`, `PIPELINE_TIMEOUT = 2400`, `APP_NAME`
(„Tsumiki" | „Restyler" — do `/start` a captionů), `MAX_PIPELINE_IMAGE_B64_CHARS`.

**`jobs.py`**: `Job.stage: str | None`, `Job.failed_frames: list[int]`,
`Job.strip_path`. Zbytek z 06.

**`app.py`**:

- `PipelineRequest`: `image`, `hair: HairSpec | None` (= dnešní `HairRequest`
  bez `image`), `glasses: GlassesSpec | None` (= `GlassesRequest` bez
  `image`, `finish: str` jedno provedení), `frames: list[FrameSpec]`
  (`style_id` z katalogu — server ho **ověřuje** proti `restyle_styles.dart`
  parsovanému `catalog.py`? Ne: server katalog Dartu za běhu nečte; appka
  posílá `block` + `style_id` + `medium` jako dnes u restyle, server validuje
  délky a enumy). `len(frames) ≤ PIPELINE_MAX_FRAMES`; aspoň jeden stupeň.
- `POST /api/pipeline` podle architektury. `_watch_pipeline`:
  `StageRefused` ve stupni 1/2 → `status=error`, `error=message`, refund
  **všech** usage (nic nevzniklo); `ComfyError` tamtéž → 502-ekvivalent
  v `error`, refund všech. Rámeček k selže → `failed_frames.append(k)`,
  refund jedné usage, jede dál. Po konci: `frames_done ≥ 1` → `done`.
  Album: `send_photo(strip, caption="📸 {APP_NAME} · {K} styles")` +
  `send_media_group(frames[:10])`.
- `GET /api/jobs/{id}` + `stage`, `frames_done`, `frames_total`,
  `failed`; `GET /api/jobs/{id}/frame/{k}`; `GET /api/jobs/{id}/strip`.
- `/start` text z `APP_NAME`: Restyler „Take a selfie, pick a haircut and
  glasses, and see yourself in a dozen styles 📸".

Testy `tgbot/tests/test_pipeline_api.py` (FakeComfy z 06 rozšířený o
počítání uploadů a o to, **který obrázek** jde do kterého promptu): happy
path hair+glasses+4 → 6 usage, 6 promptů, analýza brýlí dostala výstup
vlasů (ne originál), restyle dostal výstup brýlí, prompt rámečku obsahuje
blok účesu i brýlí i styl v pořadí medium→vzhled→styl, `frames_total 5`,
rámeček 0 = výstup brýlí, strip vznikl; bez tváře → error + 6 refundů;
rámeček 2 spadne → `done`, `failed [2]`, 1 refund, strip bez něj;
jen styly (bez vlasů a brýlí) → rámeček 0 = originál; 402 při 5 kreditech
a n=6 bez jediného promptu; 429; `frames` prázdné a bez stupňů → 422;
`RESTYLE_CONCURRENCY` nikdy překročena.

### 2. Nasazení druhé instance (`tgbot/docker-compose.yml`, JODA)

```yaml
  restylerbot:
    build: .
    container_name: restylerbot
    restart: unless-stopped
    env_file: restyler.env          # BOT_TOKEN (nový bot), APP_NAME=Restyler, MINIAPP_URL=https://restyler.ol1n.com,
                                    # ALLOWED_ORIGINS=https://restyler.ol1n.com, DATA_DIR=/app/data (vlastní volume)
    volumes:
      - ../assets/comfyui:/app/workflows:ro
      - ./data-restyler:/app/data
    ports: ["8091:8090"]
```

`restyler.env.example` vedle `mangabot.env.example`. CF tunnel: nový
public hostname `restyler-api.ol1n.com` → `http://restylerbot:8090`.
Oba boty sdílí ComfyUI frontu na SPARKu — `jobs.active_count` je per
instance, takže jeden člověk s oběma appkami může mít dva joby; přijatelné.
`docs/telegram-release.md`: sekce „Restyler" (BotFather, Pages projekt
`restyler`, doména, env, tunnel) — stejný checklist, jiné názvy.

### 3. Repo `Restyler` (Flutter, web only v1)

```
lib/
  main.dart                 ProviderScope; TelegramBackend.configure(baseUrl: 'https://restyler-api.ol1n.com')
  app.dart                  MaterialApp, tmavé téma (barvy jiné než Tsumiki — vlastní identita, ne klon)
  flow/                     Riverpod `RestylerDraft` {image, hair?, colour?, glasses?, finish?, frames[]}, krok průvodce
  screens/
    selfie_screen.dart      kamera / galerie, tipy (čelně, oči vidět, bez čepice); ukáže face box? ne — server rozhodne
    hair_step.dart          HairPicker z tsumiki_shared (náhledy), „Nechat vlasy" chip, barvy
    glasses_step.dart       GlassesPicker, provedení jako chipy pod kartou typu, „Bez brýlí" / „Sundat brýle"
    styles_step.dart        K volič (4/6/8 → cena v ⚡ hned, z /api/me), mixy, ruční výběr ze skupin, medium přepínač per rámeček
    booth_screen.dart       mřížka 2 sloupce, rámeček 0 nahoře přes šířku; placeholdery; stage text („Cutting hair…", „Putting on glasses…", „Painting 3 / 4");
                            klepnutí → detail (uložit / sdílet); FAB „Share strip" → /strip
  services/pipeline_service.dart   startPipeline(draft) → jobId; status stream; frame(k); strip()
test/   draft_test (cena = počet stupňů; prázdný draft nejde odeslat), booth_widget_test (plnění, failed rámeček má ikonu), pipeline_service_test (parsování statusu)
.github/workflows/deploy-web.yml   kopie z MangaPrompts: Pages projekt `restyler`, stejný secret-scan
```

Mixy jsou v Restyleru, ne v katalogu: `kBoothMixes = {'Epochy': [ukiyoe, baroque, egyptian, art-deco…], 'Malíři': [vangogh-arles, picasso-cubist, hopper, mucha-slav-epic…], 'Média': [...]}`
nad id z `kRestyleStyles` — test hlídá, že každé id v mixu v katalogu
existuje. **„Média"** (akvarel, tužka, olej, dřevořez, komiks) dnešní katalog
jako skupinu nemá — Popular a tradice část pokryjí; chybějící bloky jsou
kandidáti pro `run.py restyle` (bench už umí), ne ruční zápis.

Cena v UI: `n × 1 ⚡`, volná kvóta z `/api/me` („3 free today") — uživatel
vidí před odesláním, kolik stupňů platí; 402 → `PaywallSheet` ze shared.

### 4. Co se mění v Tsumiki

Nic funkčně. Po §0 jen importy; `/api/hair|glasses|restyle` jedou přes
`stages.py`. Pokud se §3 ukáže užitečný i tam, karta „Fotobuňka" v Tsumiki
je jeden `TsumikiScreen` navíc nad týmž endpointem — mimo tento plán.

### 5. Tuning feedback loop — bench task `pipeline`

Otázka, kterou nikdo neměřil: **přežije nový účes a brýle průchod přes
restyle?** Dnešní restyle měřil identitu a reakci na styl, ne obsah.

`run.py pipeline --engines flux,sdxl,kontext --styles <restyle ids> --looks
looks.json --srcs … --seeds 1,2` — `looks.json` = seznam `{hair, colour,
glasses, finish}` kombinací; stupně 1–2 se renderují jednou per (src, look)
a cachují (`out/<run>/looks/`), stupeň 3 per (look, style, engine, seed).
Engine `kontext` = nový graf `flux_restyle_kontext.api.json`: instrukce
„Turn this photo into {style block}. Keep the person, their hairstyle,
glasses, pose and clothes." bez ControlNetu a bez PuLID (Kontext drží
obsah sám) — **kandidát**, ne rozhodnutí; restyle-flux-results ukázal, že
Kontext s depth ControlNetem nedrží pózu, bez něj to nikdo nezkoušel.

| metrika | jak | práh |
|---|---|---|
| `identity` | ArcFace výstup × **původní selfie** (ne mezivýsledek — řetězec identit se sčítá) | ≥ 0.50 (restyle měl 0.6 na jeden skok; dva skoky Kontextem + restyle budou níž — kalibrovat na baseline „bez vlasů a brýlí") |
| `hair_kept` | `length_ok` + `colour_ok` ze `score.py` proti **cíli stupně 1** (ne předloze) | ≥ 2/3 |
| `glasses_kept` | `worn` z 06 (face parsing `Eyeglasses` na výstupu); u malířských stylů parsing selhává → záloha CLIP „a portrait of a person wearing glasses" vs „…without glasses", zisk ≥ 0.1 proti rámečku bez brýlí | ≥ 2/3 |
| `style_reaction` | histogram vůči baseline bez stylu (stávající) | ≥ 0.10 |
| `clothed`, `clean` | stávající | 100 % |

Osy sweepu: `param.lookPosition=middle|end`, `__face_apply__`-ekvivalent
`15.weight=0.7|0.9` (PuLID — vyšší váha drží tvář, ale přebíjí styl,
`docs/restyle-flux-results.md`), `11.strength=0.45|0.55|0.7` (depth — silueta
účesu vs. volnost stylu), `9.guidance=3.0|3.5`.

**Gate per styl, ne per katalog**: výsledek je mapa styl → `{carries_hair,
carries_glasses, engine}`. Export do `restyle_styles.dart` jako pole
`RestyleStyle.carries` (`export_catalog.py --task restyle-carry`), a Restyler
v kroku 4 u stylu, který brýle neudrží, ukáže „glasses may not survive this
style" (nebo ho při zvolených brýlích zašedne — rozhodne oko na archu, jak
moc to bolí). Odmítnout věrohodný požadavek je horší než varovat — totéž
pravidlo jako u enginů Kadeřníka.

Kola (~60–90 s/rámeček stupně 3 vč. fronty; kolo 0 změří):

| kolo | rozsah | buňky | čas |
|---|---|---|---|
| 0 | 2 looks × 4 styly (ukiyoe, vangogh-arles, hopper, art-deco) × 3 enginy × 1 src × 1 seed — grafy, cache stupňů, metriky | 24 + 2 looks | 40 min |
| 1 | 4 looks (krátké/dlouhé vlasy × čiré/sluneční brýle) × 48 stylů × 2 enginy (flux, kontext) × 1 src × 1 seed | ~400 | ~7 h (přes noc) |
| 2 | přeživší × 3 srcs (`w-long`, `m-short`, `w-glasses`) × 2 seedy + sweep PuLID/depth na 6 stylech, kde `glasses_kept` padalo | ~350 | ~6 h |

Výstup `docs/pipeline-matrix.md`, pak export `carries`, pak se Restyler
pustí ven. Do té doby Restyler funguje, jen bez varování — pipeline je
testovatelná s fake ComfyUI od prvního dne.

### 6. Dokumentace a rollout

- MangaPrompts `CLAUDE.md`: sekce „`packages/tsumiki_shared`" (co tam je, že
  katalogy exportuje bench tam, že Restyler ho pinuje tagem), „`stages.py` +
  `/api/pipeline`" (pořadí stupňů, účtování N, refund per stupeň, strip,
  `APP_NAME`, druhá instance). `tgbot/README.md`: sekce Pipeline + Restyler
  instance. `CHANGELOG.md`.
- Restyler `CLAUDE.md` (nové, krátké): co appka je, závislost na
  `tsumiki_shared` (jak posunout `ref`), backend URL, deploy jen z CI, že
  katalogy a bench žijí v MangaPrompts.
- Rollout: §0 merge (Tsumiki zelená) → §1 + testy → compose druhá instance
  s dev botem → Restyler repo, Pages preview → kolo 0–1 → `carries` →
  prod bot. E2E: selfie → vlasy + brýle + 4 styly → mřížka se plní (stage
  texty), strip v chatu + album 5 fotek, −6 ⚡; bez tváře → chyba hned,
  0 ⚡; jen styly K=4 → rámeček 0 = selfie, −4 ⚡; rámeček spadne (shodit
  ComfyUI uprostřed) → mřížka s dírou, −1 refund; 402 před odesláním;
  Tsumiki po §0 beze změny chování.

### 7. Rizika

1. **Styl smaže vzhled.** Depth drží siluetu, prompt barvu a brýle; malířské
   styly s volnou kresbou (Picasso, Pollock-like) brýle nejspíš ztratí.
   Proto `carries` per styl a varování; Kontext engine jako záloha pro styly,
   které to na restyle grafu neudrží.
2. **Identita přes dva skoky.** Kontext edit (vlasy) → Kontext edit (brýle) →
   PuLID z výsledku. PuLID dostane embedding z B, ne ze selfie; kdyby B už
   odjelo, styl to jen zhorší. Alternativa k měření: PuLID číst z
   **originálu** (druhý `LoadImage` do `ApplyPulidFlux.image`), hloubku z B —
   graf to umožňuje bez nového uzlu; osa `graph.pulid_from=original|look`.
3. **Cena.** 6 ⚡ za jednu „fotobuňku" při 3 volných denně = první den
   půlka zdarma, pak balíček. UI ukazuje cenu před odesláním; mix „Překvapení"
   drží K=4. Kdyby se ukázalo, že to brzdí, přibude package `booth` — jedno
   místo (`PACKAGES`).
4. **Délka.** ~1 min vlasy + ~1 min brýle + K×~70 s / 2 → K=4 ≈ 4–5 min,
   K=8 ≈ 7 min. Mini App usne při přepnutí; strip a album přijdou do chatu
   vždy — booth screen to říká.
5. **Dva boty, jedna fronta.** Restyler pipeline drží GPU déle než jeden
   obrázek; `RESTYLE_CONCURRENCY=2` a stupně 1–2 sériově. Kdyby Tsumiki
   uživatelé čekali, snížit na 1 (env), ne přepisovat.
6. **Refaktor §0 rozbije Tsumiki web import graph.** `tsumiki_shared` nesmí
   importovat `dart:io` (CLAUDE.md pravidlo o seamech) — `image_generation_service`
   interface ano, `comfy_image_service` ne (zůstává v Tsumiki). `web_entry_test`
   to hlídá dnes; přidat test, že balíček nemá `dart:io` import (grep v testu).
7. **Katalog v balíčku, bench v MangaPrompts, appka jinde** — tři místa.
   Pravidlo: katalog se mění **jen** exportem v MangaPrompts, Restyler jen
   posune `ref`. Zapsat do obou `CLAUDE.md`.
8. **Font v image** — Pillow bez TTF kreslí bitmapový font; `assets/fonts/`
   do `Dockerfile` (`COPY assets/fonts`), test stripu kontroluje, že font
   existuje, jinak padá.

### 8. Co nedělat (a proč)

- **Ne tři volání z appky** (hair → glasses → restyle po telefonu): WebView
  usne, mezivýsledky by chodily tam a zpátky, tři účtování, tři progress bary.
- **Ne kopie katalogů do Restyleru**: do týdne by lhaly o tom, co bench změřil.
- **Ne společný ledger obou botů**: initData validuje `BOT_TOKEN`, sdílený
  ledger by chtěl sdílený token nebo mapování účtů — produkt to nepotřebuje.
- **Ne nativní build v v1**: Restyler je Mini App; iOS/Android by chtěly
  vlastní auth (dnes je to Telegram initData) a to je jiný plán.

### 9. Fáze 2

- Karta „Fotobuňka" v Tsumiki nad týmž `/api/pipeline` (jeden `TsumikiScreen`).
- „Média" jako měřená skupina stylů (akvarel, tužka, olej, dřevořez, komiks)
  přes `run.py restyle` → `restyle_styles.dart`.
- Animace rámečku (karta Animate už umí) — „oživit fotobuňku".
- Ol1nLLM: pipeline jako akce na dlaždici (vlasy a brýle už tam zrcadlí,
  restyle = repose s identitou) — plán `08-PLAN-ol1nllm-restyler.md`.
