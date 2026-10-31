# On-device parser parity (spike, plan 07 §1)

Measured 2026-10-31. Mac: Apple M2, macOS 27.0.1, Python ORT 1.31.1. Tooling and
the exact preprocessing: [`tools/ondevice/README.md`](../tools/ondevice/README.md).

## Decision

| gate | result |
|---|---|
| same model, IoU ≥ 0.98: `face_b5.fp16`, `clothes_b2.fp16` | **pass** against PyTorch reference, every class, every image |
| reference equals ComfyUI (composites) | **pass on portraits** (min 0.9996); one miss on `p-dancer` `features`, 0.968 |
| smaller model, IoU ≥ 0.90: `alexkrz/segformer-b0-celebamask_hq` | **fail**: brows 0.76, eyes 0.75, ears 0.51 on portraits |
| 3 s on a phone | **open**: nothing was measured on a phone |

Use SegFormer-B5 and B2, both fp16. The B0 route needs a recalibration, which
plan §1 calls a different plan. The time gate must still be run before §2.

## Sizes and time

Random input of the right shape, 5 runs, median. `peak RSS` is the whole Python
process. Not a phone measurement.

| model | format | MB | CPU s | CoreML EP s | CoreML session load s | peak RSS CPU / CoreML, MB |
|---|---|---:|---:|---:|---:|---:|
| face B5 | fp32 | 339.4 | 1.077 | 2.936 | 32.38 | 1349 / 3066 |
| face B5 | fp16 | 170.5 | 1.398 | 0.919 | 0.51 | 1565 / 1718 |
| face B5 | int8 (MatMul) | 158.1 | 0.598 | 2.959 | 34.09 | 1162 / 2915 |
| face B5 | int8conv | 87.6 | 0.745 | 4.287 | 31.13 | 1095 / 3131 |
| clothes B2 | fp32 | 189.5 | 0.826 | 0.659 | 20.23 | 1195 / 2743 |
| clothes B2 | fp16 | 95.2 | 0.860 | 0.676 | 0.30 | 1483 / 1479 |
| clothes B2 | int8 | 90.1 | 0.712 | 1.030 | 16.95 | 1085 / 2639 |
| clothes B2 | int8conv | 48.8 | 0.611 | 1.906 | 16.89 | 1043 / 2895 |
| face B0 | fp32 | 15.0 | 0.134 | 0.120 | 4.85 | 402 / 760 |
| face B0 | fp16 | 7.7 | 0.187 | 0.103 | 0.07 | 464 / 463 |
| face B0 | int8 | 7.9 | 0.115 | 0.122 | 4.49 | 395 / 887 |
| face B0 | int8conv | 4.1 | 0.120 | 0.167 | 4.04 | 391 / 1227 |

The fp16 CoreML sessions load in under a second where the others take 17 to 34 s,
which suggests a different graph partition; this was not inspected.

`flutter_onnxruntime` end to end on macOS (profile build, ORT 1.28, `w-glasses`,
832×1216): PNG decode 25 ms, resize + normalise 14 ms, upsample + argmax 47 ms.
Later runs in that session were throttled (upsample rose to about 430 ms), so its
inference times are not reported. Pixel agreement with the Python golden map, whose
inputs came from Pillow: `face_b5.fp16` 0.99995, `clothes_b2.fp16` 0.99998, CPU EP
and CoreML EP alike.

**Phone: not measured.** The iPhone 12 mini was connected wirelessly, but this Xcode
(26.2) rejected it: "iOS 26.2 is not installed", and the iOS platform component was
not installed as part of this spike. No Android device was connected.

## Parity

IoU at source resolution against R, the PyTorch model with ComfyUI's preprocessing
(CPU, Pillow 12.1.1). `mean/min` over images where either side has the class.
All = 10 `srcs`; portraits = 8, without `p-dancer` and `p-seated`, whose faces
are tiny. `lips` = mouth + both lips, as in the current `hair_analyse` graph.
`glasses` has n = 2 on all (real glasses on `w-glasses`, a stray patch on
`p-dancer`) and n = 1 on portraits.

### Reference against ComfyUI

`hair_analyse` run through the broker (job 1031-83, 13:37 to 13:39, the graph
before it gained lips/nose/ears), so only four composites exist. `hat` is empty on
every src.

| composite | all, mean/min | portraits, mean/min |
|---|---|---|
| hair (face ∪ clothes) | 0.9999 / 0.9997 | 1.0000 / 0.9999 |
| face | 0.9990 / 0.9906 | 1.0000 / 1.0000 |
| features | 0.9963 / 0.9683 | 0.9998 / 0.9996 |

The miss is a very small mask on `p-dancer`, ComfyUI on GPU against PyTorch on CPU,
so no ONNX is involved. ONNX against ComfyUI was not compared directly; it follows
from the two tables.

### Export format (face, all images)

