"""Bench task `live` (Prompts/09-PLAN-zivy-portret.md §4): does the clip do what
the preset says, and is it still that person.

Cells render through ComfyUI (`live_portrait.api.json`, as `/api/render` builds
it) or the video-api (Wan). `--engines driver` scores the driver clip itself
(plan §2: a driver that does not blink is thrown away), nothing renders.

Identity is `Ol1nLLM/tools/facebench/vidbench.py`: the track, the p10 gate and
the scale are imported, not copied. It lives on SPARK in ~/Code/facebench
(`FACEBENCH_DIR`) and needs insightface and cv2, so every one of those imports
is lazy; everything above "scoring (SPARK)" that takes plain arrays runs without
them. A preset's expectations are in EXPECT.
"""

from __future__ import annotations

import csv as csvlib
import hashlib
import io
import itertools
import json
import os
import shutil
import sys
import time
from collections import defaultdict
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps

import catalog
import hairmask as hm
from comfy import output_refs, pick_outputs, prepare_workflow
from comfysync import CellError, Comfy, apply_node_sweep, set_seed

HERE = Path(__file__).resolve().parent
METRICS_VERSION = 1
MAX_SIDE = 1080  # config.LIVE_MAX_SIDE
EXIF_ORIENTATION = 0x0112
DRIVERS = catalog.ASSETS.parent / "drivers"
FACEBENCH_DIR = Path(os.environ.get("FACEBENCH_DIR", Path.home() / "Code" / "facebench"))
FRAME_EVERY = 2  # frames/ keeps every second frame
ENGINES = ("live", "wan", "driver")

THRESHOLDS = {
    "identity_p10_min": 0.60,
    "rate": 2 / 3,
    "max_yaw_clean": 30.0,  # a frame past this says nothing about identity
    "blink_factor": 0.6,  # EAR below this share of the median = eye closed
    "blink_frames": 2,
    "smile_gain": 0.15,
    "smile_quiet": 0.05,
    "look_yaw": 6.0,  # degrees to each side
    "quiet_yaw": 3.0,
    "glance_pupil": 0.08,  # of the eye's width
    "hair_flow_wan": 2.0,  # hair / face optical flow
    "hair_flow_live": (0.7, 1.3),
    "loop_max": 4.0,  # of 255
    "still_max": {"live": 1.0, "wan": 3.0, "driver": 3.0},
    "still_guard": 0.1,  # the face and hair are grown this share of the short side
    "seconds_tolerance": 0.5,
}

# What a preset must do. `blink`/`smile`/`look`: True = must happen, False = must
# not happen by itself, None = free (a nod may tilt the head).
EXPECT = {
    "blink": {"blink": True, "smile": False, "look": False},
    "glance": {"blink": False, "smile": False, "look": "glance"},
    "look-around": {"blink": False, "smile": False, "look": True},
    "smile": {"blink": False, "smile": True, "look": False},
    "nod": {"blink": False, "smile": False, "look": None},
    "alive": {"blink": True, "smile": True, "look": True},
    "hair-breeze": {"blink": None, "smile": False, "look": None},
}

# Czech names for kMotions; the manifest is the server's table and has none.
MOTION_CS = {
    "blink": "mrknutí",
    "glance": "pohled stranou",
    "look-around": "rozhlédnutí",
    "smile": "úsměv",
    "nod": "přikývnutí",
    "alive": "živý portrét",
    "hair-breeze": "vlasy ve větru",
}


def fit_for_video(data: bytes) -> bytes:
    """`render.fit_for_video`: upright, long side ≤ 1080, even sides. Copied, not
    imported, because render.py pulls aiogram and fastapi, which ComfyUI's venv
    has not got; test_bench_tasks pins the two together."""
    with Image.open(io.BytesIO(data)) as im:
        upright = im.getexif().get(EXIF_ORIENTATION, 1) in (0, 1)
        w, h = im.size if upright else ImageOps.exif_transpose(im).size
        scale = min(1.0, MAX_SIDE / max(w, h))
        target = (max(2, round(w * scale)) & ~1, max(2, round(h * scale)) & ~1)
        if upright and target == (w, h):
            return data
        out = ImageOps.exif_transpose(im).convert("RGB").resize(target, Image.Resampling.LANCZOS)
    buf = io.BytesIO()
    out.save(buf, "PNG")
    return buf.getvalue()


