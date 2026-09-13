# PLAN — Kadeřník: nová karta (portrét + účes → tvoje fotka v novém účesu)

> Pro Opuse. Repo `lioilsources/MangaPrompts` (Tsumiki web + `tgbot/`),
> ComfyUI na SPARKu. Navazuje na `03-PLAN-restyle-painters-flux.md`
> (stejné enginy, sdílený bench). Ol1nLLM část je v
> `05-PLAN-ol1nllm-kadernik.md`. Kandidátský katalog účesů:
> `Prompts/hairstyles-candidates.json` (tento adresář).

## Zadání a rozhodnutí

Uživatel nahraje portrét, vybere účes, dostane **svoji fotku v novém
účesu**. Do aplikace se pustí **jen účesy, kterým rozumí oba modely**
(FLUX i Juggernaut XL, tj. oba enginy z plánu 03). Ženské účesy jsou dané
(25), mužské „co frčí v roce 2026" jsou rozpracované níž a v JSONu.

Rozhodnutí, která plán dělá za uživatele (s důvodem — kdyby nesouhlasil,
mění se jen jedna věc):

| rozhodnutí | důvod |
|---|---|
| **Inpaint vlasové oblasti, ne restyle celého obrázku** | depth mapa v restyle grafu nese siluetu *starých* vlasů a s novým střihem by se prala; při inpaintu zůstávají pixely tváře **netknuté** → identita drží z principu, ne přes adaptér |
| **Maska se počítá automaticky na serveru** (face parsing → obálka podle třídy účesu) | uživatel v Mini Appce nemá kreslit; obálka musí sahat tam, kam nové vlasy *dorostou*, což maska ze starých vlasů neumí |
| **Výstup je fotka; karta nemá přepínač média** | „malované vlasy na fotografické tváři" je nesmysl; kreslená varianta = řetězení Kadeřník → Restyle (Fáze 2, §9) |
| **Barva vlasů se zachová automaticky** | „svoje fotka v novém účesu" bez vlastní barvy by byl cizí člověk; barva se odhadne z masky vlasů před generováním (§4.3). Výběr barvy = Fáze 2 |
| **Dva enginy měříme, jeden servíruje** | gate „oba modely rozumí" jede na FLUX Fill i SDXL inpaint; produkce jede na `HAIR_ENGINE` (default `flux`), SDXL je záloha a zároveň ten přísnější slovník |
| **Účtování jako obrázek** (`spend_generation`) | analytický průchod (maska, ~3 s) je zdarma a běží *před* stržením — bez tváře se nic neplatí |

## Co je na SPARKu (ověřeno 2026-09-13)

