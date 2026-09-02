> Stav: **IMPLEMENTOVÁNO 2026-08-21** v Ol1nLLM (commity 6813477 feat + 3752756 bump v1.5.0).
> Čeká na ověření na zařízení (checklist dole) a tag/release.

# PLAN — Image Studio: Repose (nová postava ve stejné póze)

## Context

MangaPrompts má „Repose mode": fotka tváře + **předpřipravená depth šablona
pózy** + prompt → IPAdapter + InstantID + depth ControlNet + hi-res +
FaceDetailer (`assets/comfyui/sdxl_repose_hires_stable.api.json`). Cíl v
Ol1nLLM je jiný a jednodušší: **referenční obrázek postavy (libovolná
dlaždice ve stromu) se převede na depth mapu a na ni se aplikuje úplně nový
prompt** — póza/silueta zůstane, postava i styl se přegenerují.

Rozhodnuto s uživatelem: **jen depth** (bez přenosu identity), **jen base
pass** (bez hi-res/FaceDetaileru), **režim v input baru** (vzor refine, ne
samostatný sheet).

Klíčové zjištění: Ol1nLLM už má `_injectSourceDepthControlNet()`
(DepthAnythingV2 → union-promax-xinsir, type depth), ale jen pro img2img
(VAEEncode zdroje, denoise 0.72, strength 0.7). Repose = **txt2img šablona
`sdxl_txt2img.api.json` (EmptyLatentImage, denoise 1.0) + tatáž depth
injekce ze zdrojového obrázku**. Jediný blokátor je podmínka
`sourceDepth && imageName != null` v `_prepare()`
(`lib/services/comfyui_service.dart:1022`). Žádný nový workflow JSON není
potřeba. Server má všechny nody (ověřeno přes `/object_info`:
`DepthAnythingV2Preprocessor`, `SetUnionControlNetType`,
`controlnet-union-sdxl-promax-xinsir.safetensors`).

Parametry převzaté z ověřeného MangaPrompts workflow (depth → txt2img,
denoise 1.0 na témže serveru): **strength 0.75, end_percent 0.9**.
Stávající img2img auto-depth (0.7 / 1.0) se nemění.

---

## Architektura změny

```
dlaždice → ikona Repose (pravý horní roh, Icons.directions_walk)
  → provider.startRepose(imageId): state.reposeSourceImageId (transientní,
    nepersistuje se; vylučuje se se selectedImageId), auto-switch na SDXL model
  → input bar v režimu Repose: pill s miniaturou reference + ✕, hint
    „Popiš novou postavu v této póze…", PoseChip skrytý, ModelChip needsPose
  → provider.repose(prompt): nový child GenNode(isRepose: true,
    sourceImageId: reference), prompt se NEŘETĚZÍ (_chainedPrompt se nevolá,
    stejné pravidlo jako inpaint), positivePrefix + negativy jako obvykle
  → _comfyui.repose(image, prompt, n, seed, negative, latentSize):
    upload reference → _prepare(txt2img tpl, depthImageName: ref,
    latentSize: bucket podle poměru stran reference) → _run(wf)
  → progress/resume/retry přes stávající _runAsync; resume přes
    _comfyui.follow (ne _backend.follow — vzor is3D/followMesh)
```

---

## Kroky (soubor po souboru)

### 1. `lib/models/latent_bucket.dart` (nový, čistá logika, testovatelný)

Depth hint má poměr stran reference; `ControlNetApplyAdvanced` hint na latent
center-cropuje, takže 2:3 fotka na 1024² latentu přijde o hlavu/nohy. Proto
latent odvodit z reference:

- `typedef LatentSize = ({int w, int h});`
- `const kSdxlBuckets` = 1024×1024, 896×1152, 1152×896, 832×1216, 1216×832,
  768×1344, 1344×768.
- `LatentSize snapToSdxlBucket(int w, int h)` — nejbližší bucket podle
  `|ln(w/h) − ln(bw/bh)|` (symetrické pro 2:3 a 3:2).