# ── pure metrics ────────────────────────────────────────────────────────────

# insightface 2d106 layout: eye corners and the three lid pairs, the mouth's
# corners, its top and its bottom. Index order as insightface's own markup.
LEFT_EYE = (35, 39, ((41, 36), (40, 33), (42, 37)))
RIGHT_EYE = (89, 93, ((95, 90), (94, 87), (96, 91)))
MOUTH_LEFT, MOUTH_RIGHT, MOUTH_TOP, MOUTH_BOTTOM = 52, 61, 71, 53


def _dist(lmk: np.ndarray, a: int, b: int) -> float:
    return float(np.linalg.norm(lmk[a] - lmk[b]))


def _eye(lmk: np.ndarray, spec) -> float:
    left, right, pairs = spec
    width = _dist(lmk, left, right)
    return 0.0 if width == 0 else float(np.mean([_dist(lmk, a, b) for a, b in pairs])) / width


def ear(lmk: np.ndarray) -> float:
    """Eye aspect ratio, both eyes."""
    return (_eye(lmk, LEFT_EYE) + _eye(lmk, RIGHT_EYE)) / 2


def mouth_shape(lmk: np.ndarray) -> tuple[float, float]:
    """(width / height, lift of the corners over the middle of the mouth as a
    share of the width). Both grow with a smile."""
    width = _dist(lmk, MOUTH_LEFT, MOUTH_RIGHT)
    height = max(1e-6, _dist(lmk, MOUTH_TOP, MOUTH_BOTTOM))
    middle = (lmk[MOUTH_TOP][1] + lmk[MOUTH_BOTTOM][1]) / 2
    corners = (lmk[MOUTH_LEFT][1] + lmk[MOUTH_RIGHT][1]) / 2
    return width / height, float(middle - corners) / max(1e-6, width)


def smile_gain(shapes: list[tuple[float, float]]) -> float | None:
    """Peak of "how much more of a smile than the first frame": relative growth
    of width/height plus the rise of the corners."""
    if len(shapes) < 2:
        return None
    r0, l0 = shapes[0]
    return max((r / r0 - 1) + (lift - l0) for r, lift in shapes)


def blinks(ears: list[float], every: int = 1) -> int:
    """Closed-eye runs: EAR under 0.6× the median for ≥ 2 video frames."""
    if len(ears) < 3:
        return 0
    T = THRESHOLDS
    limit = T["blink_factor"] * float(np.median(ears))
    need = max(1, int(np.ceil(T["blink_frames"] / every)))
    count = run = 0
    for e in ears:
        run = run + 1 if e < limit else 0
        count += run == need
    return count


def yaw_range(yaws: list[float]) -> tuple[float, float]:
    """(furthest to one side, to the other) relative to the first frame, as
    (≥ 0, ≤ 0)."""
    rel = np.asarray(yaws, dtype=float) - yaws[0]
    return float(rel.max(initial=0.0)), float(rel.min(initial=0.0))


def loop_error(first: np.ndarray, last: np.ndarray) -> float:
    """Mean |first − last| after evening out a brightness drift, of 255."""
    a, b = first.astype(float), last.astype(float)
    return float(np.abs((a - a.mean()) - (b - b.mean())).mean())


def still_error(greys: list[np.ndarray], keep: np.ndarray) -> float | None:
    """Mean |Δ| between neighbouring frames on `keep`, of 255. None without
    anything to look at."""
    if len(greys) < 2 or not keep.any():
        return None
    return float(np.mean([np.abs(b.astype(np.int16) - a.astype(np.int16))[keep].mean()
                          for a, b in zip(greys, greys[1:])]))


def in_range(value: float | None, low: float, high: float) -> bool | None:
    return None if value is None else low <= value <= high