| potřeba | uzel / soubor | poznámka |
|---|---|---|
| maska vlasů/tváře | `FaceSegment` (ComfyUI-RMBG): booleany `Hair`, `Skin`, `Nose`, `Left-eye`…, `Mouth`, `Upper-lip`, `Lower-lip`, `Neck`, `Eyeglasses`; `process_res`, `mask_offset`, `mask_blur`; výstup IMAGE, MASK, IMAGE | face parsing (BiSeNet); model se stáhne při prvním běhu do `models/RMBG/` — ověřit offline stažení |
| čepice | `ClothesSegment` (`Hat`, `Hair`, `Face`…) | čepice se maskuje (nahradí ji vlasy) |
| záloha masky | `BatchCLIPSeg` (KJNodes, text „hair"), `SAM3Segment` (text) | jen kdyby FaceSegment selhal na profilu/nízkém rozlišení |
| FLUX inpaint | `flux1-fill-dev-fp8.safetensors` (`UNETLoader`), `InpaintModelConditioning`, `InpaintCropImproved`/`InpaintStitchImproved` | vzor `Ol1nLLM/assets/comfyui/flux_fill_inpaint.api.json` |
| SDXL inpaint | `INPAINT_LoadFooocusInpaint` (`fooocus_inpaint_head.pth`, `inpaint_v26.fooocus.patch`), `VAEEncodeForInpaint` | vzor `Ol1nLLM/assets/comfyui/sdxl_inpaint.api.json` |
| identita (jen měření / bangs varianta) | PuLID FLUX, `ip-adapter-faceid-plusv2_sdxl` | v1 vypnuto: tvář je mimo masku |
| skórování | `~/Code/ComfyUI/.venv/bin/python`: insightface (antelopev2), `open_clip`, cv2, numpy | **systémový python3 numpy nemá** — bench běží ve venv ComfyUI |
| VLM soudce | gateway `:8080` model `ocr` → „Connection error" | **není k dispozici**; soudce = CLIP zero-shot + oko (§5) |

---

## Architektura

```
app  HairScreen ── vybraný Hairstyle {id,label,block,shape} ──▶ POST /api/hair
      {image, prompt (s __HAIRCOLOR__), negative_prompt, style: label, shape: {length,bangs,updo}}
tgbot /api/hair
   1. dekóduj obrázek, ověř shape enumy                              (400)
   2. job A "analyse" (zdarma, sync, ≤ 60 s): hair_analyse.api.json
        → PNG masky: hair, face, hat                                  (502 při výpadku, nic se nestrhlo)
   3. hairmask.build(hair, face, hat, shape) → maska PNG + face box   (400 „no face" / „face too small")
      hairmask.estimate_colour(image, hair) → "dark brown" | None
   4. spend_generation                                               (402)
   5. upload image + mask, prepare_workflow(HAIR_WORKFLOW_FILES[HAIR_ENGINE], mask_name=…)
      job B "hair-<engine>" → _watch_job (refund při chybě), caption "💇 Wolf cut"
```

`prepare_workflow` dostane nový parametr `mask_name` → placeholder
`__MASK__` (stejná konvence jako Ol1nLLM; poznámku „keep in sync" v hlavičce
`comfy.py` doplnit o `__MASK__`).

---

## Kroky

### 1. Grafy (`assets/comfyui/`)

**`hair_analyse.api.json`** (bez difuze, ~2–4 s):

| id | class | inputs |
|---|---|---|
| 1 | `LoadImage` | `__IMAGE__` |
| 2 | `FaceSegment` | `images←1`, `Hair: true`, `process_res: 1024`, `mask_blur 0`, `mask_offset 0` |
| 3 | `MaskToImage` | `mask←2.1` |
| 4 | `SaveImage` | `images←3`, prefix `tsumiki_hair_mask` |
| 5 | `FaceSegment` | `images←1`, `Skin, Nose, Left-eye, Right-eye, Left-eyebrow, Right-eyebrow, Mouth, Upper-lip, Lower-lip: true`, `process_res 1024` |
| 6 | `MaskToImage` → 7 `SaveImage` | prefix `tsumiki_face_mask` |
| 8 | `ClothesSegment` | `images←1`, `Hat: true` |
| 9 | `MaskToImage` → 10 `SaveImage` | prefix `tsumiki_hat_mask` |

Backend potřebuje **tři výstupy jednoho promptu**: `comfy.py` dostane
`wait_for_images(session, prompt_id, timeout) -> dict[prefix, bytes]`
(historie má outputs per node; párovat podle `filename` prefixu).
Stávající `wait_for_image` zůstane tenký wrapper.

Alternativa, kdyby `FaceSegment` na SPARKu chyběl model nebo nešel stáhnout:
`BatchCLIPSeg(text="hair")` + `BatchCLIPSeg(text="face")` — hrubší okraje,
ale funkční; rozhodnout v §5 kroku 0.

**`flux_hair_inpaint.api.json`** — port `Ol1nLLM/assets/comfyui/flux_fill_inpaint.api.json`
(Opus si graf vypíše stejně jako ostatní: `python3 - <<EOF json.load …`):

`UNETLoader flux1-fill-dev-fp8 (fp8_e4m3fn)` → `DualCLIPLoader` → `VAELoader` →
`LoadImage __IMAGE__` + `LoadImage __MASK__` → `ImageToMask red` →
`InpaintCropImproved` (`output_target 1024×1024`, `context_from_mask_extend_factor 1.5`
— víc kontextu než 1.2: ramena a celá tvář musí být v okně, `mask_blend_pixels 32`,
`mask_expand_pixels 0`, `device_mode gpu`) → `CLIPTextEncode __PROMPT__` →
`FluxGuidance 30` → `InpaintModelConditioning (noise_mask true)` →
`KSampler steps 28, cfg 1.0, euler, simple, denoise 1.0` → `VAEDecode` →
`InpaintStitchImproved` → `SaveImage tsumiki_hair_flux`.
Bez PuLID (tvář mimo masku). Varianta pro sweep: PuLID 0.6 jen u tříd
s ofinou (maska zasahuje čelo).

**`sdxl_hair_inpaint.api.json`** — port `Ol1nLLM/assets/comfyui/sdxl_inpaint.api.json`
(bez IPAdapteru): `CheckpointLoaderSimple __CKPT__` → pos `__PROMPT__` /
neg `__NEGATIVE__` → `LoadImage __IMAGE__` + `__MASK__` → `ImageToMask` →
`InpaintCropImproved` (tytéž hodnoty) → `INPAINT_LoadFooocusInpaint` →
`VAEEncodeForInpaint grow_mask_by 16` → `INPAINT_ApplyFooocusInpaint` →
`KSampler 30, cfg 6.0, dpmpp_2m, karras, denoise 1.0` → `VAEDecode` →
`InpaintStitchImproved` → `SaveImage tsumiki_hair_sdxl`.
Checkpoint z `HAIR_CHECKPOINT` (default `Juggernaut-XL_v9_RunDiffusionPhoto_v2`).

Všechny tři přes `check_workflow.py`. `prepare_workflow` **nesmí** na tyhle
grafy aplikovat latent override — nemají `EmptyLatentImage`, takže se nic
nestane; test to má potvrdit.

### 2. `tgbot/hairmask.py` (nový, čistý numpy — testovatelný bez ComfyUI)

Závislosti: `numpy`, `pillow` do `requirements.txt` (PNG dekódování; image
~+40 MB, přijatelné). `imagesize.py` zůstává bez Pillow (hlavičky).

```python
@dataclass
class HairShape:  length: Literal["keep","short","medium","long"]; bangs: Literal["none","full","side","curtain","wispy"]; updo: bool
@dataclass
class HairAnalysis: hair: np.ndarray; face: np.ndarray; hat: np.ndarray   # bool HxW
def face_box(face) -> tuple[int,int,int,int] | None        # x0,y0,x1,y1 z masky tváře (percentily 1/99, ne min/max — odolné na šum)
def build_mask(a: HairAnalysis, shape: HairShape) -> tuple[np.ndarray, dict]   # bool maska + info (face_box, area…)
def estimate_colour(rgb: np.ndarray, hair: np.ndarray) -> str | None
def to_png(mask) -> bytes                                   # bílá = přemalovat (konvence __MASK__)
```

`build_mask` — jednotky: `fh` = výška, `fw` = šířka face boxu `(x0,y0,x1,y1)`:

1. `base = dilate(hair ∪ hat, r = 0.06·fh)` — staré vlasy vždy pryč i s okrajem.
2. `bangs != none` → přidat **čelní pás**: obdélník `x0..x1`, `y0 .. y0+0.33·fh`
   (po obočí), **minus** masky očí/obočí (jsou ve `face`, ale pás je nad nimi
   — kontrola v testu). U `bangs == none` se čelo nemaskuje, i když dnešní
   vlasy ofinu mají — tam se ofina odstraní přes `base` (staré vlasy jsou
   v `hair`).
3. **Obálka** podle `length` (zaoblený obdélník, roh `0.3·fw`):
   `keep` → žádná; `short` → `x0−0.6fw .. x1+0.6fw`, `y0−0.9fh .. y1`;
   `medium` → `±0.9fw`, `y0−0.9fh .. y1+0.9fh`; `long` → `±1.2fw`, `y0−0.9fh .. y1+2.2fh`;
   `updo` → navíc `y0−1.3fh` nahoru (drdol) a dolů jen po bradu, pokud
   `length == keep`.
4. `mask = (base ∪ pás ∪ obálka) − (face − pás)` — tvář zůstává, čelo jen u ofin.
5. Oříznout na obraz; `info["area"]`; **chyby**: `face_box is None` nebo
   `fh < 0.08·H` → `NoFace`/`FaceTooSmall`; `area < 0.02·H·W` → `MaskTooSmall`.
6. Bez featheru — měkčení dělá `InpaintCropImproved.mask_blend_pixels`.

Ta čísla jsou **startovní**, kalibrují se v §5 (to je ta „tuning" část).

`estimate_colour`: `hair` erodovat o 3 px (bez okrajů), průměr v CIELAB
(vlastní převod sRGB→Lab, 15 řádků), pak pravidla: chroma < 8 a L > 78 →
`white`; chroma < 10 a 40 < L ≤ 78 → `grey`; L < 22 → `black`; a* > 18 →
`copper red`; jinak podle L: < 35 `dark brown`, < 50 `brown`, < 62 `light brown`,
< 75 `blonde`, jinak `platinum blonde`. Prahy ověřit na 8 předlohách z §5.
Vrací `None`, když vlasů je < 0.5 % plochy (holá hlava) — prompt pak
dostane „natural hair colour".

Testy `tgbot/tests/test_hairmask.py`: syntetické masky (elipsa tváře
100×130 v 512×512, vlasy = půlkruh nad ní): `short` obálka nesahá pod bradu;
`long` sahá ≥ 2·fh pod bradu; tvář (oči, nos, ústa) v masce **nikdy**; čelní
pás jen u `bangs != none`; `hat` se maskuje; `NoFace` bez tváře;
`FaceTooSmall` u 20 px tváře; barva: syntetická „hnědá" → `brown`, šedá → `grey`,
prázdná → `None`; `to_png` → bílá = True.

### 3. `tgbot/config.py`, `tgbot/app.py`

```python
HAIR_ANALYSE_WORKFLOW_FILE = "hair_analyse.api.json"
HAIR_WORKFLOW_FILES = {"flux": "flux_hair_inpaint.api.json", "sdxl": "sdxl_hair_inpaint.api.json"}
HAIR_ENGINE = os.environ.get("HAIR_ENGINE", "").strip() or "flux"
HAIR_CHECKPOINT = os.environ.get("HAIR_CHECKPOINT", "").strip() or _RESTYLE_DEFAULT_CKPT
HAIR_ANALYSE_TIMEOUT = _int_env("HAIR_ANALYSE_TIMEOUT", 60)
MAX_HAIR_IMAGE_B64_CHARS = MAX_RESTYLE_IMAGE_B64_CHARS
```

`HairRequest(BaseModel)`: `prompt`, `negative_prompt`, `style` (label ≤ 80),
`shape: HairShapeIn {length, bangs, updo}` (pydantic `Literal` → 422 na
neznámou hodnotu), `image`.

`POST /api/hair` — kroky z architektury. Podrobnosti:

- `jobs.active_count(user_id, "image") >= 1` → 429 **před** analýzou
  (analýza je sice zdarma, ale GPU čas stojí).
- Analýza: `comfy.upload_image` (`tsumiki_hair_src_<uuid>.png`),
  `prepare_workflow(analyse_tpl, prompt="", image_name=…)`,
  `queue_prompt`, `wait_for_images(timeout=HAIR_ANALYSE_TIMEOUT)`; masky
  přes `hairmask.decode_mask(png)` (Pillow → bool, práh 128).
- `hairmask.build` chyby → 400 s textem, který uživatel umí opravit
  („No face found — use a clear front-facing portrait", „Face is too small —
  crop closer").
- `prompt = req.prompt.replace("__HAIRCOLOR__", colour or "natural")`;
  appka posílá šablonu s tokenem (viz §4), backend token **vyžaduje** (400
  bez něj — jinak by prošel prompt bez barvy).
- Pak `spend_generation` → upload masky (`tsumiki_hair_mask_<job>.png`),
  `prepare_workflow(tpl, prompt, negative, image_name=src, mask_name=mask,
  checkpoint=HAIR_CHECKPOINT if engine=="sdxl" else None)` → `queue_prompt`
  → `Job(workflow=f"hair-{engine}", caption=f"💇 {label}")` → `_watch_job`.
  Výjimky mezi spend a queue → `undo_usage` + 502 (stejně jako restyle).
- `/start` text: doplnit „…or try a new haircut 💇".

Testy `tgbot/tests/test_hair_api.py` (vzor `test_restyle_api.py`, fake
`ComfyClient` s `wait_for_images` vracejícím syntetické masky):
analýza bez tváře → 400 a **žádný** `spend`; výpadek při analýze → 502 bez
spendu; happy path → spend, `__MASK__` dosazen, `__HAIRCOLOR__` nahrazen,
caption `💇 Wolf cut`, `job.workflow == "hair-flux"`; `HAIR_ENGINE=sdxl` →
checkpoint dosazen; 429 při běžícím jobu; 402; chybějící `__HAIRCOLOR__` → 400;
neznámý `length` → 422.

### 4. Appka

**`lib/config/hairstyles.dart`** (plain Dart, vzor `restyle_styles.dart`):

```dart
enum HairLength { keep, short, medium, long }   enum HairBangs { none, full, side, curtain, wispy }
class HairShape { final HairLength length; final HairBangs bangs; final bool updo; Map<String,Object> toJson() }
class Hairstyle { id, label, group ('Women' | 'Men'), section, block, shape }
const kHairGroups = ['Women', 'Men'];  const kHairSections = ['Cuts', 'Bangs', 'Texture', 'Updos', 'Short', 'Medium', 'Long'];
String hairPrompt(Hairstyle s) => 'a photo of the same person with a ${s.block}, __HAIRCOLOR__ hair, natural hair texture, realistic strands, same lighting and background, photorealistic';
String hairNegative() => 'hat, cap, helmet, headband, deformed hair, floating hair, extra face, second person, blurry, watermark, low quality';
```

Obsah = **jen položky, které prošly gatem v §5**; do té doby je katalog
prázdný a karta se v menu neukáže (`TsumikiScreen` menu skryje `hair`,
když `kHairstyles.isEmpty` — stejný „hide-on-failure" princip jako u
animace). Kandidáti žijí v `Prompts/hairstyles-candidates.json`, ne v kódu.

**`lib/ui/widgets/tsumiki_app_bar.dart`**: `TsumikiScreen.hair('Hairdresser',
Icons.content_cut)` mezi `restyle` a `animate`; `build()` → `HairScreen()`;
`video` getter zůstává jen pro `animate`; `_ScreenMenu` skrývá `hair`, když
je katalog prázdný. `screen_nav_test`: „hair is a pushed card, not root";
`shared_app_bar_test`: chip ⚡ u hair karty (kredity obrázků).

**`lib/ui/screens/hair_screen.dart`**: klon `restyle_screen.dart` —
fotka (`ImagePicker`, `maxWidth 1536`, kvalita 88), popisek „Keeps your face
and hair colour. Best with a front-facing portrait, hair fully visible, no
hat.", `SegmentedButton` Women/Men, sekce s `ChoiceChip`, FAB „New haircut",
progress text „Cutting… about a minute. The photo also arrives in your
chat.", `ResultScreen(prompt: '💇 ${style.label}')`, 402 → `PaywallSheet`.

**`lib/services/telegram_backend_service.dart`**: `hairImage({imageBytes,
prompt, negativePrompt, styleLabel, shape})` → `POST /api/hair` → `_awaitImageJob`.

Testy: `test/hairstyles_test.dart` (id unikátní, label ASCII, block bez slov
média, každý styl má sekci ze seznamu skupiny, `hairPrompt` obsahuje
`__HAIRCOLOR__` a končí blokem… ne — začíná „a photo of the same person",
blok uprostřed; `toJson` vrací jména enumů), widget test karty (bez fotky
FAB disabled).

### 5. Tuning feedback loop — `tgbot/tools/bench/` (nový, sdílený s plánem 03)

Princip stejný jako Ol1nLLM lab a `facebench`: **měří se to, co appka
opravdu posílá** — buňka vzniká přes `tgbot.comfy.prepare_workflow` +
`tgbot.hairmask`, ne přes ruční graf. Běží **na SPARKu** vedle ComfyUI
(`sync.sh` = rsync `tgbot/` do `~/Code/tsumiki-bench`; python
`~/Code/ComfyUI/.venv/bin/python`), obrázky nechodí přes LAN.

```
bench/run.py    --task hair|restyle --engines flux,sdxl --styles all|id,id --srcs a.png,b.png
                --seeds 2 --sweep '__cn_apply__.strength=0.45|0.55' --out out/<ts>
                • buňka = (task, engine, style, src, seed, sweep) → hash → resume (existující PNG se přeskočí)
                • hair: nejdřív analýza src (cache out/masks/<src>/{hair,face,hat}.png), pak hairmask.build per shape
                • VRAM guard před každou buňkou: GET /system_stats → vram_free < 20 GB ⇒
                  `systemctl --user restart comfyui.service`, čekat na /system_stats (past §11.17 couple reportu)
                • manifest.json: buňka → engine, style, block, shape, prompt, seed, čas
bench/score.py  out/<ts> → metrics.json + hair-matrix.md
bench/sheet.py  out/<ts> → sheet.html (styl × engine × src, badge metrik) — publikovat jako artefakt, jako u style-matrix
bench/verdicts.json   id → {accept|reject|retune, note}   (ručně, po archu)
```

**Metriky per buňka** (`score.py`; pomocné masky výstupu = tentýž
`hair_analyse` graf na výstupu, cache):

| metrika | jak | práh (v1, kalibrovat) |
|---|---|---|
| `identity` | ArcFace sim(výstup, src), `insightface antelopev2` — kód z `~/Code/facebench/bench.py` (`embedding`, `sim`; importovat, ne kopírovat) | ≥ 0.60 na všech seedech; čekáme ≥ 0.8 (tvář je mimo masku) — **nižší = maska protekla do tváře, chyba masky, ne stylu** |
| `length_ok` | nejnižší bod masky vlasů výstupu pod bradou v jednotkách `fh`: short ≤ 0.3, medium 0.3–1.1, long ≥ 1.1, keep = ±0.3 od src | ≥ 2/3 buněk |
| `bangs_ok` | podíl čelního pásu (§2 krok 2) pokrytý vlasy: bangs → ≥ 0.5; none → ≤ 0.2 | ≥ 2/3 buněk |
| `changed` | 1 − IoU(vlasy výstup, vlasy src) | ≥ 0.25 u střihů; u textur/ofin se nehodnotí |
| `recognised` | CLIP zero-shot (`open_clip` ViT-L-14 openai, nebo ViT-H-14 laion2b když se stáhne) na výřezu hlavy 1.8×face box; prompty „a photo of a person with a {label} hairstyle" pro **všechny** labely téže skupiny; pass = cílový label v top-3 **a** `p_target(out) ≥ p_target(src) + 0.10` (posun k cíli proti baseline = tomu, co appka dostala) | ≥ 2/3 buněk **na každém enginu** |
| `clean` | detektor najde přesně 1 tvář; rozměr výstupu == src (stitch OK) | 100 % |

**Gate do katalogu**: účes se přidá, jen když **na obou enginech** projde
`identity`, `length_ok`/`bangs_ok`, `recognised`, `clean` — a arch schválí
oko (style-matrix precedent: metrika propouštěla i zjevně špatné buňky,
„rozhodoval pohled"). Verdikt `retune` = přepsat `block` (jméno + popis;
lekce z umělců: jméno samo na CLIPu nestačí, popis nese styl) nebo `shape`
a pustit **jen ten** id znovu (resume).

**Kola** (aby GPU čas nebyl 20 h najednou):

| kolo | rozsah | buňky | čas (~40 s/buňka) |
|---|---|---|---|
| 0 | 1 předloha × 3 účesy × 2 enginy × 1 seed — ověření grafů, masky, `FaceSegment` modelu, `wait_for_images` | 6 | 5 min |
| 1 | 51 kandidátů × 2 enginy × 2 předlohy (žena dlouhé vlasy, muž krátké) × 2 seedy | ~400 | ~4,5 h (přes noc) |
| 2 | jen přeživší + `retune` × 2 enginy × 6 předloh × 2 seedy | ~300 | ~3,5 h |
| 3 | sweep masky (`0.06fh` dilatace, obálky ±20 %, `context_from_mask_extend_factor` 1.2/1.5/1.8, `mask_blend_pixels` 16/32) na 4 účesech, kde `length_ok` nebo `clean` padaly | ~100 | 1 h |

Předlohy pro kolo 2 (8 ks, generovat Juggernaut Lightning txt2img, ať
nejsou osobní data v repu): žena dlouhé rovné / žena krátké kudrnaté / žena
3/4 profil s ofinou / muž krátké / muž dlouhé / muž plešatějící / brýle /
tmavá pleť + afro. Uložit do `tgbot/tools/bench/srcs/` (git LFS ne —
8 × ~1 MB je OK).

Výstup: `docs/hair-matrix.md` (tabulka účes × engine × metriky + verdikt,
odkaz na arch) a **teprve pak** naplnění `kHairstyles` (§4). Formát: jako
`Ol1nLLM/docs/style-matrix.md`.

### 6. Katalog kandidátů

`Prompts/hairstyles-candidates.json` — 25 ženských (zadání) + 26 mužských.
Pole: `id, label, cs, group, section, block, shape{length,bangs,updo}`.
Mužský výběr je z trendů 2024–2026 (textured crop, low taper, modern mullet,
curtain/middle part, blowout, wolf/shag, buzz + skin fade, two-block, flow,
man bun) plus klasika, která nemizí (side part, pompadour, slick back, crew,
Ivy League, undercut, afro, locs, curly fade). Bloky jsou **jméno + popis**
(délka, kde končí, textura, čelo, strany), aby CLIP zvládl i termíny,
které v LAION nejsou (bixie 2022, butterfly 2022, wolf cut 2021).

Ženské (Cuts / Bangs / Texture / Updos):

| id | label | cs | shape |
|---|---|---|---|
| long-layered | Long Layered Haircut | dlouhé vlasy s vrstvami | long |
| curtain-bangs | Curtain Bangs | záclonová ofina | keep, curtain |
| lob | Long Bob (Lob) | dlouhé mikádo | medium |
| bob | Bob Cut | klasické mikádo | medium |
| french-bob | French Bob | krátké francouzské mikádo | medium, full |
| italian-bob | Italian Bob | plnější elegantní mikádo | medium |
| butterfly-cut | Butterfly Cut | výrazně vrstvený dlouhý střih | long |
| wolf-cut | Wolf Cut | shag + mullet | medium |
| shag | Shag Cut | rozcuchaný vrstvený střih | medium |
| pixie | Pixie Cut | velmi krátký dámský střih | short |
| bixie | Bixie Cut | bob + pixie | short |
| blunt-cut | Blunt Cut | rovný střih bez vrstev | medium |
| wispy-bangs | Wispy Bangs | jemná řídká ofina | keep, wispy |
| blunt-bangs | Blunt Bangs | rovná hustá ofina | keep, full |
| side-bangs | Side-Swept Bangs | ofina do strany | keep, side |
| face-framing | Face-Framing Layers | vrstvy rámující obličej | keep |
| beach-waves | Beach Waves | plážové vlny | keep |
| soft-curls | Soft Curls | jemné kudrliny | keep |
| messy-waves | Messy Waves | ležérní rozcuchané vlny | keep |
| sleek-straight | Sleek Straight Hair | hladké rovné vlasy | keep |
| high-ponytail | High Ponytail | vysoký culík | keep, updo |
| low-ponytail | Low Ponytail | nízký culík | keep, updo |
| messy-bun | Messy Bun | rozcuchaný drdol | keep, updo |
| top-knot | Top Knot | drdol vysoko na hlavě | keep, updo |
| half-up | Half-Up Half-Down | část nahoře, část rozpuštěná | keep, updo |

Mužské (Short / Medium / Long / Updos): textured-crop, low-taper, skin-fade,
buzz, crew, ivy-league, caesar, textured-fringe, side-part, curly-fade,
faux-hawk (Short); modern-mullet, wolf-cut, shag, curtains, blowout, quiff,
pompadour, slick-back, undercut, two-block, afro (Medium); flow, locs (Long);
man-bun, top-knot (Updos). Přesné bloky a `shape` jsou v JSONu (prefix `m-`).

### 7. Dokumentace a rollout

- `CLAUDE.md`: odstavec „Čtvrtá karta **Hairdresser**" (analýza → maska →
  inpaint, `HAIR_ENGINE`, účtování, `hairmask.py`, gate přes bench,
  `docs/hair-matrix.md`).
- `tgbot/README.md`, `mangabot.env.example`: `HAIR_ENGINE`, `HAIR_CHECKPOINT`,
  `HAIR_ANALYSE_TIMEOUT`.
- `docs/telegram-release.md`: BotFather `/setdescription` zmínit účes.
- Rollout jako u restyle: `check_workflow.py` × 3 → kolo 0 → kola 1–3 →
  katalog → JODA (`docker compose up -d --build`, záloha DB) → merge → E2E:
  portrét → fotka v appce i chatu s `💇 <label>`, −1; krajina → 400 bez
  stržení; čepice → vlasy místo čepice; 1:2 celá postava → „face too small"
  nebo funkční (rozhodne `0.08·H`); 429; 402; shozené ComfyUI během analýzy
  → 502 bez stržení.

### 8. Rizika

1. **Obálka u `long` přemaluje ramena a kus pozadí** — model může změnit
   oblečení. Prompt říká „same lighting and background"; kdyby to nestačilo,
   obálku zúžit (`±1.0fw`) nebo omezit na `y1+1.8fh`. Měří `clean` + oko.
2. **`FaceSegment` na profilu / s brýlemi** — parsing je trénovaný na
   frontálních tvářích. Předloha „3/4 profil" v kole 2 to odhalí; záloha
   `BatchCLIPSeg`.
3. **Barva**: odhad z průměru je hrubý (melír, protisvětlo). Pro v1 stačí
   8 tříd; když bench ukáže systematickou chybu (blond → light brown),
   posunout prahy, ne přidávat třídy.
4. **Účesy `keep` (textury, ofiny)** — maska = jen staré vlasy + čelo; když
   model délku „zkrátí", `length_ok` to chytí. Obálka `keep` se **nerozšiřuje**
   — jinak by textura měnila délku.
5. **VRAM/CPU fallback** — jako v plánu 03; bench má guard, produkce ne.
6. **Dvě kopie logiky masky** (Python tady, Dart v Ol1nLLM, plán 05) —
   stejné fixtury v testech obou repozitářů; poznámka „keep in sync" v obou
   `CLAUDE.md`.
7. **Prázdný katalog do konce gate** — karta je v kódu, ale skrytá; PR se
   dá mergnout dřív, než měření skončí (backend i UI jsou testovatelné
   s fake maskami).

### 9. Fáze 2 (mimo tento plán, jen aby se na to nezapomnělo)

- Výběr barvy (chipy: natural / black / brown / blonde / copper / grey /
  pastel) — backend už umí dosadit `__HAIRCOLOR__`.
- Kreslené médium = řetězení: Kadeřník → výsledek jako vstup Restyle
  (illustration) — dva joby, dva kredity.
- Účesy do builderu: přeživší bloky jako `hair.yaml` kostičky (tam už jsou
  tagy pro pony/wai; gate „oba modely" pak dostane i booru dialekt).
