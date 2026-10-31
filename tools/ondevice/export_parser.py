#!/usr/bin/env python3
"""Export a SegFormer parser (face or clothes) to ONNX: 1x3x512x512 -> logits.

    export_parser.py --model <dir with config.json + model.safetensors> \
                     --name face_b5 --out out/models --fp16 --int8

Writes <name>.fp32.onnx, .fp16.onnx (weights only, float32 I/O) and .int8.onnx
(dynamic quantisation), and merges their sizes into <out>/sizes.json. Every
output is checked against PyTorch on a fixed noise input. Graph I/O names are
`pixel_values` (float32 NCHW, already normalised) and `logits` (float32
1xCx128x128): upsampling and argmax stay in the caller, as in the ComfyUI node.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import onnx
import onnxruntime as ort
import torch
from transformers import AutoModelForSemanticSegmentation

SIZE = 512
OPSET = 17


class LogitsOnly(torch.nn.Module):
    def __init__(self, model: torch.nn.Module) -> None:
        super().__init__()
        self.model = model

    def forward(self, pixel_values: torch.Tensor) -> torch.Tensor:
        return self.model(pixel_values=pixel_values, return_dict=True).logits


def load(model_dir: str) -> torch.nn.Module:
    m = AutoModelForSemanticSegmentation.from_pretrained(model_dir)
    return LogitsOnly(m.eval()).eval()


def export_fp32(wrapped: torch.nn.Module, path: Path) -> None:
    dummy = torch.zeros(1, 3, SIZE, SIZE)
    torch.onnx.export(
        wrapped, (dummy,), str(path),
        input_names=["pixel_values"], output_names=["logits"],
        opset_version=OPSET, do_constant_folding=True, dynamo=False,
    )
    onnx.checker.check_model(str(path))


def to_fp16(src: Path, dst: Path) -> None:
    from onnxconverter_common import float16
    model = float16.convert_float_to_float16(onnx.load(str(src)), keep_io_types=True)
    onnx.save(model, str(dst))
    onnx.checker.check_model(str(dst))


def to_int8(src: Path, dst: Path, conv: bool) -> None:
    from onnxruntime.quantization import QuantType, quantize_dynamic
    ops = ["MatMul", "Gemm"] + (["Conv"] if conv else [])
    quantize_dynamic(str(src), str(dst), weight_type=QuantType.QUInt8, op_types_to_quantize=ops)


def check(wrapped: torch.nn.Module, path: Path) -> float:
    """Max abs logit difference to PyTorch; also proves the file loads and runs."""
    x = np.random.default_rng(0).normal(size=(1, 3, SIZE, SIZE)).astype(np.float32)
    with torch.no_grad():
        ref = wrapped(torch.from_numpy(x)).numpy()
    s = ort.InferenceSession(str(path), providers=["CPUExecutionProvider"])
    out = s.run(["logits"], {"pixel_values": x})[0]
    assert out.shape == ref.shape, (out.shape, ref.shape)
    return float(np.abs(out - ref).max())


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--model", required=True, help="local HF model directory or repo id")
    ap.add_argument("--name", required=True, help="output basename, e.g. face_b5")
    ap.add_argument("--out", default="out/models")
    ap.add_argument("--fp16", action="store_true")
    ap.add_argument("--int8", action="store_true", help="dynamic quantisation of MatMul/Gemm")
    ap.add_argument("--int8-conv", action="store_true", help="dynamic quantisation incl. Conv (ConvInteger)")
    args = ap.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    wrapped = load(args.model)
    fp32 = out / f"{args.name}.fp32.onnx"
    export_fp32(wrapped, fp32)
    files = {"fp32": fp32}
    if args.fp16:
        files["fp16"] = out / f"{args.name}.fp16.onnx"
        to_fp16(fp32, files["fp16"])
    if args.int8:
        files["int8"] = out / f"{args.name}.int8.onnx"
        to_int8(fp32, files["int8"], conv=False)
    if args.int8_conv:
        files["int8conv"] = out / f"{args.name}.int8conv.onnx"
        to_int8(fp32, files["int8conv"], conv=True)

    sizes_path = out / "sizes.json"
    sizes = json.loads(sizes_path.read_text()) if sizes_path.exists() else {}
    for fmt, path in files.items():
        mb = path.stat().st_size / 1e6
        delta = check(wrapped, path)
        sizes[f"{args.name}.{fmt}"] = {"bytes": path.stat().st_size, "mb": round(mb, 1), "max_logit_delta": round(delta, 4)}
        print(f"{path.name}: {mb:.1f} MB, max |logit - torch| = {delta:.4f}", flush=True)
    sizes_path.write_text(json.dumps(sizes, indent=2) + "\n")


if __name__ == "__main__":
    main()
