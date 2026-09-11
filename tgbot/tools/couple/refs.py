#!/usr/bin/env python3
"""Reference set for the Couple bench — portrait and full-body of the *same* person.

    refs.py build            # 4 couples: full body + portrait crop of each
    refs.py check            # facebench similarity portrait <-> full body

The point is a controlled comparison. `srcB` versus `ref2` told us nothing about
framing because they are different women; here each pair is cut from one render,
so identity is held **exactly** and the only thing that varies is how much of the
person the reference shows.

Each person is rendered once as a full body on Juggernaut XL (photoreal SDXL,
832×1216). The portrait is then a head-and-shoulders crop of that same render,
upscaled 4× and resized to 1024² — the framing `ref1`/`ref2` have. The crop box
comes from the InsightFace detection, the same detector the identity gate uses,
widened the way facebench widens a face mask.

Caveat worth carrying into any conclusion: the portrait is an **upscaled crop**,
so its face carries less real detail than a natively rendered headshot. That is
also what a user's own full-body snapshot looks like, so it is the honest
comparison for the card — but it is not a comparison of framing alone.
"""

from __future__ import annotations

import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import run as bench_run  # noqa: E402  submit/report against the live ComfyUI

CKPT = "Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors"
UPSCALER = "4x-UltraSharp.pth"
OUT = os.path.expanduser("~/Code/couplebench/refs")

# Juggernaut v9 photoreal defaults, same shape Ol1nLLM's registry uses for it.
STEPS, CFG, SAMPLER, SCHEDULER = 30, 5.0, "dpmpp_2m", "karras"
NEGATIVE = ("cartoon, anime, illustration, painting, 3d render, cgi, blurry, "
            "deformed, extra limbs, extra fingers, watermark, text, logo")

# Four couples, deliberately unlike each other — two references were never going
# to tell us whether a weak transfer is a property of the model or of one face.
PEOPLE = [
    ("c1m", "a man in his late 30s with short dark brown hair, light stubble, "
            "brown eyes, wearing a plain navy t-shirt and dark jeans"),
    ("c1w", "a woman in her early 30s with long straight black hair, brown eyes, "
            "wearing a plain white blouse and blue jeans"),
    ("c2m", "a man in his 50s with grey hair and a full grey beard, blue eyes, "
            "wearing a dark green sweater and grey trousers"),
    ("c2w", "a woman in her late 40s with shoulder-length auburn hair, green eyes, "
            "wearing a burgundy cardigan and black trousers"),
    ("c3m", "a young man in his mid 20s with curly black hair, dark skin, "
            "wearing a light grey hoodie and black jeans"),
    ("c3w", "a young woman in her mid 20s with braided dark hair, dark skin, "
            "wearing a yellow blouse and white trousers"),
    ("c4m", "a man in his 40s with blond hair combed back, pale skin, glasses, "
            "wearing a light blue shirt and beige chinos"),
    ("c4w", "a woman in her late 30s with short blonde bob hair, pale skin, "
            "wearing a dark teal dress"),
]

BODY = ("full body photograph of %s, standing straight, arms relaxed at the "
        "sides, facing the camera, plain light grey studio backdrop, soft even "
        "studio lighting, sharp focus, photorealistic, 50mm lens")


def _graph(name, prompt, seed, width=832, height=1216):
    """Plain SDXL txt2img plus a 4× upscale branch the crop is taken from."""
    return {
        "ckpt": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": CKPT}},
        "pos": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["ckpt", 1], "text": prompt}},
        "neg": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["ckpt", 1], "text": NEGATIVE}},
        "latent": {"class_type": "EmptyLatentImage", "inputs": {
            "width": width, "height": height, "batch_size": 1}},
        "sampler": {"class_type": "KSampler", "inputs": {
            "model": ["ckpt", 0], "positive": ["pos", 0], "negative": ["neg", 0],
            "latent_image": ["latent", 0], "seed": seed, "steps": STEPS, "cfg": CFG,
            "sampler_name": SAMPLER, "scheduler": SCHEDULER, "denoise": 1.0}},
        "decode": {"class_type": "VAEDecode", "inputs": {
            "samples": ["sampler", 0], "vae": ["ckpt", 2]}},
        "save_body": {"class_type": "SaveImage", "inputs": {
            "images": ["decode", 0], "filename_prefix": "refs/%s_body" % name}},
        "upmodel": {"class_type": "UpscaleModelLoader", "inputs": {"model_name": UPSCALER}},
        # The portrait is cut from the upscaled render, not from the 832-wide
        # one — a head is ~150 px there and would arrive at 1024² as mush.
        "up": {"class_type": "ImageUpscaleWithModel", "inputs": {
            "upscale_model": ["upmodel", 0], "image": ["decode", 0]}},
        "save_up": {"class_type": "SaveImage", "inputs": {
            "images": ["up", 0], "filename_prefix": "refs/%s_up" % name}},
    }


