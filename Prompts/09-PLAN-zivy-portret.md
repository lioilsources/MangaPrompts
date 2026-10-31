# PLAN — Živý portrét: rozhýbání fotky (mrkání, pohled kolem, úsměv, vlasy)

> Pro Opuse. Repo `lioilsources/MangaPrompts` (bench, grafy, `tgbot/`),
> ComfyUI + video-api na SPARKu. Krok průvodce Restyleru
> (`07-PLAN-restyler.md`: „Oživit rámeček") a druhá sekce karty Animate
> v Tsumiki. Navazuje na měřicí aparát pro video identitu
> (`Ol1nLLM/tools/facebench/vidbench.py`, `reports/couple_phase0.md` §4).

## Zadání a rozhodnutí

Z hotové fotky (selfie, rámeček fotobuňky) udělat krátký klip, kde člověk
**mrkne, podívá se kolem sebe, usměje se** a případně se mu **pohnou vlasy**.
Zůstává to on, zůstává to ta fotka — žádná scéna, žádná kamera.

| rozhodnutí | důvod |
|---|---|
| **Dva enginy podle druhu pohybu**: mrkání / pohled / úsměv / otočení hlavy = **LivePortrait** (expression retargeting, sekundy); vlasy ve větru = **Wan 2.2 I2V** přes video-api (minuty) | Wan 2.2 14B na GB10 trvá 15–30 min na 5 s (`docs/couple-spark-setup.md`) a na mikropohyby tváře je to kanón na vrabce; LivePortrait pohyb tváře *přenese* z řídicího klipu do fotky za sekundy, deterministicky a bez změny identity mimo tvář. Vlasy ale nehýbe (jedou tuze s hlavou) — na vítr je potřeba generativní model |
| **Řídicí klipy (drivers) jsou syntetické a v repu** | LivePortrait potřebuje video někoho, kdo mrká a usmívá se; z klipu bere jen pohyb. Drivers se jednou vygenerují Wanem ze syntetických předloh (`tgbot/tools/bench/srcs/`, žádná osobní data) a uloží do `assets/drivers/<motion>.mp4` (3–4 s, 25 fps, ~200 kB). Vlastní nahrávka majitele je povolená jen lokálně, mimo repo |
| **Pohyb = preset z katalogu, ne volný text** | u mikropohybů není co psát; preset má driver, délku a to, co bench změřil (mrkne? usměje se?). Kombinace (`alive` = mrknutí + pohled kolem + úsměv) je driver slepený z dílů |
| **Klip je smyčka**: driver začíná i končí neutrálně | portrét, který se po 4 s zasekne v úsměvu, je horší než ten, co se vrátí; smyčka se dá přehrávat donekonečna (Live Photo později) |
| **Výstup mp4 H.264 25 fps v rozměru fotky** (dlouhá strana ≤ 1080) | sdílení, přehrávání v appce (`video_player`), chat Telegramu |
| **V Restyleru je to krok `/api/render`** (graf `live_portrait`), **Wan preset je krok `wan_motion`** přes video-api v tomtéž jobu | jediný endpoint zůstává; server k obrázku kroku přidá driver a vrátí mp4. Wan krok je v DAGu označený jako dlouhý a appka ho ukazuje zvlášť („vlasy ve větru, ~20 min") |
| **Účtování**: LivePortrait = 1 generace, Wan = `RENDER_VIDEO_COST` generací (Restyler) / 1 video kredit (Tsumiki) | sekundy GPU vs. dvacet minut |

## Co je hotové a znovu se použije

| potřeba | kde | poznámka |
|---|---|---|
| identita ve videu | `Ol1nLLM/tools/facebench/vidbench.py` — ArcFace per snímek, stopy, **p10 čistých snímků**, `--action` do CSV, `--max-yaw/--min-det/--min-face` | jedna osoba = jedna stopa; zavřené oči a profil nejsou selhání identity (čistota) |
| landmarks | insightface antelopev2 má `2d106det` (106 bodů: oči, ústa) + pózu (yaw/pitch) | EAR mrkání, poměr úst, rozsah yaw — bez nového modelu |
| maska vlasů / tváře | `hair_analyse` graf / `face_parse.dart`, `hairmask` | pohyb vlasů = optický tok v masce vlasů |
| Wan I2V s vlastním promptem | video-api `POST /jobs {prompt, beats}` (LLM přepis do angličtiny), `tgbot/video.py`, Tsumiki `/api/animate`, Ol1nLLM `video_service.dart` | preset „vlasy ve větru" je jen prompt + `beats=1` |
| render DAG | `07-PLAN` §2 `/api/render`, job s víc výstupy (06) | nový typ výstupu: soubor mp4 (`history.outputs[*].gifs` u VHS, ne `images`) |
| bench | `run.py` (resume, sweep), `score.py`, `sheet.py`, `verdicts.py`, `export_catalog.py --task` | task `live`; arch s videem (`<video>` v sheetu, náhled = prostřední snímek) |

## Co je potřeba na SPARKu (ověřit přes `/object_info` před čímkoli)

| potřeba | uzel / soubor | poznámka |
|---|---|---|
| LivePortrait | `ComfyUI-LivePortraitKJ` (kijai): `DownloadAndLoadLivePortraitModels`, `LivePortraitLoadCropper` (insightface **nebo** MediaPipe), `LivePortraitProcess`, `LivePortraitComposite`, `LivePortraitRetargeting` | váhy `models/liveportrait/*.safetensors` (appearance_feature_extractor, motion_extractor, spade_generator, warping_module, stitching_retargeting_module, ~1 GB); cropper insightface `buffalo_l` nebo MediaPipe — vzít ten, co už na boxu je |
| video I/O | VideoHelperSuite: `VHS_LoadVideo`, `VHS_VideoCombine` (h264-mp4, crf 19) | nebo nativní `LoadVideo`/`SaveVideo` ComfyUI ≥ 0.3.4x — rozhodne inventura |
| Wan | video-api beze změny | preset je prompt |
| skórování | ComfyUI venv: insightface, cv2, numpy (`vidbench` už tam běží) | MediaPipe FaceMesh (iris) volitelně — pohled očí bez otočení hlavy jinak nezměříme |

---

## Architektura

```
fotka (selfie / rámeček)  +  motion preset ─▶ POST /api/render step {graph:"live_portrait", input:"hair", motion:"alive"}
                                                 server: driver = assets/drivers/alive.mp4 (jednou nahraný do ComfyUI /input)
                                                 graf: LoadImage(__IMAGE__) → cropper → LivePortraitProcess(driving=__DRIVER__,
                                                       relative_motion, stitching, driving_multiplier) → Composite → VHS_VideoCombine → mp4
                                                 výstup outputs/<job>_<id>.mp4 ; GET /api/jobs/{id}/step/{id} vrací video/mp4
                             motion:"hair-breeze" ─▶ step {graph:"wan_motion"}: server volá video-api POST /jobs {prompt, beats:1},
                                                 polluje jako /api/animate, stáhne result → tentýž tvar výstupu
```

Tsumiki: karta Animate dostane sekci **Live portrait** (sekundy) nad **Scenes**
(minuty): `POST /api/live {motion, image}` → tentýž graf, 1 image kredit,
mp4 do chatu (`send_animation`). Ol1nLLM: akce na dlaždici = Fáze 2.

---

## Kroky

### 1. Inventura a graf (`assets/comfyui/live_portrait.api.json`)

1. `/object_info` → tabulka výš; chybějící uzly/váhy nainstalovat
   (`comfyui_nodes/deploy.sh` rozšířit o LivePortraitKJ + VHS, váhy přes
   `hf download`), zapsat do `docs/live-portrait-setup.md`.
2. Graf: `LoadImage __IMAGE__` → `LivePortraitLoadCropper` → `VHS_LoadVideo
   __DRIVER__` (force_rate 25) → `LivePortraitProcess` (`relative_motion:
   true`, `stitching: true`, `lip_zero: false`, `driving_multiplier: 1.0`,
   `mismatch_method: constant`) → `LivePortraitComposite` (zpět do původní
   fotky, mimo tvář pixel-přesně) → `VHS_VideoCombine` (`frame_rate 25`,
   `format video/h264-mp4`, `crf 19`, `filename_prefix tsumiki_live`).
   Placeholder `__DRIVER__` → `prepare_workflow` dostane `driver_name`
   (stejná konvence jako `__POSE__`). `check_workflow.py` proti SPARKu.
3. `comfy.output_refs` / `pick_outputs`: VHS ukládá do `gifs` (klíč historie),
   ne `images` — rozšířit párování podle prefixu a vracet i mp4;
   `wait_for_image` → `wait_for_output` s typem. Test v `test_comfy.py` nad
   zachycenou historií VHS.

### 2. Drivers (`tgbot/tools/bench/drivers/`)

`run.py drivergen --out assets/drivers`: pro každý preset jeden klip Wanem
přes video-api z `srcs/w-long.png` (neutrální tvář, čelně), prompt
v angličtině bez kamery, `beats=1`, pak `ffmpeg` ořez na 3–4 s a **návrat do
neutrálu** (klip se prodlouží o reverzní část, nebo se vybere úsek, který
končí blízko začátku — `loop_error` L1 první vs. poslední snímek ≤ práh).

| preset | driver prompt (Wan) | délka |
|---|---|---|
| `blink` | the person blinks naturally twice, otherwise perfectly still, looking at the camera | 3 s |
| `glance` | the person's eyes glance to the left, then to the right, then back to the camera, head still | 3 s |
| `look-around` | the person slowly turns their head slightly left, then right, looking around curiously, then back to the camera | 4 s |
| `smile` | the person breaks into a warm natural smile, then relaxes back to neutral | 3 s |
| `nod` | the person gives a small friendly nod and returns to neutral | 2 s |
| `alive` | slepené `blink` + `look-around` + `smile` (ffmpeg concat, přechody přes neutrál) | 8 s |
| `hair-breeze` | *(Wan přímo na fotce, žádný driver)*: a gentle breeze moves the person's hair softly, the person stays still and looks at the camera | 5 s |

Drivers se kontrolují týmiž metrikami jako výstupy (§4): driver, který
nemrkne, se zahodí a generuje s jiným seedem. Výsledné mp4 do
`assets/drivers/` (repo, ~1–2 MB celkem), seed a prompt do
`drivers/manifest.json`. Server je při startu nahraje do ComfyUI `/input`
(`tsumiki_driver_<motion>.mp4`, overwrite — vzor pose šablon v Ol1nLLM).

### 3. Backend

- `config.py`: `LIVE_WORKFLOW_FILE = "live_portrait.api.json"`, `DRIVERS_DIR`,
  `MOTIONS` (načteno z `assets/drivers/manifest.json`: id → {driver, seconds,
  engine: live|wan, prompt?}), `RENDER_VIDEO_COST = 5`, `LIVE_TIMEOUT = 180`.
- `/api/render` (07 §2): graf `live_portrait` (`motion` povinné, `mask`
  zakázaná; `input` = libovolný krok nebo source) a `wan_motion` (`motion`
  s `engine: wan`; server volá `video.submit(prompt=MOTIONS[m].prompt, beats=1)`
  a polluje `video.status` — stejný kód jako `_watch_video_job`, jen bez
  Telegramu a v DAGu). Výstup kroku má `kind: image|video`; `GET
  /api/jobs/{id}/step/{id}` posílá správný `Content-Type`.
- Tsumiki `POST /api/live {motion, image}` → `spend_generation` (obrázková
  kvóta) → `live_portrait` graf → `_watch_job` ukládá `.mp4`, do chatu
  `send_animation` s caption „🎞 Smile". `/api/animate` beze změny (Wan scény).
- Testy: `test_render_api.py` + krok `live_portrait` (driver dosazen, výstup
  mp4, `kind: video`, cena 1) a `wan_motion` (cena `RENDER_VIDEO_COST`,
  FakeVideo z `test_video.py`); `test_live_api.py` vzor `test_hair_api.py`;
  neznámý `motion` → 422; `mask` u live → 422.

### 4. Bench — task `live` (`run.py live --motions all --srcs … --engines live,wan`)

Buňka = (motion, src, engine, seed — u LivePortrait seed nic nemění, jeden).
Výstup mp4 + `frames/` každý 2. snímek. Metriky (`score.py`, běží v ComfyUI
venv; identita importem z `vidbench`):

| metrika | jak | práh |
|---|---|---|
| `identity` | `vidbench` p10 čistých snímků vs. zdrojová fotka; čistota: `det ≥ 0.55`, EAR nad mrkacím prahem (zavřené oči se nepočítají), yaw ≤ 30° | ≥ 0.60 (stejná osoba na stupnici facebenche; LivePortrait by měl dávat > 0.8, Wan níž) |
| `blink` | EAR (eye aspect ratio z 2d106: výška/šířka očí) — mrknutí = pokles pod 0.6× medián na ≥ 2 snímky | preset s mrknutím ≥ 1, bez mrknutí 0 |
| `smile` | poměr šířka/výška úst + zdvih koutků vs. 1. snímek; vrchol ≥ +15 % | preset s úsměvem pass; ostatní ≤ +5 % (úsměv nemá vzniknout sám) |
| `look_around` | rozsah yaw z insightface pózy: ≥ 6° na obě strany; `glance` navíc posun zornice (MediaPipe iris) ≥ 8 % šířky oka, yaw ≤ 3° | preset pass; `blink`/`smile` yaw ≤ 3° (hlava se nemá hýbat sama) |
| `hair_motion` | medián velikosti optického toku (Farneback) v masce vlasů / v masce tváře | `hair-breeze` ≥ 2.0; LivePortrait presety 0.7–1.3 (vlasy jedou s hlavou, ne jinak) |
| `loop` | L1 první vs. poslední snímek (po normalizaci) ≤ 4/255 | 100 % u presetů označených `loop` |
| `still` | průměrný |Δ| mezi sousedními snímky **mimo** masku tváře+vlasů ≤ 1/255 (LivePortrait) / ≤ 3/255 (Wan) | 100 % — pozadí a tělo se nemají hýbat ani blikat |
| `clean` | právě jedna tvář v každém snímku; rozměr = zdroj; délka a fps podle presetu | 100 % |

Gate per preset × engine (jako u všeho ostatního): přijatý preset jde do
`motions_catalog` s enginem, odmítnutý se ladí (`driving_multiplier`,
jiný driver seed) a měří znovu. Arch (`sheet.py`) ukazuje `<video>` smyčku
a tři snímky (začátek / vrchol / konec).

Předlohy: `srcs/` všechny (muž, žena, brýle, ofina ¾ profil, afro, dlouhé
vlasy) — brýle a ¾ profil jsou pro LivePortrait kritické (cropper, odlesky
na sklech při mrknutí). Sweepy: `driving_multiplier=0.8|1.0|1.2`,
`relative_motion=on|off`, `stitching=on|off` (bez stitchingu se hýbe krk a
límec — `still` to chytí), `cropper=insightface|mediapipe`.

Kola: 0 = 3 presety × 2 předlohy × live (grafy, VHS výstup, metriky; ~10 min);
1 = 6 presetů × 10 předloh × live + `hair-breeze` × 3 předlohy × wan
(~60 buněk live ≈ 20 min, 3 Wan ≈ 1 h); 2 = sweepy na tom, co padalo. Výstup
`docs/live-matrix.md`, `export_catalog.py --task live` →
`tsumiki_shared/lib/catalogs/motions_catalog.dart` (id, label, cs, seconds,
engine, loop) — bez náhledu obrázkem; náhled presetu = ikona + sekundy
(video náhledy v katalogu = Fáze 2).

### 5. Appky

**Restyler**: v `booth_screen` má každý rámeček akci „Oživit" → sheet
presetů (`kMotions`, rychlé sekundy / pomalé minuty odděleně, cena v
kvótě) → nový krok do existujícího projektu (`RenderPlan` s jedním krokem,
`input: "source"` = bytes toho rámečku — appka ho pošle jako `source`, ne
jako odkaz na starý job, který už nemusí existovat) → mp4 do
`stepPaths`, přehrávání `video_player` (smyčka), sdílení `share_plus`,
uložení do Fotek (`gal` umí mp4). Dlaždice s klipem má ikonu přehrávání.
**Tsumiki**: `AnimateScreen` sekce Live portrait (`kMotions` engine `live`),
`TelegramBackendService.liveImage()` → `_awaitImageJob` s mp4 → nový
`VideoResultScreen` (nebo rozšířený `ResultScreen` o video), do chatu přijde
animace. `screenOffered` beze změny (karta už existuje). **Ol1nLLM**: Fáze 2.

### 6. Dokumentace a rollout

`CLAUDE.md` (MangaPrompts): odstavec „Živý portrét" (dva enginy a proč,
drivers syntetické v repu, `MOTIONS` z manifestu, VHS výstup `gifs`, bench
`live`, `docs/live-matrix.md`). `tgbot/README.md`, `restyler.env.example`
(`RENDER_VIDEO_COST`), `docs/live-portrait-setup.md`. Rollout: inventura →
graf + `check_workflow` → drivers → kolo 0–1 → katalog → Tsumiki sekce →
Restyler krok. E2E: selfie s brýlemi → `alive` za < 30 s, smyčka, pozadí
stojí; `hair-breeze` → ~20 min, vlasy se hýbou, tvář stojí; Tsumiki: mp4 do
chatu, −1 ⚡; neznámý preset 422; shozené ComfyUI → refund.

### 7. Rizika

1. **LivePortrait a brýle / profil**: cropper tvář nenajde nebo odlesky na
   sklech při mrknutí „plavou". Měří `clean` + `identity` na `w-glasses` a
   `w-bangs-3q`; záloha `cropper=mediapipe`, nebo preset u brýlí nenabídnout
   (`carries`-like příznak z gate, appka to ví z masky brýlí).
2. **Syntetický driver, co nemrká**: Wan nemusí mikropohyb vyrobit; drivers
   se měří stejnými metrikami a generují s jiným seedem. Záloha: nahrávka
   majitele mimo repo (dokumentovaná v `drivers/README.md`, gitignore).
3. **Tuhé vlasy**: u LivePortrait jedou vlasy s hlavou jako maska —
   u `look-around` to může vypadat jako vystřižená hlava. `stitching` a
   `driving_multiplier ≤ 1.0` to mírní; `look-around` může skončit jen pro
   malé úhly (6–10°). Oko na archu.
4. **Wan preset na vlasy je 20 min** a může změnit tvář (I2V nemá identitu).
   `identity` gate z vidbench, p10 ≥ 0.6; pokud padá, `hair-breeze` zůstane
   mimo katalog, dokud nebude rychlejší/věrnější model (Wan 2.2 TI2V-5B jako
   kandidát — jiný checkpoint ve video-stacku, jiný repo).
5. **mp4 v ComfyUI historii** (`gifs`, ne `images`) rozbije dnešní párování
   výstupů — proto `wait_for_output` s typem a test nad zachycenou historií.
6. **Pozadí bliká** (Wan) nebo **krk se trhá** (LivePortrait bez stitchingu)
   — metrika `still`.

### 8. Fáze 2

Live Photo export (iOS, HEIC+MOV pár), video náhledy presetů v katalogu,
Ol1nLLM akce na dlaždici, vlastní driver z kamery telefonu („udělej to po
mně": nahrát 3 s, poslat jako driver — pak už to je osobní data, jen
lokálně a jen pro ten render), rychlejší vítr ve vlasech (TI2V-5B),
řeč podle textu (TTS z Voice Studia + lip retargeting — jiný plán).
