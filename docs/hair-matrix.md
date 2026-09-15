# Kadeřník — měření účesů a gate do katalogu

Měřeno na SPARKu (`http://192.168.88.66:8188`, ComfyUI 0.19.3, GB10) benchem
`tgbot/tools/bench` od 2026-09-13. Plán: `Prompts/04-PLAN-kadernik.md` §5.
Box je sdílený s Ol1nLLM appkou, takže časy buněk obsahují čekání ve frontě.

Předlohy jsou syntetické portréty (`tgbot/tools/bench/srcs/`, Juggernaut
Lightning, prompty v `srcs/prompts.json`) — žádná osobní data.

## Metriky (`score.py`)

| metrika | co měří | práh |
|---|---|---|
| `identity` | ArcFace (antelopev2) výstup × předloha, největší tvář | ≥ 0.60 u každé buňky |
| `length_ok` | nejnižší vlasy pod bradou v jednotkách výšky tváře vs. délka stylu | ≥ 2/3 buněk |
| `bangs_ok` | pokrytí čelního pásu vlasy podle typu ofiny | ≥ 2/3 buněk |
| `recognised` | CLIP ViT-L/14: cílový label v top 5 ze skupiny a zisk proti předloze ≥ 0.05 | ≥ 2/3 buněk |
| `clean` | právě jedna tvář, rozměr beze změny | 100 % |

Metriky jen řadí. O katalogu rozhoduje pohled na arch — stejné pravidlo jako
ve style-matrix Ol1nLLM.

## Kolo 0 — co se rozbilo a proč (5 účesů, 1 předloha)

Každé zjištění skončilo v kódu; odkazy na konstanty jsou v `tgbot/hairmask.py`
a grafech.

1. **Barva vlasů z mediánu padala do stínů.** Hnědé vlasy měly medián
   L\* 18 a četly se jako „black“. Barva se teď bere z 50.–90. percentilu jasu
   (podle pořadí) v jádru masky. Na všech osmi předlohách vyšla správně:
   brown, brown, black, blonde, light brown, grey, auburn, black.
2. **Obálky byly dvakrát větší, než portrét snese.** Střední střih přemaloval
   85 % obrazu včetně trička a pozadí. Obálky jsou zmenšené
   (`ENVELOPES`), pás ofiny je 0.28 výšky tváře a obočí chrání odstup
   0.04 výšky tváře.
3. **`mask_fill_holes: true` přemaloval obličej.** Obličej je v masce díra;
   když ho obálka obklopí, `InpaintCropImproved` ji vyplní. Identita u mikáda
   spadla na **0.11**. Po vypnutí vyšla 0.72–0.97 (kolo 0c).
4. **FLUX Fill maluje tvar masky.** Pixie maskovaný jako silueta starých
   dlouhých vlasů se vrátil jako dlouhé vlasy; SDXL nechal pramen na rameni.
   `MASK_MODE = "blob"` (obalový zaoblený obdélník minus tvář) oba zkrátil.
   Cena: oblečení a pozadí uvnitř obdélníku se přemalují.
5. **FLUX Fill účes skoro nemění** ani s blokem — pixie vyšel jako mikádo,
   wolf cut jako dlouhé vlny. **FLUX Kontext** (instrukce „change the
   hairstyle… keep the face…“) se složením zpět přes masku
   (`flux_hair_kontext.api.json`) střih mění, drží oblečení i barvy, identita
   0.75–0.88. Pixie ale i Kontext zkrátí jen na mikádo s ofinou.
6. **SDXL s `VAEEncodeForInpaint` barvil vlasy do olivova.** Šedá výplň masky
   posunula barvu. `INPAINT_VAEEncodeInpaintConditioning` (comfyui-inpaint-nodes)
   dává přirozené barvy při stejné identitě (0.92–0.96).

Enginy pro gate proto jsou **Kontext** a **SDXL** (Juggernaut XL v9 +
Fooocus inpaint). FLUX Fill zůstává v `HAIR_WORKFLOW_FILES` jako `flux`,
ale do gate nejde.

