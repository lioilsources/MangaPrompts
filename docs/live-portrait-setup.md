# Živý portrét: instalace na SPARK

Stav: **nic z tohoto ještě neběželo.** `assets/comfyui/live_portrait.api.json`
je napsaný ze zdrojáků, ne proti serveru. Uzly ComfyUI-LivePortraitKJ na SPARKu
nejsou (žádný `LivePortrait*` v `/object_info`, `models/liveportrait` chybí);
`VHS_LoadVideo` a `VHS_VideoCombine` tam jsou, ale jejich revize není ověřená.

Všechno níž běží přes `spark-broker` (`sparkctl`), `deploy.sh --live-portrait`
restartuje ComfyUI.

## Instalace

```bash
COMFY_PYTHON=<python z venv ComfyUI> comfyui_nodes/deploy.sh --live-portrait
```

Skript udělá:

1. `custom_nodes/ComfyUI-LivePortraitKJ` na pinnuté revizi; VHS jen když chybí
   (stávající instalaci nehýbe).
2. `pip install pykalman` a kontrolu importů. **Ne** `pip install -r
   requirements.txt`: pinuje `numpy<=1.26.4` do venv sdíleného se všemi uzly.
   `mediapipe` a `onnx2torch` jsou potřeba jen pro MediaPipe cropper a jeho
   `torch_gpu` variantu, import MediaPipe je v uzlu v `try`.
3. Váhy `Kijai/LivePortrait_safetensors` bez `animal/` do `models/liveportrait`
   (včetně `landmark.onnx`, který potřebuje i InsightFace cropper).
4. `buffalo_l` do `models/insightface/models/buffalo_l`. README uzlu píše cestu
   bez `models/`; `FaceAnalysis` ale hledá `<root>/models/<name>`.
5. Čeká na prázdnou frontu, restartuje ComfyUI.

`COMFY_PYTHON` je cesta na SPARKu; bez něj se použije `python3`, což na boxu
s venv nemusí být ten správný. Ověř před spuštěním.

## Ověření

```bash
cd tgbot
python3 tools/check_workflow.py ../assets/comfyui/live_portrait.api.json --url http://192.168.88.66:8188
```

`check_workflow` zná dynamické inputy `format` u VHS (`crf`, `pix_fmt`, …)
z metadat `formats`. Hlásí-li něco, přizpůsob graf serveru, ne naopak.

Potom jeden ruční běh s reálnou fotkou a driverem. Co sledovat:

- `history.outputs[<id>].gifs[0].filename` = `tsumiki_live_00001.mp4`, `type:
  output`. Parser v `comfy.output_refs` je napsaný podle zdrojáku VHS; test
  `VHS_HISTORY` v `tests/test_comfy.py` je rekonstrukce, ne záznam.
- `VHS_LoadVideo` dostane jméno z `/upload/image`. Soubor leží přímo v `/input`.
- délka výstupu odpovídá driveru (25 fps), rozměr fotce.

## Odchylky grafu od plánu 09

Plán popisoval inputy jinak, než je má kód uzlu:

| plán | kód uzlu (revize 4d9dc62) |
|---|---|
| `relative_motion: true` | `relative_motion_mode: "relative"` |
| `driving_multiplier` | `delta_multiplier` |
| Cropper přímo do Process | `LivePortraitLoadCropper` → `LivePortraitCropper` → `crop_info` |

Bench sweep `driving_multiplier` proto cílí na `6.delta_multiplier`.

## Cropper a licence

Graf používá InsightFace (`LivePortraitLoadCropper`, `onnx_device: CPU`), protože
InsightFace na boxu už je. Modely InsightFace jsou **nekomerční**; README uzlu
to říká výslovně a Tsumiki se prodává. PuLID a InstantID stojí na antelopev2 se
stejnou licencí, takže to není nový druh rizika, ale je to rozhodnutí pro
majitele. Alternativa: `LivePortraitLoadMediaPipeCropper` (Apache 2.0), vyžaduje
`mediapipe`, horší detekce.

## Drivers

Mp4 v `assets/drivers/` zatím nejsou; dokud chybí, preset vrací 422 „motion not
available". Generování: `tgbot/tools/bench/drivers/README.md`.

Server nahrává driver do ComfyUI při prvním použití, ne při startu, jako
`tsumiki_driver_<motion>.mp4`. Po odmítnutém grafu ho zapomene a příště nahraje
znovu. Změněný driver se projeví po restartu služby.

Docker: `assets/drivers` je namountované do `/app/drivers` (`DRIVERS_DIR`).
