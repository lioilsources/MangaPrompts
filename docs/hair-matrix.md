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

## Kolo 1 — 51 kandidátů × 2 enginy

_Doplní se po doběhnutí běhu `out/hair-r1`._