CLIP práh byl původně top 3. Viditelně správná mikáda na Kontextu měla rank
6–8 z 25, protože sousední labely (bob, lob, Italian bob, blunt cut) mají pro
CLIP stejný tvar. Práh je proto top 5.

## Kolo 1 — 51 kandidátů × 2 enginy (2026-09-13)

Běh `out/hair-r1` (Kontext + SDXL, předloha `w-long` pro ženské a `m-short`
pro pánské účesy, seed 1) a `out/hair-colours` (16 barev × 2 enginy × obě
předlohy, `keep-cut`). Arch pro mobil: artefakt „Kadeřnický arch“.

**Gate = automatický verdikt na obou enginech**, schválený pohledem na arch
(verdikty v `tgbot/tools/bench/verdicts.json`, export `export_catalog.py`).
Každý účes má zatím jednu buňku na engine, takže prahy „≥ 2/3 buněk“ jsou
tady všechno nebo nic.

Do katalogu (8 účesů, 4 barev):

| účes | skupina | Kontext | SDXL |
|---|---|---|---|
| Beach Waves (`beach-waves`) | Women | pass | pass |
| Curtain Bangs (`curtain-bangs`) | Women | pass | pass |
| Face-Framing Layers (`face-framing`) | Women | pass | pass |
| French Bob (`french-bob`) | Women | pass | pass |
| Long Bob (Lob) (`lob`) | Women | pass | pass |
| Quiff (`m-quiff`) | Men | pass | pass |
| High Skin Fade (`m-skin-fade`) | Men | pass | pass |
| Soft Curls (`soft-curls`) | Women | pass | pass |

| barva | Kontext | SDXL |
|---|---|---|
| Blue black (`blue-black`) | pass | pass |
| Burgundy (`burgundy`) | pass | pass |
| Honey balayage (`honey-balayage`) | pass | pass |
| Jet black (`jet-black`) | pass | pass |

Prošly jen na jednom enginu — kandidáti na kolo s víc předlohami a seedy,
ne do katalogu (appky jedou na obou enginech):

| účes | Kontext | SDXL |
|---|---|---|
| Blunt Bangs (`blunt-bangs`) | pass | fail: length_ok 0% |
| Bob Cut (`bob`) | fail: recognised 0% | pass |
| High Ponytail (`high-ponytail`) | fail: length_ok 0% | pass |
| Long Layered Haircut (`long-layered`) | fail: length_ok 0%, recognised 0% | pass |
| Low Ponytail (`low-ponytail`) | fail: length_ok 0%, recognised 0% | pass |
| Buzz Cut (`m-buzz`) | fail: recognised 0% | pass |
| Curly Top Fade (`m-curly-fade`) | fail: recognised 0% | pass |
| Man Bun (`m-man-bun`) | fail: recognised 0% | pass |
| Top Knot (Undercut) (`m-top-knot`) | pass | fail: recognised 0% |
| Messy Bun (`messy-bun`) | fail: length_ok 0%, recognised 0% | pass |
| Messy Waves (`messy-waves`) | fail: recognised 0% | pass |
| Pixie Cut (`pixie`) | fail: recognised 0% | pass |
| Shag Cut (`shag`) | fail: recognised 0% | pass |
| Sleek Straight Hair (`sleek-straight`) | fail: recognised 0% | pass |
| Top Knot (`top-knot`) | fail: length_ok 0%, recognised 0% | pass |
| Wispy Bangs (`wispy-bangs`) | pass | fail: recognised 0% |

| barva | Kontext | SDXL |
|---|---|---|
| Ash blonde (`ash-blonde`) | pass | fail: colour_ok 0% |
| Auburn (`auburn`) | fail: colour_ok 50% | pass |
| Chocolate brown (`chocolate-brown`) | fail: colour_ok 0% | pass |
| Honey blonde (`honey-blonde`) | pass | fail: colour_ok 0% |
| Lavender (`lavender`) | pass | fail: colour_ok 50% |
| Pastel pink (`pastel-pink`) | fail: length_ok 50% | pass |
| Platinum blonde (`platinum-blonde`) | pass | fail: colour_ok 0% |
| Silver grey (`silver-grey`) | pass | fail: colour_ok 0% |