def cmd_build(a):
    os.makedirs(OUT, exist_ok=True)
    url = a.url
    for i, (name, desc) in enumerate(PEOPLE):
        if os.path.exists(os.path.join(OUT, name + "_portrait.png")) and not a.force:
            print("  %s  hotové" % name)
            continue
        g = _graph(name, BODY % desc, a.seed + i)
        marks, total, pid = bench_run.submit(url, g, name)
        files = dict(bench_run.report(marks, total, url, pid))
        _crop(name, files["save_body"], files["save_up"])


def _crop(name, body_png, up_png):
    """Full body as-is, plus a head-and-shoulders crop from the 4× render.

    The box is the InsightFace bbox widened the way facebench widens a mask
    (`bench.py:cmd_mask`): 1.6× the face width either side, one face height of
    headroom, two below for the shoulders. Then squared off and resized to 1024².
    """
    import cv2
    import numpy as np
    sys.path.insert(0, os.path.expanduser("~/Code/facebench"))
    import vidbench

    body = cv2.imread(body_png)
    up = cv2.imread(up_png)
    cv2.imwrite(os.path.join(OUT, name + "_body.png"), body)

    dets = vidbench.detect(up)
    if not dets:
        print("  ⚠ %s: v upscalu není tvář, portrét nevznikl" % name)
        return
    d = max(dets, key=lambda x: (x["bbox"][2] - x["bbox"][0]))
    x0, y0, x1, y1 = d["bbox"]
    w, h = x1 - x0, y1 - y0
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    side = max(w * 2.6, h * 2.2)
    x, y = int(cx - side / 2), int(cy - side * 0.45)
    H, W = up.shape[:2]
    x, y = max(0, x), max(0, y)
    side = int(min(side, W - x, H - y))
    crop = cv2.resize(up[y:y + side, x:x + side], (1024, 1024))
    cv2.imwrite(os.path.join(OUT, name + "_portrait.png"), crop)
    print("  %s  tvář %d px v upscalu → portrét 1024²" % (name, int(w)))


def cmd_check(a):
    """Portrait and full body must measure as the same person, or the framing
    comparison is measuring something else."""
    sys.path.insert(0, os.path.expanduser("~/Code/facebench"))
    import bench
    print("%-6s %8s %8s %8s" % ("osoba", "port↔tělo", "tvář v těle", "tvář v portrétu"))
    for name, _ in PEOPLE:
        p = os.path.join(OUT, name + "_portrait.png")
        b = os.path.join(OUT, name + "_body.png")
        if not (os.path.exists(p) and os.path.exists(b)):
            continue
        ep, eb = bench.embedding(p), bench.embedding(b)
        fp, fb = bench.faces(p), bench.faces(b)
        sz = lambda fs: int(min(fs[0].bbox[2] - fs[0].bbox[0],
                                fs[0].bbox[3] - fs[0].bbox[1])) if fs else 0
        print("%-6s %8.3f %8d %8d" % (name, bench.sim(ep, eb), sz(fb), sz(fp)))


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--url", default="http://127.0.0.1:8188")
    ap.add_argument("--seed", type=int, default=9100)
    ap.add_argument("--force", action="store_true")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("build")
    sub.add_parser("check")
    a = ap.parse_args()
    {"build": cmd_build, "check": cmd_check}[a.cmd](a)
