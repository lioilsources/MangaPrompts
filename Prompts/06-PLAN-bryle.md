# PLAN — Brýle: nová karta (selfie + typ brýlí → sada 10+ fotek s těmi brýlemi)

> Pro Opuse. Repo `lioilsources/MangaPrompts` (Tsumiki web + `tgbot/`),
> ComfyUI na SPARKu. Navazuje na `04-PLAN-kadernik.md` (stejná kostra:
> analýza zdarma → maska → FLUX Kontext edit → kompozit přes masku → gate
> benchem → generovaný katalog). Co je v Kadeřníkovi hotové, se **nepíše
> znovu, parametrizuje se**. Ol1nLLM zrcadlo je mimo tento plán (§10).

## Zadání a rozhodnutí

Uživatel se vyfotí (nebo nahraje portrét), vybere typ brýlí a dostane
**sadu 10+ fotek sebe s tím typem brýlí** — ne jeden obrázek jako
u Kadeřníka. Engine je **FLUX Kontext** (`flux1-dev-kontext_fp8_scaled`,
graf `flux_hair_kontext.api.json` jako vzor).

Rozhodnutí, která plán dělá za uživatele (s důvodem — kdyby nesouhlasil,
mění se jen jedna věc):

| rozhodnutí | důvod |
|---|---|
| **Kontext edit + kompozit přes masku pásu očí, ne inpaint a ne celý restyle** | Kadeřník to změřil: Fill účes skoro nemění, Kontext ano a drží oblečení i světlo; kompozit vrací všechno mimo masku pixel-přesně. Brýle jsou lokální objekt, pás kolem očí je přirozená maska |
| **Jeden engine (`kontext`), žádný SDXL** | zadání říká flux-kontext; gate je per engine, takže SDXL jde přidat později bez změny katalogu. Ušetří polovinu GPU času benche |
| **Sada = N samostatných ComfyUI promptů z jednoho jobu, ne `batch_size`** | (a) výsledky chodí do appky **průběžně** — první fotka za ~1 min, ne celá sada za 10; (b) pád jedné buňky nezabije sadu; (c) `ImageCompositeMasked` a `TsumikiAlignToReference` by chtěly batch-aware vstupy, které nikdo neměřil. Model zůstává v paměti, cena na obrázek je stejná |
| **Varianty nejsou jen seedy** | Kontext je v editech skoro deterministický — 10 seedů téže instrukce dá 10 skoro stejných fotek (riziko §8.1). Typ brýlí nese **seznam provedení** (`finishes`: černý acetát, želvovina, zlatý drát…), sada = provedení × seedy. Bench má metriku `distinct` |
| **Maska smí do tváře** (oči, kořen nosu, tváře pod obrubou) | bez toho se brýle nedají nasadit. Identita tedy **nedrží z principu** jako u vlasů, drží ji Kontext — proto je `identity` tvrdý gate (§5) a pás je co nejnižší |
| **Stávající brýle se nahradí**, styl `no-glasses` je sundá | face parsing třídu `Eyeglasses` už vrací (`hair_analyse` ji má v masce `features`); staré obruby jdou do masky stejně jako čepice u Kadeřníka. „Bez brýlí" je stejný kód s prázdnou instrukcí nasazení |
| **Účtování: sada = jeden `spend_generation`**, počet variant je serverová konstanta `GLASSES_VARIANTS` (default 10) | ledger ani paywall se nemění; GPU čas 10× je cena za feature, ne za uživatele. Kdyby to bylo moc, mění se jedno číslo nebo přibude package — ne protokol. **Ověřit s majitelem před mergem.** |
| **Do chatu album, do appky mřížka** | Telegram `sendMediaGroup` bere max 10 položek — chat dostane prvních 10 (nebo dvě alba, když `GLASSES_VARIANTS > 10`), appka ukáže všechny |

## Co je hotové a znovu se použije (ověřeno v kódu 2026-10-31)