def verdicts(motion: str, m: dict, loop: bool, engine: str) -> dict:
    """The preset checks from raw numbers. None = not measured, not gated."""
    T, want = THRESHOLDS, EXPECT[motion]
    out: dict[str, bool | None] = {}
    if m.get("blinks") is not None and want["blink"] is not None:
        out["blink_ok"] = m["blinks"] >= 1 if want["blink"] else m["blinks"] == 0
    if m.get("smile") is not None and want["smile"] is not None:
        out["smile_ok"] = m["smile"] >= T["smile_gain"] if want["smile"] else m["smile"] <= T["smile_quiet"]
    if m.get("yaw_max") is not None and want["look"] is not None:
        lo, hi = m["yaw_min"], m["yaw_max"]
        if want["look"] is True:
            out["look_ok"] = hi >= T["look_yaw"] and lo <= -T["look_yaw"]
        else:
            out["look_ok"] = max(hi, -lo) <= T["quiet_yaw"]
        if want["look"] == "glance":
            pupil = m.get("pupil")  # MediaPipe iris, optional on the box
            out["pupil_ok"] = None if pupil is None else pupil >= T["glance_pupil"]
    if m.get("hair_flow") is not None:
        if motion == "hair-breeze":
            out["hair_ok"] = m["hair_flow"] >= T["hair_flow_wan"]
        elif engine == "live":
            out["hair_ok"] = in_range(m["hair_flow"], *T["hair_flow_live"])
    if m.get("loop") is not None and loop:
        out["loop_ok"] = m["loop"] <= T["loop_max"]
    if m.get("still") is not None:
        out["still_ok"] = m["still"] <= T["still_max"][engine]
    return out


def seconds_ok(frames: int, fps: float, preset: dict) -> bool:
    return fps > 0 and abs(frames / fps - preset["seconds"]) <= THRESHOLDS["seconds_tolerance"]


def write_frames_csv(path: Path, rows: list[dict]) -> None:
    """The layout `vidbench.summary` reads. One person, so no cross similarity."""
    fields = ["action", "person", "frame", "sim", "sim_cross", "det", "yaw", "size", "clean"]
    with path.open("w", newline="") as fh:
        wr = csvlib.DictWriter(fh, fieldnames=fields)
        wr.writeheader()
        wr.writerows(rows)


def identity_rows(track: dict, ref, motion: str, sim, min_det: float, min_face: float, ear_median: float | None) -> list[dict]:
    """One track's frames as `frames.csv` rows; `clean` = plan §4: a sure
    detection, eyes open (a blink is no identity failure), head within 30°."""
    T = THRESHOLDS
    rows = []
    for idx, obs in track["obs"]:
        open_eyes = ear_median is None or obs.get("ear") is None or obs["ear"] >= T["blink_factor"] * ear_median
        clean = (obs["det"] >= min_det and abs(obs["yaw"]) <= T["max_yaw_clean"]
                 and obs["size"] >= min_face and open_eyes)
        rows.append({"action": motion, "person": "person", "frame": idx,
                     "sim": round(sim(obs["emb"], ref), 3), "sim_cross": 0.0, "det": round(obs["det"], 3),
                     "yaw": round(obs["yaw"], 1), "size": round(obs["size"]), "clean": int(clean)})
    return rows


# ── graph ───────────────────────────────────────────────────────────────────

# `graph.cropper=mediapipe`: kijai's second cropper loader. The name and input
# are from the node pack, not checked against this box's /object_info.
MEDIAPIPE_CROPPER = {"class_type": "LivePortraitLoadMediaPipeCropper",
                     "inputs": {"landmarkrunner_device": "CPU", "keep_model_loaded": True}}


