#!/usr/bin/env python3
"""Řídicí klipy pro LivePortrait: Wan přes video-api, ořez, návrat do neutrálu.

Čte assets/drivers/manifest.json. Každý preset s enginem `live` a `prompt`
se vyrenderuje ze syntetické předlohy, ořízne na `seconds` a prodlouží
reverzní částí (začíná i končí neutrálně); preset s `parts` se slepí z dílů.
Seed zapíše zpět do manifestu. Spouští se přes sparkctl, viz README.md.

    python3 drivergen.py --url http://192.168.88.66:8096/v1/video --only blink,smile
"""

from __future__ import annotations

import argparse
import base64
import json
import random
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
DRIVERS = ROOT / "assets" / "drivers"
SOURCE = ROOT / "tgbot" / "tools" / "bench" / "srcs" / "w-long.png"
FPS = 25


def trim_cmd(src: Path, dst: Path, seconds: float) -> list[str]:
    """První polovina délky tam, tatáž pozpátku zpět: poslední snímek = první."""
    half = seconds / 2
    return [
        "ffmpeg", "-y", "-loglevel", "error", "-i", str(src),
        "-filter_complex",
        f"[0:v]fps={FPS},trim=duration={half},setpts=PTS-STARTPTS,split[a][b];"
        "[b]reverse[r];[a][r]concat=n=2:v=1[out]",
        "-map", "[out]", "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "20", str(dst),
    ]


def concat_cmd(parts: list[Path], dst: Path) -> list[str]:
    inputs = [arg for part in parts for arg in ("-i", str(part))]
    streams = "".join(f"[{i}:v]" for i in range(len(parts)))
    return [
        "ffmpeg", "-y", "-loglevel", "error", *inputs,
        "-filter_complex", f"{streams}concat=n={len(parts)}:v=1[out]",
        "-map", "[out]", "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "20", str(dst),
    ]


def order(manifest: dict) -> list[str]:
    """Slepené presety až po dílech."""
    live = [k for k, v in manifest.items() if v.get("engine") == "live"]
    return sorted(live, key=lambda k: "parts" in manifest[k])


def _request(url: str, headers: dict, body: dict | None = None) -> bytes:
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json", **headers})
    with urllib.request.urlopen(req, timeout=180) as resp:
        return resp.read()


def render(url: str, headers: dict, prompt: str, seed: int, timeout: int) -> bytes:
    image = base64.b64encode(SOURCE.read_bytes()).decode()
    body = {"prompt": prompt, "beats": 1, "image": image, "seed": seed}
    job_id = json.loads(_request(f"{url}/jobs", headers, body))["job_id"]
    deadline = time.time() + timeout
    while time.time() < deadline:
        time.sleep(10)
        status = json.loads(_request(f"{url}/jobs/{job_id}", headers))
        if status.get("status") == "error":
            raise RuntimeError(f"video-api: {status.get('error')}")
        if status.get("status") == "done":
            return _request(f"{url}/jobs/{job_id}/result", headers)
    raise TimeoutError(job_id)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--url", required=True, help="video-api base, …/v1/video")
    ap.add_argument("--only", help="čárkami oddělené presety")
    ap.add_argument("--timeout", type=int, default=3600)
    ap.add_argument("--cf-id")
    ap.add_argument("--cf-secret")
    args = ap.parse_args()

    headers = {}
    if args.cf_id and args.cf_secret:
        headers = {"CF-Access-Client-Id": args.cf_id, "CF-Access-Client-Secret": args.cf_secret}
    path = DRIVERS / "manifest.json"
    manifest = json.loads(path.read_text())
    only = set(args.only.split(",")) if args.only else None

    for motion in order(manifest):
        if only and motion not in only:
            continue
        preset = manifest[motion]
        dst = DRIVERS / preset["driver"]
        if "parts" in preset:
            parts = [DRIVERS / manifest[p]["driver"] for p in preset["parts"]]
            subprocess.run(concat_cmd(parts, dst), check=True)
        else:
            seed = random.randrange(1 << 31)
            try:
                mp4 = render(args.url.rstrip("/"), headers, preset["prompt"], seed, args.timeout)
            except (urllib.error.URLError, RuntimeError, TimeoutError) as e:
                print(f"{motion}: {e}", file=sys.stderr)
                return 1
            with tempfile.TemporaryDirectory() as tmp:
                raw = Path(tmp) / "raw.mp4"
                raw.write_bytes(mp4)
                subprocess.run(trim_cmd(raw, dst, preset["seconds"]), check=True)
            preset["seed"] = seed
            path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
        print(f"{motion}: {dst}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
