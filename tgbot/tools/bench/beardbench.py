"""Bench task `beard` (Prompts/08-PLAN-vousy.md §6).

Cells run through `run.py`'s own matrix loop; this module adds what is specific
to beards: the cell's mask and prompt, the metrics, the per-portrait gate. The
mask and the prompt come from the bot's `beardmask` / `beardprompt`, so the bench
measures what ships. `analysis` reads all seven outputs of hair_analyse (the
hair task needs four; a beard mask without lips, nose and ears is a different
mask).

Pure functions up top run without a GPU; `score_run` needs ComfyUI, insightface
and CLIP, all imported through `score` when it is called.
"""

from __future__ import annotations

import hashlib
import io
import itertools
import json
from collections import defaultdict
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image

import beardmask as bm
import beardprompt
import catalog
import hairmask as hm
from comfy import prepare_workflow
from comfysync import CellError

METRICS_VERSION = 1
ENGINES = ("kontext",)

THRESHOLDS = {
    "identity_min": 0.60,
    "rate": 2 / 3,
    "beard_gain": 0.10,  # target section's CLIP probability, output over source
    "lips_max": 2.0,  # mean |output − source| over the lips, of 255
    "outside_max": 1.0,  # the same outside the mask and its feathered edge
}

# CLIP labels. One class per kBeardSections entry: `Shave` is "clean-shaven".
SECTION_TEXTS = {
    "Shave": "a close-up photo of a clean-shaven man's chin and jaw, smooth bare skin, no facial hair",
    "Stubble": "a close-up photo of a man's chin and jaw with short stubble",
    "Short": "a close-up photo of a man's chin and jaw with a short neatly trimmed beard",
    "Full": "a close-up photo of a man's chin and jaw with a long thick full beard",
    "Goatee": "a close-up photo of a man's chin with a goatee and shaved cheeks",
    "Moustache": "a close-up photo of a man's mouth with a moustache and shaved cheeks and chin",
}
SECTIONS = tuple(SECTION_TEXTS)
SHAVED_KINDS = ("chin", "moustache")  # narrow masks: an old beard stays unless the mask grows


# ── analysis ────────────────────────────────────────────────────────────────


def full_analysis(c, cache: Path, png: bytes, uploaded: str | None = None) -> hm.HairAnalysis:
    """All masks of hair_analyse, by SaveImage prefix (`hm.ANALYSE_OUTPUTS`),
    cached by content hash next to what the hair task caches."""
    d = cache / "analysis" / hashlib.sha1(png).hexdigest()[:16]
    names = hm.ANALYSE_OUTPUTS
    if not all((d / f"{n}.png").exists() for n in names.values()):
        d.mkdir(parents=True, exist_ok=True)
        name = uploaded or c.upload(png, f"bench_src_{hashlib.sha1(png).hexdigest()[:12]}.png")
        template = json.loads((catalog.ASSETS / "hair_analyse.api.json").read_text())
        wf = prepare_workflow(template, prompt="", image_name=name)
        for prefix, data in c.run(wf, tuple(names), timeout=900).items():
            (d / f"{names[prefix]}.png").write_bytes(data)
    return hm.HairAnalysis(**{n: hm.decode_mask((d / f"{n}.png").read_bytes()) for n in names.values()})


def rgb_of(png: bytes) -> np.ndarray:
    with Image.open(io.BytesIO(png)) as im:
        return np.asarray(im.convert("RGB"))


# ── sweep keys ──────────────────────────────────────────────────────────────


def _mask_keys(sweep: dict) -> list[tuple[str, object]]:
    return [(k[5:], v) for k, v in sweep.items() if k.startswith("mask.")]


def check_sweep(sweep: dict) -> None:
    """A typo in a tunable fails before any GPU time."""
    for name, _ in _mask_keys(sweep):
        if name == "SIDE_fw" or name.startswith("BELOW_CHIN_"):
            continue
        if not hasattr(bm, name) and not hasattr(hm, name):
            raise SystemExit(f"beard: no tunable {name} in beardmask or hairmask")