| variant | hair | skin | brows | eyes | glasses | lips | nose | ears |
|---|---|---|---|---|---|---|---|---|
| fp32 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 |
| **fp16** | 1.0000/1.000 | 0.9994/0.994 | 0.9999/1.000 | 0.9998/1.000 | 1.0000/1.000 | 0.9999/1.000 | 0.9999/1.000 | 0.9993/0.995 |
| int8 | 0.9974/0.992 | 0.9673/0.691 | 0.9912/0.984 | 0.9905/0.987 | 0.5874/0.179 | 0.9822/0.881 | 0.9960/0.995 | 0.9752/0.900 |
| int8conv | 0.9962/0.988 | 0.9586/0.610 | 0.9906/0.986 | 0.9890/0.982 | 0.6354/0.275 | 0.9821/0.901 | 0.9940/0.991 | 0.9829/0.962 |

Portraits only, int8: hair 0.9981/0.994, skin 0.9983/0.998, glasses 0.9953/0.995,
ears 0.9729/0.900. int8conv: ears 0.9813/0.962. Both fail the 0.98 gate on the worst
image.

Clothes parser, hair class: fp32 1.0000/1.000, fp16 0.9999/1.000, int8 0.9903/0.979,
int8conv 0.9889/0.967.

**CoreML EP changes int8 output.** Pixel agreement with the golden map on `w-glasses`:
fp32 0.99993, fp16 0.99996, int8 0.330, int8conv 0.189. int8conv gave 0.189 in
the Flutter plugin as well as in Python, so this is not a Python artefact.

### Preprocessing (B5 fp32, face)

Portraits:

| resize / postprocessing | hair | skin | brows | eyes | glasses | lips | nose | ears |
|---|---|---|---|---|---|---|---|---|
| **Dart PIL port** | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 | 1.0000/1.000 |
| `copyResize` average | 0.9873/0.974 | 0.9890/0.987 | 0.9555/0.940 | 0.9490/0.899 | 0.9838/0.984 | 0.9825/0.971 | 0.9803/0.974 | 0.9065/0.801 |
| `copyResize` linear | 0.9858/0.972 | 0.9864/0.985 | 0.9314/0.917 | 0.9298/0.880 | 0.9746/0.975 | 0.9733/0.956 | 0.9786/0.970 | 0.8756/0.689 |
| `copyResize` cubic | 0.9837/0.967 | 0.9848/0.983 | 0.9279/0.912 | 0.9253/0.867 | 0.9719/0.972 | 0.9719/0.947 | 0.9737/0.962 | 0.8459/0.620 |
| `copyResize` nearest | 0.9779/0.957 | 0.9778/0.972 | 0.8900/0.865 | 0.8932/0.845 | 0.9567/0.957 | 0.9582/0.941 | 0.9630/0.950 | 0.7300/0.000 |
| class map 512, then nearest | 0.9927/0.990 | 0.9889/0.987 | 0.9414/0.922 | 0.9457/0.928 | 0.9783/0.978 | 0.9719/0.963 | 0.9833/0.979 | 0.9423/0.866 |
| class map 128, then nearest | 0.9709/0.959 | 0.9572/0.949 | 0.7939/0.740 | 0.8142/0.758 | 0.9202/0.920 | 0.8952/0.867 | 0.9296/0.908 | 0.7915/0.556 |
| JPEG q92, package:image decode, PIL port | 0.9969/0.994 | 0.9973/0.997 | 0.9833/0.973 | 0.9918/0.983 | 0.9967/0.997 | 0.9949/0.992 | 0.9948/0.991 | 0.9208/0.646 |

All images are worse: `copyResize` average drops to eyes 0.8436/0.000, brows
0.8493/0.000, because the small faces lose whole classes. The `copyResize` rows are
real `package:image` output fed through the model, not a simulation. The Dart PIL
port is byte-identical to Pillow 12.1.1 on all 10 `srcs`.

Pillow 13.0.0 is not: about 16 % of bytes differ by ±1 on `m-long`, and that alone cost
`p-dancer` `features` IoU 0.70 against ComfyUI until the reference was pinned to 12.1.1.
The model is that sensitive on small faces, and it means upgrading Pillow in
ComfyUI would shift the server masks too.

The JPEG row combines compression with the decoder and has no libjpeg row to
compare with, so it does not isolate `package:image`.

### Smaller model

`alexkrz/segformer-b0-celebamask_hq` (ready-made, 15 MB, label order remapped, license
"other"). Against R, fp16:

| scope | hair | skin | brows | eyes | glasses | lips | nose | ears |
|---|---|---|---|---|---|---|---|---|
| portraits | 0.9389/0.886 | 0.9252/0.807 | 0.7573/0.521 | 0.7501/0.000 | 0.8109/0.811 | 0.8708/0.802 | 0.9110/0.819 | 0.5100/0.122 |
| all | 0.9270/0.832 | 0.8033/0.067 | 0.6732/0.000 | 0.7501/0.000 | 0.4080/0.005 | 0.7839/0.089 | 0.8098/0.000 | 0.4670/0.000 |

No ready B2 on CelebAMask-HQ turned up in the Hugging Face search. BiSeNet and
MediaPipe `selfie_multiclass` were not measured.

## Not verified

- Anything on a phone: time, memory, whether a 170 MB session loads, CoreML or NNAPI.
- Real selfies (plan §1.4): `srcs` are the only test set here, and all are PNG.
- Camera path: EXIF orientation, HEIC, real JPEG files.
- Per-class ComfyUI comparison: the run predates the lips/nose/ears outputs.
