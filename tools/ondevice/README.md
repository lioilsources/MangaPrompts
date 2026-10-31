# On-device parser spike

Export, parity and timing of the face and clothes parsers for Restyler (plan 07
§1). Results and the gate decision: [`docs/ondevice-parity.md`](../../docs/ondevice-parity.md).

Models: `~/Code/ComfyUI/models/RMBG/segformer_face` on SPARK (SegFormer-B5, 19
classes, HF `1038lab/segformer_face`) and `segformer_clothes` (B2, 18 ATR classes).

| file | purpose |
|---|---|
| `export_parser.py` | safetensors -> `<name>.{fp32,fp16,int8,int8conv}.onnx`, `sizes.json` |
| `parity.py` | IoU: ComfyUI / PyTorch / ONNX / resize variants |
| `bench_time.py` | inference time in this Python ORT |
| `dart_resize/` | `parser_preprocess.dart`, the Dart preprocessing; `bin/resize.dart` dumps resize variants for `parity.py` |
| `probe/` | Flutter app running the whole path on a device |

```sh
python3 -m venv $VENV && $VENV/bin/pip install -r requirements.txt
$VENV/bin/python export_parser.py --model <segformer_face> --name face_b5 --out $OUT --fp16 --int8 --int8-conv
$VENV/bin/python export_parser.py --model <segformer_clothes> --name clothes_b2 --out $OUT --fp16 --int8 --int8-conv
(cd dart_resize && dart pub get && dart run bin/resize.dart $RGB ../../../tgbot/tools/bench/srcs/*.png)
# ComfyUI reference, on the broker; the bench writes <cache>/analysis/<sha>/*.png
sparkctl exec restyler comfyui 10 5 "hair_analyse nad srcs" -- <script calling> \
  run.py analyse --url http://spark:8188 --cache $CACHE --srcs <srcs>
$VENV/bin/python parity.py --face <dir> --clothes <dir> --onnx $OUT --srcs <srcs> \
  --comfy-cache $CACHE --dart-rgb $RGB --golden $GOLDEN --json parity.json
$VENV/bin/python bench_time.py $OUT --json time.json
```

`requirements.txt` pins `pillow==12.1.1` on purpose: it is what ComfyUI runs, and
Pillow 13.0.0 gives a different resize (see below).

## Preprocessing, exactly

ComfyUI-RMBG `FaceSegment` and `ClothesSegment` with `process_res=512` do the
same thing. `dart_resize/lib/parser_preprocess.dart` is the Dart implementation.

1. Decode to 8-bit RGB. ComfyUI's float round trip in `LoadImage`/`tensor2pil`
   maps every byte value to itself (checked for 0..255).
2. Resize to 512×512 **ignoring the aspect ratio**, no pad, no crop.
   `pilBilinearResize` = Pillow `Image.resize(BILINEAR)`: an antialiased triangle
   filter with support scaled by the shrink factor, 22-bit fixed-point weights,
   horizontal pass first, rounded to 8 bits, then the vertical pass. On all ten
   `srcs` the output is byte-identical to Pillow 12.1.1.
   **Do not use `package:image` `copyResize`**: none of its interpolations is
   this filter, and the parser is sensitive to it (table in the parity doc).
3. `value / 255`, then per channel `(v - mean) / std`, mean
   `[0.485, 0.456, 0.406]`, std `[0.229, 0.224, 0.225]`.
4. Input `pixel_values`: float32, NCHW, shape `[1, 3, 512, 512]`, RGB order,
   flattened as all R, then all G, then all B.
5. Output `logits`: float32, shape `[1, C, 128, 128]`, C = 19 face, 18 clothes.
   Not softmaxed, not upsampled.
6. Bilinear upsampling of the **logits** to the source `(h, w)`,
   `align_corners=False`: source coordinate `(i + 0.5) * 128 / n - 0.5`, clamped to
   the edge. Then argmax over C. `upsampleArgmax` does both per pixel without
   storing the upsampled logits. **Argmax first and resizing the class map is not
   equivalent**: `FaceParse.resized` (nearest neighbour) must not be how a 128 or
   512 class map reaches the photo size; see the parity doc.

Class ids: face `1 skin, 2 nose, 3 eye_g, 4/5 eyes, 6/7 brows, 8/9 ears, 10 mouth,
11/12 lips, 13 hair, 14 hat, 15 earring, 16 necklace, 17 neck, 18 cloth`; clothes
`1 Hat, 2 Hair, ...` as in the model's `config.json`.

The camera path is outside this: EXIF orientation must be applied before step 2
(ComfyUI's `LoadImage` applies it), and `package:image`'s JPEG decoder was only
tested on re-encoded `srcs`, not camera files.

## Recommendation

- **Format: `fp16`** (`face_b5.fp16.onnx` 170.5 MB, `clothes_b2.fp16.onnx` 95.2 MB).
  Same masks as fp32 at half the size. `int8` is smaller and faster on CPU but moves
  masks on the small-face images, and its output is **wrong under the CoreML EP**.
- **Runtime: `flutter_onnxruntime` 1.9.0.** `onnxruntime` 1.4.1 also runs (macOS,
  this model family) but ships ORT 1.15.1 from 2024 and has no SwiftPM support.
- **Never run the int8 files under the CoreML EP.** With fp16 it gave correct
  output and was faster on the Mac (0.92 s vs 1.40 s). How much of the graph
  CoreML really takes, and what it does on a phone, was not established.
- **Hosting:** fp16 files are over the 50 MB limit of plan §1.3, so they are
  downloaded on first start from `restyler-api.ol1n.com/models/` (risk 9):
  versioned name plus sha256 (`face_b5.fp16.<sha8>.onnx`), immutable caching, download
  to a temp file, verify, rename; keep it in Application Support, excluded from
  backup, not the OS cache directory. gzip gains little (157 MB and 87 MB).
  `createSessionFromAsset` copies the asset to the temporary directory, so for
  downloaded files use `createSession(path)`.

## Building the probe

```sh
flutter create --platforms=macos,ios --org com.ol1n.ondevice --project-name ort_probe $DIR
cp probe/pubspec.yaml $DIR/ && cp probe/lib/main.dart dart_resize/lib/parser_preprocess.dart $DIR/lib/
# assets/src.png, assets/models/*.onnx, assets/golden/{face_b5,clothes_b2}.png (parity.py --golden)
# macos: Podfile platform 14.0, MACOSX_DEPLOYMENT_TARGET 14.0, sandbox off
# ios: Podfile platform 16.0, IPHONEOS_DEPLOYMENT_TARGET 16.0, DEVELOPMENT_TEAM set
# both Podfiles: use_frameworks! :linkage => :static   (ORT pods are static binaries)
flutter run -d <device> --profile
```

The plugin needs iOS 16 and macOS 14, and with SwiftPM enabled the Xcode resolve
failed here, hence `enable-swift-package-manager: false`.
