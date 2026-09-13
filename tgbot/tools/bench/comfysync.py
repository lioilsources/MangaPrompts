"""Blocking ComfyUI client for the bench — the bot's async client is built for
one job per request, the bench runs hundreds in a row and wants to be simple
to read. Graph preparation is NOT here: cells are built by `comfy.prepare_workflow`,
the function the bot itself sends through, so the bench measures what ships."""

from __future__ import annotations

import json
import os
import subprocess
import time
import uuid

import requests

import comfy  # tgbot/comfy.py — pick_outputs / execution_error_message


class CellError(Exception):
    pass


class Comfy:
    def __init__(self, url: str = "http://127.0.0.1:8188"):
        self.url = url.rstrip("/")
        self.client_id = f"tsumiki-bench-{uuid.uuid4().hex[:8]}"
        self.http = requests.Session()

    # ── plumbing ──────────────────────────────────────────────────────────
    def upload(self, data: bytes, name: str) -> str:
        r = self.http.post(
            f"{self.url}/upload/image",
            files={"image": (name, data, "application/octet-stream")},
            data={"overwrite": "true"},
            timeout=60,
        )
        r.raise_for_status()
        info = r.json()
        return f"{info['subfolder']}/{info['name']}" if info.get("subfolder") else info["name"]

    def queue(self, wf: dict) -> str:
        r = self.http.post(
            f"{self.url}/prompt", json={"prompt": wf, "client_id": self.client_id}, timeout=30
        )
        if r.status_code != 200:
            raise CellError(f"/prompt HTTP {r.status_code}: {r.text[:300]}")
        data = r.json()
        if data.get("node_errors"):
            raise CellError(f"node errors: {json.dumps(data['node_errors'])[:300]}")
        return data["prompt_id"]

    def wait(self, prompt_id: str, timeout: float) -> dict:
        deadline = time.time() + timeout
        while time.time() < deadline:
            time.sleep(1.5)
            try:
                r = self.http.get(f"{self.url}/history/{prompt_id}", timeout=15)
                hist = r.json().get(prompt_id) if r.status_code == 200 else None
            except requests.RequestException:
                continue
            if not hist:
                continue
            status = hist.get("status") or {}
            if status.get("status_str") == "error":
                raise CellError(comfy.execution_error_message(status))
            return hist
        self.interrupt()
        raise CellError(f"timed out after {timeout:.0f} s")

    def view(self, ref: dict) -> bytes:
        r = self.http.get(
            f"{self.url}/view",
            params={
                "filename": ref["filename"],
                "subfolder": ref.get("subfolder", ""),
                "type": ref.get("type", "output"),
            },
            timeout=120,
        )
        r.raise_for_status()
        return r.content

    def run(self, wf: dict, prefixes: tuple[str, ...], timeout: float = 900) -> dict[str, bytes]:
        hist = self.wait(self.queue(wf), timeout)
        found = comfy.pick_outputs(comfy.output_refs(hist), prefixes)
        missing = [p for p in prefixes if p not in found]
        if missing:
            raise CellError(f"missing outputs {missing}")
        return {p: self.view(ref) for p, ref in found.items()}

    def free_models(self) -> None:
        try:
            self.http.post(f"{self.url}/free", json={"unload_models": True, "free_memory": True}, timeout=30)
        except requests.RequestException:
            pass

    def interrupt(self) -> None:
        try:
            self.http.post(f"{self.url}/interrupt", timeout=10)
        except requests.RequestException:
            pass

    # ── health ────────────────────────────────────────────────────────────
    def stats(self) -> dict | None:
        try:
            return self.http.get(f"{self.url}/system_stats", timeout=10).json()
        except (requests.RequestException, ValueError):
            return None

    def queue_busy(self) -> bool:
        try:
            q = self.http.get(f"{self.url}/queue", timeout=10).json()
        except (requests.RequestException, ValueError):
            return True
        return bool(q.get("queue_running") or q.get("queue_pending"))

    def vram_free_gb(self) -> float | None:
        """What ComfyUI itself sees as free GPU memory (CUDA's figure). On the
        GB10 that is system RAM *without* page cache, so it sinks as model
        files are read even while `free` shows plenty available — and below
        `--reserve-vram` (8 GB) ComfyUI loads nothing onto the GPU, logs
        `loaded partially; 0.00 MB usable` and runs for minutes on the CPU
        (bench hair-r1, 2026-09-13: 100 s cells became 420 s)."""
        s = self.stats()
        if not s:
            return None
        return s["devices"][0]["vram_free"] / 1e9

    def guard(self, min_free_gb: float, log=print) -> None:
        """Keep ComfyUI on the GPU. First drop the page cache of the model
        files (posix_fadvise DONTNEED, no root needed — video-stack's
        chain.drop_page_cache, measured 7 → 53 GB free in 2 s); only if that
        is not enough and nobody else's job is queued, restart the service.
        The box is shared with the Ol1nLLM app and video-stack."""
        free = self.vram_free_gb()
        rss = comfy_rss_gb()
        if rss is not None and rss > LEAK_RSS_GB and not self.queue_busy():
            # The couple-bench signature: the process swells over a series of
            # jobs and never gives the memory back (45 GB RSS after /free on
            # 2026-09-13). Only a restart returns it; do it while idle.
            log(f"[guard] ComfyUI holds {rss:.0f} GB RSS with an empty queue — restarting")
            self.restart(log)
            return
        if free is None or free >= min_free_gb:
            return
        n = drop_page_cache()
        after = self.vram_free_gb()
        log(f"[guard] {free:.1f} GB free → dropped page cache of {n} files → {after:.1f} GB")
        if after is not None and after >= min_free_gb:
            return
        # Models ComfyUI keeps loaded (--cache-lru 2) are the other big
        # holder; unloading costs only a reload (video-stack chain.free_models).
        self.free_models()
        time.sleep(5)
        after = self.vram_free_gb()
        log(f"[guard] asked ComfyUI to unload models → {after:.1f} GB")
        if after is not None and after >= min_free_gb / 2:
            return
        waited = 0
        while self.queue_busy() and waited < 1800:
            log(f"[guard] still {after:.1f} GB free and the queue is busy — waiting")
            time.sleep(30)
            waited += 30
            drop_page_cache()
            after = self.vram_free_gb()
            if after is not None and after >= min_free_gb / 2:
                return
        log(f"[guard] {after} GB free — restarting comfyui.service")
        self.restart(log)

    def restart(self, log=print) -> None:
        subprocess.run(["systemctl", "--user", "restart", "comfyui.service"], check=False)
        deadline = time.time() + 300
        time.sleep(15)
        while time.time() < deadline:
            if self.stats():
                log(f"[guard] back up, {self.vram_free_gb():.1f} GB free")
                time.sleep(5)
                return
            time.sleep(5)
        raise CellError("ComfyUI did not come back after restart")


