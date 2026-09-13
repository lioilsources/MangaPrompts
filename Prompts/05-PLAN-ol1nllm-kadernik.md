# PLAN — Ol1nLLM: Kadeřník v Image Studiu (dlaždice → účes → tatáž fotka)

> Pro Opuse. Repo `/Volumes/YOTTA/Dev/Ol1nLLM` (Flutter, v1.16.0, branch
> `main`), ComfyUI na SPARKu. **Předpokládá hotový gate z
> `04-PLAN-kadernik.md` §5** — registr účesů se plní jen přeživšími; do té
> doby jde implementovat všechno kromě obsahu `kHairstyles` (a lab flow
> `hair` je naopak nástroj, kterým se gate v Ol1nLLM opakuje).

## Co už v Ol1nLLM je (a proto je tahle část malá)

- **Inpaint** s maskou z editoru (`MaskEditorScreen`), modely s `inpaint:
  true`: `flux-fill` (`flux_fill_inpaint*.api.json`, Fill + Redux ref +
  PuLID face) a SDXL rodina (`sdxl_inpaint*.api.json`, Fooocus patch).
  `ImageStudioNotifier.inpaint(prompt, maskPng, {refPng, refIsFace})`
  (`image_studio_provider.dart:1090`) ukládá masku vedle obrázků
  (`GenNode.maskFileName`), retry ji znovu posílá, strom má badge.
- `ComfyUIService._prepare` umí `__MASK__`/`__REF__`, `_run` stahuje
  **všechny** výstupy promptu (`_downloadOutputs`, `GenComplete(images)`).
- `latent_bucket.dart` už závisí na `package:image` (^4.8.0) — dekódování
  PNG masek v Dartu je k dispozici.
- Lab (`tools/lab`) dumpuje workflow přes `prepareForTest`, umí
  `--styles-file` kandidáty, resume, baseline; skórování histogramem.
- `tools/facebench` (ArcFace) běží na SPARKu v `~/Code/facebench`.

Kadeřník je tedy: **automatická maska + katalog + jedno tlačítko**, které
nakonec zavolá stávající `inpaint()`.

---

## Architektura

```
dlaždice → ikona Účes (Icons.content_cut) → HairSheet (Ženy/Muži, sekce, hledání)
  → notifier.hairRestyle(imageId, hairstyleId):
      1. _comfyui.analyseHair(bytes)  →  HairAnalysis{hair, face, hat}  (graf hair_analyse, ~3 s, bez kreditu)
      2. buildHairMask(analysis, shape)  (lib/models/hair_mask.dart — port tgbot/hairmask.py)
         chyby: NoFace / FaceTooSmall / MaskTooSmall → state.error, nic se negeneruje
      3. colour = estimateHairColour(rgb, hair)
      4. model: když state.model.inpaint == false → přepnout na 'flux-fill' (info snackbar, vzor startRepose)
      5. inpaint(hairPrompt(style, colour), maskPng, hairstyleId: id)  — stávající cesta, PuLID vypnutý
  → node s maskFileName + hairstyleId; retry/resume/export beze změny
  volitelně: „Upravit masku" → MaskEditorScreen s předvyplněnou maskou
```

---

## Kroky

### 1. Assety

- `assets/comfyui/hair_analyse.api.json` — **kopie** z MangaPrompts
  (`04-PLAN` §1), beze změn; zaregistrovat v `pubspec.yaml` assets, pokud
  se nelistuje adresářem.
- Žádný nový inpaint graf: použije se `flux_fill_inpaint.api.json`
  (bez ref/face) a `sdxl_inpaint.api.json`. Jediná úprava:
  `InpaintCropImproved.context_from_mask_extend_factor` 1.2 → **1.5**
  (víc kontextu = ramena i celá tvář; sjednotit s Tsumiki). Změna platí i
  pro ruční inpaint — ověřit v labu, že face inpaint (`flux_fill_inpaint_face`)
  se **nemění** (má vlastní soubor, číslo 0.72 se měřilo s 1.2).

### 2. `lib/models/hairstyle_preset.dart` (nový)

```dart
enum HairLength { keep, short, medium, long }
enum HairBangs { none, full, side, curtain, wispy }
class HairShape { const HairShape({required this.length, this.bangs = HairBangs.none, this.updo = false}); … }
class HairstylePreset { id, label, cs, group, section, block, shape }
const kHairstyles = <HairstylePreset>[ /* jen přeživší gate, id == Tsumiki */ ];
String hairPrompt(HairstylePreset s, String? colour) => 'a photo of the same person with a ${s.block}, ${colour ?? 'natural'} hair, natural hair texture, realistic strands, same lighting and background, photorealistic';
bool hairstyleMatchesQuery(HairstylePreset s, String q)  // bez diakritiky, jako styleMatchesQuery
```

Labely česky (appka je česká), `cs` z kandidátského JSONu jako label,
anglický `label` do tooltipu ne — stačí `block` jako podtitulek (vzor
pickeru stylů).

### 3. `lib/models/hair_mask.dart` (nový, čistá logika, testovatelný)