def apply_live_variants(wf: dict, sweep: dict) -> None:
    """Plan axes under their readable names. `driving_multiplier` etc. are on
    LivePortraitProcess, whichever id it has in the graph."""
    process = next(n for n in wf.values() if n["class_type"] == "LivePortraitProcess")["inputs"]
    if "graph.driving_multiplier" in sweep:
        process["delta_multiplier"] = float(sweep["graph.driving_multiplier"])
    if "graph.relative_motion" in sweep:
        process["relative_motion_mode"] = "relative" if sweep["graph.relative_motion"] in (1, True, "on") else "off"
    if "graph.stitching" in sweep:
        process["stitching"] = sweep["graph.stitching"] in (1, True, "on")
    if sweep.get("graph.cropper") == "mediapipe":
        key = next(k for k, n in wf.items() if n["class_type"] == "LivePortraitLoadCropper")
        wf[key] = json.loads(json.dumps(MEDIAPIPE_CROPPER))


def set_video_prefix(wf: dict, prefix: str) -> None:
    for node in wf.values():
        if node.get("class_type") == "VHS_VideoCombine":
            node["inputs"]["filename_prefix"] = prefix


# ── cells ───────────────────────────────────────────────────────────────────


def plan(args, sweeps: list[dict], seeds: list[int], srcs: list[str], engines: list[str]) -> list[dict]:
    motions = catalog.motions()
    picked = list(motions) if args.styles in (None, "", "all") else [s.strip() for s in args.styles.split(",")]
    for m in picked:
        if m not in motions:
            raise SystemExit(f"unknown motion '{m}'")
    for e in engines:
        if e not in ENGINES:
            raise SystemExit(f"live runs on {ENGINES}, not '{e}'")
    cells = []
    for engine, src, motion, sweep in itertools.product(engines, srcs, picked, sweeps):
        preset = motions[motion]
        # A preset has one engine; `driver` scores the clip of a live preset.
        wanted = "live" if engine == "driver" else engine
        if preset["engine"] != wanted:
            continue
        # LivePortrait is deterministic: seeds would only render the same clip.
        for seed in seeds if engine == "wan" else [0]:
            cells.append({"task": "live", "engine": engine, "src": Path(src).name, "style": motion,
                          "seed": seed, "sweep": sweep, "ckpt": None})
    return cells


def missing_drivers(cells: list[dict]) -> list[str]:
    motions = catalog.motions()
    names = {motions[c["style"]]["driver"] for c in cells if c["engine"] in ("live", "driver")}
    return sorted(n for n in names if not (DRIVERS / n).is_file())


