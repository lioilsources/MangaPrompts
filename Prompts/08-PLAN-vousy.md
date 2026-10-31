# PLAN — Vousy: změna vousů na pánském portrétu (maska dolní tváře + Kontext)

> Pro Opuse. Repo `lioilsources/MangaPrompts`. Čtvrtý editační blok po
> vlasech (`04`), brýlích (`06`) a vedle restyle; primárně jako krok 1
> průvodce Restyleru (`07-PLAN-restyler.md` §5), volitelně karta Tsumiki.
> Kostra je stejná jako u brýlí: masku a prompt má Python (`tgbot/`) i Dart
> (`tsumiki_shared`), bench gate rozhoduje o katalogu, katalog se generuje.

## Zadání a rozhodnutí

Uživatel (muž) nahraje portrét a vybere vousy — od oholení přes strniště po
plnovous, knír, bradku — a dostane tutéž fotku s novými vousy. Barva vousů
se drží barvy vlasů z fotky.

| rozhodnutí | důvod |
|---|---|
| **Kontext edit přes masku dolní tváře**, stejný graf jako vlasy a brýle | vousy jsou lokální objekt; kompozit vrátí oči, nos, vlasy, oblečení pixel-přesně. Žádný nový graf, jen prompt a maska |
| **Maska jde přes kůži dolní tváře, rty vynechává** | bez kůže tváří a brady se vousy nedají nasadit ani oholit; rty nesou identitu a výraz, a žádný styl vousů rty nezakrývá (knír sedí *nad* horním rtem). Nos a oči jsou mimo masku z definice |
| **Rozsah masky podle třídy stylu (`region`)**, ne jedna maska pro všechno | knír potřebuje jen pás nad rtem, bradka bradu, plnovous tváře + bradu + pod bradou + kotlety k uchu. Maska plnovousu na kníru by přemalovala tváře zbytečně (identita) |
| **Stávající vousy se neparsují, odhadují se barvou** | CelebAMask-HQ třídu „vousy" nemá (jsou v kůži). Pro `clean-shaven` i pro přepis stačí vědět, že dolní tvář je tmavší a texturovanější než horní tvář; `has_beard` je heuristika z Lab, ověří ji bench na předlohách s vousy a bez. Když heuristika selže, Kontext oholí i hladkou tvář bez škody — jen uživatel zaplatil za nic; proto 400 „na fotce nejsou vousy k oholení" jen při jasném negativu |
| **Barva = barva vlasů z fotky** (`estimate_colour` nad maskou vlasů), s možností „prošedivělé" | vousy jiné barvy než vlasy jsou výjimka; grey/salt-and-pepper je jediná volba, kterou lidé opravdu chtějí zkusit. Bez vlasů na fotce (holá hlava) → „matching natural colour" |
| **Katalog jen mužský; krok se v průvodci nabízí všem s výchozím „Nechat"** | appka pohlaví nezjišťuje a nemá proč; kdo krok nechce, přeskočí ho |
| **Engine jen Kontext** | jako u brýlí: zadání i graf jsou Kontext; gate per engine umožní SDXL přidat později |

## Co je hotové a znovu se použije

| potřeba | kde |
|---|---|
| parsing tváře | `hair_analyse.api.json` (server) / `face_parse.dart` (telefon, 07 §1): kůže, nos, rty (`Upper-lip`, `Lower-lip`, `Mouth`), uši, vlasy |
| primitivy masky | `hairmask.face_box/dilate/rounded_rect/to_png`, Dart `bool_mask.dart` |
| barva | `hairmask.estimate_colour`, `colour_name`; Dart `estimateHairColour` |
| graf | `flux_hair_kontext.api.json` (`kontext_edit` v 07), `apply_feather` |
| bench | `run.py` task pattern z 06 (`glasses`), `score.py` (ArcFace, CLIP, `clean`), `duplicates.py`, `export_catalog.py --task` |
| předlohy | `srcs/m-short.png`, `m-long.png`, `m-receding.png`; nové `m-beard-full`, `m-stubble`, `m-goatee` (`run.py srcgen`, Juggernaut Lightning) |

---

## Kroky

### 1. Analýza

