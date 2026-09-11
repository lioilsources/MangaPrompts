#!/usr/bin/env python3
"""Run the Couple bench against a live ComfyUI and report what it cost.

Runs on the SPARK box next to ComfyUI (inputs are staged by copying into its
`input/` directory).

    run.py solo   driving.mp4 ref_a.png                      # S2 — how slow is this box
    run.py couple driving.mp4 ref_a.png ref_b.png \
                  --point-a 200,100;200,280 --point-b 600,170;610,330   # S3
    run.py check  couple                                     # pre-flight only, no GPU

The numbers the report needs (docs/couple-spark-setup.md §9) are per *pass*,
not per job, so this listens on the websocket and stamps every node as it
starts. ComfyUI's `/history` only carries execution_start and execution_success.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
import time
import urllib.request
import uuid

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import graph  # noqa: E402

COMFY = os.path.expanduser("~/Code/ComfyUI")
IN, OUT = os.path.join(COMFY, "input"), os.path.join(COMFY, "output")

# Which node each pass begins at, for the per-pass split in the summary. Keyed
# by the prefix `graph.py` gives its nodes.
PHASES = [("P0 masky (SAM2)", ("sam2", "seg_", "grow_", "block_", "solo_")),
          ("P0 póza a tváře (ViTPose, CPU)", ("onnx", "pose_", "draw_")),
          ("P1 osoba A", ("ref_a", "ref_fit_a", "wan_a", "noise_a", "guider_a",
                          "sample_a", "trim_a", "out_a")),
          ("P2 osoba B", ("ref_b", "ref_fit_b", "wan_b", "noise_b", "guider_b",
                          "sample_b", "trim_b", "out_b")),
          ("načtení modelů", ("unet", "lora_", "clip", "pos", "neg", "vae",
                              "sigmas", "sampler", "load", "src", "black")),
          ("ukládání", ("save_", "maskimg_"))]


def post(url, path, payload):
    req = urllib.request.Request(url.rstrip("/") + path,
                                 data=json.dumps(payload).encode(),
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read())


def get(url, path):
    with urllib.request.urlopen(url.rstrip("/") + path, timeout=60) as r:
        return json.loads(r.read())


def stage(path):
    """Into ComfyUI's input/ under a stable name, so a rerun reuses it."""
    name = "couplebench_" + os.path.basename(path)
    dst = os.path.join(IN, name)
    if not (os.path.exists(dst) and os.path.getsize(dst) == os.path.getsize(path)):
        shutil.copy(path, dst)
    return name


def points(spec):
    """"x,y;x,y;…" → [(x, y), …]. Several points down one person, because a
    single SAM2 click answers with whatever granularity it likes."""
    return [tuple(int(v) for v in p.split(",")) for p in spec.split(";") if p]


def phase_of(node):
    for label, prefixes in PHASES:
        if any(node == p or node.startswith(p) for p in prefixes):
            return label
    return "ostatní"


def submit(url, g, label):
    """Queue the graph, follow the websocket, return (marks, prompt_id).

    `marks` is [(timestamp, node)] — one stamp per node as it starts, plus a
    final stamp when the prompt finishes, which is what makes the per-pass
    split possible.
    """
    import asyncio
    import aiohttp

    client_id = str(uuid.uuid4())
    res = post(url, "/prompt", {"prompt": g, "client_id": client_id})
    if res.get("node_errors"):
        # ComfyUI answers 200 and then silently drops a node whose required
        # input is missing — the failure mode the UGC pipeline hit before.
        raise SystemExit("node_errors: %s" % json.dumps(res["node_errors"], indent=1))
    pid = res["prompt_id"]
    print("  %s → %s" % (label, pid))

    async def follow():
        marks, t0 = [], time.time()
        ws_url = url.replace("http://", "ws://").replace("https://", "wss://")
        async with aiohttp.ClientSession() as s:
            async with s.ws_connect("%s/ws?clientId=%s" % (ws_url.rstrip("/"), client_id),
                                    heartbeat=30, timeout=60) as ws:
                async for msg in ws:
                    if msg.type is not aiohttp.WSMsgType.TEXT:
                        continue           # binary frames are preview images
                    m = json.loads(msg.data)
                    d = m.get("data") or {}
                    if d.get("prompt_id") not in (None, pid):
                        continue
                    if m["type"] == "executing":
                        node = d.get("node")
                        marks.append((time.time(), node))
                        if node is None:
                            return marks, time.time() - t0
                        print("    %6.0f s  %s" % (time.time() - t0, node), flush=True)
                    elif m["type"] == "execution_error":
                        raise SystemExit("execution_error: %s" %
                                         json.dumps(d, indent=1)[:2000])
                    elif m["type"] == "execution_interrupted":
                        raise SystemExit("interrupted")
        raise SystemExit("websocket closed before the job finished")

    return asyncio.run(follow()) + (pid,)