Port `tgbot/hairmask.py` 1:1 (stejné konstanty, stejné pořadí kroků):

- `class HairAnalysis { final Uint8List hair, face, hat; final int w, h; }`
  (bool masky jako `Uint8List` 0/1, `decodeMaskPng(bytes)` přes
  `package:image`, práh 128 na R kanálu).
- `Rect? faceBox(HairAnalysis)` (percentily 1/99).
- `HairMaskResult buildHairMask(HairAnalysis, HairShape)` → `Uint8List mask`
  + `faceBox` + `area`; výjimky `HairMaskError.noFace / faceTooSmall /
  maskTooSmall` s českým textem pro UI.
- `String? estimateHairColour(img.Image rgb, Uint8List hair)` — CIELAB
  průměr, stejné prahy jako Python.
- `Uint8List maskToPng(mask, w, h)` — bílá = přemalovat (formát, který
  `_inpaint` už posílá z editoru).

`test/hair_mask_test.dart`: **tytéž syntetické fixtury** jako
`tgbot/tests/test_hairmask.py` (elipsa tváře 100×130 v 512², půlkruh
vlasů) a tytéž asserty (short nepod bradu, long ≥ 2·fh, tvář nikdy
v masce, čelní pás jen u ofin, hat maskován, chyby, barvy). Do obou
souborů komentář „zrcadlo …/hairmask.py — měnit spolu".

### 4. `lib/services/comfyui_service.dart`

```dart
Future<HairAnalysis> analyseHair(Uint8List image) async {
  final name = await _uploadImage(image, filename: 'hair_${_uuidV4()}.png');
  final tpl = await _template('assets/comfyui/hair_analyse.api.json');
  final wf = _prepare(tpl, prompt: '', batch: 1, seed: 0, imageName: name);   // žádný sampler, žádný latent — _prepare musí projít bez KSampleru
  // spustit a počkat: _run(wf) → GenComplete(images) — 3 PNG; párovat podle filename prefixu
  //   (tsumiki_hair_mask / tsumiki_face_mask / tsumiki_hat_mask), ne podle pořadí
}
```

Pozor na `_prepare`: patch smyčka hledá `KSampler`/latent — na grafu bez
nich musí být no-op, ne výjimka (test `prepareForTest` na `hair_analyse`).
`_downloadOutputs` vrací `GenImage`/bytes bez jména → přidat jméno souboru
do výsledku (nebo interní variantu, která vrací `Map<String, Uint8List>`),
aby šlo párovat prefixem. Progress eventy pro analýzu se do stromu
nepromítají (běží před vznikem nodu) — provider ukáže jen `busy` overlay.

### 5. `lib/providers/image_studio_provider.dart`

- `Future<void> hairRestyle(String imageId, String hairstyleId)`:
  kroky z architektury. Model switch: když `!state.model.inpaint` →
  `setModel('flux-fill')` + `info` „Přepnuto na FLUX Fill — účes je
  inpaint." (vzor `startRepose`, zahodí LoRA stejně jako inpaint flow).
  Chyby masky → `state.copyWith(error: e.message)`. Pak
  `inpaint(prompt, maskPng, hairstyleId: id)`.
- `inpaint(...)`: nový volitelný `String? hairstyleId` → `_createNodeWithMeta`
  → `GenNode.hairstyleId`. Prompt se u inpaintu **neřetězí** a **styl se
  neaplikuje** (stávající pravidla) — sedí, účes je celý prompt.
- `retry()` inpaint větev: beze změny (maska persistovaná); jen ať
  `hairstyleId` přežije `copyWith`.
- `_adoptNodeSettings` / `adoptableSettings`: `hairstyleId` se **nepřebírá**
  (je to akce, ne nastavení).

### 6. `lib/models/gen_node.dart`

`final String? hairstyleId` (vzor `styleId`: v `create()`, `toJson` jen
když non-null, `fromJson`, `copyWith`). `finetune_export_service` jde přes
`toJson` → manifest ho dostane sám. `test/hairstyle_node_test.dart`:
round-trip, legacy JSON bez klíče, copyWith.

### 7. UI — `lib/screens/image_studio_screen.dart` + `lib/screens/hair_sheet.dart`

- `_ImageTile`: `VoidCallback? onHair` → ikona `Icons.content_cut`
  (umístění: vedle Repose vpravo nahoře je už jedna; dát ji **vlevo
  nahoře** `Positioned(top: 4, left: 4)` — spodní řada na 375 pt nemá
  místo, viz plán 02 §5). `_NodeGrid`: `canHair = state.availableModels.any((m) => m.inpaint)`.
- `HairSheet` (bottom sheet, vzor pickeru stylů): `SegmentedButton`
  Ženy/Muži, sekce, hledání (`hairstyleMatchesQuery`), podtitulek =
  `block`; výběr → `Navigator.pop(id)` → `notifier.hairRestyle(imageId, id)`.
  Klávesnici zavírat při tažení (`keyboardDismissBehavior`), pole se samo
  nefokusuje (stejná pravidla jako u stylů).