Nejčastější důvod pádu je `recognised` — CLIP ViT-L/14 si plete sousední
střihy (bob / lob / blunt cut / Italian bob), i když výstup střih zjevně
mění. Delší pánské střihy (afro, flow, dredy, blowout, slick back, curtains)
padají na obou enginech na `length` — z krátké pánské předlohy nedorostou
pod bradu tak, jak metrika čeká.

Produkce Tsumiki jede na `HAIR_ENGINE=kontext` (výchozí od tohoto kola) — FLUX
Fill gate neprošel už v kole 0.

## Kolo 2 — Kontext posouvá obraz (2026-09-14)

Při procházení archu kola 1 měla většina pánských účesů na Kontextu přes čelo
průsvitný pruh starých vlasů a u krku dvojitý límec — i High Skin Fade a Quiff,
které prošly do katalogu. U dlouhých ženských vlasů šev schovají vlasy.

Příčina: **FLUX Kontext výstup přerámuje.** Similarity transformace výstup →
předloha ze SIFT shod na tváři (`scratch/align`, seed 1):

| předloha | účes | s `FluxKontextImageScale` | bez něj |
|---|---|---|---|
| m-short | m-crew | měřítko 0.996, posun (−1, 71) px | 1.009, (−1, 73) px |
| w-long | curtain-bangs | 0.960, (9, 51) px | 0.970, (3, 38) px |
| m-receding | m-quiff | 1.038, (−13, 2) px | 1.051, (−19, 15) px |

Není to škálování na preferované rozlišení (bez něj posun zůstává) ani offset
reference v RoPE (první reference má offset 0); směr i velikost se mění
s fotkou, takže pevná korekce nejde. Graf proto před složením volá
`TsumikiAlignToReference` (`comfyui_nodes/ComfyUI-Tsumiki`): SIFT shody jen
mimo masku (tvář, oblečení), RANSAC similarity, warp zpět; bez dost shod nebo
s nevěrohodným měřítkem (> 15 %) projde obraz beze změny a node to zaloguje.
Po zarovnání zbývá 0–2 px. Pruh zmizel; zůstává drobný šev u ramen, kde spodní
hrana masky protíná tričko, které Kontext přegeneroval.

Kolo 2 (`out/hair-r2`, `out/hair-colours-r2`) měří se zarovnaným grafem všech
65 kandidátů (14 nových: hime cut, box/dutch/french/crown braids, space buns,
sleek bun, side undercut, hollywood waves, mohawk, spiky, cornrows, twists,
long curly) na třech předlohách na skupinu a 19 barev včetně nových módních
(fox red, hot pink, violet, pastel/electric blue, teal) na třech předlohách.

Gate je od tohoto kola **per appka**: Tsumiki bere, co prošlo na jeho
`HAIR_ENGINE` (Kontext), Ol1nLLM dál jen to, co prošlo na Kontextu i SDXL
(`export_catalog.py --engines` / `--ol1nllm-engines`, verdikt může být mapa
engine → verdikt).

### Výsledky kola 2 (2026-09-15)

390 buněk účesů (65 × 2 enginy × 3 předlohy) a 114 buněk barev (19 × 2 × 3),
vše dorenderované (běh spadl 14. 9. s ComfyUI a dojel 15. 9. přes `--resume`
s opraveným hlídačem v `comfysync.py`). Verdikty v `tgbot/tools/bench/verdicts.json`
(mapa engine → verdikt), práh stejný jako v kole 1 (≥ 2/3 buněk), ale teď má
každý účes tři buňky na engine, takže 2/3 opravdu znamená dvě ze tří předloh.

**Tři předlohy místo jedné změnily obraz kola 1.** Z osmi účesů kola 1 přežil
na Kontextu jen `face-framing`; zbytek padá na `recognised` (CLIP styl nepozná
na jedné ze tří předloh — kolo 1 mělo jednu, a tu příznivou), `curtain-bangs`
navíc na identitě (min 0.39). Nebyla to regrese zarovnání: `beach-waves`,
`m-skin-fade` a `m-quiff` padají stejně i na SDXL, který se nezarovnává.