COMFY_ROOT = os.path.expanduser("~/Code/ComfyUI")
LEAK_RSS_GB = 35.0


def comfy_rss_gb() -> float | None:
    """Resident memory of the comfyui.service main process, or None."""
    try:
        pid = subprocess.run(
            ["systemctl", "--user", "show", "comfyui.service", "-p", "MainPID", "--value"],
            capture_output=True, text=True, timeout=10,
        ).stdout.strip()
        with open(f"/proc/{int(pid)}/status") as f:
            for line in f:
                if line.startswith("VmRSS:"):
                    return int(line.split()[1]) / 1e6
    except (OSError, ValueError, subprocess.SubprocessError):
        return None
    return None


def drop_page_cache() -> int:
    """Ask the kernel to forget cached pages of ComfyUI's model, input and
    output files. Harmless: the next read comes from disk."""
    n = 0
    for sub in ("models", "input", "output"):
        for dp, _, fs in os.walk(os.path.join(COMFY_ROOT, sub)):
            for f in fs:
                try:
                    fd = os.open(os.path.join(dp, f), os.O_RDONLY)
                    os.posix_fadvise(fd, 0, 0, os.POSIX_FADV_DONTNEED)
                    os.close(fd)
                    n += 1
                except OSError:
                    pass
    return n


def set_seed(wf: dict, seed: int) -> None:
    for node in wf.values():
        inputs = node.get("inputs") or {}
        if "seed" in inputs:
            inputs["seed"] = seed
        if "noise_seed" in inputs:
            inputs["noise_seed"] = seed


def apply_node_sweep(wf: dict, values: dict[str, object]) -> None:
    """`{"11.strength": 0.45}` → wf["11"]["inputs"]["strength"] = 0.45. Keys
    starting with `mask.` / `graph.` are handled by the caller."""
    for key, value in values.items():
        node_id, _, field = key.partition(".")
        if node_id in ("mask", "graph"):
            continue
        if node_id not in wf:
            raise CellError(f"sweep key {key}: node {node_id} is not in the graph")
        if field not in wf[node_id]["inputs"]:
            raise CellError(f"sweep key {key}: input {field} is not on node {node_id}")
        wf[node_id]["inputs"][field] = value