@contextmanager
def tunables(sweep: dict):
    """Temporarily override beardmask/hairmask constants for one sweep value.

    Separate from `run.mask_tunables` on purpose: there `mask.BELOW_*` means a
    glasses size, here `mask.BELOW_CHIN_<kind>` means how far a region hangs
    under the chin (read by `region_of`). `mask.SIDE_fw` moves both sides of the
    mask, full and jaw."""
    saved: list[tuple[object, str, object]] = []

    def override(module, name, value):
        saved.append((module, name, getattr(module, name)))
        setattr(module, name, value)

    try:
        for name, value in _mask_keys(sweep):
            if name.startswith("BELOW_CHIN_"):
                continue
            if name == "SIDE_fw":
                override(bm, "FULL_SIDE_FW", value)
                override(bm, "JAW_SIDE_FW", value)
            elif hasattr(bm, name):
                override(bm, name, value)
            elif hasattr(hm, name):
                override(hm, name, value)
            else:
                raise CellError(f"beard: no tunable {name}")
        yield
    finally:
        for module, name, value in reversed(saved):
            setattr(module, name, value)


def region_of(style: dict, sweep: dict) -> bm.BeardRegion:
    fields = dict(style["region"])
    override = sweep.get(f"mask.BELOW_CHIN_{fields['kind']}")
    if override is not None:
        fields["below_chin"] = override
    return bm.BeardRegion(**fields)


def mode_of(style: dict) -> str | None:
    return "shave" if style["id"] == beardprompt.CLEAN else None


# ── cells ───────────────────────────────────────────────────────────────────


def plan(args, sweeps: list[dict], seeds: list[int], srcs: list[str], engines: list[str]) -> list[dict]:
    cands = catalog.beards()
    styles = list(cands) if args.styles in (None, "", "all") else [s.strip() for s in args.styles.split(",")]
    for s in styles:
        if s not in cands:
            raise SystemExit(f"unknown beard style '{s}'")
    for e in engines:
        if e not in ENGINES:
            raise SystemExit(f"beard runs on {ENGINES}, not '{e}'")
    for sweep in sweeps:
        check_sweep(sweep)
    return [
        {"task": "beard", "engine": engine, "src": Path(src).name, "style": style,
         "seed": seed, "sweep": sweep, "ckpt": None}
        for engine, src, style, seed, sweep in itertools.product(engines, srcs, styles, seeds, sweeps)
    ]


@dataclass
class CellContext:
    """What `run.run_matrix` hands a task-specific cell builder."""

    comfy: object
    cache: Path
    out: Path
    name: str  # the cell's file name
    src: Path
    uploaded: str
    template: dict


def build(ctx: CellContext, ident: dict, row: dict) -> dict:
    """The cell's graph. A photo the card would refuse leaves the row `refused`
    and raises, as the hair branch of run_matrix does."""
    style = catalog.beards()[ident["style"]]
    sweep = ident["sweep"]
    png = ctx.src.read_bytes()
    analysis, rgb = full_analysis(ctx.comfy, ctx.cache, png, ctx.uploaded), rgb_of(png)
    beard = bm.detect_beard(rgb, analysis)
    with tunables(sweep):
        try:
            res = bm.build_mask(analysis, region_of(style, sweep), mode_of(style), beard)
        except hm.HairMaskError as e:
            row.update(status="refused", error=e.code, has_beard=beard)
            raise
    mask_png = hm.to_png(res.mask)
    mask_name = ctx.comfy.upload(mask_png, f"bench_mask_{hashlib.sha1(mask_png).hexdigest()[:12]}.png")
    (ctx.out / "masks").mkdir(exist_ok=True)
    (ctx.out / "masks" / ctx.name).write_bytes(mask_png)
    colour = hm.estimate_colour(rgb, analysis.hair)
    prompt = catalog.beard_prompt(style, colour, grey=bool(sweep.get("graph.grey")))
    wf = prepare_workflow(ctx.template, prompt=prompt, negative=beardprompt.NEGATIVE,
                          image_name=ctx.uploaded, mask_name=mask_name)
    with tunables(sweep):
        hm.apply_feather(wf, mask_png)
    row.update(prompt=prompt, colour_src=colour, has_beard=beard, region=style["region"],
               mask=f"masks/{ctx.name}", mask_area=round(res.area, 4), face_box=res.face_box)
    return wf