Server (Tsumiki karta): `hair_analyse.api.json` dostane výstupy
`tsumiki_lips_mask` (`Upper-lip`, `Lower-lip`, `Mouth`), `tsumiki_nose_mask`
(`Nose`) a `tsumiki_ears_mask` (`Left-ear`, `Right-ear`, pokud třídy jsou —
ověřit `/object_info`, 06 to potřebuje taky). Telefon (Restyler): tytéž
třídy z `FaceParse`. `HairAnalysis` dostane pole `lips`, `nose`, `ears`
s defaultem nul.

### 2. `tgbot/beardmask.py` + `tsumiki_shared/lib/masks/beard_mask.dart`

```python
REGIONS = ("moustache", "chin", "jaw", "full")
@dataclass(frozen=True)
class BeardRegion: kind: str; below_chin: float = 0.0   # kolik fh pod bradu (plnovous visí)

def lower_face_box(face, nose, lips) -> (x0, y0, x1, y1)   # y0 = spodek nosu, y1 = brada (face box), x0..x1 = face box
def has_beard(rgb, face, lower_box) -> bool | None          # heuristika: Lab dolní tváře (mimo rty) vs. horní tváře; None = nejasné
def build_mask(analysis, region, mode=None) -> MaskResult
def prepare(image, masks, region) -> (mask_png, colour_word, has_beard)
```

`build_mask`, jednotky `fw`/`fh` face boxu, `lb` = lower_face_box:

| region | maska |
|---|---|
| `moustache` | pás `lb.x0+0.15fw .. lb.x1−0.15fw`, svisle od spodku nosu do horního okraje rtů + `0.03fh`; `−lips` |
| `chin` | zaoblený obdélník kolem brady: `x` střední třetina `lb`, `y` od spodního okraje rtů `−0.05fh` do `y1 + below_chin·fh`; `−lips` |
| `jaw` | `chin` ∪ pás podél čelisti: dolní polovina `lb` v celé šířce, `+0.06fw` do stran; `−lips`, `−nose` |
| `full` | `lb` celý `+0.08fw` do stran (kotlety: až k uchu, když `ears` je) , `y0 = spodek nosu`, `y1 + below_chin·fh` (0.25 u plnovousu, 0.5 u dlouhého); ∪ `moustache`; `−lips`, `−nose`, `−eyes` |
| `clean-shaven` | `full` s `below_chin 0.1` — oholit se musí všude, kde vousy mohly být |

Vždy `mask &= ~dilate(lips, 0.02fh)` a `mask &= ~nose`; `mask &= ~hair`
(vlasy nad spánky zůstávají — kotlety jdou do `hair` jen po `0.06fh`
dilataci). Refusals: `NO_FACE`, `FACE_TOO_SMALL` (z hairmask), `MOUTH_NOT_VISIBLE`
(`lips` prázdné — ruka, rouška, profil), u `clean-shaven`
`has_beard is False` → `NO_BEARD_TO_SHAVE`. Konstanty startovní, kolo 3 kalibruje.
Mode `blob` není třeba — regiony jsou obdélníky.

Testy nad **souborovými fixturami** (07 §0): každý region pokrývá bradu,
resp. horní ret, resp. tváře; rty nikdy; nos nikdy; oči nikdy; `full` sahá
pod bradu; `MOUTH_NOT_VISIBLE` bez rtů; `has_beard` True na syntetické
tmavé dolní tváři, False na hladké, None na šumu; Dart dává tutéž masku jako
Python (IoU 1.0 na fixtuře).

### 3. `tgbot/beardprompt.py` + `beard_prompt.dart`

```python
def prompt(block, style_id, colour, grey=False):
    if style_id == CLEAN:
        return ("Shave off the beard and moustache completely so the man is clean-shaven with smooth bare skin. "
                "Keep the face, eyes, nose, lips, expression, skin tone, hair, clothes, lighting and background exactly the same.")
    shade = "salt-and-pepper grey" if grey else f"{colour or 'natural'}"
    return (f"Give the man a {block}, {shade}, matching his hair, with realistic individual hairs and natural density. "
            "Keep the face, eyes, nose, lips, expression, skin tone, hair, clothes, lighting and background exactly the same.")
```

