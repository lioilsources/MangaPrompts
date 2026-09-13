"""Blocking ComfyUI client for the bench — the bot's async client is built for
one job per request, the bench runs hundreds in a row and wants to be simple
to read. Graph preparation is NOT here: cells are built by `comfy.prepare_workflow`,
the function the bot itself sends through, so the bench measures what ships."""

from __future__ import annotations

import json
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
        """Memory ComfyUI can still get. On the GB10 the GPU shares system RAM,
        and `devices[0].vram_free` counts page cache as used (it read 10 GB on
        a healthy box with 32 GB available), so the system figure is the one
        that sinks when the offload trap springs (117 of 121 GB used)."""
        s = self.stats()
        if not s:
            return None
        return s["system"]["ram_free"] / 1e9

    def guard(self, min_free_gb: float, log=print) -> None:
        """The couple-bench trap (reports/couple_phase0.md §11.17): after a
        long series ComfyUI stops fitting models on the GPU, offloads them all
        and keeps running on the CPU for hours without failing. Restart before
        the next cell when free memory has sunk — but never while somebody
        else's job is queued; the box is shared with the Ol1nLLM app."""
        free = self.vram_free_gb()
        if free is None or free >= min_free_gb:
            return
        waited = 0
        while self.queue_busy() and waited < 1800:
            log(f"[guard] {free:.1f} GB free but the queue is busy — waiting")
            time.sleep(30)
            waited += 30
        free = self.vram_free_gb()
        if free is not None and free >= min_free_gb:
            return
        log(f"[guard] {free} GB free < {min_free_gb} GB — restarting comfyui.service")
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