# ── metrics ─────────────────────────────────────────────────────────────────


def crop_box(box: tuple[int, int, int, int], shape: tuple[int, ...], factor: float = 1.3) -> tuple[int, int, int, int]:
    """`box` grown `factor` times around its centre, clipped to the image."""
    x0, y0, x1, y1 = box
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    hw, hh = (x1 - x0 + 1) * factor / 2, (y1 - y0 + 1) * factor / 2
    h, w = shape[:2]
    return max(0, int(cx - hw)), max(0, int(cy - hh)), min(w, int(cx + hw)), min(h, int(cy + hh))


def mean_diff(out: np.ndarray, src: np.ndarray, where: np.ndarray) -> float | None:
    """Mean |output − source| over `where`. None when the sizes differ (`clean`
    reports that) or there is nothing to measure."""
    if out.shape != src.shape or where.shape != src.shape[:2] or not where.any():
        return None
    return float(np.abs(out.astype(np.int16) - src.astype(np.int16))[where].mean())


def outside_diff(out: np.ndarray, src: np.ndarray, mask: np.ndarray, margin: int) -> float | None:
    """Outside the mask and its feathered edge the composite is the source."""
    if mask.shape != src.shape[:2]:
        return None
    keep = ~hm.dilate(mask, margin)
    return mean_diff(out, src, keep) if keep.any() else 0.0


def beard_ok(p_out: np.ndarray, p_src: np.ndarray, section: str) -> bool:
    """Target section on top of the CLIP labels and gained on the source. A
    target the source already shows cannot gain: top on both counts, as for
    hair; `clean-shaven` only has to end up on top."""
    t = SECTIONS.index(section)
    if int(p_out.argmax()) != t:
        return False
    if section == "Shave" or int(p_src.argmax()) == t:
        return True
    return bool(p_out[t] - p_src[t] >= THRESHOLDS["beard_gain"])


def shaved_cheeks(rgb: np.ndarray, a: hm.HairAnalysis, narrow: np.ndarray) -> bool | None:
    """`has_beard` on the output's cheeks: the skin of the lower face without
    the style's own hair (`narrow`, its region's mask). True = shaved, False =
    the old beard is still there, None = cannot tell."""
    box = bm.lower_face_box(a.face, a.nose, a.lips)
    if box is None:
        return None
    skin = a.face & ~a.lips & ~a.nose & ~a.features & ~narrow
    verdict = bm.has_beard(rgb, skin, box)
    return None if verdict is None else not verdict


def rate(cells: list[dict], key: str) -> float | None:
    vals = [m[key] for m in cells if m.get(key) is not None]
    return sum(map(bool, vals)) / len(vals) if vals else None


def portrait_reasons(cells: list[dict]) -> list[str]:
    """Why one portrait fails a style; [] = passed."""
    T = THRESHOLDS
    why = []
    done = [m for m in cells if m.get("status") == "done"]
    if not done:
        return ["nothing rendered"]
    if len(done) < len(cells):
        why.append(f"{len(cells) - len(done)} errors")
    ids = [m.get("identity") for m in done]
    if any(i is None for i in ids):
        why.append("face lost")
    elif min(ids) < T["identity_min"]:
        why.append(f"identity {min(ids):.2f}")
    for key in ("beard_ok", "shaved_cheeks"):
        r = rate(done, key)
        if r is not None and r < T["rate"]:
            why.append(f"{key} {r:.0%}")
    for key in ("lips_ok", "outside_ok", "clean"):
        if not all(m.get(key) for m in done):
            why.append(key.removesuffix("_ok"))
    return why