`NEGATIVE` konstanta kvůli benchi (Kontext cfg 1 ji nečte). Pinnuto
fixturou `prompts.json` v obou jazycích.

### 4. Server a appky

- **Tsumiki** (volitelná karta „Try a beard", `TsumikiScreen.beard`,
  `Icons.face`): `POST /api/beard {style_id, block, style, region, grey, image}`
  přes `stages`-podobnou cestu z `/api/hair` (analýza → `beardmask.prepare`
  → `beardprompt` → `kontext_edit` graf → `_watch_job`). Skryto, dokud je
  `kBeards` prázdný. Testy vzor `test_hair_api.py`.
- **Restyler**: krok 1 průvodce; maska a prompt v telefonu, krok
  `{id:"beard", graph:"kontext_edit", input:"source", prompt, mask}` v
  `RenderPlan` (07 §2). Žádný nový endpoint.
- `tsumiki_shared/lib/catalogs/beards.dart`: `Beard{id, label, cs, section,
  block, region, previewPath}`, `kBeardSections = ['Shave', 'Stubble', 'Short',
  'Full', 'Goatee', 'Moustache']`, `kBeards` generovaný, `kCleanShavenId`.

### 5. Katalog kandidátů — `tgbot/tools/bench/candidates/beards.json`

Pole `id, label, cs, section, block, region{kind, below_chin}`. ~22:

| id | label | section | block | region |
|---|---|---|---|---|
| clean-shaven | Clean shaven | Shave | — | full 0.1 |
| light-stubble | Light stubble | Stubble | light five o'clock shadow stubble, very short even facial hair | full 0.0 |
| heavy-stubble | Heavy stubble | Stubble | heavy stubble, 3–5 mm even facial hair over cheeks, jaw and chin | full 0.0 |
| short-boxed | Short boxed beard | Short | short boxed beard, neatly trimmed full beard with clean sharp cheek and neck lines | full 0.1 |
| corporate | Corporate beard | Short | corporate beard, short tidy full beard about 1 cm, well groomed | full 0.1 |
| full-beard | Full beard | Full | full thick beard with moustache, medium length covering cheeks, jaw and chin | full 0.25 |
| long-beard | Long beard | Full | long full beard reaching the upper chest, thick moustache | full 0.5 |
| garibaldi | Garibaldi | Full | garibaldi beard, wide full rounded beard with an integrated moustache | full 0.35 |
| ducktail | Ducktail beard | Full | ducktail beard, full beard tapered to a point under the chin | full 0.35 |
| goatee | Goatee | Goatee | goatee, hair on the chin only with a clean-shaven jaw, no moustache | chin 0.1 |
| circle-beard | Circle beard | Goatee | circle beard, goatee connected to a moustache in a ring around the mouth, shaved cheeks | chin 0.1 (+moustache) |
| van-dyke | Van Dyke | Goatee | van dyke beard, pointed goatee and a separate styled moustache, shaved cheeks | chin 0.15 (+moustache) |
| anchor | Anchor beard | Goatee | anchor beard tracing the jawline to a point under the chin with a pencil moustache | jaw 0.1 (+moustache) |
| chin-strap | Chin strap | Goatee | chin strap beard, a thin line of hair along the jawline, no moustache | jaw 0.05 |
| soul-patch | Soul patch | Goatee | soul patch, a small tuft of hair just below the lower lip, otherwise clean-shaven | chin 0.0 |
| mutton-chops | Mutton chops | Full | mutton chops, thick sideburns extending down the cheeks to the jaw, clean chin, no moustache | jaw 0.0 |
| chevron | Chevron moustache | Moustache | chevron moustache, thick full moustache covering the upper lip, clean-shaven otherwise | moustache |
| handlebar | Handlebar moustache | Moustache | handlebar moustache with long ends curled upward, clean-shaven otherwise | moustache |
| pencil | Pencil moustache | Moustache | thin pencil moustache just above the upper lip, clean-shaven otherwise | moustache |
| walrus | Walrus moustache | Moustache | walrus moustache, very thick and bushy, hanging over the upper lip | moustache |
| horseshoe | Horseshoe moustache | Moustache | horseshoe moustache running down both sides of the mouth to the jaw | moustache (+chin sides) |

