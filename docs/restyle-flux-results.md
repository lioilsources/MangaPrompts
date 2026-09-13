# Restyle na FLUXu + malíři — výsledky měření

Měřeno 2026-09-13 benchem `tgbot/tools/bench` proti ComfyUI na SPARKu.
Plán: `Prompts/03-PLAN-restyle-painters-flux.md` §1. Navazuje na
[`restyle-rollout-results.md`](restyle-rollout-results.md) (SDXL cesta, 09-09).

Předlohy (syntetické, `tgbot/tools/bench/srcs/`): `p-dancer` (celá postava,
výrazná póza, malá tvář), `w-bangs-3q` (portrét), `x-landscape` (bez tváře).
Styly: `ukiyoe` (kontrola z registru), `vangogh-arles`, `picasso-cubist`,
`hopper`, `mucha-slav-epic` + nestylovaná baseline. Seed 777.

## Sweep A — který FLUX unet (přerušeno po 3 buňkách)

| unet | póza | poznámka |
|---|---|---|
| `flux1-dev` (fp8) | drží | baseline na tanečnici vyšla **nahá** — viz níž |
| `flux1-dev-kontext_fp8_scaled` | **nedrží** | místo celé postavy detail obličeje; InstantX depth ControlNet je trénovaný na dev |

Rozhodnutí: **flux1-dev**. Zbytek sweepu A se zastavil, výsledek byl
jednoznačný už z baseline a dalších 25 buněk by stálo ~40 minut GPU.

### Nález: medium věta neříkala nic o oblečení

`a photorealistic photograph of a person, natural skin texture, …` + hloubková
mapa oblečené tanečnice dala na FLUXu nahou postavu. Hloubková mapa nese siluetu
těla, ne oblečení, a FLUX na cfg 1 negativ nečte. Stejná věta jede v produkci
na SDXL cestě (od 09-09), kde negativ nahotu nezmiňoval.

Oprava (commit `fc9224c`): medium věty v `lib/config/restyle_styles.dart`
říkají `a fully clothed person wearing the clothes from the photo`, negativ
SDXL začíná `nude, naked, nsfw`. Test `both media sentences keep the person
clothed` to hlídá. Stejné výrazy dostal negativ Kadeřníka (`hairprompt.py`).

## Sweepy B–E

_Doplní se po doběhnutí `out/restyle-b` … `out/restyle-e`._
