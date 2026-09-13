#!/usr/bin/env python3
"""Score a bench run: metrics per cell, auto-verdict per style × engine.

    score.py out/hair-r1            # → metrics.json + summary.md
    score.py out/restyle-a

Runs on SPARK in ComfyUI's venv (insightface, transformers CLIP); the hair
metrics re-run `hair_analyse.api.json` on every output through ComfyUI, cached
by content hash, so re-scoring after a threshold change costs no GPU time.

Identity is ArcFace cosine (insightface antelopev2, the largest face) — the
same scale as Ol1nLLM's tools/facebench: 1.0 same image, ~0.6 same person,
<0.4 a stranger. The numbers are reported raw; thresholds live in THRESHOLDS
and in `verdict()`, so they can be changed and re-applied without re-rendering.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path[:0] = [str(HERE.parents[1]), str(HERE)]

import numpy as np  # noqa: E402
from PIL import Image  # noqa: E402

import catalog  # noqa: E402
import hairmask as hm  # noqa: E402
from comfy import prepare_workflow  # noqa: E402
from comfysync import Comfy  # noqa: E402

INSIGHTFACE_ROOT = Path.home() / "Code" / "ComfyUI" / "models" / "insightface"
CLIP_MODEL = "openai/clip-vit-large-patch14"
ANALYSE_PREFIXES = ("tsumiki_hair_mask", "tsumiki_face_mask", "tsumiki_hat_mask", "tsumiki_features_mask")

THRESHOLDS = {
    "identity_min": 0.60,  # every cell of a style × engine
    "rate": 2 / 3,  # share of cells that must pass each hair check
    "short_below_max": 0.35,  # lowest hair, face heights below the chin
    "medium_below": (-0.3, 1.3),
    "long_below_min": 0.9,
    "keep_below_delta": 0.5,
    "updo_below_max": 0.5,
    "bangs_cover": {"full": 0.5, "side": 0.3, "curtain": 0.2, "wispy": 0.2},
    "no_bangs_extra": 0.10,
    "clip_top": 3,
    "clip_gain": 0.05,
    "style_reaction_min": 0.10,  # restyle: histogram distance from baseline
}


# ── faces ───────────────────────────────────────────────────────────────────

_face_app = None


def faces(img: np.ndarray):
    global _face_app
    if _face_app is None:
        from insightface.app import FaceAnalysis

        _face_app = FaceAnalysis(name="antelopev2", root=str(INSIGHTFACE_ROOT), providers=["CPUExecutionProvider"])
        _face_app.prepare(ctx_id=-1, det_size=(640, 640))
    return [f for f in _face_app.get(img[:, :, ::-1]) if f.det_score >= 0.5]


def embedding(img: np.ndarray):
    fs = faces(img)
    if not fs:
        return None, 0
    f = max(fs, key=lambda x: (x.bbox[2] - x.bbox[0]) * (x.bbox[3] - x.bbox[1]))
    e = f.normed_embedding
    return e / np.linalg.norm(e), len(fs)


# ── colour histogram (Ol1nLLM tools/lab/metrics.go, same 512 bins) ──────────


def histogram(img: np.ndarray) -> np.ndarray:
    h, w = img.shape[:2]
    ys = (np.arange(96) * h // 96)[:, None]
    xs = (np.arange(96) * w // 96)[None, :]
    px = img[ys, xs].astype(np.int64) >> 5
    idx = px[..., 0] * 64 + px[..., 1] * 8 + px[..., 2]
    hist = np.bincount(idx.ravel(), minlength=512).astype(float)
    return hist / hist.sum()


def cos_dist(a, b) -> float:
    na, nb = np.linalg.norm(a), np.linalg.norm(b)
    return 1.0 if na == 0 or nb == 0 else float(1 - a @ b / (na * nb))


# ── CLIP ────────────────────────────────────────────────────────────────────

_clip = None


def clip_probs(img: Image.Image, texts: list[str]) -> np.ndarray:
    global _clip
    import torch
    from transformers import CLIPModel, CLIPProcessor

    if _clip is None:
        dev = "cuda" if torch.cuda.is_available() else "cpu"
        _clip = (CLIPModel.from_pretrained(CLIP_MODEL).to(dev).eval(), CLIPProcessor.from_pretrained(CLIP_MODEL), dev, {})
    model, proc, dev, text_cache = _clip
    key = tuple(texts)
    if key not in text_cache:
        with torch.no_grad():
            t = proc(text=texts, return_tensors="pt", padding=True).to(dev)
            te = model.get_text_features(**t)
            text_cache[key] = te / te.norm(dim=-1, keepdim=True)
    with torch.no_grad():
        i = proc(images=img, return_tensors="pt").to(dev)
        ie = model.get_image_features(**i)
        ie = ie / ie.norm(dim=-1, keepdim=True)
        logits = model.logit_scale.exp() * ie @ text_cache[key].T
    return logits.softmax(dim=-1)[0].float().cpu().numpy()


# ── hair geometry ───────────────────────────────────────────────────────────


def analysis_for(c: Comfy, cache: Path, png: bytes) -> hm.HairAnalysis:
    d = cache / "analysis" / hashlib.sha1(png).hexdigest()[:16]
    names = dict(zip(ANALYSE_PREFIXES, ("hair", "face", "hat", "features")))
    if not all((d / f"{n}.png").exists() for n in names.values()):
        d.mkdir(parents=True, exist_ok=True)
        uploaded = c.upload(png, f"bench_score_{hashlib.sha1(png).hexdigest()[:12]}.png")
        wf = prepare_workflow(json.loads((catalog.ASSETS / "hair_analyse.api.json").read_text()), prompt="", image_name=uploaded)
        for prefix, data in c.run(wf, ANALYSE_PREFIXES, timeout=300).items():
            (d / f"{names[prefix]}.png").write_bytes(data)
    return hm.HairAnalysis(**{n: hm.decode_mask((d / f"{n}.png").read_bytes()) for n in names.values()})


def hair_below(hair: np.ndarray, box) -> float | None:
    """Lowest hair near the head, in face heights below the chin."""
    x0, y0, x1, y1 = box
    fw, fh = x1 - x0 + 1, y1 - y0 + 1
    w = hair.shape[1]
    band = hair[:, max(0, int(x0 - 1.5 * fw)) : min(w, int(x1 + 1.5 * fw))]
    rows = np.nonzero(band.sum(axis=1) >= max(5, 0.03 * fw))[0]
    return None if rows.size == 0 else float((rows.max() - y1) / fh)


def fringe_cover(hair: np.ndarray, box) -> float:
    x0, y0, x1, y1 = box
    fw, fh = x1 - x0 + 1, y1 - y0 + 1
    region = hair[y0 : y0 + max(1, int(0.33 * fh)), int(x0 + 0.15 * fw) : int(x1 - 0.15 * fw) + 1]
    return float(region.mean()) if region.size else 0.0


def head_crop(img: Image.Image, box) -> Image.Image:
    x0, y0, x1, y1 = box
    fw, fh = x1 - x0 + 1, y1 - y0 + 1
    return img.crop((max(0, int(x0 - 1.3 * fw)), max(0, int(y0 - 1.0 * fh)),
                     min(img.width, int(x1 + 1.3 * fw)), min(img.height, int(y1 + 2.0 * fh))))


def length_ok(style_id: str, shape: dict, below_out, below_src):
    T = THRESHOLDS
    if below_out is None:
        return False if shape["length"] != "keep" or shape["updo"] else None
    if shape["updo"]:
        return None if style_id == "half-up" else below_out <= T["updo_below_max"]
    return {
        "keep": None if below_src is None else abs(below_out - below_src) <= T["keep_below_delta"],
        "short": below_out <= T["short_below_max"],
        "medium": T["medium_below"][0] <= below_out <= T["medium_below"][1],
        "long": below_out >= T["long_below_min"],
    }[shape["length"]]


def bangs_ok(shape: dict, cover_out: float, cover_src: float) -> bool:
    T = THRESHOLDS
    if shape["bangs"] == "none":
        return cover_out <= max(0.35, cover_src + T["no_bangs_extra"])
    return cover_out >= T["bangs_cover"][shape["bangs"]]


# ── scoring ─────────────────────────────────────────────────────────────────


def score(run: Path, url: str, cache: Path) -> dict:
    manifest = json.loads((run / "manifest.json").read_text())
    cells = manifest["cells"]
    prev = json.loads((run / "metrics.json").read_text()) if (run / "metrics.json").exists() else {"cells": {}}
    c = Comfy(url)
    src_cache: dict[str, dict] = {}
    out_cells: dict[str, dict] = {}
    hair_styles = catalog.hairstyles() if manifest["task"] == "hair" else {}

    def src_info(name: str) -> dict:
        if name not in src_cache:
            path = run / manifest["srcs"][name]
            png = path.read_bytes()
            img = np.asarray(Image.open(path).convert("RGB"))
            emb, _ = embedding(img)
            info = {"png": png, "img": img, "emb": emb}
            if manifest["task"] == "hair":
                a = analysis_for(c, cache, png)
                box = hm.face_box(a.face)
                info.update(analysis=a, box=box,
                            below=hair_below(a.hair, box) if box else None,
                            cover=fringe_cover(a.hair, box) if box else 0.0)
            src_cache[name] = info
        return src_cache[name]

    baselines = {}
    if manifest["task"] == "restyle":
        for key, row in cells.items():
            if row["style"] == catalog.BASELINE and row["status"] == "done":
                gk = (row["engine"], row["medium"], row["src"], row["seed"], json.dumps(row["sweep"], sort_keys=True))
                baselines[gk] = histogram(np.asarray(Image.open(run / row["file"]).convert("RGB")))

    for key, row in cells.items():
        if row["status"] != "done":
            out_cells[key] = {"status": row["status"], "error": row.get("error")}
            continue
        if key in prev["cells"] and prev["cells"][key].get("scored_file") == row["file"]:
            out_cells[key] = prev["cells"][key]
            continue
        src = src_info(row["src"])
        out_png = (run / row["file"]).read_bytes()
        out_img = np.asarray(Image.open(io.BytesIO(out_png)).convert("RGB"))
        emb, n_faces = embedding(out_img)
        m = {
            "status": "done",
            "scored_file": row["file"],
            "identity": None if emb is None or src["emb"] is None else round(float(emb @ src["emb"]), 3),
            "faces": n_faces,
        }
        if manifest["task"] == "restyle":
            m["clean"] = n_faces == 1
            gk = (row["engine"], row["medium"], row["src"], row["seed"], json.dumps(row["sweep"], sort_keys=True))
            if row["style"] != catalog.BASELINE and gk in baselines:
                m["reaction"] = round(cos_dist(histogram(out_img), baselines[gk]), 3)
        else:
            style = hair_styles[row["style"]]
            shape = style["shape"]
            m["clean"] = n_faces == 1 and out_img.shape == src["img"].shape
            box = src["box"]
            a = analysis_for(c, cache, out_png)
            below = hair_below(a.hair, box)
            cover = fringe_cover(a.hair, box)
            inter = (a.hair & src["analysis"].hair).sum()
            union = (a.hair | src["analysis"].hair).sum()
            m.update(
                below=None if below is None else round(below, 2),
                below_src=None if src["below"] is None else round(src["below"], 2),
                cover=round(cover, 2),
                cover_src=round(src["cover"], 2),
                changed=round(1 - inter / union, 2) if union else None,
                length_ok=length_ok(row["style"], shape, below, src["below"]),
                bangs_ok=bangs_ok(shape, cover, src["cover"]),
            )
            group = [h for h in hair_styles.values() if h["group"] == style["group"]]
            labels = [h["id"] for h in group]
            texts = [f"a photo of a person with a {h['label']} hairstyle" for h in group]
            t = labels.index(row["style"])
            p_out = clip_probs(head_crop(Image.fromarray(out_img), box), texts)
            p_src = clip_probs(head_crop(Image.fromarray(src["img"]), box), texts)
            rank_out = int((p_out > p_out[t]).sum()) + 1
            rank_src = int((p_src > p_src[t]).sum()) + 1
            m.update(
                clip_p=round(float(p_out[t]), 3), clip_p_src=round(float(p_src[t]), 3),
                clip_rank=rank_out, clip_rank_src=rank_src,
                clip_top_other=labels[int(p_out.argmax())],
            )
            m["recognised"] = rank_out <= THRESHOLDS["clip_top"] and (
                p_out[t] - p_src[t] >= THRESHOLDS["clip_gain"] or (rank_out == 1 and rank_src == 1)
            )
        out_cells[key] = m
        print(f"{row['style']:22} {row['engine']:5} {row['src']:18} {json.dumps({k: v for k, v in m.items() if k not in ('status', 'scored_file')})}", flush=True)

    return {"cells": out_cells, "thresholds": THRESHOLDS, "summary": summarise(manifest, out_cells)}


def summarise(manifest: dict, metrics: dict) -> dict:
    groups: dict[tuple, list] = defaultdict(list)
    for key, row in manifest["cells"].items():
        sweep = json.dumps(row["sweep"], sort_keys=True)
        groups[(row["style"], row["engine"], row.get("medium", ""), sweep)].append((row, metrics.get(key, {})))
    out = {}
    for (style, engine, medium, sweep), items in sorted(groups.items()):
        done = [m for _, m in items if m.get("status") == "done"]
        refused = [r for r, m in items if r["status"] == "refused"]
        errors = [r for r, m in items if r["status"] == "error"]
        ids = [m["identity"] for m in done if m.get("identity") is not None]
        s = {
            "cells": len(items), "done": len(done), "refused": len(refused), "errors": len(errors),
            "identity_min": min(ids) if ids else None,
            "identity_mean": round(sum(ids) / len(ids), 3) if ids else None,
            "clean": sum(1 for m in done if m.get("clean")) / len(done) if done else None,
        }
        reasons = []
        if not done:
            reasons.append("nothing rendered")
        if errors:
            reasons.append(f"{len(errors)} errors")
        if len(ids) < len(done):
            reasons.append("face lost")
        elif ids and min(ids) < THRESHOLDS["identity_min"]:
            reasons.append(f"identity {min(ids):.2f}")
        if done and s["clean"] < 1:
            reasons.append("not clean")
        if manifest["task"] == "hair":
            for check in ("length_ok", "bangs_ok", "recognised"):
                vals = [m[check] for m in done if m.get(check) is not None]
                rate = sum(vals) / len(vals) if vals else None
                s[check] = None if rate is None else round(rate, 2)
                if rate is not None and rate < THRESHOLDS["rate"]:
                    reasons.append(f"{check} {rate:.0%}")
        else:
            reacts = [m["reaction"] for m in done if m.get("reaction") is not None]
            s["reaction_mean"] = round(sum(reacts) / len(reacts), 3) if reacts else None
        s["auto"] = "pass" if not reasons else "fail"
        s["reasons"] = reasons
        out[f"{style}|{engine}|{medium}|{sweep}"] = s
    return out


def write_summary_md(run: Path, manifest: dict, metrics: dict) -> None:
    lines = [f"# {run.name} — {manifest['task']}", ""]
    if manifest["task"] == "hair":
        lines += ["| style | engine | sweep | done | identity min/mean | length | bangs | CLIP | clean | auto |",
                  "|---|---|---|---|---|---|---|---|---|---|"]
    else:
        lines += ["| style | engine | medium | sweep | done | identity min/mean | reaction | clean | auto |",
                  "|---|---|---|---|---|---|---|---|---|"]
    fmt = lambda v: "—" if v is None else (f"{v:.0%}" if isinstance(v, float) and v <= 1 else str(v))
    for key, s in metrics["summary"].items():
        style, engine, medium, sweep = key.split("|", 3)
        sweep = "" if sweep == "{}" else sweep
        ident = f"{s['identity_min']:.2f} / {s['identity_mean']:.2f}" if s["identity_min"] is not None else "—"
        auto = s["auto"] + ("" if not s["reasons"] else f" ({', '.join(s['reasons'])})")
        done = f"{s['done']}/{s['cells']}" + (f" ({s['refused']} refused)" if s["refused"] else "")
        if manifest["task"] == "hair":
            lines.append(f"| {style} | {engine} | {sweep} | {done} | {ident} | {fmt(s.get('length_ok'))} | "
                         f"{fmt(s.get('bangs_ok'))} | {fmt(s.get('recognised'))} | {fmt(s['clean'])} | {auto} |")
        else:
            lines.append(f"| {style} | {engine} | {medium} | {sweep} | {done} | {ident} | "
                         f"{s.get('reaction_mean') if s.get('reaction_mean') is not None else '—'} | {fmt(s['clean'])} | {auto} |")
    (run / "summary.md").write_text("\n".join(lines) + "\n")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("run")
    ap.add_argument("--url", default="http://127.0.0.1:8188")
    ap.add_argument("--cache", default=str(HERE / "cache"))
    args = ap.parse_args()
    run = Path(args.run)
    metrics = score(run, args.url, Path(args.cache))
    (run / "metrics.json").write_text(json.dumps(metrics, indent=1))
    write_summary_md(run, json.loads((run / "manifest.json").read_text()), metrics)
    print((run / "summary.md").read_text())


if __name__ == "__main__":
    main()