def gate(by_src: dict[str, list[dict]]) -> tuple[dict, list[str]]:
    """A style passes on ≥ 2/3 of the portraits. A portrait the card refuses
    (`no_beard_to_shave` on a bare face) says nothing about the style, so the
    caller leaves it out, as the glasses gate does."""
    passed, reasons = 0, []
    for src, cells in sorted(by_src.items()):
        why = portrait_reasons(cells)
        if why:
            reasons.append(f"{Path(src).stem}: {', '.join(why)}")
        else:
            passed += 1
    total = len(by_src)
    ok = total > 0 and passed / total >= THRESHOLDS["rate"]
    return {"srcs_passed": passed, "srcs": total}, ([] if ok else reasons or ["no portraits"])


def summarise(manifest: dict, metrics: dict) -> dict:
    groups: dict[tuple, list] = defaultdict(list)
    for key, row in manifest["cells"].items():
        groups[(row["style"], row["engine"], json.dumps(row["sweep"], sort_keys=True))].append(
            (row, metrics.get(key, {})))
    out = {}
    for (style, engine, sweep), items in sorted(groups.items()):
        by_src: dict[str, list[dict]] = defaultdict(list)
        for r, m in items:
            if r["status"] != "refused":
                by_src[r["src"]].append(m if m else {"status": r["status"]})
        s, reasons = gate(by_src)
        done = [m for _, m in items if m.get("status") == "done"]
        ids = [m["identity"] for m in done if m.get("identity") is not None]
        s.update(
            cells=len(items), done=len(done),
            refused=sum(r["status"] == "refused" for r, _ in items),
            errors=sum(r["status"] == "error" for r, _ in items),
            identity_min=min(ids) if ids else None,
            identity_mean=round(sum(ids) / len(ids), 3) if ids else None,
            clean=rate(done, "clean"), beard_ok=rate(done, "beard_ok"),
            shaved_cheeks=rate(done, "shaved_cheeks"),
            lips=max((m["lips"] for m in done if m.get("lips") is not None), default=None),
            outside=max((m["outside"] for m in done if m.get("outside") is not None), default=None),
            auto="pass" if not reasons else "fail", reasons=reasons,
        )
        out[f"{style}|{engine}||{sweep}"] = s
    return out


# ── scoring (SPARK) ─────────────────────────────────────────────────────────