- `LatentSize? decodeImageSize(Uint8List bytes)` — **jen hlavička**, bez
  dekódování pixelů: `PngDecoder().startDecode(bytes) ??
  JpegDecoder().startDecode(bytes)` (z `package:image`, už závislost).
  Foto rooty z image_picker jsou **JPEG bajty pod `.png` jménem**, takže PNG-only
  by vracel null pro každou fotku. try/catch → null.
- `LatentSize reposeLatentFor(Uint8List ref, {required LatentSize fallback})`
  — `snapToSdxlBucket(decodeImageSize(ref) ?? fallback)`.

### 2. `lib/services/comfyui_service.dart`

- Konstanty vedle `_depthStrength` (~ř. 93):
  `_reposeDepthStrength = 0.75`, `_reposeDepthEndPercent = 0.9` + komentář
  proč ne 1.0 (při plné síle celého schedule se zapeče objem těla / vlasy /
  oblečení z reference a pere se s novou postavou; posledních 10 % kroků bez
  hintu nechá dosednout detaily; pokud by póza ujížděla, nejdřív zkusit 0.85).
- `_spliceControlNet(..., {double endPercent = _poseEndPercent})` → zapisuje
  `'end_percent': endPercent`. Stávající volající beze změny.
- `_injectSourceDepthControlNet(wf, name, {double strength = _depthStrength,
  double endPercent = _poseEndPercent})` → forwarduje do splice.
- `_prepare()` (+ `prepareForTest()` — **musí forwardovat oba nové parametry**,
  jinak testy projdou naprázdno):
  - nové `String? depthImageName` (explicitní zdroj depth hintu, nezávislý na
    `imageName`) a `({int w, int h})? latentSize`.
  - Injekce (nahrazuje ř. 1020–1024), explicitní depth má přednost, takže
    šablona pózy v repose nikdy nevyhraje:
    ```dart
    if (depthImageName != null) {
      _injectSourceDepthControlNet(wf, depthImageName,
          strength: _reposeDepthStrength, endPercent: _reposeDepthEndPercent);
    } else if (poseImageName != null) {
      _injectPoseControlNet(wf, poseImageName);
    } else if (sourceDepth && imageName != null) {
      _injectSourceDepthControlNet(wf, imageName);
    }
    ```
  - Latent (ř. 1051–1053): `latentSize?.w ?? (poseImageName != null ?
    kPoseWidth : preset.width)` (dtto height).
  - Denoise (ř. 1067–1071) **beze změny** — repose nepředává `imageName`,
    takže vychází 1.0 samo.
- Nová veřejná metoda (vzor `generateMesh`, **ne** na `ImageBackend` — NIM
  backendy to neumí):
  ```dart
  Stream<GenEvent> repose({
    required Uint8List image, required String prompt, required int n,
    required int seed, String? negativePrompt, ({int w, int h})? latentSize,
  }) async* {
    if (_preset.ckptName == null) { yield GenFailed('[ComfyUI] Repose umí jen SDXL modely.'); return; }
    final refName = await _uploadImage(image, filename: 'repose_${_uuidV4()}.png');
    final tpl = await _template(_txt2imgAsset);
    final wf = _prepare(tpl, prompt: prompt, batch: n, seed: seed,
        depthImageName: refName,
        latentSize: latentSize ?? reposeLatentFor(image, fallback: (w: _preset.width, h: _preset.height)),
        userNegative: negativePrompt);
    yield* _run(wf);
  }
  ```
  Nevolá `_ensurePoseUploaded`, nepředává `poseImageName`. Resume = stávající
  `follow(jobId)` (`_run(null, promptId:)`), nic nového.

### 3. `lib/models/gen_node.dart` — flag `isRepose` (přesný vzor `is3D`)

Field `final bool isRepose` (default false), param v `create()`,
`if (isRepose) 'isRepose': true` v `toJson`, `json['isRepose'] as bool? ??
false` ve `fromJson`, passthrough v `copyWith` (vedle ř. 343). Staré Hive
sessions validní bez migrace. `finetune_export_service.dart` serializuje přes
`node.toJson()` genericky → **bez změny**.

