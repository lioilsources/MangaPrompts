#!/usr/bin/env python3
"""Parity of the on-device parser against the server parser.

    parity.py --face <dir> --clothes <dir> --onnx out/models --srcs <dir> \
              [--comfy-cache <run.py --cache dir>] [--dart-rgb <resize.dart outdir>] \
              [--json out/parity.json]

Reference R = PyTorch with the ComfyUI node's exact preprocessing. Compared:
  1. ComfyUI masks vs R, on the four composites hair_analyse saves (the gate
     reference; proves R may stand in for ComfyUI per class).
  2. ONNX fp32/fp16/int8/int8conv vs R, per class.
  3. fp32 fed by each resize variant vs R, per class.
IoU is computed at source resolution, on images where either side has the
class; `n` counts them. Absent from both = not counted.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import onnxruntime as ort
import torch
from PIL import Image
from torchvision import transforms
from transformers import AutoModelForSemanticSegmentation

FACE = {"hair": [13], "skin": [1], "brows": [6, 7], "eyes": [4, 5], "glasses": [3],
        "lips": [10, 11, 12], "nose": [2], "ears": [8, 9]}
CLOTHES = {"hair": [2], "hat": [1]}
FACE_MASK = [1, 2, 3, 4, 5, 6, 7, 10, 11, 12]  # hair_analyse node 5
FEATURES_MASK = [3, 4, 5, 6, 7]  # hair_analyse node 11

TO_TENSOR = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
])
RESIZE = transforms.Resize((512, 512))


def pil_rgb512(im: Image.Image) -> Image.Image:
    return RESIZE(im)


def tensor(im: Image.Image) -> torch.Tensor:
    return TO_TENSOR(im).unsqueeze(0)


def seg(logits, h: int, w: int) -> np.ndarray:
    t = torch.as_tensor(logits)
    return torch.nn.functional.interpolate(t, size=(h, w), mode="bilinear", align_corners=False).argmax(1)[0].numpy()


def iou(a: np.ndarray, b: np.ndarray) -> float | None:
    u = (a | b).sum()
    return None if u == 0 else float((a & b).sum() / u)


def class_ious(pred: np.ndarray, ref: np.ndarray, classes: dict, pred_classes: dict | None = None) -> dict:
    pc = pred_classes or classes
    row = {k: iou(np.isin(pred, pc[k]), np.isin(ref, v)) for k, v in classes.items()}
    return row


def summarise(vals: list) -> dict | None:
    vals = [v for v in vals if v is not None]
    return {"mean": float(np.mean(vals)), "min": float(np.min(vals)), "n": len(vals)} if vals else None


def accumulate(rows: dict[str, dict]) -> dict:
    """{src name: {class: iou}} -> per class stats over all srcs and over portraits (no p-*)."""
    keys = next(iter(rows.values())).keys()
    return {"all": {k: summarise([r[k] for r in rows.values()]) for k in keys},
            "portraits": {k: summarise([r[k] for n, r in rows.items() if not n.startswith("p-")]) for k in keys}}


def label_classes(model_dir: str) -> dict:
    """FACE, re-expressed in another CelebAMask-HQ model's label order."""
    names = {v: int(k) for k, v in json.loads((Path(model_dir) / "config.json").read_text())["id2label"].items()}
    ours = {"hair": ["hair"], "skin": ["skin"], "brows": ["l_brow", "r_brow"], "eyes": ["l_eye", "r_eye"],
            "glasses": ["eye_g"], "lips": ["mouth", "u_lip", "l_lip"], "nose": ["nose"], "ears": ["l_ear", "r_ear"]}
    return {k: [names[n] for n in v] for k, v in ours.items()}