def extract_frames(clip: Path, out: Path, every: int = FRAME_EVERY) -> int:
    import cv2

    out.mkdir(parents=True, exist_ok=True)
    cap = cv2.VideoCapture(str(clip))
    idx = saved = 0
    while True:
        ok, frame = cap.read()
        if not ok:
            break
        if idx % every == 0:
            cv2.imwrite(str(out / f"{saved:04d}.jpg"), frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
            saved += 1
        idx += 1
    cap.release()
    return saved


def render_live(c: Comfy, ident: dict, src: Path, preset: dict, timeout: float) -> bytes:
    driver = DRIVERS / Path(preset["driver"]).name
    if not driver.is_file():
        raise CellError(f"driver {driver.name} is not generated yet (drivers/drivergen.py)")
    fitted = fit_for_video(src.read_bytes())
    image = c.upload(fitted, f"bench_live_{hashlib.sha1(fitted).hexdigest()[:12]}.png")
    driver_name = c.upload(driver.read_bytes(), f"tsumiki_driver_{ident['style']}.mp4")
    template = json.loads((catalog.ASSETS / "live_portrait.api.json").read_text())
    wf = prepare_workflow(template, prompt="", image_name=image, driver_name=driver_name)
    apply_live_variants(wf, ident["sweep"])
    apply_node_sweep(wf, ident["sweep"])
    prefix = f"bench_{ident['key']}"
    set_video_prefix(wf, prefix)
    hist = c.wait(c.queue(wf), timeout)
    found = pick_outputs(output_refs(hist, "video"), (prefix,))
    if prefix not in found:
        raise CellError("no mp4 in the history (VHS_VideoCombine output)")
    return c.view(found[prefix])


def render_wan(url: str, ident: dict, src: Path, preset: dict, timeout: float) -> bytes:
    """As `render._wan_motion`, blocking: the video-api job of the preset."""
    sys.path.insert(0, str(HERE / "drivers"))
    import base64

    import drivergen

    image = base64.b64encode(fit_for_video(src.read_bytes())).decode()
    body = {"prompt": preset["prompt"], "beats": 1, "image": image, "seed": ident["seed"]}
    job_id = json.loads(drivergen._request(f"{url}/jobs", {}, body))["job_id"]
    deadline = time.time() + timeout
    while time.time() < deadline:
        time.sleep(10)
        status = json.loads(drivergen._request(f"{url}/jobs/{job_id}", {}))
        if status.get("status") == "error":
            raise CellError(f"video-api: {status.get('error')}")
        if status.get("status") == "done":
            return drivergen._request(f"{url}/jobs/{job_id}/result", {})
    raise CellError(f"video-api job {job_id} timed out")


def run(args, host) -> None:
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    cells = host.plan_cells(args)
    manifest_path = out / "manifest.json"
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {"cells": {}}
    todo = [c for c in cells if manifest["cells"].get(c["key"], {}).get("status") != "done"]
    missing = missing_drivers(cells)
    host.log(f"{len(cells)} cells, {len(cells) - len(todo)} finished, {len(todo)} to render"
             + (f"; drivers not generated: {', '.join(missing)}" if missing else ""))
    if args.plan:
        return
    src_paths = {Path(s).name: Path(s) for s in host.csv(args.srcs)}
    manifest["task"] = "live"
    manifest.setdefault("srcs", {})
    for name, p in src_paths.items():
        (out / "srcs").mkdir(exist_ok=True)
        (out / "srcs" / name).write_bytes(p.read_bytes())
        manifest["srcs"][name] = f"srcs/{name}"
    motions = catalog.motions()
    c = Comfy(args.url)
    (out / "clips").mkdir(exist_ok=True)
    for i, ident in enumerate(todo, 1):
        preset = motions[ident["style"]]
        stem = f"{ident['style']}__{ident['engine']}__{Path(ident['src']).stem}__s{ident['seed']}__{ident['key']}"
        clip = out / "clips" / f"{stem}.mp4"
        row = {**ident, "video": f"clips/{stem}.mp4", "file": f"frames/{stem}/0000.jpg",
               "frames": f"frames/{stem}", "loop": preset.get("loop", False), "status": "running"}
        started = time.time()
        try:
            if ident["engine"] == "driver":
                driver = DRIVERS / Path(preset["driver"]).name
                if not driver.is_file():
                    raise CellError(f"driver {driver.name} is not generated yet")
                shutil.copyfile(driver, clip)
            elif ident["engine"] == "wan":
                clip.write_bytes(render_wan(args.video_url, ident, src_paths[ident["src"]], preset, args.timeout))
            else:
                c.guard(args.min_free_gb, host.log)
                clip.write_bytes(render_live(c, ident, src_paths[ident["src"]], preset, args.timeout))
            row["frames_saved"] = extract_frames(clip, out / row["frames"])
            row["status"] = "done"
        except CellError as e:
            row.update(status="error", error=str(e)[:300])
        except Exception as e:  # noqa: BLE001 — one broken cell must not end the run
            row.update(status="error", error=f"{type(e).__name__}: {e}"[:300])
        row["seconds"] = round(time.time() - started, 1)
        manifest["cells"][ident["key"]] = row
        manifest_path.write_text(json.dumps(manifest, indent=1, ensure_ascii=False))
        host.log(f"[{i}/{len(todo)}] {row['status']:7} {row['seconds']:6.1f}s {stem}"
                 + (f"  ({row.get('error')})" if row.get("error") else ""))


# ── scoring (SPARK) ─────────────────────────────────────────────────────────


def facebench():
    """(vidbench, bench) of Ol1nLLM's facebench, as synced to the box. Lazy:
    importing them pulls insightface and video-stack's chain."""
    sys.path.insert(0, str(FACEBENCH_DIR))
    import bench
    import vidbench

    return vidbench, bench


def read_clip(path: Path, every: int, width: int = 360):
    """(sampled BGR frames with their index, small greys of every frame, fps,
    frame count, (w, h))."""
    import cv2

    cap = cv2.VideoCapture(str(path))
    if not cap.isOpened():
        raise CellError(f"cannot open {path}")
    fps = cap.get(cv2.CAP_PROP_FPS) or 0.0
    sampled, greys, idx, size = [], [], 0, (0, 0)
    while True:
        ok, frame = cap.read()
        if not ok:
            break
        size = (frame.shape[1], frame.shape[0])
        if idx % every == 0:
            sampled.append((idx, frame))
        height = max(2, round(frame.shape[0] * width / frame.shape[1]))
        greys.append(cv2.cvtColor(cv2.resize(frame, (width, height)), cv2.COLOR_BGR2GRAY))
        idx += 1
    cap.release()
    return sampled, greys, fps, idx, size


def face_record(f) -> dict:
    """An insightface face as vidbench.detect has it, plus the landmarks."""
    x0, y0, x1, y1 = (float(v) for v in f.bbox)
    e = f.normed_embedding
    lmk = getattr(f, "landmark_2d_106", None)
    return {"bbox": (x0, y0, x1, y1), "emb": e / np.linalg.norm(e), "det": float(f.det_score),
            "yaw": float(f.pose[1]) if getattr(f, "pose", None) is not None else 0.0,
            "size": min(x1 - x0, y1 - y0), "lmk": lmk,
            "ear": None if lmk is None else ear(lmk)}


def flow_ratio(greys: list[np.ndarray], hair: np.ndarray, face: np.ndarray) -> float | None:
    """Median optical-flow magnitude in the hair over the same in the face."""
    import cv2

    if len(greys) < 2 or not hair.any() or not face.any():
        return None
    in_hair, in_face = [], []
    step = max(1, len(greys) // 20)
    for a, b in zip(greys[::step], greys[step::step]):
        flow = cv2.calcOpticalFlowFarneback(a, b, None, 0.5, 3, 15, 3, 5, 1.2, 0)
        mag = np.linalg.norm(flow, axis=2)
        in_hair.append(float(np.median(mag[hair])))
        in_face.append(float(np.median(mag[face])))
    face_flow = float(np.mean(in_face))
    return None if face_flow < 1e-3 else float(np.mean(in_hair)) / face_flow


def pupil_shift(sampled: list) -> float | None:
    """Iris travel as a share of the eye's width, MediaPipe FaceMesh. None when
    the box has no MediaPipe: `glance` then has no pupil check, only yaw."""
    try:
        import mediapipe as mp
    except ImportError:
        return None
    shifts = []
    with mp.solutions.face_mesh.FaceMesh(static_image_mode=False, refine_landmarks=True, max_num_faces=1) as mesh:
        for _, frame in sampled:
            res = mesh.process(frame[:, :, ::-1])
            if not res.multi_face_landmarks:
                continue
            lm = res.multi_face_landmarks[0].landmark
            # iris 468 between the eye corners 33 and 133
            shifts.append((lm[468].x - lm[33].x) / max(1e-6, lm[133].x - lm[33].x))
    return float(max(shifts) - min(shifts)) if shifts else None


def score_clip(path: Path, src_path: Path, motion: str, preset: dict, engine: str, hair_face, csv_path: Path) -> dict:
    vb, bench = facebench()
    every = 1 if EXPECT[motion]["blink"] else FRAME_EVERY
    sampled, greys, fps, count, size = read_clip(path, every)
    per_frame, one_face = [], True
    for idx, frame in sampled:
        records = [face_record(f) for f in bench.analyser().get(frame) if float(f.det_score) >= 0.5]
        one_face &= len(records) == 1
        per_frame.append((idx, records))
    tracks = vb.track(per_frame)
    m: dict = {"frames": count, "fps": round(fps, 2), "size": list(size)}
    if not tracks:
        return {**m, "identity": None, "clean": False}
    track = tracks[0]
    obs = [o for _, o in track["obs"]]
    ears = [o["ear"] for o in obs if o.get("ear") is not None]
    ref = bench.embedding(str(src_path))
    rows = identity_rows(track, ref, motion, vb.sim, vb.MIN_DET, vb.MIN_FACE, float(np.median(ears)) if ears else None)
    write_frames_csv(csv_path, rows)
    person = vb.summary(str(csv_path), THRESHOLDS["identity_p10_min"])["persons"]["person"]
    shapes = [mouth_shape(o["lmk"]) for o in obs if o.get("lmk") is not None]
    hi, lo = yaw_range([o["yaw"] for o in obs])
    m.update(identity=person.get("p10"), clean_frames=person.get("clean", 0), blinks=blinks(ears, every),
             smile=None if (g := smile_gain(shapes)) is None else round(g, 3), yaw_max=round(hi, 1), yaw_min=round(lo, 1),
             loop=round(loop_error(greys[0], greys[-1]), 2) if len(greys) > 1 else None)
    if EXPECT[motion]["look"] == "glance":
        p = pupil_shift(sampled)
        m["pupil"] = None if p is None else round(p, 3)
    if hair_face is not None:
        hair, face = (hm._resize(x, (greys[0].shape[1], greys[0].shape[0])) for x in hair_face)
        guard = round(THRESHOLDS["still_guard"] * min(greys[0].shape))
        flow = flow_ratio(greys, hair & ~face, face & ~hair)
        still = still_error(greys, ~hm.dilate(hair | face, guard))
        m.update(hair_flow=None if flow is None else round(flow, 2), still=None if still is None else round(still, 2))
    m["clean"] = bool(one_face and seconds_ok(count, fps, preset))
    return m


def summarise(manifest: dict, metrics: dict) -> dict:
    T = THRESHOLDS
    groups: dict[tuple, list] = defaultdict(list)
    for key, row in manifest["cells"].items():
        groups[(row["style"], row["engine"], json.dumps(row["sweep"], sort_keys=True))].append(
            (row, metrics.get(key, {})))
    out = {}
    for (motion, engine, sweep), items in sorted(groups.items()):
        done = [m for _, m in items if m.get("status") == "done"]
        ids = [m.get("identity") for m in done]
        known = [i for i in ids if i is not None]
        s = {"cells": len(items), "done": len(done), "errors": sum(r["status"] == "error" for r, _ in items),
             "refused": 0, "identity_min": min(known) if known else None,
             "identity_mean": round(sum(known) / len(known), 3) if known else None}
        reasons = []
        if not done:
            reasons.append("nothing rendered")
        if s["errors"]:
            reasons.append(f"{s['errors']} errors")
        if len(known) < len(done):
            reasons.append("face lost")
        elif known and min(known) < T["identity_p10_min"]:
            reasons.append(f"identity {min(known):.2f}")
        for key, need in (("blink_ok", T["rate"]), ("smile_ok", T["rate"]), ("look_ok", T["rate"]),
                          ("pupil_ok", T["rate"]), ("hair_ok", T["rate"]), ("loop_ok", 1), ("still_ok", 1), ("clean", 1)):
            vals = [m[key] for m in done if m.get(key) is not None]
            s[key] = None if not vals else round(sum(map(bool, vals)) / len(vals), 2)
            if s[key] is not None and s[key] < need - 1e-6:
                reasons.append(f"{key.removesuffix('_ok')} {s[key]:.0%}")
        s["auto"], s["reasons"] = ("pass" if not reasons else "fail"), reasons
        out[f"{motion}|{engine}||{sweep}"] = s
    return out


def score_run(run: Path, manifest: dict, url: str, cache: Path) -> dict:
    import score as sc

    prev = json.loads((run / "metrics.json").read_text()) if (run / "metrics.json").exists() else {"cells": {}}
    c = sc.Comfy(url)
    motions = catalog.motions()
    masks: dict[str, tuple] = {}
    cells: dict[str, dict] = {}
    for key, row in manifest["cells"].items():
        if row["status"] != "done":
            cells[key] = {"status": row["status"], "error": row.get("error")}
            continue
        if (prev.get("metrics_version") == METRICS_VERSION and key in prev["cells"]
                and prev["cells"][key].get("scored_file") == row["video"]):
            cells[key] = prev["cells"][key]
            continue
        src_path = run / manifest["srcs"][row["src"]]
        if row["src"] not in masks:
            a = sc.analysis_for(c, cache, src_path.read_bytes())
            masks[row["src"]] = (a.hair, a.face)
        csv_path = (run / row["video"]).with_suffix(".frames.csv")
        m = score_clip(run / row["video"], src_path, row["style"], motions[row["style"]], row["engine"],
                       masks[row["src"]], csv_path)
        m.update(verdicts(row["style"], m, row.get("loop", False), row["engine"]))
        m.update(status="done", scored_file=row["video"])
        cells[key] = m
        print(f"{row['style']:12} {row['engine']:6} {row['src']:18} {json.dumps({k: v for k, v in m.items() if k not in ('status', 'scored_file')})}", flush=True)
    return {"metrics_version": METRICS_VERSION, "cells": cells, "thresholds": THRESHOLDS,
            "summary": summarise(manifest, cells)}


def write_summary_md(run: Path, manifest: dict, metrics: dict) -> None:
    pct = lambda v: "—" if v is None else f"{v:.0%}"  # noqa: E731
    lines = [f"# {run.name} — live", "",
             "| motion | engine | sweep | done | identity p10 min/mean | blink | smile | look | pupil | hair | loop | still | clean | auto |",
             "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
    for key, s in metrics["summary"].items():
        motion, engine, _, sweep = key.split("|", 3)
        sweep = "" if sweep == "{}" else sweep
        ident = f"{s['identity_min']:.2f} / {s['identity_mean']:.2f}" if s["identity_min"] is not None else "—"
        auto = s["auto"] + ("" if not s["reasons"] else f" ({', '.join(s['reasons'])})")
        checks = " | ".join(pct(s[k]) for k in ("blink_ok", "smile_ok", "look_ok", "pupil_ok", "hair_ok", "loop_ok", "still_ok", "clean"))
        lines.append(f"| {motion} | {engine} | {sweep} | {s['done']}/{s['cells']} | {ident} | {checks} | {auto} |")
    (run / "summary.md").write_text("\n".join(lines) + "\n")


def badge_bits(m: dict) -> list[tuple[str, str]]:
    bits = [("ok" if m.get(k) else "bad", label) for k, label in
            (("blink_ok", "blink"), ("smile_ok", "smile"), ("look_ok", "look"), ("hair_ok", "hair"),
             ("loop_ok", "loop"), ("still_ok", "still")) if m.get(k) is not None]
    if m.get("blinks") is not None:
        bits.append(("dim", f"{m['blinks']} blinks"))
    return bits


def cell_extra(run: Path, row: dict, data_uri) -> str:
    """Under a clip's first frame in sheet.py: the loop, and the middle and last
    frames. The clip stays a file next to the sheet (`clips/`): embedded, a
    60-cell round would be a sheet of tens of MB."""
    if row.get("status") != "done" or not row.get("video"):
        return ""
    html = f'<video src="{row["video"]}" controls loop muted playsinline style="width:100%;margin-top:4px"></video>'
    frames = sorted((run / row["frames"]).glob("*.jpg"))
    if len(frames) >= 3:
        html += '<div style="display:flex;gap:2px;margin-top:2px">' + "".join(
            f'<img loading="lazy" src="{data_uri(p, 72)}" style="width:72px" alt="">'
            for p in (frames[len(frames) // 2], frames[-1])) + "</div>"
    return html


def main(argv: list[str], host) -> None:
    ap = host.task_parser("live", engines="live", seeds="1")
    ap.add_argument("--motions", dest="styles", default="all")
    ap.add_argument("--video-url", default="http://127.0.0.1:8096/v1/video", help="video-api base (engine wan)")
    run(ap.parse_args(argv), host)
