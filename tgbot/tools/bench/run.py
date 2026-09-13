#!/usr/bin/env python3
"""Tsumiki bench — render a matrix of cells on ComfyUI, resumable.

Runs on the SPARK box next to ComfyUI (see sync.sh), in ComfyUI's venv.
Every cell is built by the bot's own `comfy.prepare_workflow` and, for hair,
`hairmask.build_mask` — the bench measures what the bot would send.

    run.py srcgen  --out srcs
    run.py restyle --engines flux --media photo --styles ukiyoe,vangogh-arles \\
                   --srcs srcs/w-long.png --seeds 777 --baseline \\
                   --sweep '11.strength=0.45|0.55|0.7' --out out/restyle-a
    run.py hair    --engines flux,sdxl --styles all --srcs srcs/w-long.png,srcs/m-short.png \\
                   --seeds 1,2 --out out/hair-r1
    run.py hair    ... --sweep 'mask.DILATE_FH=0.04|0.08' '90.context_from_mask_extend_factor=1.2|1.8'

Re-running the same command skips finished cells. `--plan` prints the cell
count and exits. Sweep keys: `<node id>.<input>` patches the graph after
prepare_workflow; `mask.<CONSTANT>` overrides a hairmask tunable
(`mask.ENVELOPE_SCALE` scales every envelope); `graph.facepass=1` adds a
FLUX face pass to the restyle graph.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import itertools
import json
import sys
import time
from contextlib import contextmanager
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path[:0] = [str(HERE.parents[1]), str(HERE)]  # tgbot/, bench/

import numpy as np  # noqa: E402
from PIL import Image  # noqa: E402

import catalog  # noqa: E402
import haircolours  # noqa: E402
import hairmask as hm  # noqa: E402
from comfy import prepare_workflow  # noqa: E402
from comfysync import CellError, Comfy, apply_node_sweep, set_seed  # noqa: E402
from imagesize import latent_for  # noqa: E402

DEFAULT_CKPT = "Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors"
ANALYSE_PREFIXES = ("tsumiki_hair_mask", "tsumiki_face_mask", "tsumiki_hat_mask", "tsumiki_features_mask")

WORKFLOWS = {
    ("restyle", "flux"): "flux_restyle.api.json",
    ("restyle", "sdxl"): "sdxl_restyle.api.json",
    ("hair", "flux"): "flux_hair_inpaint.api.json",
    ("hair", "sdxl"): "sdxl_hair_inpaint.api.json",
    ("hair", "kontext"): "flux_hair_kontext.api.json",
}


def log(msg: str) -> None:
    print(time.strftime("%H:%M:%S"), msg, flush=True)


def csv(s: str | None) -> list[str]:
    return [x.strip() for x in (s or "").split(",") if x.strip()]


def parse_value(v: str):
    try:
        return json.loads(v)
    except json.JSONDecodeError:
        return v


def expand_sweeps(specs: list[str]) -> list[dict]:
    axes = []
    for spec in specs:
        key, _, values = spec.partition("=")
        axes.append([(key.strip(), parse_value(v)) for v in values.split("|")])
    return [dict(combo) for combo in itertools.product(*axes)] if axes else [{}]


def cell_key(ident: dict) -> str:
    return hashlib.sha1(json.dumps(ident, sort_keys=True).encode()).hexdigest()[:10]


def save_png_and_thumb(out: Path, name: str, data: bytes) -> None:
    (out / "img").mkdir(parents=True, exist_ok=True)
    (out / "thumb").mkdir(parents=True, exist_ok=True)
    (out / "img" / name).write_bytes(data)
    with Image.open(io.BytesIO(data)) as im:
        im = im.convert("RGB")
        im.thumbnail((320, 320))
        im.save(out / "thumb" / name.replace(".png", ".jpg"), quality=82)


def load_template(task: str, engine: str) -> dict:
    return json.loads((catalog.ASSETS / WORKFLOWS[(task, engine)]).read_text())


def set_save_prefix(wf: dict, prefix: str) -> None:
    for node in wf.values():
        if node.get("class_type") == "SaveImage":
            node["inputs"]["filename_prefix"] = prefix


# ── restyle graph variants ──────────────────────────────────────────────────


def add_flux_face_pass(wf: dict, weight: float = 1.2, denoise: float = 0.45) -> None:
    """Second pass over the detected face on FLUX dev + PuLID, the pattern
    Ol1nLLM's flux_fill_inpaint_face measured (0.48 → 0.72 ArcFace). Its own
    unet and PuLID loaders on purpose: shared with the first pass they end up
    offloaded after sampling and ApplyPulidFlux fails on cuda/cpu mismatch."""
    save = next(k for k, n in wf.items() if n["class_type"] == "SaveImage")
    decoded = wf[save]["inputs"]["images"]
    wf["100"] = {"class_type": "UNETLoader", "inputs": {"unet_name": "flux1-dev.safetensors", "weight_dtype": "fp8_e4m3fn"}}
    wf["101"] = {"class_type": "PulidFluxModelLoader", "inputs": {"pulid_file": "pulid_flux_v0.9.1.safetensors"}}
    wf["102"] = {"class_type": "PulidFluxEvaClipLoader", "inputs": {}}
    wf["103"] = {"class_type": "PulidFluxInsightFaceLoader", "inputs": {"provider": "CPU"}}
    wf["104"] = {"class_type": "ApplyPulidFlux", "inputs": {"model": ["100", 0], "pulid_flux": ["101", 0], "eva_clip": ["102", 0], "face_analysis": ["103", 0], "image": ["5", 0], "weight": weight, "start_at": 0.0, "end_at": 1.0}}
    wf["105"] = {"class_type": "UltralyticsDetectorProvider", "inputs": {"model_name": "bbox/face_yolov8m.pt"}}
    wf["106"] = {
        "class_type": "FaceDetailer",
        "inputs": {
            "image": decoded, "model": ["104", 0], "clip": ["2", 0], "vae": ["3", 0],
            # the prompt without the depth ControlNet: the detailer samples a
            # crop, a full-frame depth hint does not describe it
            "positive": ["9", 0], "negative": ["10", 0], "bbox_detector": ["105", 0],
            "guide_size": 1024.0, "guide_size_for": True, "max_size": 1024.0, "seed": 0,
            "steps": 20, "cfg": 1.0, "sampler_name": "euler", "scheduler": "simple",
            "denoise": denoise, "feather": 5, "noise_mask": True, "force_inpaint": True,
            "bbox_threshold": 0.5, "bbox_dilation": 10, "bbox_crop_factor": 3.0,
            "sam_detection_hint": "center-1", "sam_dilation": 0, "sam_threshold": 0.93,
            "sam_bbox_expansion": 0, "sam_mask_hint_threshold": 0.7,
            "sam_mask_hint_use_negative": "False", "drop_size": 10, "wildcard": "", "cycle": 1,
        },
    }
    wf[save]["inputs"]["images"] = ["106", 0]


def apply_graph_variants(wf: dict, sweep: dict) -> None:
    """Structural variants named in the sweep (`graph.*`)."""
    if sweep.get("graph.composite") in (0, False, "0"):
        # Kontext without pasting the original back outside the mask.
        comp = next((k for k, n in wf.items() if n["class_type"] == "ImageCompositeMasked"), None)
        if comp:
            src = wf[comp]["inputs"]["source"]
            for n in wf.values():
                if n["class_type"] == "SaveImage":
                    n["inputs"]["images"] = src
    if sweep.get("graph.sdxl_encode") == "v2":
        # comfyui-inpaint-nodes' own encoder instead of VAEEncodeForInpaint's
        # grey fill — round 0c SDXL outputs came back olive-tinted.
        enc = next((k for k, n in wf.items() if n["class_type"] == "VAEEncodeForInpaint"), None)
        if enc:
            e = wf[enc]["inputs"]
            pos_neg = next(k for k, n in wf.items() if n["class_type"] == "KSampler")
            ks = wf[pos_neg]["inputs"]
            wf["__enc2__"] = {"class_type": "INPAINT_VAEEncodeInpaintConditioning", "inputs": {
                "positive": ks["positive"], "negative": ks["negative"], "vae": e["vae"],
                "pixels": e["pixels"], "mask": e["mask"]}}
            ks["positive"], ks["negative"] = ["__enc2__", 0], ["__enc2__", 1]
            ks["latent_image"] = ["__enc2__", 3]
            for n in wf.values():
                if n["class_type"] == "INPAINT_ApplyFooocusInpaint":
                    n["inputs"]["latent"] = ["__enc2__", 2]
            del wf[enc]


# ── hair analysis ───────────────────────────────────────────────────────────


def analyse(c: Comfy, cache: Path, src: Path, uploaded: str) -> tuple[hm.HairAnalysis, np.ndarray]:
    """Face-parsing masks of one portrait, cached by content hash."""
    data = src.read_bytes()
    d = cache / "analysis" / hashlib.sha1(data).hexdigest()[:16]
    names = dict(zip(ANALYSE_PREFIXES, ("hair", "face", "hat", "features")))
    if not all((d / f"{n}.png").exists() for n in names.values()):
        d.mkdir(parents=True, exist_ok=True)
        wf = prepare_workflow(load_template_file("hair_analyse.api.json"), prompt="", image_name=uploaded)
        for prefix, png in c.run(wf, ANALYSE_PREFIXES, timeout=900).items():
            (d / f"{names[prefix]}.png").write_bytes(png)
    masks = {n: hm.decode_mask((d / f"{n}.png").read_bytes()) for n in names.values()}
    with Image.open(src) as im:
        rgb = np.asarray(im.convert("RGB"))
    return hm.HairAnalysis(**masks), rgb


def load_template_file(name: str) -> dict:
    return json.loads((catalog.ASSETS / name).read_text())


@contextmanager
def mask_tunables(values: dict):
    """Temporarily override hairmask constants for one sweep value."""
    saved = {}
    try:
        for key, value in values.items():
            if not key.startswith("mask."):
                continue
            name = key[5:]
            if name == "ENVELOPE_SCALE":
                saved["ENVELOPES"] = hm.ENVELOPES
                hm.ENVELOPES = {
                    k: (None if v is None else tuple(x * value for x in v))
                    for k, v in hm.ENVELOPES.items()
                }
                continue
            if not hasattr(hm, name):
                raise CellError(f"hairmask has no tunable {name}")
            saved[name] = getattr(hm, name)
            setattr(hm, name, value)
        yield
    finally:
        for name, value in saved.items():
            setattr(hm, name, value)


# ── matrix ──────────────────────────────────────────────────────────────────


def plan_cells(args) -> list[dict]:
    cells = []
    sweeps = expand_sweeps(args.sweep or [])
    seeds = [int(s) for s in csv(args.seeds)] or [777]
    srcs = csv(args.srcs)
    engines = csv(args.engines)
    if args.task == "restyle":
        styles = csv(args.styles)
        if args.baseline:
            styles = [catalog.BASELINE] + [s for s in styles if s != catalog.BASELINE]
        media = csv(args.media) or ["photo"]
        for engine, medium, src, style, seed, sweep in itertools.product(
            engines, media, srcs, styles, seeds, sweeps
        ):
            catalog.restyle_style(style)  # fail on a typo before any GPU time
            ident = {"task": "restyle", "engine": engine, "medium": medium, "src": Path(src).name,
                     "style": style, "seed": seed, "sweep": sweep,
                     "ckpt": (args.ckpt or DEFAULT_CKPT) if engine == "sdxl" else None}
            cells.append(ident)
    elif args.task == "hair":
        cands = catalog.hairstyles()
        styles = list(cands) if args.styles in (None, "", "all") else csv(args.styles)
        if args.group:
            styles = [s for s in styles if cands[s]["group"] == args.group]
        for s in styles:
            if s not in cands and s != haircolours.KEEP_CUT:
                raise SystemExit(f"unknown hairstyle '{s}'")
        colours = csv(args.colours) or [None]
        for col in colours:
            if col is not None and col not in haircolours.COLOURS:
                raise SystemExit(f"unknown hair colour '{col}'")
        for engine, src, style, col, seed, sweep in itertools.product(
            engines, srcs, styles, colours, seeds, sweeps
        ):
            ident = {"task": "hair", "engine": engine, "src": Path(src).name, "style": style,
                     "seed": seed, "sweep": sweep,
                     "ckpt": (args.ckpt or DEFAULT_CKPT) if engine == "sdxl" else None}
            if col is not None:  # absent, not None: keeps pre-colour cell keys stable
                ident["colour"] = col
            cells.append(ident)
    for ident in cells:
        ident["key"] = cell_key({k: v for k, v in ident.items() if k != "key"})
    if args.limit:
        cells = cells[: args.limit]
    return cells


def run_matrix(args) -> None:
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    cells = plan_cells(args)
    src_paths = {Path(s).name: Path(s) for s in csv(args.srcs)}
    manifest_path = out / "manifest.json"
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {"cells": {}}
    manifest["task"] = args.task
    manifest.setdefault("srcs", {})
    for name, p in src_paths.items():
        (out / "srcs").mkdir(exist_ok=True)
        (out / "srcs" / name).write_bytes(p.read_bytes())
        manifest["srcs"][name] = f"srcs/{name}"
    todo = [c for c in cells if manifest["cells"].get(c["key"], {}).get("status") not in ("done", "refused")]
    log(f"{len(cells)} cells, {len(cells) - len(todo)} already finished, {len(todo)} to render")
    if args.plan:
        return

    c = Comfy(args.url)
    uploaded: dict[str, str] = {}
    cache = Path(args.cache)
    templates: dict[tuple, dict] = {}
    durations: list[float] = []

    for i, ident in enumerate(todo, 1):
        key = ident["key"]
        src = src_paths[ident["src"]]
        label = ident["style"] + (f"+{ident['colour']}" if ident.get("colour") else "")
        name = f"{label}__{ident['engine']}__{src.stem}__s{ident['seed']}__{key}.png"
        row = {**ident, "file": f"img/{name}", "status": "running"}
        c.guard(args.min_free_gb, log)
        started = time.time()
        try:
            if ident["src"] not in uploaded:
                uploaded[ident["src"]] = c.upload(src.read_bytes(), f"bench_src_{hashlib.sha1(src.read_bytes()).hexdigest()[:12]}.png")
            tpl = templates.setdefault((ident["task"], ident["engine"]), load_template(ident["task"], ident["engine"]))
            if ident["task"] == "restyle":
                prompt, negative = catalog.restyle_prompt(ident["style"], ident["medium"])
                wf = prepare_workflow(tpl, prompt=prompt, negative=negative, image_name=uploaded[ident["src"]],
                                      checkpoint=ident["ckpt"], latent=latent_for(src.read_bytes()))
                if ident["sweep"].get("graph.facepass"):
                    add_flux_face_pass(wf, weight=float(ident["sweep"].get("graph.facepass_weight", 1.2)),
                                       denoise=float(ident["sweep"].get("graph.facepass_denoise", 0.45)))
                row.update(prompt=prompt, negative=negative)
            else:
                style = catalog.hair_style(ident["style"])
                analysis, rgb = analyse(c, cache, src, uploaded[ident["src"]])
                shape = hm.HairShape(**style["shape"])
                with mask_tunables(ident["sweep"]):
                    try:
                        res = hm.build_mask(analysis, shape, "hair" if style["id"] == haircolours.KEEP_CUT else None)
                    except hm.HairMaskError as e:
                        row.update(status="refused", error=e.code)
                        raise
                mask_png = hm.to_png(res.mask)
                mask_name = c.upload(mask_png, f"bench_mask_{hashlib.sha1(mask_png).hexdigest()[:12]}.png")
                (out / "masks").mkdir(exist_ok=True)
                (out / "masks" / name).write_bytes(mask_png)
                colour = hm.estimate_colour(rgb, analysis.hair)
                prompt = catalog.hair_prompt(style, colour, ident["engine"], ident.get("colour"))
                wf = prepare_workflow(tpl, prompt=prompt, negative=catalog.HAIR_NEGATIVE,
                                      image_name=uploaded[ident["src"]], mask_name=mask_name,
                                      checkpoint=ident["ckpt"])
                row.update(prompt=prompt, colour=colour, shape=style["shape"], mask=f"masks/{name}",
                           mask_area=round(res.area, 4), face_box=res.face_box)
            apply_graph_variants(wf, ident["sweep"])
            apply_node_sweep(wf, ident["sweep"])
            set_seed(wf, ident["seed"])
            prefix = f"bench_{key}"
            set_save_prefix(wf, prefix)
            png = c.run(wf, (prefix,), timeout=args.timeout)[prefix]
            save_png_and_thumb(out, name, png)
            row["status"] = "done"
        except hm.HairMaskError:
            pass
        except CellError as e:
            row.update(status="error", error=str(e)[:300])
        except Exception as e:  # noqa: BLE001 — one broken cell must not end the run
            row.update(status="error", error=f"{type(e).__name__}: {e}"[:300])
        row["seconds"] = round(time.time() - started, 1)
        manifest["cells"][key] = row
        manifest_path.write_text(json.dumps(manifest, indent=1, ensure_ascii=False))
        if row["status"] == "done":
            durations.append(row["seconds"])
        eta = (len(todo) - i) * (sum(durations[-10:]) / max(1, len(durations[-10:])))
        log(f"[{i}/{len(todo)}] {row['status']:7} {row['seconds']:6.1f}s {name}"
            + (f"  ({row.get('error')})" if row.get("error") else "") + f"  eta {eta / 60:.0f} min")


def srcgen(args) -> None:
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    specs = json.loads((HERE / "srcs" / "prompts.json").read_text())
    c = Comfy(args.url)
    tpl = load_template_file("juggernaut_lightning_txt2img.api.json")
    for spec in specs:
        target = out / f"{spec['id']}.png"
        if target.exists():
            continue
        wf = prepare_workflow(tpl, prompt=spec["prompt"], latent=(832, 1216))
        set_seed(wf, spec["seed"])
        prefix = f"bench_src_{spec['id']}"
        set_save_prefix(wf, prefix)
        target.write_bytes(c.run(wf, (prefix,), timeout=300)[prefix])
        log(f"src {target}")


def analyse_srcs(args) -> None:
    """Face-parsing masks + hair colour of each source, nothing rendered."""
    c = Comfy(args.url)
    for src in map(Path, csv(args.srcs)):
        up = c.upload(src.read_bytes(), f"bench_src_{hashlib.sha1(src.read_bytes()).hexdigest()[:12]}.png")
        a, rgb = analyse(c, Path(args.cache), src, up)
        box = hm.face_box(a.face)
        log(f"{src.name}: face_box={box} hair={a.hair.mean():.3f} colour={hm.estimate_colour(rgb, a.hair)}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("task", choices=["restyle", "hair", "srcgen", "analyse"])
    ap.add_argument("--url", default="http://127.0.0.1:8188")
    ap.add_argument("--out")
    ap.add_argument("--cache", default=str(HERE / "cache"))
    ap.add_argument("--engines", default="flux")
    ap.add_argument("--media", default="photo")
    ap.add_argument("--styles")
    ap.add_argument("--group", choices=["Women", "Men"])
    ap.add_argument("--colours", help="haircolours ids; with --styles keep-cut a colour-only round")
    ap.add_argument("--srcs")
    ap.add_argument("--seeds", default="777")
    ap.add_argument("--sweep", nargs="*")
    ap.add_argument("--ckpt")
    ap.add_argument("--baseline", action="store_true")
    ap.add_argument("--limit", type=int)
    ap.add_argument("--plan", action="store_true")
    ap.add_argument("--timeout", type=float, default=900)
    ap.add_argument("--min-free-gb", type=float, default=8.0)
    args = ap.parse_args()
    if args.task == "srcgen":
        srcgen(args)
    elif args.task == "analyse":
        analyse_srcs(args)
    else:
        run_matrix(args)


if __name__ == "__main__":
    main()