| potřeba | kde | poznámka |
|---|---|---|
| analýza tváře zdarma | `hair_analyse.api.json`, `comfy.wait_for_images`, `hairmask.ANALYSE_OUTPUTS` | maska `features` = oči + obočí + `Eyeglasses` (`FaceSegment`, uzel 11). Pro brýle přibude pátý výstup: samostatná maska `Eyeglasses` (§1) |
| face box, dilatace, zaoblený obdélník, `WORK_SIDE`, refusals | `tgbot/hairmask.py` (`face_box`, `dilate`, `rounded_rect`, `HairMaskError`) | **importovat**, ne kopírovat — nový modul `glassesmask.py` nad těmi primitivy |
| Kontext graf + kompozit + zarovnání | `flux_hair_kontext.api.json`, `TsumikiAlignToReference` (`comfyui_nodes/ComfyUI-Tsumiki`), `hairmask.apply_feather` | graf se **kopíruje** do `flux_glasses_kontext.api.json` (jiný prefix výstupu, jiná guidance po sweepu); feather je funkce masky, ne účesu — přesunout do sdíleného místa nebo volat z `hairmask` |
| `prepare_workflow` | `tgbot/comfy.py` | umí `__IMAGE__`, `__MASK__`, seed. Pro N variant se volá N× s jiným seedem (seed losuje sama) |
| job + watcher + účtování + refund | `tgbot/jobs.py`, `app._watch_job`, `db.spend_generation/undo_usage` | watcher se zobecní na víc `prompt_id` (§3) |
| bench | `tgbot/tools/bench/run.py` (`hair` task), `score.py`, `sheet.py`, `verdicts.py`, `duplicates.py`, `export_catalog.py` | přidá se task `glasses`; `duplicates.py` je přesně metrika `distinct` |
| předlohy | `tgbot/tools/bench/srcs/` — `w-glasses.png` (nahrazení brýlí), `w-bangs-3q` (¾ profil), `w-afro`, `m-receding`, `w-long`, `m-short`… | syntetické, žádná osobní data |
| UI karty | `hair_screen.dart`, `TsumikiScreen`, `screenOffered`, `_StyleCard` s náhledem, `PaywallSheet` | klon s mřížkou výsledků místo `ResultScreen` |
| ComfyUI-RMBG `FaceSegment` třídy | `Eyeglasses`, `Left-eye`, `Right-eye`, `Left-eyebrow`, `Right-eyebrow`, `Nose`, `Skin` | **ověřit přes `/object_info`**, zda je i `Left-ear`/`Right-ear` (CelebAMask-HQ je má) — ucho = kam sahají nožičky |

---

## Architektura

```
app  GlassesScreen ── fotka (kamera/galerie, ≤1536 px) + Glasses{id,label,block,finishes,fit} ──▶ POST /api/glasses
      {image, style_id, block, style: label, fit: {size, tinted}}
tgbot /api/glasses
   1. dekóduj obrázek, ověř fit enumy; 429 když běží jiný image job             (400/429)
   2. analýza zdarma (hair_analyse.api.json + výstup tsumiki_glasses_mask)       (502, nic se nestrhlo)
   3. glassesmask.prepare(image, masks, fit) → maska PNG                        (400 „no face" / „face too small" / „eyes not visible")
   4. spend_generation                                                          (402)
   5. upload image + mask; pro i in range(GLASSES_VARIANTS):
        prompt_i = glassesprompt.prompt(block, finish=finishes[i % len], style_id)
        wf_i = prepare_workflow(flux_glasses_kontext, prompt_i, image_name, mask_name) + apply_feather
      → Job(kind="image", prompt_ids=[…], images_total=N)  → _watch_set_job
      rolling window: GLASSES_CONCURRENCY (2) promptů ve frontě naráz, další se zařadí, až jeden doběhne
   6. GET /api/jobs/{id} → {status: running|done|error, images_done, images_total}
      GET /api/jobs/{id}/image/{i} → PNG i-té hotové varianty   (/image bez indexu = první, kompatibilita)
   7. po doběhnutí: sendMediaGroup (≤10) do chatu s caption „👓 Round tortoiseshell"
```

Proč rolling window a ne všech N najednou: box je sdílený s Ol1nLLM, 10
promptů jednoho uživatele by na ~8 minut zablokovalo frontu všem. Dva
v letu drží GPU vytížené (druhý čeká, než první dekóduje) a ostatní se
mezi ně dostanou.

---

## Kroky

### 1. Grafy (`assets/comfyui/`)

**`hair_analyse.api.json`** — přidat pátý výstup, aby šlo rozlišit „má
brýle" od „oči + obočí":

| id | class | inputs |
|---|---|---|
| 16 | `FaceSegment` | `images←1`, `Eyeglasses: true`, `process_res 512` |
| 17 | `MaskToImage` → 18 `SaveImage` | prefix `tsumiki_glasses_mask` |

`hairmask.ANALYSE_OUTPUTS` dostane `"tsumiki_glasses_mask": "glasses"` a
`HairAnalysis.glasses` s defaultem nul (jako `features`) — Kadeřník se tím
nemění, jen stáhne jeden soubor navíc (~kB). Ol1nLLM má kopii grafu;
poznámka do §10. Pokud `/object_info` ukáže třídy `Left-ear`/`Right-ear`,
přidat i masku uší (`tsumiki_ears_mask`) — nožičky brýlí končí na uchu a
pás masky má sahat právě tam, ne na odhad `0.08·fw`.