def composites(face: np.ndarray, clothes: np.ndarray) -> dict:
    return {"hair": (face == 13) | (clothes == 2), "face": np.isin(face, FACE_MASK),
            "hat": clothes == 1, "features": np.isin(face, FEATURES_MASK)}


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--face", required=True)
    ap.add_argument("--clothes", required=True)
    ap.add_argument("--onnx", required=True)
    ap.add_argument("--srcs", required=True)
    ap.add_argument("--comfy-cache")
    ap.add_argument("--alt-face", help="HF dir of the face_b0 model, for its label order")
    ap.add_argument("--dart-rgb")
    ap.add_argument("--json", default="parity.json")
    ap.add_argument("--golden", help="write <dir>/<src>.{face_b5,clothes_b2}.png, class id per pixel (for the probe)")
    ap.add_argument("--providers", default="CPUExecutionProvider")
    args = ap.parse_args()

    srcs = sorted(Path(args.srcs).glob("*.png"))
    face_m = AutoModelForSemanticSegmentation.from_pretrained(args.face).eval()
    clothes_m = AutoModelForSemanticSegmentation.from_pretrained(args.clothes).eval()
    onnx_dir = Path(args.onnx)
    sessions = {}
    for f in sorted(onnx_dir.glob("*.onnx")):
        sessions[f.name.removesuffix(".onnx")] = ort.InferenceSession(str(f), providers=args.providers.split(","))

    refs = {}
    comfy_rows: dict[str, dict] = {}
    onnx_rows: dict[str, dict[str, dict]] = {}
    alt = label_classes(args.alt_face) if args.alt_face else None
    for src in srcs:
        with Image.open(src) as im:
            rgb = im.convert("RGB")
        w, h = rgb.size
        x = tensor(pil_rgb512(rgb))
        with torch.no_grad():
            fl, cl = face_m(x).logits, clothes_m(x).logits
        rf, rc = seg(fl, h, w), seg(cl, h, w)
        refs[src.name] = (rf, rc)
        if args.golden:
            Path(args.golden).mkdir(parents=True, exist_ok=True)
            Image.fromarray(rf.astype(np.uint8)).save(Path(args.golden) / f"{src.stem}.face_b5.png")
            Image.fromarray(rc.astype(np.uint8)).save(Path(args.golden) / f"{src.stem}.clothes_b2.png")

        if args.comfy_cache:
            d = Path(args.comfy_cache) / "analysis" / hashlib.sha1(src.read_bytes()).hexdigest()[:16]
            mine = composites(rf, rc)
            row = {}
            for n, m in mine.items():
                with Image.open(d / f"{n}.png") as png:
                    theirs = np.asarray(png.convert("L")) > 127
                row[n] = iou(m, theirs)
            comfy_rows[src.name] = row

        for name, s in sessions.items():
            out = s.run(["logits"], {"pixel_values": x.numpy()})[0]
            pred = seg(out, h, w)
            if name.startswith("clothes"):
                row = class_ious(pred, rc, CLOTHES)
            elif name.startswith("face_b0"):
                row = class_ious(pred, rf, FACE, alt)
            else:
                row = class_ious(pred, rf, FACE)
            onnx_rows.setdefault(name, {})[src.name] = row

    report = {"srcs": [s.name for s in srcs],
              "comfy_vs_torch": accumulate(comfy_rows) if comfy_rows else None,
              "onnx_vs_torch": {k: accumulate(v) for k, v in onnx_rows.items()},
              "per_image": {"comfy": comfy_rows, **onnx_rows}}

    resize_rows: dict[str, dict[str, dict]] = {}
    pil_exact = []
    if args.dart_rgb:
        d = Path(args.dart_rgb)
        fp32 = sessions["face_b5.fp32"]
        for src in srcs:
            rf, _ = refs[src.name]
            h, w = rf.shape
            with Image.open(src) as im:
                ref512 = np.asarray(pil_rgb512(im.convert("RGB")))
            for f in sorted(d.glob(f"{src.name}.*.rgb")):
                variant = f.name[len(src.name) + 1:-4]
                arr = np.frombuffer(f.read_bytes(), np.uint8).reshape(512, 512, 3)
                if variant == "pil":
                    pil_exact.append(int((arr != ref512).sum()))
                out = fp32.run(["logits"], {"pixel_values": tensor(Image.fromarray(arr)).numpy()})[0]
                resize_rows.setdefault(variant, {})[src.name] = class_ious(seg(out, h, w), rf, FACE)
            with Image.open(src) as im:
                out = fp32.run(["logits"], {"pixel_values": tensor(pil_rgb512(im.convert("RGB"))).numpy()})[0]
            for label, size in (("classmap128+nearest", (128, 128)), ("classmap512+nearest", (512, 512))):
                small = seg(out, *size)
                big = np.asarray(Image.fromarray(small.astype(np.uint8)).resize((w, h), Image.NEAREST))
                resize_rows.setdefault(label, {})[src.name] = class_ious(big, rf, FACE)
            jpg = d / f"{src.stem}.jpg.pil.rgb"
            if jpg.exists():
                arr = np.frombuffer(jpg.read_bytes(), np.uint8).reshape(512, 512, 3)
                out = fp32.run(["logits"], {"pixel_values": tensor(Image.fromarray(arr)).numpy()})[0]
                resize_rows.setdefault("jpeg-q92-decode+pil", {})[src.name] = class_ious(seg(out, h, w), rf, FACE)
        report["resize_vs_torch"] = {k: accumulate(v) for k, v in resize_rows.items()}
        report["dart_pil_port_differing_bytes_per_image"] = pil_exact

    Path(args.json).write_text(json.dumps(report, indent=2) + "\n")

    keys = list(FACE)
    for scope in ("all", "portraits"):
        print(f"--- {scope}: mean/min IoU vs R")
        print("variant".ljust(26) + "".join(k.rjust(14) for k in keys))
        for label, t in [*report["onnx_vs_torch"].items(), *report.get("resize_vs_torch", {}).items()]:
            table = t[scope]
            print(label.ljust(26) + "".join(
                (f"{table[k]['mean']:.4f}/{table[k]['min']:.3f}" if table.get(k) else "-").rjust(14) for k in keys))
    if report["comfy_vs_torch"]:
        print("comfy vs torch:", json.dumps(report["comfy_vs_torch"]))
    if pil_exact:
        print("dart PIL port, differing bytes per image:", pil_exact)


if __name__ == "__main__":
    main()
