# PLAN — Restyle: malířské styly + FLUX pro fotografické médium

> Pro Opuse. Repo `lioilsources/MangaPrompts` (Tsumiki), backend `tgbot/`,
> ComfyUI na SPARKu (`ol1n@spark`, `~/Code/ComfyUI`, LAN `http://192.168.88.66:8188`).
> Navazuje na `docs/restyle-rollout.md` + `docs/restyle-rollout-results.md`
> (naměřeno 2026-09-09). Sourozenecké plány: `04-PLAN-kadernik.md`
> (sdílí bench z §5) a `05-PLAN-ol1nllm-kadernik.md`.

## Zadání a jak je čtu

1. Do karty **Restyle a photo** přidat **malířské styly** (Van Gogh, Picasso,
   Monet, Mucha…). Ol1nLLM má 42 takových stylů **změřených** (třetí vlna,
   `Ol1nLLM/docs/style-matrix.md`, registr `Ol1nLLM/lib/models/style_preset.dart`,
   položky s `artist:`) — nevymýšlet nové, portovat ty.
2. Routování enginů podle média: **photo → FLUX**, **anime/illustration →
   Juggernaut XL**. Čtu to jako „per-medium engine", přepínač média zůstává
   dvoustavový (`Photo` / `Illustration`), jen se mění, co za ním běží.
3. **Držet identitu tváře i pózu** na obou enginech.

Dvě věci, které se zadáním kolidují a řeší je měření, ne rozhodnutí od stolu:

- **Illustration na Juggernautu**: `restyle-rollout-results.md` §2 naměřil,
  že Juggernaut v illustration režimu vrátí fotku (běhy 1–2) a teprve
  `sd_xl_base_1.0` dá styl (běh 3); na JODĚ dnes běží
  `RESTYLE_CKPT_ILLUSTRATION=sd_xl_base_1.0.safetensors`. Zadání říká
  Juggernaut. **Kód dostane Juggernaut jako default (zadání), env na JODĚ se
  nemění, dokud A/B v §1 neřekne jinak.** Pokud A/B potvrdí výsledky z 09-09,
  zůstane env na sd_xl_base a do reportu se to napíše.
- **Malířský styl + médium „photo"**: prompt „photorealistic photograph …
  painting by Van Gogh" je záměrný rozpor — stejný jako u ukiyo-e dnes
  (styl se čte jako kostým a kulisa, ne jako médium; komentář
  v `restyle_styles.dart`). Na FLUXu (T5 čte prózu doslovněji než CLIP) může
  styl médium přebít. Měří se v §1; když přebíjí, ladí se hlava promptu /
  `FluxGuidance`, ne katalog.

## Proč FLUX někdy nedrží pózu (odpověď na otázku)

V našich grafech FLUX **nemá žádné prostorové vedení pózy** — to, co pózu
drží u SDXL (depth ControlNet), u FLUXu nikde zapojené není:

1. **Tsumiki builder** (`assets/comfyui/flux_manga_img2img.api.json`):
   Kontext unet použitý jako obyčejný img2img — `VAEEncode` + `denoise 0.72`,
   bez `ReferenceLatent`, bez ControlNetu. Z předlohy přežije jen to, co
   zbyde v latentu po 72 % šumu; T5 váží prompt silně a FLUX při guidance
   3.5 poslouchá prompt víc než zbytek latentu. Prompt, který popisuje jiné
   rámování, gesto nebo víc postav, pózu přepíše.