Styly se „shaved cheeks" říkají oholení **v promptu**, protože maska regionu
`chin` tváře nepřemaluje — na předloze s plnovousem by zbyly. Proto u
`chin`/`jaw`/`moustache` stylů platí: `has_beard == True` → maska se
rozšíří na `full` (napřed oholit, pak nasadit, v jednom průchodu). Test to
hlídá; bench to měří (`beard_ok` na `m-beard-full`).

### 6. Bench — task `beard`

`run.py beard --engines kontext --styles all --srcs srcs/m-short.png,srcs/m-beard-full.png,srcs/m-receding.png --seeds 1,2`
(+ `--sweep 'mask.BELOW_CHIN_full=0.2|0.3' 'mask.SIDE_fw=0.06|0.1' '10.guidance=2.5|3.5'`).

| metrika | jak | práh |
|---|---|---|
| `identity` | ArcFace výstup × předloha | ≥ 0.60 (maska je přes půl tváře — tvrdý gate; ArcFace je na vousy poměrně robustní, číslo kalibruje kolo 0) |
| `beard_ok` | CLIP ViT-L/14 na výřezu dolní tváře 1.3× `lb`, labely = všechny sekce + „clean-shaven" (~8 tříd, dobře oddělitelné): cílová sekce top 1, zisk ≥ 0.10 proti předloze; u `clean-shaven` top 1 „clean-shaven" | ≥ 2/3 |
| `shaved_cheeks` | u `chin`/`moustache` stylů: `has_beard` heuristika na tvářích výstupu == False | ≥ 2/3 |
| `lips_unchanged` | mean |výstup − předloha| přes `lips` masku ≤ 2/255 | 100 % (sanity, rty jsou mimo masku) |
| `outside`, `clean` | jako u brýlí | 100 % |

Gate: `identity` + `beard_ok` + (`shaved_cheeks`) + `lips_unchanged` +
`clean` na ≥ 2/3 předloh, arch schválí oko (vousy „nalepené", knír do rtu,
dvojitá brada). Kola: 0 = 3 styly (clean-shaven, full-beard, chevron) × 3
předlohy × 1 seed (~10 min, graf + maska + metriky); 1 = 21 × 3 × 2 (~2 h);
2 = přeživší × 6 předloh (+ `m-long`, `m-stubble`, `m-goatee`) × 2 seedy
(~3 h); 3 = sweepy masky na stylech, kde `identity`/`beard_ok` padaly (1 h).
Výstup `docs/beard-matrix.md`; `export_catalog.py --task beard` →
`beards_catalog.dart` + `assets/beard/<id>.jpg` (náhled na `m-short`).

### 7. Rizika

1. **Identita přes půl tváře.** Maska `full` zasahuje tváře a čelist; Kontext
   může změnit tvar obličeje. Práh 0.60 a co nejnižší `y0` (spodek nosu, ne
   lícní kosti); kdyby to nestačilo, `full` rozdělit na tváře + brada se
   zachovanou nosní rýhou.
2. **`has_beard` heuristika** splete tmavou pleť nebo stín pod bradou.
   Vrací None při nejasnosti a appka se chová jako „bez vousů" u oholení
   (žádné 400) — radši zbytečný render než odmítnutí. Bench to měří na
   `m-beard-full` (True) a `m-short` (False) + tmavší syntetická předloha.
3. **Dlouhé vousy a límec**: `below_chin 0.5` jde přes oblečení; prompt
   říká „same clothes", kompozit pustí jen pás. Oko rozhodne.
4. **Barva vousů ≠ vlasy** (šedivé vousy, hnědé vlasy): volba „prošedivělé"
   to pokryje; jiné barvy nejsou.
5. **Dvě zrcadla masky** (Python, Dart) — souborové fixtury.

### 8. Fáze 2

- Barva vousů jako u vlasů (`haircolours` phrase), SDXL engine, karta
  v Ol1nLLM (dlaždice jako Kadeřník), obočí (stejný princip, jiný region).