Snapshot metadat repose nodu: modelId, loraName, `poseId: null`, seed,
negativePrompt (preset + user), positivePrefix, width/height = bucket,
steps/cfg/sampler/scheduler z presetu, `denoise: 1.0`.

### 4. `lib/providers/image_studio_provider.dart`

- `ImageStudioState`: `final String? reposeSourceImageId` (default null, aby
  `const` konstrukce v `newSession`/`selectSession`/`deleteSession`/`_load`
  zůstaly a režim tím automaticky spadl), `copyWith(reposeSourceImageId,
  bool clearRepose = false)`. Veřejný `GenImage? imageById(String? id)` na
  state (notifier `_imageById` deleguje) — input bar potřebuje miniaturu.
- Vzájemné vyloučení: `selectImage()` → `clearRepose: true`; `navigateTo()` →
  `clearRepose: true`; `startRepose()` → `clearSelected: true`.
- `startRepose(String imageId)`: když `!state.model.supportsPose`, přepnout
  na naposledy použitý SDXL model v session (`state.nodes.reversed` podle
  `modelId`, jinak první z `availableModels.where(supportsPose)`) přes
  `setModel()` + `info` snackbar „Přepnuto na X — repose umí jen SDXL
  modely."; žádný kandidát → `error`. Pak nastavit `reposeSourceImageId`.
- `cancelRepose()` → `clearRepose`.
- `repose(String prompt)`: vzor `make3D()` + `generate()`:
  `splitPromptNegatives`, `_newSeed()`, `latent = reposeLatentFor(base.bytes,
  fallback: preset w/h)`, `_createNodeWithMeta(parentId: currentNodeId,
  sourceImageId: base.id, isImg2img: false, isRepose: true, latentSize:
  latent, userNegative: …)`, state s `clearSelected + clearRepose`,
  `_runAsync(node.id, () => _comfyui.repose(image: base.bytes, prompt:
  parts.positive, n: _comfyui.variantCount, seed, negativePrompt, latentSize:
  latent))`. **Bez `_chainedPrompt`.**
- `_createNodeWithMeta`: nové `bool isRepose = false`, `({int w,int h})?
  latentSize`; `poseId = (isInpaint || isRepose) ? null : selectedPoseId`;
  width/height pro repose = `latentSize`; `isRepose` do `GenNode.create`.
