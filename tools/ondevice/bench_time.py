#!/usr/bin/env python3
"""Inference time of one ONNX file on this machine.

    bench_time.py <dir> [--providers CPU,CoreML] [--runs 5]   # all *.onnx, one subprocess each
"""

from __future__ import annotations

import argparse
import json
import platform
import resource
import statistics
import subprocess
import sys
import time
from pathlib import Path

import numpy as np

PROVIDERS = {"CPU": ["CPUExecutionProvider"], "CoreML": ["CoreMLExecutionProvider", "CPUExecutionProvider"]}


def one(path: str, provider: str, runs: int) -> None:
    import onnxruntime as ort
    t0 = time.perf_counter()
    s = ort.InferenceSession(path, providers=PROVIDERS[provider])
    load = time.perf_counter() - t0
    x = np.random.default_rng(0).normal(size=(1, 3, 512, 512)).astype(np.float32)
    t0 = time.perf_counter()
    s.run(["logits"], {"pixel_values": x})
    first = time.perf_counter() - t0
    times = []
    for _ in range(runs):
        t0 = time.perf_counter()
        s.run(["logits"], {"pixel_values": x})
        times.append(time.perf_counter() - t0)
    print(json.dumps({"file": Path(path).name, "provider": provider, "active": s.get_providers(),
                      "load_s": round(load, 2), "first_s": round(first, 2),
                      "median_s": round(statistics.median(times), 3), "min_s": round(min(times), 3),
                      "max_s": round(max(times), 3), "peak_rss_mb": resource.getrusage(resource.RUSAGE_SELF).ru_maxrss // 2**20}))


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("dir")
    ap.add_argument("--providers", default="CPU,CoreML")
    ap.add_argument("--runs", type=int, default=5)
    ap.add_argument("--timeout", type=float, default=400)
    ap.add_argument("--one", nargs=2)
    ap.add_argument("--json")
    args = ap.parse_args()
    if args.one:
        one(args.one[0], args.one[1], args.runs)
        return
    print("#", platform.machine(), platform.mac_ver()[0], flush=True)
    rows = []
    for prov in args.providers.split(","):
        for f in sorted(Path(args.dir).glob("*.onnx")):
            cmd = [sys.executable, __file__, args.dir, "--one", str(f), prov, "--runs", str(args.runs)]
            try:
                p = subprocess.run(cmd, capture_output=True, text=True, timeout=args.timeout)
                line = p.stdout.strip().splitlines()[-1] if p.returncode == 0 and p.stdout.strip() else None
                row = json.loads(line) if line else {"file": f.name, "provider": prov, "error": p.stderr.strip()[-300:]}
            except subprocess.TimeoutExpired:
                row = {"file": f.name, "provider": prov, "error": f"timeout {args.timeout}s"}
            rows.append(row)
            print(json.dumps(row), flush=True)
    if args.json:
        Path(args.json).write_text(json.dumps(rows, indent=2) + "\n")


if __name__ == "__main__":
    main()