| účes z kola 1 | Kontext | SDXL |
|---|---|---|
| Curtain Bangs (`curtain-bangs`) | fail: identity 0.39, recognised 33% | pass |
| Long Bob (Lob) (`lob`) | fail: recognised 33% | pass |
| French Bob (`french-bob`) | fail: identity 0.38, recognised 33% | pass |
| Face-Framing Layers (`face-framing`) | pass | pass |
| Beach Waves (`beach-waves`) | fail: recognised 33% | fail: recognised 33% |
| Soft Curls (`soft-curls`) | fail: recognised 33% | pass |
| High Skin Fade (`m-skin-fade`) | fail: recognised 0% | fail: recognised 33% |
| Quiff (`m-quiff`) | fail: recognised 33% | fail: recognised 33% |

**Do obou appek** (Kontext i SDXL — gate Ol1nLLM):

| účes | Kontext | SDXL |
|---|---|---|
| Box Braids (`box-braids`) | pass | pass |
| Crown Braid (`crown-braid`) | pass | pass |
| Dutch Braids (`dutch-braids`) | pass | pass |
| Face-Framing Layers (`face-framing`) | pass | pass |
| Cornrows (`m-cornrows`) | pass | pass |
| Man Bun (`m-man-bun`) | pass | pass |
| Spiky Hair (`m-spiky`) | pass | pass |

| barva | Kontext | SDXL |
|---|---|---|
| Auburn (`auburn`) | pass | pass |
| Blue black (`blue-black`) | pass | pass |
| Burgundy (`burgundy`) | pass | pass |
| Copper red (`copper-red`) | pass | pass |
| Fox red (`fox-red`) | pass | pass |
| Honey balayage (`honey-balayage`) | pass | pass |
| Jet black (`jet-black`) | pass | pass |
| Pastel pink (`pastel-pink`) | pass | pass |

**Navíc do Tsumiki** (jen Kontext — `HAIR_ENGINE`):

| účes / barva | Kontext | SDXL |
|---|---|---|
| Buzz Cut (`m-buzz`) | pass | fail: recognised 33% |
| Crew Cut (`m-crew`) | pass | fail: recognised 33% |
| Top Knot (Undercut) (`m-top-knot`) | pass | fail: recognised 0% |
| Ash blonde (`ash-blonde`) | pass | fail: colour_ok 0% |
| Electric blue (`electric-blue`) | pass | fail: colour_ok 0% |
| Honey blonde (`honey-blonde`) | pass | fail: colour_ok 0% |
| Hot pink (`hot-pink`) | pass | fail: colour_ok 0% |
| Lavender (`lavender`) | pass | fail: colour_ok 33% |
| Platinum blonde (`platinum-blonde`) | pass | fail: colour_ok 0% |
| Silver grey (`silver-grey`) | pass | fail: colour_ok 0% |
| Mermaid teal (`teal`) | pass | fail: colour_ok 33% |

Jen na SDXL (do žádné appky — Tsumiki jede na Kontextu):

`blunt-bangs`, `bob`, `curtain-bangs`, `french-bob`, `french-braid`, `hollywood-waves`, `lob`, `m-caesar`, `m-curly-fade`, `m-shag`, `m-textured-fringe`, `m-twists`, `m-two-block`, `messy-bun`, `pixie`, `sleek-bun`, `soft-curls`, `space-buns`, `top-knot`, `chocolate-brown`

Katalogy: Ol1nLLM 7 účesů + 8 barev (bylo 8 + 4), Tsumiki 10 účesů + 16 barev.
Co v kole 1 prošlo a teď ne, z katalogů odešlo — jedna buňka na engine
byla „projde/neprojde“ z jedné fotky, a to je slabší doklad než tři.
Copánky (box, dutch, crown, cornrows) prošly napříč: mají jasnou siluetu,
kterou CLIP na každé předloze pozná. Nejčastější důvod pádu zůstává
`recognised` — sousední střihy (bob/lob/blunt) pro CLIP splývají, jak už
ukázalo kolo 1.