**`flux_glasses_kontext.api.json`** — kopie `flux_hair_kontext.api.json`
s těmito rozdíly: `SaveImage.filename_prefix` → `tsumiki_glasses_kontext`;
`_meta.title` uzlu 15 → „Glasses mask (white = new glasses)"; `FluxGuidance`
zůstává 2.5 jako startovní hodnota (sweep `10.guidance=2.5|3.0|3.5` v kole 3 —
brýle jsou malý objekt, vyšší guidance drží instrukci líp, ale začne měnit
tvář). `KSampler.steps` 28; sweep `12.steps=20|28` — při 20 krocích je sada
o 30 % rychlejší a u lokálního editu to může stačit.

Přes `tgbot/tools/check_workflow.py` proti SPARKu oba grafy; `deploy.sh`
pro `TsumikiAlignToReference` se nemusí pouštět (uzel už na boxu je), ale
`check_workflow` to potvrdí.

### 2. `tgbot/glassesmask.py` (nový, čistý numpy, nad primitivy `hairmask`)

```python
from hairmask import HairAnalysis, HairMaskError, face_box, dilate, rounded_rect, to_png, decode_mask, WORK_SIDE, MIN_FACE_H

SIZES = ("small", "regular", "oversized")

@dataclass(frozen=True)
class GlassesFit:
    size: str = "regular"      # jak hluboko pod oči sahá obruba
    tinted: bool = False       # sluneční: maska stejná, jen metrika identity se nehodnotí (§5)

def eye_box(features, glasses, face_box) -> (x0,y0,x1,y1) | None   # oči+obočí (+staré brýle), percentily 1/99
def build_mask(analysis, fit, mode=None) -> MaskResult
def prepare(image, masks, fit) -> bytes                              # maska PNG; bez barvy — brýle nic nečtou z fotky
```

`build_mask` — jednotky `fw`/`fh` = face box, `ew`/`eh` = eye box
(oči + obočí; bez obočí by pás u vysokých obrub končil pod ním):

1. `base = dilate(glasses, 0.04·fh)` — staré brýle vždy pryč i s okrajem
   (jako čepice u vlasů). Prázdné u člověka bez brýlí.
2. **Pás**: zaoblený obdélník `x0−SIDE·fw .. x1+SIDE·fw` (SIDE = 0.10;
   s maskou uší: do vnějšího okraje uší), svisle `ey0 − ABOVE·fh .. ey1 + BELOW[size]·fh`
   (ABOVE = 0.06 — horní linka obruby je nad obočím jen u browline;
   BELOW: small 0.12, regular 0.20, oversized 0.32 — spodní obruba oversized
   sedí na lícních kostech). Roh `0.15·fw`.
3. `mask = base ∪ pás`; **tvář se nechrání** — jen `mask &= ~mouth` (ústa
   z `face` nejsou zvlášť; když to bude třeba, přidat šestý výstup). Vlasy se
   v pásu nechávají: nožičky jdou přes spánky do vlasů a Kontext tam musí
   smět kreslit.
4. Refusals: `face_box None` → `NO_FACE`; `fh < MIN_FACE_H·H` → `FACE_TOO_SMALL`;
   `eye_box None` nebo `eh < 0.08·fh` (oči zavřené/za vlasy/profil) →
   `EYES_NOT_VISIBLE` („Eyes must be visible — face the camera, no hand or
   hair over the eyes."); `area > 0.35` → `MASK_TOO_LARGE` (face box je
   skoro celý obrázek = extrémní close-up, kompozit by nic nechránil).
