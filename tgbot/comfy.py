"""ComfyUI client + workflow preparation.

`prepare_workflow` is a direct port of ComfyImageService._prepare in
lib/services/comfy_image_service.dart — keep the two in sync: placeholder
substitution (__PROMPT__/__NEGATIVE__/__IMAGE__/__POSE__/__CKPT__), forced
batch size, randomized seed/noise_seed.
"""

import asyncio
import copy
import json
import random

import aiohttp


class ComfyError(Exception):
    pass


def prepare_workflow(
    template: dict,
    prompt: str,
    negative: str = "",
    batch: int = 1,
    image_name: str | None = None,
    pose_name: str | None = None,
    checkpoint: str | None = None,
) -> dict:
    wf = copy.deepcopy(template)
    seed = random.randrange(1 << 31)

    for node in wf.values():
        if not isinstance(node, dict):
            continue
        inputs = node.get("inputs")
        if not isinstance(inputs, dict):
            continue

        for key, value in list(inputs.items()):
            if value == "__PROMPT__":
                inputs[key] = prompt
            elif value == "__NEGATIVE__":
                inputs[key] = negative
            elif value == "__IMAGE__" and image_name is not None:
                inputs[key] = image_name
            elif value == "__POSE__" and pose_name is not None:
                inputs[key] = pose_name
            elif value == "__CKPT__" and checkpoint is not None:
                inputs[key] = checkpoint

        cls = node.get("class_type")
        if cls in ("EmptySD3LatentImage", "EmptyLatentImage"):
            if "batch_size" in inputs:
                inputs["batch_size"] = batch
        elif cls == "RepeatLatentBatch":
            if "amount" in inputs:
                inputs["amount"] = batch

        if "seed" in inputs:
            inputs["seed"] = seed
        if "noise_seed" in inputs:
            inputs["noise_seed"] = seed

    return wf


class ComfyClient:
    def __init__(self, base_url: str, client_id: str, headers: dict | None = None):
        """`headers` carries CF Access service-token credentials when ComfyUI
        is reached through its public hostname instead of the LAN."""
        self.base_url = base_url.rstrip("/")
        self.client_id = client_id
        self.headers = headers or {}

    async def queue_prompt(self, session: aiohttp.ClientSession, workflow: dict) -> tuple[str, int]:
        """Submits the workflow; returns (prompt_id, queue_number)."""
        async with session.post(
            f"{self.base_url}/prompt",
            json={"prompt": workflow, "client_id": self.client_id},
            headers=self.headers,
            timeout=aiohttp.ClientTimeout(total=30),
        ) as resp:
            body = await resp.text()
            if resp.status != 200:
                raise ComfyError(f"/prompt HTTP {resp.status}: {body[:200]}")
            data = json.loads(body)
        node_errors = data.get("node_errors")
        if node_errors:
            raise ComfyError(f"workflow error: {json.dumps(node_errors)[:300]}")
        return data["prompt_id"], int(data.get("number", 0))

    async def get_history(self, session: aiohttp.ClientSession, prompt_id: str) -> dict | None:
        async with session.get(
            f"{self.base_url}/history/{prompt_id}",
            headers=self.headers,
            timeout=aiohttp.ClientTimeout(total=15),
        ) as resp:
            if resp.status != 200:
                return None
            data = await resp.json()
        return data.get(prompt_id)

    async def view(
        self, session: aiohttp.ClientSession, filename: str, subfolder: str, type_: str
    ) -> bytes:
        async with session.get(
            f"{self.base_url}/view",
            params={"filename": filename, "subfolder": subfolder, "type": type_},
            headers=self.headers,
            timeout=aiohttp.ClientTimeout(total=120),
        ) as resp:
            if resp.status != 200:
                raise ComfyError(f"/view HTTP {resp.status} for {filename}")
            return await resp.read()

    async def wait_for_image(
        self,
        session: aiohttp.ClientSession,
        prompt_id: str,
        timeout: int = 300,
        poll_interval: float = 2.0,
    ) -> bytes:
        """Polls /history until the job finishes, then downloads the first output."""
        deadline = asyncio.get_event_loop().time() + timeout
        while True:
            if asyncio.get_event_loop().time() > deadline:
                raise ComfyError("generation timed out")
            await asyncio.sleep(poll_interval)
            try:
                hist = await self.get_history(session, prompt_id)
            except (aiohttp.ClientError, asyncio.TimeoutError):
                continue
            if hist is None:
                continue
            status = (hist.get("status") or {}).get("status_str")
            if status == "error":
                raise ComfyError("generation failed on the ComfyUI side")

            outputs = hist.get("outputs") or {}
            refs = [
                img
                for node in outputs.values()
                for img in (node.get("images") or [])
                if img.get("type") != "temp"
            ]
            if not refs:
                raise ComfyError("no output images in workflow result")
            ref = refs[0]
            return await self.view(
                session, ref["filename"], ref.get("subfolder", ""), ref.get("type", "output")
            )