- Strom (`_TreeNodeWidget`): node s `hairstyleId` dostane badge
  `Icons.content_cut` místo `auto_fix_high` (predikát rozšířit, vzor
  `isRepose` z plánu 02 §5).
- Volitelné (levné, ale ne v prvním commitu): tlačítko „Upravit masku" v
  `HairSheet` po analýze → `MaskEditorScreen(initialMask: …)` — editor
  dostane nový volitelný parametr s předvyplněným tahem; pop vrátí masku a
  provider pokračuje krokem 5 s ní.

### 8. Lab — flow `hair` (nástroj pro opakování gate v Ol1nLLM)

Cíl: stejná matice účes × model × předloha × seed, kterou dělá
`tgbot/tools/bench`, ale postavená kódem **téhle** appky.

- `tools/lab/dump.dart`: nová flow `hair` — vyžaduje `HAIR_FILE`
  (kandidáti = **tentýž** `tgbot/tools/bench/candidates/hairstyles.json`, zkopírovaný
  do `tools/lab/candidates/hairstyles.json`) a `HAIR_MASKS_DIR`. Dump je bez
  GPU, takže masky musí existovat předem: nový příkaz `lab hairmasks --ref
  a.png,b.png` (Go volá malý Dart runner `tools/lab/hairmask.dart` přes
  `flutter test`, stejně jako `dump.dart`): pustí `hair_analyse` na SPARKu
  pro každou referenci, uloží `hair/face/hat` a přes `buildHairMask` vyrobí
  `<ref>/<shapeKey>.png` pro každý unikátní `shape` v kandidátech. Dump pak
  buňku staví `prepareForTest(inpaintAsset, imageName: ref, maskName:
  masks/<ref>/<shapeKey>.png, prompt: hairPrompt(cand, colour))` pro modely
  s `inpaint: true`. Baseline buňka = reference sama (bez generování).
- `tools/lab/cli.go`, `plan.go`: `--flows hair`, `--hair-file`, `--hair-masks`;
  `runner.go` uploaduje masku před promptem (vzor `--ref`).
- Skórování: lab má jen histogram. Hair metriky (ArcFace, délka, CLIP)
  dělá **Python scorer z MangaPrompts** (`tgbot/tools/bench/score.py`) —
  běží na SPARKu nad libovolným adresářem s `manifest.json` + PNG. `lab
  score --external metrics.json` tabulku jen zobrazí (sloupce `identity`,
  `length_ok`, `bangs_ok`, `recognised`). Nekopírovat scorer do Go.
- `tools/lab/README.md`: sekce „Účesy".

### 9. Dokumentace, verze, commity

- `CLAUDE.md`: sekce **„Kadeřník (auto maska + inpaint)"** za „Face inpaint":
  analýza grafem bez difuze, maska v Dartu (`hair_mask.dart` = zrcadlo
  `MangaPrompts/tgbot/hairmask.py`), barva z masky, `flux-fill` default,
  `GenNode.hairstyleId`, registr `kHairstyles` = jen gate-přeživší
  (`MangaPrompts/docs/hair-matrix.md`), lab flow `hair`.
- `pubspec.yaml` → **v1.17.0** (nová kapitola).
- Commity: `feat: Image Studio — Kadeřník: automatická maska vlasů + účes
  přes inpaint` → `feat(lab): flow hair` → `chore: bump v1.17.0`.

---

## Rizika / gotchas

1. `_prepare` na grafu bez `KSampler` — patch smyčka a `_samplerInputs`
   vracejí null; každé místo, které sampler *vyžaduje*, musí být gated.
2. Párování tří výstupů podle prefixu, ne pořadí — `hist['outputs']` je
   mapa podle node id, pořadí není garantované.
3. Model switch na `flux-fill` zahodí FLUX LoRA (stejně jako inpaint) —
   snackbar.
4. `context_from_mask_extend_factor` 1.5 mění i ruční inpaint — jeden
   lab běh na `sdxl_inpaint` před a po (stejný seed), ať se to nepřehlédne.
5. Dvě kopie masky (Dart/Python) — bez sdílených fixtur se rozejdou do
   měsíce. Fixtury jsou textové (rozměry + parametry elips), ne PNG, aby
   šly držet v obou testech doslova.
6. Analýza běží před vznikem nodu — zabití appky během ní nic nerozbije
   (nic se nepersistuje), ale UI musí mít `busy` stav, jinak jde klepnout
   dvakrát.

## Verifikace

- `flutter analyze`, `flutter test` (hair_mask, hairstyle_node,
  image_studio_state, controlnet_injection — regrese).
- `make lab-dry` s `--flows hair` vyrobí buňky s maskou; `lab hairmasks`
  proti SPARKu uloží tři masky + shape masky.
- Na zařízení (`make debug`): dlaždice → Účes → sheet → výběr → snackbar
  přepnutí na FLUX Fill (když byl SDXL/flux-manga) → node s badge nůžek →
  výsledek: tatáž tvář, nový účes, barva jako v předloze; retry funguje;
  zabít appku během generování → dotáhne; krajina → chyba „Na fotce není
  tvář", žádný node; FINETUNE export má `hairstyleId` a `maskFileName`.