- `retry()`: nová větev `if (node.isRepose)` **před** generickou cestou (ta má
  `isImg2img: !node.isRoot` + `_backend.edit` → udělala by z retry řetězený
  img2img s auto-depth 0.7). Guard `supportsPose` (jinak error node „Repose
  umí jen SDXL modely — vyber jiný model."), `base == null` → „Source image
  gone", jinak refresh snapshotu + `_comfyui.repose(...)` s novým seedem.
- `_resumeInFlightJob()`: `node.isRepose ? _comfyui.follow(jobId) :
  backend.follow(jobId)` — `_backend` je backend **aktuálně vybraného**
  modelu a ModelChip není při `isBusy` zamčený; 3D to řeší stejně přes
  `followMesh`.
- `_runAsync`, `cancel()`, `fail()`: beze změny (standardní clear-jobId-on-
  failure, **ne** 3D `keepJobId` logika).

### 5. `lib/screens/image_studio_screen.dart`

- `_ImageTile`: `VoidCallback? onRepose`; když non-null, 5. tlačítko
  `Positioned(top: 4, right: 4)` s `Icons.directions_walk` (stejný
  Material/InkWell kroužek jako ostatní). **Ne** do spodní řady na
  `right: 148` — na 375 pt displeji (SE/mini) je dlaždice 169,5 px a pátá
  ikona by přetekla. `Icons.accessibility_new` už používá `_PoseChip`, proto
  jiná ikona.
- `_NodeGrid.build`: `canRepose = state.availableModels.any((m) =>
  m.supportsPose)`; `onRepose: canRepose ? () =>
  notifier.startRepose(img.id) : null`. Bez potvrzovacího dialogu (režim je
  vratný přes ✕).
- `_StudioInputBarState`:
  - `_isReposeMode => state.reposeSourceImageId != null`; `_hint` → „Popiš
    novou postavu v této póze…" (před refine větví).
  - `didUpdateWidget`: při přechodu null→non-null `_focusNode.requestFocus()`.
  - `_send()`: první větev `if (_isReposeMode)` — guard `spec.supportsPose`
    (snackbar „Repose umí jen SDXL modely — vyber jiný model."), clear,
    `notifier.repose(text)`.
  - Chips row: `_ModelChip(needsPose: _isReposeMode, …)`; `_PoseChip` jen
    `if (spec.supportsPose && !_isReposeMode)`.
  - Repose pill (místo řádku s node promptem): accent-tinted kontejner,
    `Image.file(ref.filePath, 28×28, cacheWidth: 56)` + text „Repose — nová
    postava ve stejné póze" + `IconButton(Icons.close)` →
    `cancelRepose()`. Reference přes `state.imageById(...)`; když null,
    nic nerenderovat.
- `_ModelChip`: `required bool needsPose`; `_isUsable` přidá `&& !(needsPose
  && !spec.supportsPose)`; hint „… — repose umí jen SDXL".
- `_TreeNodeWidget` (ř. 493): predikát `node.maskFileName == null &&
  !node.isRepose ? kroužek : Stack(badge)`; ikona `node.isRepose ?
  Icons.directions_walk : Icons.auto_fix_high`; tap badge pro repose no-op
  (rodičovský kroužek už zobrazuje referenci přes `displayImageId =
  currentNode.sourceImageId`, ř. 635–636).
- `_ProgressBanner`: beze změny (zobrazuje `node.prompt` = nový prompt).

### 6. Testy

- `test/controlnet_injection_test.dart`, nová group „repose" přes
  `prepareForTest(_txt2img(), depthImageName: 'ref.png', latentSize: (w: 832,
  h: 1216), …)`:
  1. depth chain: `__depth_src__` LoadImage `image == 'ref.png'`,
     `DepthAnythingV2Preprocessor.image == ['__depth_src__', 0]`,
     `SetUnionControlNetType.type == 'depth'`, ControlNetLoader obsahuje
     `union`;
  2. `ControlNetApplyAdvanced`: strength 0.75, start 0.0, **end 0.9**;
     sampler positive/negative = `['__cn_apply__', 0/1]`;
  3. `KSampler.denoise == 1.0`, žádný `VAEEncode`, v `jsonEncode(wf)` nezbyl
     `__IMAGE__`;
  4. `EmptyLatentImage` width 832 / height 1216 / batch_size == batch;
  5. šablona pózy ignorována: s `poseImageName: 'skeleton.png'` → žádný
     openpose ControlNetLoader, právě jeden `ControlNetApplyAdvanced` čtoucí
     `['__depth_pre__', 0]`;
  6. kompozice s LoRA: `setLora(...)` → `__lora__` přítomný, žádná visící
     hrana (helper `_allEdges` z `lora_injection_test.dart`);
  7. regrese: stávající img2img sourceDepth test navíc assertuje strength
     0.7 a end_percent 1.0; „txt2img never gets source depth" zůstává
     (depthImageName null);
  8. positivePrefix + preset negativ + userNegative se stále skládají.
- `test/latent_bucket_test.dart` (nový): snap 1024²→1024², 512×768→832×1216,
  768×1024→896×1152, 1024×768→1152×896, 720×1280→768×1344,
  1280×720→1344×768, 1000×1010→1024²; `decodeImageSize` na
  `encodePng(Image(3×5))` → (3,5), `encodeJpg` → (w,h), garbage → null,
  `reposeLatentFor(garbage, fallback 1024²)` → 1024².
- `test/repose_node_test.dart` (nový, vzor `mesh_3d_test.dart`): round-trip
  `isRepose: true`, legacy JSON bez klíče → false, `copyWith` zachová flag,
  non-repose node nemá klíč.
- `test/image_studio_state_test.dart`: `reposeSourceImageId` přežije
  nesouvisející `copyWith`, `clearRepose` nuluje, `clearSelected` ho nechá,
  default null.

### 7. Dokumentace + verze

- `CLAUDE.md`: odstavec **„Repose (nová postava ve stejné póze)"** hned za
  „Auto póza ze zdroje (img2img)": txt2img šablona + `depthImageName`, denoise
  1.0, strength 0.75 / end 0.9 a proč, latent bucket podle reference
  (`latent_bucket.dart`), prompt se neřetězí, šablona pózy se ignoruje,
  `GenNode.isRepose`, resume přes `_comfyui.follow`, retry přes `repose()`,
  jen SDXL (`supportsPose`), `reposeSourceImageId` transientní.
- Commity podle konvence: `feat: Image Studio — Repose: nová postava ve
  stejné póze (depth ControlNet)` → `chore: bump v1.5.0` (nová kapitola,
  jako 1.3.0 pro 3D a 1.4.0 pro nové modely; teď 1.4.4).
- Volitelně (zvyk z 3D vieweru): kopii tohoto plánu uložit do
  `/Volumes/YOTTA/Dev/MangaPrompts/Prompts/02-PLAN-ol1nllm-repose.md`.

---

## Rizika / gotchas

1. `prepareForTest` musí forwardovat `depthImageName` i `latentSize`.
2. `retry()` větev `isRepose` musí být **před** generickou cestou.
3. Resume přes `_comfyui.follow`, ne `_backend.follow` (model lze přepnout
   během běhu).
4. Velikost z hlavičky: PNG **i** JPEG (foto rooty jsou JPEG pod `.png`).
5. Latent override není kosmetický — bez něj se depth hint center-cropne.
6. Auto-switch modelu v `startRepose` zahodí FLUX LoRA (stejně jako inpaint
   flow) — `info` snackbar to zviditelní.
7. Badge ve stromu: stávající `maskFileName == null ? … : …` musí dostat
   kombinovaný predikát.

## Verifikace

- `flutter analyze` čistý; `flutter test` — nové i stávající testy
  (`controlnet_injection`, `lora_injection`, `inpaint_prepare`, `mesh_3d`,
  `image_studio_state`, `image_model`) zelené.
- Na zařízení (`make debug`):
  1. SDXL model aktivní → Repose na dlaždici → pill s miniaturou, refine výběr
     zrušen, PoseChip skrytý, klávesnice fokus; ✕ zruší.
  2. flux-manga / FLUX Schnell aktivní → Repose → auto-switch snackbar, model
     picker šedí ne-SDXL s hintem.
  3. Prompt s ALL-CAPS negativy → child node, rodičovský kroužek ukazuje
     referenci, progress banner; výsledek drží pózu, nová postava, poměr
     stran = bucket (ověřit `width/height` v FINETUNE manifestu).
  4. Portrétní foto root (JPEG) → 832×1216 / 896×1152, bez oříznutých končetin.
  5. Vybraná šablona pózy + LoRA → repose pózu ignoruje (`poseId` null), LoRA
     aplikovaná (log `[comfy] POST /prompt`).
  6. Zabít appku uprostřed jobu → relaunch → dotáhne přes `_comfyui.follow`;
     zopakovat po přepnutí modelu na FLUX Schnell před zabitím.
  7. Retry na failed repose nodu: s SDXL znovu běží (nový seed); po přepnutí
     na flux-manga → error „Repose umí jen SDXL modely".
  8. `navigateTo` / nová session / výběr session → režim repose zmizí.
  9. FINETUNE export → manifest má `"isRepose": true`, `width/height`,
     `denoise: 1.0`, bez `poseId`.