5. Styl `no-glasses`: `mask = base` samotný (bez pásu); prázdný `base` →
   400 `NO_GLASSES_TO_REMOVE` („No glasses found in this photo.").

Konstanty jsou **startovní**, kolo 3 je kalibruje. `MASK_MODE` tu není —
pás je blob z definice.

Testy `tgbot/tests/test_glassesmask.py` nad `test_hairmask.synthetic()`
rozšířeným o masky očí/obočí/brýlí (fixture **sdílet** s Ol1nLLM, až přijde
zrcadlo): pás pokrývá obě oči a obočí; `oversized` sahá níž než `regular`;
staré brýle jsou v masce celé i s okrajem; bez tváře `NO_FACE`; oči
zakryté (features prázdné) → `EYES_NOT_VISIBLE`; `no-glasses` na předloze
bez brýlí → `NO_GLASSES_TO_REMOVE`; ústa nikdy v masce; `to_png` bílá = True;
plocha pásu mezi 3 a 20 % u portrétu hlava-ramena.

### 3. `tgbot/glassesprompt.py`, `config.py`, `jobs.py`, `app.py`

**`glassesprompt.py`** (vzor `hairprompt.py`, jen engine `kontext`):

```python
def prompt(block: str, finish: str | None, style_id: str) -> str:
    if style_id == NO_GLASSES:
        return ("Remove the person's glasses completely, showing the bare face and eyes underneath. "
                "Keep the face, eyes, expression, skin, hair, clothes, lighting and background exactly the same.")
    frames = f"{finish} {block}" if finish else block
    return (f"Put {frames} on the person's face. The glasses fit naturally on the nose and ears, "
            "with realistic lens reflections and soft shadows on the skin. "
            "Keep the face, eyes, expression, skin, hair, clothes, lighting and background exactly the same.")
```

Pro `tinted` provedení (sluneční) věta „The lenses are dark and the eyes are
not visible through them." místo odlesků — jinak Kontext kreslí průhledné
sklo. `NEGATIVE` se nepoužívá (cfg 1), ale konstantu nechat kvůli benchi.

**`config.py`**:

```python
GLASSES_WORKFLOW_FILE = "flux_glasses_kontext.api.json"
GLASSES_VARIANTS = _int_env("GLASSES_VARIANTS", 10)        # velikost sady
GLASSES_CONCURRENCY = _int_env("GLASSES_CONCURRENCY", 2)   # promptů ve frontě naráz
GLASSES_SET_TIMEOUT = _int_env("GLASSES_SET_TIMEOUT", 1200) # celá sada; jedna varianta drží JOB_TIMEOUT
MAX_GLASSES_IMAGE_B64_CHARS = MAX_RESTYLE_IMAGE_B64_CHARS
```

**`jobs.py`**: `Job.prompt_ids: list[str]`, `Job.image_paths: list[Path]`,
`Job.images_total: int = 1`. `image_path` zůstává jako alias první položky
(getter), aby `/api/jobs/{id}/image`, restyle a hair fungovaly beze změny.

**`app.py`**:

- `GlassesFitIn(BaseModel)`: `size: Literal["small","regular","oversized"]`,
  `tinted: bool = False`. `GlassesRequest`: `style_id` (pattern jako hair),
  `block ≤ 300`, `style ≤ 80`, `fit`, `finishes: list[str] ≤ 12` (každé ≤ 40
  znaků, jen `[a-z ,-]` — jde do promptu, takže validovat přísně), `image`.
- `POST /api/glasses` podle architektury. `_glasses_analysing` set jako u
  vlasů (nebo zobecnit `_hair_analysing` na `_analysing`). Mezi `spend` a
  prvním `queue_prompt` výjimka → `undo_usage` + 502. Jakmile je **aspoň
  jeden** prompt ve frontě, sada se platí.
- `_watch_set_job(job, usage_id)`: semafor `GLASSES_CONCURRENCY`; každá
  varianta `comfy.queue_prompt` → `wait_for_image(JOB_TIMEOUT)` → zapsat
  `outputs/<job>_<i>.png`, `job.image_paths.append`. Chyba varianty se
  loguje a přeskočí. Po všech: 0 obrázků → `status=error` + `undo_usage`;
  jinak `done`. Chat: `bot.send_media_group` po 10 (`InputMediaPhoto`,
  caption jen u první), `TelegramForbiddenError` jako dnes.
  `job.status` je `running` od prvního promptu; `images_done = len(image_paths)`.
- `GET /api/jobs/{id}` vrací navíc `images_done`, `images_total`;
  nový `GET /api/jobs/{id}/image/{i}` (404 nad `images_done`).
- `/start` text: „…try on glasses 👓".

Testy `tgbot/tests/test_glasses_api.py` (vzor `test_hair_api.py`, `FakeComfy`
s `wait_for_image` vracejícím PNG a čítačem promptů): bez tváře → 400 a
žádný spend; výpadek analýzy → 502 bez spendu; happy path → **jeden** spend,
`GLASSES_VARIANTS` promptů, každý s jiným seedem a `__MASK__`, provedení
rotují (`finishes[i % len]`), status postupně `images_done` 0→N,
`/image/3` vrací třetí; selže-li 1 z N → `done` s N−1 a bez refundu;
selžou-li všechny → `error` + refund; `no-glasses` bez brýlí → 400; 429; 402;
neznámý `size` → 422; `finishes` s nepovoleným znakem → 422;
`GLASSES_CONCURRENCY=2` → ve frontě nikdy víc než 2 (FakeComfy to počítá).

### 4. Appka

**`lib/config/glasses.dart`** (vzor `hairstyles.dart`):

```dart
enum GlassesSize { small, regular, oversized }
class GlassesFit { final GlassesSize size; final bool tinted; Map<String,Object> toJson(); }
class Glasses { id, label, group ('Eyeglasses' | 'Sunglasses'), section, block, finishes (List<String>), fit;
                String get preview => 'assets/glasses/$id.jpg'; }
const kGlassesGroups = ['Eyeglasses', 'Sunglasses'];
const kGlassesSections = ['Round', 'Rectangular', 'Cat-eye', 'Browline', 'Aviator', 'Oversized', 'Geometric', 'Rimless', 'Sport', 'Remove'];
const kNoGlassesId = 'no-glasses';
```

**`lib/config/glasses_catalog.dart`** — **generovaný** (`export_catalog.py
--task glasses`), do gate prázdný; karta se neukáže (`screenOffered`
dostane `glassesAvailable: kGlasses.isNotEmpty`).

**`tsumiki_app_bar.dart`**: `TsumikiScreen.glasses('Try on glasses',
Icons.visibility)` mezi `hair` a `animate`; `build()` → `GlassesScreen()`.
Testy `screen_nav_test` („glasses is a pushed card"), `shared_app_bar_test`
(chip ⚡, skrytí při prázdném katalogu).

**`lib/ui/screens/glasses_screen.dart`**: klon `hair_screen.dart` bez barev
— fotka (`ImagePicker`; nabídnout **kameru** i galerii, `maxWidth 1536`,
kvalita 88; na webu `ImageSource.camera` otevře přední kameru telefonu),
popisek „Keeps your face and everything else. Face the camera, eyes
visible, no hand over the face.", `SegmentedButton` Eyeglasses/Sunglasses,
sekce s `_StyleCard` (náhled z `assets/glasses/`), FAB „Try them on".
Po odeslání se otevře **`GlassesResultScreen`**: mřížka 2 sloupce ×
`images_total` dlaždic, placeholder s kolečkem; polling
`TelegramBackendService.glassesSet()` vrací `Stream<TgSetProgress>`
(`imagesDone`, `imagesTotal`, `status`), appka při každém přírůstku stáhne
`/image/{i}`; klepnutí na dlaždici → stávající `ResultScreen` (uložení,
sdílení). Hlavička „3 / 10 · about 6 minutes" z `imagesTotal − imagesDone`
× průměrné doby mezi příchody. 402 → `PaywallSheet`; 400 text ze serveru.

**`telegram_backend_service.dart`**: `startGlasses({imageBytes, styleId,
block, styleLabel, fit, finishes}) → jobId` (timeout 180 s jako hair kvůli
analýze), `setStatus(jobId)`, `setImage(jobId, i)`. `_awaitImageJob` se
nemění.

Testy: `test/glasses_test.dart` (id unikátní, `no-glasses` má prázdné
`finishes`, ostatní ≥ 3 provedení — jinak sada nemá z čeho být různá;
`block` bez slov média; sekce ze seznamu; `toJson` jména enumů; každý styl
má náhled v `assets/glasses/` a žádný náhled bez stylu — vzor
`hairstyles_test.dart`), widget test mřížky (progres 3/10, dlaždice bez
obrázku jsou placeholder, klepnutí na hotovou otevře `ResultScreen`).

### 5. Tuning feedback loop — `tgbot/tools/bench/`, task `glasses`

Stejný princip: buňka vzniká přes `prepare_workflow` + `glassesmask.prepare`
+ `glassesprompt.prompt`, tedy to, co bot pošle.

**`run.py glasses`** `--engines kontext --styles all --srcs … --seeds 1,2,3
--finishes all|first` (`all` = každé provedení stylu je vlastní buňka —
to je ta sada; `first` = jen první, pro rychlé kolo) `--sweep
'mask.BELOW_regular=0.16|0.24' '10.guidance=2.5|3.5' '12.steps=20|28'`.
`WORKFLOWS[("glasses","kontext")] = "flux_glasses_kontext.api.json"`.
Analýza se cachuje per src jako dnes (`ANALYSE_PREFIXES` + nový prefix).
`catalog.py`: `glasses()` čte `candidates/glasses.json`,
`glasses_prompt()` volá bot modul (test v `test_bench_catalog.py`, že je to
tentýž řetězec).

**Metriky per buňka** (`score.py`, task `glasses`):

| metrika | jak | práh (v1, kalibrovat) |
|---|---|---|
| `identity` | ArcFace výstup × předloha (stávající kód) | ≥ 0.60 na všech buňkách **u čirých skel**; u `tinted` se **nehodnotí** (ArcFace za tmavým sklem padá z důvodu, který není selhání identity — stejný princip jako profil ve vidbench) |
| `worn` | `FaceSegment Eyeglasses` na výstupu (tentýž analýza graf, cache): plocha třídy ≥ 0.4 % obrazu **a** leží v pásu masky; u `no-glasses` naopak ≤ 0.05 % | ≥ 2/3 buněk |
| `recognised` | CLIP ViT-L/14 na výřezu očí 1.4× eye box, labely všech **tvarů** (ne provedení — ~12 labelů), cílový tvar top 3 a zisk ≥ 0.05 proti předloze | řadí, nerozhoduje (lekce `structure.py`: CLIP měří rozlišitelnost nálepek) |
| `distinct` | `duplicates.py` nad buňkami **téže sady** (styl × src × všechna provedení × seedy): podíl dvojic s podobností výřezu očí < 0.85 | ≥ 70 % dvojic různých; sada, kde je 10 fotek k nerozeznání, neprojde |
| `outside` | mean |výstup − předloha| mimo masku ≤ 1/255 | 100 % (sanity kompozitu) |
| `clean` | právě jedna tvář, rozměr beze změny | 100 % |

**Gate do katalogu**: styl přidat, jen když projde `identity` (čiré),
`worn`, `distinct`, `outside`, `clean` na **≥ 2/3 předloh** — a arch schválí
oko (brýle visící ve vzduchu, nožička do oka, dvojité obruby — to metriky
nevidí). Verdikt `retune` = přepsat `block`/`finishes`/`fit` v JSONu a pustit
jen ten id (resume).

**Kola** (~45–60 s/varianta; kolo 0 to změří a tahle tabulka se přepíše):

| kolo | rozsah | buňky | čas |
|---|---|---|---|
| 0 | 3 styly (round, aviator sun, no-glasses) × 3 předlohy (`w-long`, `m-short`, `w-glasses`) × 1 provedení × 2 seedy — grafy, maska, pátý výstup analýzy, `worn` metrika | 18 | 20 min |
| 1 | ~30 kandidátů × 3 předlohy × první provedení × 2 seedy | ~180 | ~2,5 h |
| 2 | přeživší × **všechna provedení** × 3 předlohy × 1 seed → `distinct`; + předlohy `w-bangs-3q` (¾ profil), `w-afro`, `m-receding`, `w-glasses` | ~400 | ~5 h (přes noc) |
| 3 | sweep `mask.BELOW_*`, `mask.SIDE`, `10.guidance`, `12.steps` na 4 stylech, kde `worn`/`identity` padaly | ~100 | 1,5 h |

Do `srcs/` přidat (`run.py srcgen`, Juggernaut Lightning): `m-glasses`
(muž s brýlemi — nahrazení), `w-selfie-close` (close-up z ruky, tvář přes
půl obrázku — test `MASK_TOO_LARGE`), `w-sunglasses` (má sluneční — výměna
za čiré). Žádná osobní data.

Výstup: `docs/glasses-matrix.md` (formát `hair-matrix.md`) a **teprve pak**
`export_catalog.py --task glasses verdicts-glasses.json --bench out/glasses-r2`
→ `lib/config/glasses_catalog.dart` + `assets/glasses/<id>.jpg` (náhled =
buňka stylu na `w-long` v prvním provedení; **jedna** tvář pro oba groups,
brýle jsou unisex).

### 6. Katalog kandidátů — `tgbot/tools/bench/candidates/glasses.json`

Pole: `id, label, cs, group, section, block, finishes[], fit{size,tinted}`.
Blok = **tvar + popis** (kde sedí, jak široká obruba), provedení = materiál
+ barva, které Kontext zná ze slov. Startovní seznam (~30):

| id | label | section | block | finishes | fit |
|---|---|---|---|---|---|
| round | Round glasses | Round | round eyeglasses with thin circular rims | black acetate, tortoiseshell, gold wire, silver wire, clear crystal | regular |
| round-oversized | Oversized round | Oversized | oversized round eyeglasses with wide circular rims | black, tortoiseshell, clear, honey | oversized |
| panto | Panto glasses | Round | panto eyeglasses, rounded lenses with a flat top and keyhole bridge | tortoiseshell, black, dark green, crystal | regular |
| oval | Oval glasses | Round | small oval eyeglasses with thin rims | gold wire, silver wire, black | small |
| rectangular | Rectangular glasses | Rectangular | rectangular eyeglasses with slim straight rims | black, matte navy, gunmetal, brown | regular |
| square-bold | Bold square | Rectangular | bold square eyeglasses with thick dark acetate frames | black, tortoiseshell, clear, dark blue | regular |
| wayfarer | Wayfarer glasses | Rectangular | wayfarer-style eyeglasses with a trapezoid frame and thick arms | black, tortoiseshell, matte grey | regular |
| cat-eye | Cat-eye glasses | Cat-eye | cat-eye eyeglasses with upswept outer corners | black, tortoiseshell, red, pink crystal, leopard | regular |
| cat-eye-oversized | Oversized cat-eye | Oversized | oversized cat-eye eyeglasses with dramatic upswept corners | black, tortoiseshell, burgundy | oversized |
| browline | Browline glasses | Browline | browline (clubmaster) eyeglasses, thick acetate upper rim and thin metal lower rim | black and gold, tortoiseshell and gold, navy and silver | regular |
| aviator-clear | Aviator eyeglasses | Aviator | aviator eyeglasses with teardrop lenses and a double bridge, thin metal frame | gold, silver, rose gold, black | regular |
| hexagonal | Hexagonal glasses | Geometric | hexagonal eyeglasses with thin metal rims | gold, silver, black, rose gold | small |
| octagonal | Octagonal glasses | Geometric | octagonal eyeglasses with thin angular rims | gold, gunmetal, black | regular |
| rimless | Rimless glasses | Rimless | rimless eyeglasses, lenses held by a thin metal bridge and arms | silver, gold, titanium grey | small |
| half-rim | Half-rim glasses | Rimless | half-rim eyeglasses with a rim only along the top of the lenses | black, gunmetal, brown | regular |
| oversized-square | Oversized square | Oversized | oversized square eyeglasses with wide clear-acetate frames | clear, black, tortoiseshell, milky white | oversized |
| geek-chic | Geek-chic glasses | Rectangular | chunky thick-rimmed nerd eyeglasses | black, tortoiseshell, red | regular |
| sport-wrap | Sport glasses | Sport | wraparound sport glasses with a single curved shield lens | black with clear lens, white, neon yellow | regular |
| aviator-sun | Aviator sunglasses | Aviator | aviator sunglasses with dark teardrop lenses and a thin metal frame | gold with green lenses, silver with dark grey lenses, black with mirrored lenses | regular, tinted |
| wayfarer-sun | Wayfarer sunglasses | Rectangular | wayfarer sunglasses with dark lenses | black, tortoiseshell, matte black | regular, tinted |
| round-sun | Round sunglasses | Round | round sunglasses with small dark lenses and thin metal rims | gold, silver, black | small, tinted |
| cat-eye-sun | Cat-eye sunglasses | Cat-eye | cat-eye sunglasses with dark lenses | black, tortoiseshell, white | regular, tinted |
| oversized-sun | Oversized sunglasses | Oversized | oversized square sunglasses with dark gradient lenses | black, tortoiseshell, brown gradient | oversized, tinted |
| sport-sun | Sport sunglasses | Sport | wraparound sport sunglasses with a mirrored shield lens | black with blue mirror, white with red mirror | regular, tinted |
| shield-sun | Shield sunglasses | Sport | futuristic shield sunglasses with a single wide lens | silver mirror, black, iridescent | oversized, tinted |
| clubmaster-sun | Browline sunglasses | Browline | browline sunglasses with dark green lenses | black and gold, tortoiseshell and gold | regular, tinted |
| no-glasses | No glasses | Remove | — | — | regular |

Tři až pět provedení na styl dává sadu 10 jako 2 seedy × 5 provedení (nebo
3 × 4; server rotuje `i % len`, seed losuje každý prompt). Sluneční i čiré
jsou **jeden katalog**, group řídí jen záložku v UI.

### 7. Dokumentace a rollout

- `CLAUDE.md`: odstavec „Pátá karta **Try on glasses**" — analýza (pátý
  výstup), `glassesmask.py` nad `hairmask` primitivy, sada N promptů s
  rolling window, `GLASSES_VARIANTS`/`GLASSES_CONCURRENCY`, účtování sada =
  1 generace, album do chatu, gate `docs/glasses-matrix.md`, generovaný
  katalog + náhledy `assets/glasses/`.
- `tgbot/README.md` sekce „Brýle — `POST /api/glasses`", `mangabot.env.example`
  nové proměnné; `docs/telegram-release.md` (BotFather description).
- `CHANGELOG.md` záznam.
- Rollout: `check_workflow.py` × 2 → kolo 0 → kola 1–3 → katalog → JODA
  (`docker compose up -d --build`, záloha DB) → merge → E2E: selfie → mřížka
  se plní, 10 fotek, v chatu album s `👓 <label>`, −1 kredit; člověk
  s brýlemi → staré pryč, nové na místě; `no-glasses` bez brýlí → 400 bez
  stržení; krajina → 400; profil → „eyes must be visible"; shozené ComfyUI
  po 3. variantě → sada `done` se 3 obrázky, bez refundu, album se 3; 429
  při běžící sadě; 402.

### 8. Rizika

1. **Sada bez variability.** Kontext mění při různém seedu málo — bez
   provedení by uživatel dostal 10 skoro stejných fotek. `distinct` to
   měří v kole 2; když ani provedení nestačí, přidat osu
   „posazení" (`sitting higher on the nose` / `slightly lower`) nebo sweep
   `12.denoise=0.9` (hint: nižší denoise u Kontextu zvětší rozptyl, ale
   rozmaže edit — měřit, ne hádat).
2. **Identita přes oči.** Maska jde přes oči, Kontext je může „vylepšit"
   (barva, tvar). `identity ≥ 0.60` je tvrdý gate u čirých skel; u slunečních
   je gate slepý (zapsat do matice, neprodukovat číslo, které nic neměří).
   Pojistka: `ABOVE`/`BELOW` co nejmenší, roh pásu malý.
3. **Nožičky do vlasů.** Pás sahá přes spánky do vlasů; Kontext tam
   přegeneruje vlasy a kompozit to pustí. Měkký okraj (`apply_feather`) to
   změkčí; kdyby to bylo vidět, zúžit `SIDE` a nechat nožičky „useknuté"
   za spánkem — oko rozhodne na archu.
4. **Fronta na sdíleném boxu.** 10 promptů × ~50 s = 8 min GPU na jednoho
   uživatele; rolling window 2 to rozprostře, ale latence sady roste
   s provozem. `GLASSES_VARIANTS` je env — produkce může jet na 6.
5. **Dlouhé čekání v Mini Appce.** Telegram WebView usne při přepnutí
   appky; mřížka se plní jen při otevřené appce, ale **album v chatu přijde
   vždy** — to je záchrana, popsat v UI („The set also arrives in your
   chat.").
6. **`FaceSegment Eyeglasses` na slunečních / bezrámových.** Parsing může
   bezrámové nevidět (`worn` false negative) a tmavá skla splést s očima.
   Kolo 0 na `w-glasses` + nová `w-sunglasses` to ukáže; záloha pro `worn`
   je CLIP „a person wearing glasses" vs „a person without glasses".
7. **Částečný úspěch a účtování.** Sada se 3 z 10 je zaplacená celá —
   uživatel to může vnímat jako podvod. Práh: `images_done < GLASSES_VARIANTS/2`
   → refund + `done` (dostane, co je, zdarma). Zapsat do README.
8. **Dvě kopie analýzy grafu** (Ol1nLLM má `hair_analyse.api.json`): pátý
   výstup tam nevadí, dokud Ol1nLLM nečeká na konkrétní sadu prefixů —
   ověřit `analyseHair` (párování podle prefixu, tolerantní).

### 9. Co nedělat (a proč)

- **Ne `batch_size`/`RepeatLatentBatch`** na Kontext latentu: žádný průběh,
  kompozit a `TsumikiAlignToReference` by chtěly batch broadcast, který
  není ověřený, a jedna chyba zabije sadu.
- **Ne druhý engine v v1.** SDXL inpaint brýlí nikdo nezměřil; gate je per
  engine, přidá se, až bude důvod (Kontext selže na třídě stylů).
- **Ne výběr barvy obruby v UI.** Provedení jsou náplň sady, ne volba —
  jinak by sada ztratila smysl. Výběr jednoho provedení = Fáze 2.

### 10. Fáze 2 (mimo tento plán)

- **Ol1nLLM zrcadlo** (`07-PLAN-ol1nllm-bryle.md`): `glasses_mask.dart`
  nad `hair_mask.dart` primitivy, `GlassesSheet`, `glassesTryOn()` → N×
  `inpaint()` přes `hairInpaint`-podobnou cestu na `flux-fill` presetu;
  katalog z `export_catalog.py --ol1nllm`; sdílená fixture masek.
- Výběr jednoho provedení a „ještě 10 takových".
- Dvojice: brýle + účes v jednom průchodu (dvě masky, dvě instrukce).
- Virtuální zrcadlo: po sadě „animate" vybrané fotky (karta Animate už umí).