def score_run(run: Path, manifest: dict, url: str, cache: Path) -> dict:
    import score as sc

    cells = manifest["cells"]
    prev = json.loads((run / "metrics.json").read_text()) if (run / "metrics.json").exists() else {"cells": {}}
    c = sc.Comfy(url)
    styles = catalog.beards()
    texts = [SECTION_TEXTS[s] for s in SECTIONS]
    srcs: dict[str, dict] = {}
    out_cells: dict[str, dict] = {}

    def src_info(name: str) -> dict:
        if name not in srcs:
            png = (run / manifest["srcs"][name]).read_bytes()
            img = rgb_of(png)
            a = full_analysis(c, cache, png)
            srcs[name] = {"img": img, "emb": sc.embedding(img)[0], "analysis": a,
                          "lower": bm.lower_face_box(a.face, a.nose, a.lips)}
        return srcs[name]

    for key, row in cells.items():
        if row["status"] != "done":
            out_cells[key] = {"status": row["status"], "error": row.get("error")}
            continue
        if (prev.get("metrics_version") == METRICS_VERSION and key in prev["cells"]
                and prev["cells"][key].get("scored_file") == row["file"]):
            out_cells[key] = prev["cells"][key]
            continue
        src = src_info(row["src"])
        style = styles[row["style"]]
        out_png = (run / row["file"]).read_bytes()
        out_img = rgb_of(out_png)
        emb, n_faces = sc.embedding(out_img)
        a = full_analysis(c, cache, out_png)
        mask = hm.decode_mask((run / row["mask"]).read_bytes())
        lips = mean_diff(out_img, src["img"], src["analysis"].lips)
        outside = outside_diff(out_img, src["img"], mask, sum(hm.feather_px(out_img.shape[1], out_img.shape[0])))
        box = crop_box(src["lower"], out_img.shape)
        p_out = sc.clip_probs(Image.fromarray(out_img).crop(box), texts)
        p_src = sc.clip_probs(Image.fromarray(src["img"]).crop(box), texts)
        m = {
            "status": "done", "scored_file": row["file"],
            "identity": None if emb is None or src["emb"] is None else round(float(emb @ src["emb"]), 3),
            "faces": n_faces,
            "clean": n_faces == 1 and out_img.shape == src["img"].shape,
            "beard_ok": beard_ok(p_out, p_src, style["section"]),
            "beard_top": SECTIONS[int(p_out.argmax())],
            "lips": None if lips is None else round(lips, 2),
            "lips_ok": lips is not None and lips <= THRESHOLDS["lips_max"],
            "outside": None if outside is None else round(outside, 2),
            "outside_ok": outside is not None and outside <= THRESHOLDS["outside_max"],
            "has_beard_out": bm.detect_beard(out_img, a) if out_img.shape[:2] == a.face.shape else None,
        }
        if style["region"]["kind"] in SHAVED_KINDS:
            with tunables(row["sweep"]):
                narrow = bm.build_mask(src["analysis"], region_of(style, row["sweep"])).mask
            m["shaved_cheeks"] = shaved_cheeks(out_img, a, narrow)
        out_cells[key] = m
        print(f"{row['style']:18} {row['src']:18} {json.dumps({k: v for k, v in m.items() if k not in ('status', 'scored_file')})}", flush=True)
    return {"metrics_version": METRICS_VERSION, "cells": out_cells, "thresholds": THRESHOLDS,
            "summary": summarise(manifest, out_cells)}


def write_summary_md(run: Path, manifest: dict, metrics: dict) -> None:
    pct = lambda v: "—" if v is None else f"{v:.0%}"  # noqa: E731
    lines = [f"# {run.name} — beard", "",
             "| style | sweep | done | portraits | identity min/mean | beard | shaved | lips | outside | clean | auto |",
             "|---|---|---|---|---|---|---|---|---|---|---|"]
    for key, s in metrics["summary"].items():
        style, _, _, sweep = key.split("|", 3)
        sweep = "" if sweep == "{}" else sweep
        ident = f"{s['identity_min']:.2f} / {s['identity_mean']:.2f}" if s["identity_min"] is not None else "—"
        done = f"{s['done']}/{s['cells']}" + (f" ({s['refused']} refused)" if s["refused"] else "")
        auto = s["auto"] + ("" if not s["reasons"] else f" ({', '.join(s['reasons'])})")
        lines.append(f"| {style} | {sweep} | {done} | {s['srcs_passed']}/{s['srcs']} | {ident} | {pct(s['beard_ok'])} | "
                     f"{pct(s['shaved_cheeks'])} | {s['lips'] if s['lips'] is not None else '—'} | "
                     f"{s['outside'] if s['outside'] is not None else '—'} | {pct(s['clean'])} | {auto} |")
    (run / "summary.md").write_text("\n".join(lines) + "\n")


def badge_bits(m: dict) -> list[tuple[str, str]]:
    """(css class, text) under a cell in sheet.py."""
    bits = [("ok" if m.get(k) else "bad", label) for k, label in
            (("beard_ok", "beard"), ("shaved_cheeks", "shaved"), ("lips_ok", "lips"), ("outside_ok", "outside"))
            if m.get(k) is not None]
    if m.get("beard_top"):
        bits.append(("dim", m["beard_top"]))
    return bits


def main(argv: list[str], host) -> None:
    ap = host.task_parser("beard", engines="kontext")
    host.run_matrix(ap.parse_args(argv))
