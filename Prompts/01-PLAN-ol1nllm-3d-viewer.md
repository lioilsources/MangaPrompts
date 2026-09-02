# PLAN — Ol1nLLM: 3D viewer v appce (img → STL → 360° náhled)

> Stav: **IMPLEMENTOVÁNO 2026-08-16** (čeká na release v1.3.0 + device
> ověření: viewer na iOS — GLB jako base64 data URI; follow test = zabít
> appku uprostřed 3D jobu, po otevření se má výsledek dotáhnout).
> Odchylky od plánu: resume je history-nezávislý (deterministické cesty
> `3D/app/<meshId>` — followMesh nejdřív zkusí stáhnout hotové soubory);
> mesh soubory se jmenují podle node id; unload modelu zatím ručně
> (restart služby), auto-unload odloženo.
> Týká se repa `/Volumes/YOTTA/Dev/Ol1nLLM` (Flutter appka, v1.2.4)
> a ComfyUI na SPARKu. Uloženo sem do Prompts/ na přání — k tématu se
> vracíme později.

## Cíl

Z dlaždice obrázku v Image Studiu spustit img→3D generování na SPARKu
a výsledek zobrazit **přímo v appce jako 3D model s 360° otáčením**
(jedna barva stačí). STL sdílet ven (AirDrop/Files → Prusa Slicer).

## Co už existuje (hotové podklady, 2026-08-16)

- **Server pipeline funguje end-to-end**: Trellis2 (TRELLIS.2-4B, 16 GB)
  na SPARKu; ukázkové workflow
  `/home/ol1n/Code/ComfyUI/user/default/workflows/img2print-anime.json`
  (UI formát) + otestovaný **API formát** v scratchpadu session
  (znovu vygenerovatelný — graf je popsán níže)
- Ověřený výstup: watertight STL, 300k faces, `target_height_mm=100`,
  Z-up (`reorient_vertices=None`); GLB preview (Y-up, `90 degrees`)
- Klíčové gotchas v memory `spark-3d-print-pipeline`:
  Meshlib (ne Cumesh) na simplify + FillHolesWithMeshlib za ním;
  PreProcessImage má vestavěný rembg; LoadModel backend=sdpa,
  conv_backend=flex_gemm; server má `--cache-none` → běh ~7 min
- Graf (API): LoadModel → LoadImageWithTransparency(__IMAGE__) →
  PreProcess(rembg) → ImageCond → Sparse(25) → Shape512(25,heun) →
  Cascade→1024(12) → TexSlat(12, jen kvůli coords) → DecodeLatents →
  FillHolesCuMesh → VoxelToMesh(100mm, taubin20) → Simplify(300k,
  **Meshlib**) → FillHolesMeshlib → PostProcess2(dedup+weld) →
  ToTrimesh(None)→Export **stl** / ToTrimesh(90°)→Export **glb**

## Architektura změny (Ol1nLLM)

```
dlaždice obrázku → nová akce „3D“ (ikona kostky, vedle ✨)
  → comfyui_service: nový job typ (asset flux… ne — trellis workflow
    s __IMAGE__ sentinelem, stejný template systém jako inpaint assety)
  → progress přes stávající _run (WebSocket/poll, follow po restartu)
  → stáhnout GLB + STL z output/3D přes GET /view
  → GenNode.glbFileName/stlFileName (vzor maskFileName — nullable,
    bez Hive migrace)
  → Model3DViewerScreen: model_viewer_plus (GLB, orbit 360°, 1 barva)
    + tlačítko „Sdílet STL“ (share_plus → AirDrop/Files → Prusa)
```

## Úkoly

1. **Asset**: `assets/comfyui/img2print.api.json` — API graf výše
   s `__IMAGE__` sentinelem (zdroj: otestovaná verze; případně
   regenerovat z UI workflow na serveru)
2. **comfyui_service**: metoda `generate3D(image)` — upload obrázku,
   patch sentinelu, queue, poll; **outputs nejsou images** —
   `Trellis2ExportMesh` vrací cesty (zjistit přesný tvar v history
   outputs a stáhnout přes /view s subfolder=3D); po dokončení zavolat
   unload (Trellis2UnloadAllModels přes malý API graf, nebo aspoň
   doporučit v UI) — 16GB model nesmí zůstat blokovat FLUX/SDXL
3. **GenNode**: `glbFileName`, `stlFileName` (+ toJson/fromJson/copyWith,
   vzor `maskFileName` z v1.2.x)
4. **Provider**: akce `make3D(imageId)` — nový node ve stromu (dítě
   zdrojového obrázku, badge kostky), follow/retry vzor jako inpaint
5. **UI**: akce na dlaždici; `Model3DViewerScreen` — závislost
   `model_viewer_plus` (WebView wrapper <model-viewer>, GLB orbit);
   share STL přes `share_plus`; progress banner zvládne ~7min job
   (indeterminate + elapsed, existuje z NIM)
6. **Testy**: sentinel/patch test na nový asset (vzor
   `inpaint_prepare_test.dart`); GenNode round-trip
7. **Release jako v1.3.0** (nová kapitola, ne patch) — standardní
   flow: commit → bump → tag → CI → TestFlight

## Otevřené otázky (rozhodnout při implementaci)

- Výška figurky: fixně 100 mm, nebo slider v UI před spuštěním?
- Unload 16GB modelu: automaticky po každém jobu (další 3D job pak
  načítá znovu ~2 min), nebo tlačítko/timeout?
- Zobrazit v treeview 3D node jako co — thumbnail není (GLB render
  na thumbnail = netriviální); ikona kostky stačí?
- `model_viewer_plus` vs `flutter_3d_controller` — ověřit na iOS 26

## Verifikace

- unit: 65+ testů zůstává zelených; nový asset test
- device: vygenerovat obrázek → „3D“ → ~7 min → otáčení v appce,
  share STL → otevřít v Prusa Slicer (100 mm, stojí, watertight)
- server po jobu: RAM se vrátí (unload funguje)

## Odhad

Rozsah ≈ mask editor (M4): backend+model ~2 h, viewer+UI ~2-3 h,
testy+release ~1 h. Server beze změn.