def report(marks, total, url, pid):
    """Per-phase seconds, then where the outputs landed."""
    per = {}
    for (t, node), (t_next, _) in zip(marks, marks[1:]):
        if node is not None:
            per[phase_of(node)] = per.get(phase_of(node), 0.0) + (t_next - t)
    print("\n  %-34s %7s" % ("fáze", "s"))
    for label, _ in PHASES:
        if label in per:
            print("  %-34s %7.0f" % (label, per[label]))
    if "ostatní" in per:
        print("  %-34s %7.0f" % ("ostatní", per["ostatní"]))
    print("  %-34s %7.0f" % ("celkem", total))

    try:
        dev = get(url, "/system_stats")["devices"][0]
        print("  volná VRAM po běhu: %.1f / %.1f GB"
              % (dev["vram_free"] / 1e9, dev["vram_total"] / 1e9))
    except Exception:                                        # noqa: BLE001
        pass

    hist = get(url, "/history/%s" % pid).get(pid, {})
    files = []
    for node, out in (hist.get("outputs") or {}).items():
        for item in out.get("gifs", []) + out.get("images", []):
            files.append((node, os.path.join(OUT, item.get("subfolder", ""),
                                             item["filename"])))
    if files:
        print("\n  výstupy:")
        for node, path in sorted(files):
            print("    %-16s %s" % (node, path))
    return files


def cmd_check(a):
    """Pre-flight without spending GPU time — the graph this box would get."""
    sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    from check_workflow import check_workflow, fetch_object_info
    g = build(a, dummy=True)
    problems = check_workflow(g, fetch_object_info(a.url))
    print("%d nodes" % len(g))
    for p in problems:
        print("  • %s" % p)
    return 1 if problems else 0


def build(a, dummy=False):
    kw = dict(width=a.width, height=a.height, length=a.length, seed=a.seed,
              fps=a.fps, prefix=a.prefix, steps=a.steps)
    # `__`-prefixed names are what check_workflow.py treats as substituted at
    # request time, so a pre-flight checks the graph and not the staging.
    if a.cmd == "solo" or (dummy and a.what == "solo"):
        video = "__VIDEO__" if dummy else stage(a.video)
        ref = "__IMAGE__" if dummy else stage(a.ref_a)
        return graph.solo(video, ref, **kw)
    video = "__VIDEO__" if dummy else stage(a.video)
    ref_a = "__IMAGE__" if dummy else stage(a.ref_a)
    ref_b = "__IMAGE__" if dummy else stage(a.ref_b)
    pa = [(0, 0)] if dummy else points(a.point_a)
    pb = [(0, 0)] if dummy else points(a.point_b)
    build_fn = graph.preprocess if (a.what if dummy else a.cmd) == "preprocess" \
        else graph.couple
    return build_fn(video, ref_a, ref_b, pa, pb, **kw)


def cmd_run(a):
    g = build(a)
    open(os.path.join(OUT, a.prefix + ".api.json"), "w").write(json.dumps(g, indent=1))
    marks, total, pid = submit(a.url, g, a.cmd)
    report(marks, total, a.url, pid)
    return 0


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--url", default="http://127.0.0.1:8188")
    ap.add_argument("--width", type=int, default=832)
    ap.add_argument("--height", type=int, default=480)
    ap.add_argument("--length", type=int, default=77, help="snímků (77 ≈ 5 s při 16 fps)")
    ap.add_argument("--fps", type=float, default=16.0)
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--steps", type=int, default=graph.STEPS)
    ap.add_argument("--prefix", default=None)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("solo"); p.add_argument("video"); p.add_argument("ref_a")
    for name in ("couple", "preprocess"):
        p = sub.add_parser(name)
        p.add_argument("video"); p.add_argument("ref_a"); p.add_argument("ref_b")
        p.add_argument("--point-a", required=True,
                       help="x,y[;x,y…] na prvním snímku po resize, několik po těle")
        p.add_argument("--point-b", required=True)
    p = sub.add_parser("check")
    p.add_argument("what", choices=["solo", "couple", "preprocess"])

    a = ap.parse_args()
    if a.prefix is None:
        a.prefix = "couple_" + (a.what if a.cmd == "check" else a.cmd)
    raise SystemExit(cmd_check(a) if a.cmd == "check" else cmd_run(a))