2. **Ol1nLLM flux-manga** (`Ol1nLLM/assets/comfyui/flux_manga_img2img.api.json`):
   Kontext správně (`ReferenceLatent`, denoise 1.0), ale reference je
   **sémantické** podmínění (tokeny obrázku připojené k sekvenci), ne
   prostorové. Kontext drží rozvržení, když instrukce zní jako editace
   („change X, keep everything else"); stylový blok bez instrukce čte jako
   „udělej nový obrázek jako tenhle" — proto style-matrix §3: „jako jediný
   pustí styl, ale pózu si přeskládá". `FluxKontextImageScale` navíc přepočítá
   rozlišení (jiný poměr stran → další drift).
3. **Depth ControlNet pro FLUX existuje jen v Ol1nLLM labu** (repose na
   flux-manga: InstantX `flux-depth-controlnet-v3`, síla 0.55 = **odhad, ne
   měření**; telefon zůstal SDXL-only). InstantX táhne silněji než xinsir
   union, proto 0.55 a ne 0.75; `end_percent` 0.9 nechá dosednout textury.
4. I s hloubkou zůstane nejednoznačnost vpředu/vzadu (ruka před tělem vs.
   za ním) — hloubková mapa to nerozliší. Pokud to bude vadit, je na serveru
   i `flux1-dev-controlnet-union-pro-2` (Shakker, umí openpose); varianta
   do sweepu, ne do v1.

Závěr: **nový FLUX restyle graf musí mít depth ControlNet** (§2) a jeho sílu
je potřeba změřit, ne převzít.

## Co je na SPARKu (ověřeno 2026-09-13, `/object_info` 1778 tříd)

| potřeba | soubor / uzel | stav |
|---|---|---|
| FLUX base pro PuLID | `models/unet/flux1-dev.safetensors` (`UNETLoader`, fp8_e4m3fn) | ✅ |
| FLUX Kontext (alternativa) | `models/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors` | ✅ |
| identita FLUX | `ComfyUI_PuLID_Flux_ll`: `PulidFluxModelLoader` (`pulid_flux_v0.9.1`), `PulidFluxEvaClipLoader`, `PulidFluxInsightFaceLoader`, `ApplyPulidFlux` (weight, start_at, end_at, opt. attn_mask) | ✅ |
| póza FLUX | `models/controlnet/flux-depth-controlnet-v3.safetensors` (InstantX), `flux1-dev-controlnet-union-pro-2.safetensors` (Shakker) | ✅ |
| hloubka | `DepthAnythingV2Preprocessor` (`depth_anything_v2_vitl.pth`) | ✅ |
| T5/CLIP/VAE | `t5xxl_fp16`, `clip_l`, `ae.safetensors` | ✅ |
| face pass | `UltralyticsDetectorProvider` + `FaceDetailer` (Impact) | ✅ |
| SDXL cesta | beze změny (`sdxl_restyle.api.json` — 19 uzlů, preflight OK) | ✅ |

ComfyUI běží jako **user systemd** služba (`systemctl --user status
comfyui.service`, `Restart=always`, ExecStart `~/Code/ComfyUI/run.sh` s
`--reserve-vram 8 --cache-lru 2 --use-sage-attention`). Restart bez sudo:
`systemctl --user restart comfyui.service`. Paměť 121 GB unified (GB10).

---

## Architektura změny

```
app  RestyleMedium.photo|illustration ── prompt hlava (beze změny) ──▶ POST /api/restyle {medium, prompt, negative, style, image}
tgbot  RESTYLE_ENGINES[medium] → "flux" | "sdxl"          (env RESTYLE_ENGINE_PHOTO / _ILLUSTRATION)
       sdxl → sdxl_restyle.api.json + RESTYLE_CHECKPOINTS[medium]     (stávající)
       flux → flux_restyle.api.json                                   (nový §2)
              flux1-dev fp8 + PuLID (tvář) + InstantX depth CN (póza) [+ face pass = varianta B]
```

Placeholdery a `prepare_workflow` (`tgbot/comfy.py`) zůstávají: `__PROMPT__`,
`__IMAGE__`, latent override už umí `EmptySD3LatentImage` i `ImageResizeKJv2`.
Ve FLUX grafu není `__CKPT__` ani `__NEGATIVE__` (cfg 1 → negativ se
nepoužívá; appka ho dál posílá, backend ho u fluxu ignoruje — poznamenat
v README).

---

## Kroky

### 0. Bench runner (sdílený s Kadeřníkem) — udělat první

Specifikace je v `04-PLAN-kadernik.md` §5 (`tgbot/tools/bench/`). Pro tenhle
plán stačí `run.py` (matice × sweep × resume × VRAM guard), `score.py`
s identitou (ArcFace) a stylovou odezvou (histogram vs. baseline) a
`sheet.py`. Bez něj se §1 dá odjet ručně skriptem z `restyle-rollout.md`
krok 2, ale ztratí se resume a hlídání VRAM — a §1 má ~150 buněk.

### 1. Měření před kódem appky (na SPARKu, GPU, ~3 h)

Předlohy: `ab_repose_ref.png` (portrét), `tall_ref.png` (1:2), plus **jedna
nová: žena, 3/4 profil, delší vlasy** (dosavadní dvě jsou muž/portrét a
postava — rozptyl mezi předlohami byl v 09-09 hlavní zdroj šumu).
Styly: `ukiyoe`, `baroque` (kontroly z registru) + `vangogh-arles`,
`picasso-cubist`, `mucha-slav-epic`, `hopper` (malíři s různou „silou jména").
Seed 777 + jeden další.

| sweep | hodnoty | proč |
|---|---|---|
| A: FLUX unet | `flux1-dev` vs `flux1-dev-kontext_fp8_scaled` | PuLID i InstantX jsou trénované na dev; Kontext je to, co Ol1nLLM zapojil, ale nikdy neměřil |
| B: `__cn_apply__.strength` | 0.45 / 0.55 / 0.7 | InstantX táhne víc než xinsir; 0.55 je odhad |
| C: `__face_apply__.weight` (PuLID) | 0.7 / 0.9 / 1.1 | 0.9 = Ol1nLLM odhad pro celý snímek |
| D: face pass | bez / s (FaceDetailer na flux1-dev + PuLID 1.2, denoise 0.45) | u Fill zvedl identitu 0.48 → 0.72 (Ol1nLLM CLAUDE.md „Face inpaint — dva průchody"); tady je otázka, jestli je potřeba |
| E: illustration ckpt | `Juggernaut-XL_v9` vs `sd_xl_base_1.0` | zadání vs. měření 09-09; jen SDXL graf, jen illustration |
| F: `FluxGuidance` | 3.5 / 5.0 | jen když malíř v „photo" přebije médium |

Metriky (score.py): **identita** = ArcFace sim(výstup, předloha) — cíl ≥ 0.6
(SDXL cesta dnes odhadem kolem 0.6–0.7, změřit i ji jako baseline);
**styl** = kosinová vzdálenost histogramu od nestylované baseline téhož
enginu (laťka = nejslabší kontrola, stejně jako ve style-matrix); **póza** =
okem na archu (+ volitelně IoU depth map předlohy a výstupu přes
`DepthAnythingV2` — levné, stačí prahovat). Výstup: `docs/restyle-flux-results.md`
ve formátu `restyle-rollout-results.md` (tabulka běhů, čas, verdikt) + arch.

Rozhodnutí, která z toho vypadnou a zapíšou se do grafu jako defaulty:
unet, síla hloubky, váha PuLID, face pass ano/ne, illustration ckpt.

### 2. `assets/comfyui/flux_restyle.api.json` (nový)

Ručně psaný API graf ve stylu `sdxl_restyle.api.json` (číselná id, `_meta.title`):

| id | class | inputs |
|---|---|---|
| 1 | `UNETLoader` | `unet_name: flux1-dev.safetensors`, `weight_dtype: fp8_e4m3fn` (nebo Kontext podle §1-A) |
| 2 | `DualCLIPLoader` | `t5xxl_fp16.safetensors`, `clip_l.safetensors`, `type: flux` |
| 3 | `VAELoader` | `ae.safetensors` |
| 4 | `LoadImage` | `image: __IMAGE__` |
| 5 | `ImageResizeKJv2` | `image←4`, 832×1216, lanczos, `keep_proportion: pad`, `pad_color "0, 0, 0"`, center, `divisible_by: 16` |
| 6 | `DepthAnythingV2Preprocessor` | `image←5`, `depth_anything_v2_vitl.pth`, resolution 768 |
| 7 | `ControlNetLoader` | `flux-depth-controlnet-v3.safetensors` |
| 8 | `CLIPTextEncode` | `clip←2`, `text: __PROMPT__` |
| 9 | `FluxGuidance` | `conditioning←8`, `guidance: 3.5` |
| 10 | `CLIPTextEncode` | `clip←2`, `text: ""` (negativ, cfg 1) |
| 11 | `ControlNetApplyAdvanced` | `positive←9`, `negative←10`, `control_net←7`, `image←6`, **`vae←3`** (InstantX kóduje hint přes VAE), `strength 0.55`, `start 0.0`, `end 0.9` |
| 12 | `PulidFluxModelLoader` | `pulid_flux_v0.9.1.safetensors` |
| 13 | `PulidFluxEvaClipLoader` | — |
| 14 | `PulidFluxInsightFaceLoader` | `provider: CPU` |
| 15 | `ApplyPulidFlux` | `model←1`, `pulid_flux←12`, `eva_clip←13`, `face_analysis←14`, `image←5`, `weight 0.9`, `start_at 0.0`, `end_at 1.0` |
| 16 | `EmptySD3LatentImage` | 832×1216, `batch_size 1` |
| 17 | `KSampler` | `model←15`, `positive←11.0`, `negative←11.1`, `latent_image←16`, steps 28, cfg 1.0, euler, simple, denoise 1.0 |
| 18 | `VAEDecode` | `samples←17`, `vae←3` |
| 19 | `SaveImage` | `filename_prefix: tsumiki_restyle_flux` |

Varianta B (face pass, jen když §1-D řekne ano) — přesný vzor uzlů 100–109
v `Ol1nLLM/assets/comfyui/flux_fill_inpaint_face.api.json`: **druhý**
`UNETLoader` (flux1-dev) + **vlastní** trojice PuLID loaderů (sdílené
s prvním průchodem skončí offloadnuté na CPU a `ApplyPulidFlux` spadne na
cuda/cpu mismatch — naměřená past) + `ApplyPulidFlux` weight 1.2 +
`UltralyticsDetectorProvider bbox/face_yolov8m.pt` + `FaceDetailer`
(guide 1024, max 1024, steps 20, cfg 1.0, euler/simple, denoise 0.45,
`positive` = FluxGuidance promptu **bez** ControlNetu — detailer pracuje
s výřezem, celoobrazový hint na něj nesedí) → `SaveImage`.

Ověření bez GPU: `python3 tgbot/tools/check_workflow.py assets/comfyui/flux_restyle.api.json --url http://192.168.88.66:8188`
(očekávat `OK … (19 nodes)`; `vae` je u `ControlNetApplyAdvanced` volitelný
vstup — skript ho musí tolerovat, viz `test_check_workflow.py`).

Pozn. k paddingu: `pad` dělá černé pruhy (u 1:2 předlohy ~6 % šířky), které
si model vyloží po svém (v 09-09 z nich ukiyo-e udělalo okraje svitku). FLUX
je v tom horlivější než SDXL. Pokud to na archu vadí, druhá možnost je
`keep_proportion: crop` **jen pro FLUX** — ale pak hint ztratí okraj a je
nutné zkontrolovat, že 1:2 fotka nepřijde o chodidla (bucket 768×1344 by
měl stačit).

### 3. `tgbot/config.py`

```python
RESTYLE_WORKFLOW_FILES = {"sdxl": "sdxl_restyle.api.json", "flux": "flux_restyle.api.json"}
# Zadání: fotografické médium na FLUXu (PuLID + InstantX depth), kreslené na SDXL (InstantID).
RESTYLE_ENGINES = {
    "photo": os.environ.get("RESTYLE_ENGINE_PHOTO", "").strip() or "flux",
    "illustration": os.environ.get("RESTYLE_ENGINE_ILLUSTRATION", "").strip() or "sdxl",
}
assert set(RESTYLE_ENGINES.values()) <= set(RESTYLE_WORKFLOW_FILES), RESTYLE_ENGINES
```

`RESTYLE_WORKFLOW_FILE` (singular) zrušit; `RESTYLE_CHECKPOINTS` zůstává,
platí jen pro `sdxl`. Default checkpointu pro illustration = Juggernaut
(zadání), env na JODĚ ho přebíjí. Komentář u `RESTYLE_CHECKPOINTS` přepsat:
dnešní text tvrdí, že obě média jedou na Juggernautu — po 09-09 to není
pravda a po tomhle plánu už vůbec.

### 4. `tgbot/app.py` — `/api/restyle`

- `engine = config.RESTYLE_ENGINES.get(req.medium)` → 400 na neznámé médium
  (stávající kontrola přes `RESTYLE_CHECKPOINTS` se přesune sem).
- `template = _load_template_file(f"restyle_{engine}", config.RESTYLE_WORKFLOW_FILES[engine])`
  (cache klíč per engine, ne `"restyle"`).
- `checkpoint = config.RESTYLE_CHECKPOINTS[req.medium] if engine == "sdxl" else None`.
- `Job(workflow=f"restyle-{engine}", …)`, log řádek s enginem.
- Vše ostatní (spend, upload s per-job jménem, `latent_for`, `_watch_job`,
  refund) beze změny.
- `execution_error_message`: ověřit v §1 na krajině bez tváře, jaký text
  vyhodí `ApplyPulidFlux`/InsightFace u PuLID (u InstantID to je
  „Reference Image: No face detected."). Když je jiný a nečitelný, přidat
  mapování na „no face found in the photo".

`tgbot/comfy.py`: beze změny. Jen zkontrolovat, že `ImageResizeKJv2` s
`divisible_by 16` a buckety z `imagesize.py` (násobky 64) nedají konflikt —
nedají, ale test to má říct.

### 5. Testy backendu (`tgbot/tests/test_restyle_api.py`)

- `photo` → načte `flux_restyle.api.json`, `prepare_workflow` dostane
  `checkpoint=None`, `job.workflow == "restyle-flux"`.
- `illustration` → `sdxl_restyle.api.json` + checkpoint z
  `RESTYLE_CHECKPOINTS`, `job.workflow == "restyle-sdxl"`.
- `monkeypatch.setattr(config, "RESTYLE_ENGINES", {"photo": "sdxl", …})`
  → photo jede na SDXL s checkpointem (env override funguje).
- stávající testy (402, 429, refund při 502, auth, caption) beze změny.
- `test_comfy.py`: `prepare_workflow` na FLUX šabloně — `__IMAGE__` dosazen,
  `EmptySD3LatentImage` i `ImageResizeKJv2` dostaly latent, žádný `__CKPT__`
  nezůstal, seed nastaven ve všech uzlech se `seed`.
- `test_check_workflow.py`: volitelný vstup (`vae`) na uzlu, kde je zapojený,
  neprojde jako „unknown input".

### 6. Katalog v appce — `lib/config/restyle_styles.dart`

- Nová skupina `kRestyleGroupPainters = 'Painters'`, v `kRestyleGroups`
  hned za `Popular`.
- 42 položek portovaných z `Ol1nLLM/lib/models/style_preset.dart` (ty s
  `artist:`): **`id` shodné** (traceabilita k měření), `block` **doslova**
  (`booru` se neportuje — oba enginy Restyle čtou prózu), `label` anglicky
  a ASCII (test `restyle_styles_test` to vynucuje): např.
  `vangogh-arles` → „Van Gogh (Arles)", `picasso-cubist` → „Picasso (Cubist)",
  `lautrec-poster` → „Toulouse-Lautrec poster", `josef-capek` → „Josef Capek",
  `kubista` → „Kubista", `klimt-golden` → „Klimt (Golden)". Pořadí: podle
  autora, ne abecedně (Da Vinci, Botticelli, Vermeer, El Greco, Goya ×2,
  Van Gogh ×2, Monet, Cézanne, Seurat, Gauguin, Lautrec ×2, Mucha, Klimt,
  Schiele, Munch, Matisse ×2, Picasso ×3, Kandinsky, Chagall, Modigliani
  ne (zahozen), Dalí, Magritte, Lempicka, Hopper, Kahlo, Rivera, Bacon,
  Warhol, Lichtenstein, Haring, Basquiat, Hockney, Beardsley, Lada, Čapek,
  Kubišta).
- **Přepsat `artnouveau.block`** na Muchův text z Ol1nLLM (na Juggernautu
  0.458 → 0.934; id zůstává).
- Dart komentář u třídy: odkud čísla jsou (style-matrix třetí vlna,
  2026-09-10) a že „Popular" je pořád neměřené.
- `restyle_styles_test.dart`: přidat test „painter ids jsou podmnožinou
  známého seznamu z Ol1nLLM" (pevný seznam 42 id v testu — chrání překlepy
  při portu), a že žádný painter `block` neobsahuje slova média
  (`photograph`, `photo`, `anime`) — médium určuje hlava promptu.

### 7. UI — `lib/ui/screens/restyle_screen.dart`

90 chipů v pěti sekcích je na telefonu dlouhé. Minimální zásah: nad sekce
`TextField` „Filter styles" (`_query`), chip se zobrazí, když
`label.toLowerCase().contains(q)`; prázdná sekce se nevykreslí. Nic
dalšího (žádné collapsible sekce, žádné ikony). Popisek karty „Keeps your
face and pose…" beze změny.

### 8. Dokumentace

- `CLAUDE.md` odstavec „Model routing": Restyle má **dva enginy** — photo
  = `flux_restyle.api.json` (flux1-dev + PuLID + InstantX depth), illustration
  = `sdxl_restyle.api.json` (InstantID + xinsir union depth), routování
  `RESTYLE_ENGINES`, checkpoint jen u SDXL. Doplnit k `WORKFLOW_FILES` větu,
  že restyle grafy jsou web-only.
- `tgbot/README.md` + `mangabot.env.example`: `RESTYLE_ENGINE_PHOTO`,
  `RESTYLE_ENGINE_ILLUSTRATION`; věta, že negativ se na FLUXu nepoužije.
- `docs/restyle-flux-results.md` (výstup §1) + odkaz z
  `restyle-rollout-results.md` §6 „Co zbývá".
- `lib/config/restyle_styles.dart` hlavičkový komentář (viz §6).

### 9. Rollout (podle `docs/restyle-rollout.md`, zkráceně)

1. `check_workflow.py` na nový graf (zdarma).
2. §1 měření (GPU) → defaulty do grafu → commit.
3. JODA: `git pull` na `main` (nebo fetch větve s explicitním refspec — klon je
   single-branch), záloha `tgbot/data/mangabot.db`, `docker compose up -d --build`;
   `mangabot.env` beze změny, dokud §1-E nerozhodne o `RESTYLE_CKPT_ILLUSTRATION`.
4. Web: merge do `main` → CI. Rollback = revert merge.
5. E2E scénáře 1, 2, 3 (krajina → čitelná chyba + refund), 4 (1:2) z rollout
   plánu — tentokrát pro **obě** média, protože každé jede jinou cestou.

---

## Rizika / gotchas

1. **CPU fallback po sérii běhů** (`reports/couple_phase0.md` §11.17): po
   ~20 těžkých jobech ComfyUI hlásí `loaded partially; 0.00 MB usable` a
   počítá na CPU (job trvá hodiny, nespadne). Střídání FLUX/SDXL enginů to
   uspíší (`--cache-lru 2` drží obě rodiny). Bench má VRAM guard (§0);
   **produkce ho nemá** — doporučený follow-up: watchdog na SPARKu (cron
   každých 5 min: `GET /system_stats`, když `vram_free` < 16 GB a fronta
   prázdná → `systemctl --user restart comfyui.service`). Není součást
   tohohle plánu, ale bez něj bude FLUX restyle první, kdo to spustí.
2. **Čas jobu**: studený start FLUX (t5 9,8 GB + unet 12 GB fp8 + PuLID +
   EVA-CLIP) je delší než SDXL; `JOB_TIMEOUT` 300 s by měl stačit, face
   pass (§1-D) čas zhruba zdvojí. Změřit první a druhý běh, jako v 09-09.
   Klient: `_jobTimeout` v `telegram_backend_service.dart` (ověřit, že
   ≥ 5 min; jinak zvednout společně s `JOB_TIMEOUT`).
3. **PuLID bere největší tvář** (jako InstantID): skupinová fotka → cizí
   člověk. Text pod fotkou v appce už říká „one person".
4. **Negativ na FLUXu neexistuje**: vynucení média v `photo` sedí jen na
   hlavě promptu. Pokud malíři médium přebijí, ladit hlavu
   (`_photoMedium`) nebo `FluxGuidance`, ne blok stylu — bloky jsou měřené.
5. **`vae` hrana u `ControlNetApplyAdvanced`** je pro InstantX nutná
   (Ol1nLLM CLAUDE.md „flux-manga umí repose"); bez ní uzel projde
   validací, ale hint se špatně zakóduje.
6. **Ol1nLLM 42 stylů bylo měřeno v repose na SDXL/Kontext bez identity**
   (styl × model), ne s PuLID/InstantID v grafu. Identita styl tlumí
   (InstantID embedding je fotografický; PuLID méně, ale také). Proto §1
   měří i stylovou odezvu, ne jen identitu — a proto se v katalogu nic
   nepřeskakuje „protože to Ol1nLLM změřil".
7. `restyle_styles_test` ASCII regex `^[A-Za-z0-9 \-&()]+$` — žádné
   diakritiky ani pomlčky „—" v labelech.

## Verifikace

- `flutter analyze`, `flutter test` (restyle_styles, screen_nav,
  shared_app_bar, widget), `flutter build web --release`.
- `cd tgbot && python -m pytest` (restyle_api, comfy, check_workflow).
- `check_workflow.py` OK na všech 9 grafech v `assets/comfyui/`.
- §1 report existuje a jsou v něm obrázky; defaulty v grafu odpovídají
  reportu; `RESTYLE_ENGINES` v kontejneru na JODĚ =
  `{'photo': 'flux', 'illustration': 'sdxl'}`.
- E2E: photo + `vangogh-arles` → obrázek v appce i chatu, popisek
  `🖼 Van Gogh (Arles) · photo`, zůstatek −1; totéž illustration; krajina
  → chyba + zůstatek beze změny na obou médiích.
