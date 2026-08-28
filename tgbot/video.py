"""video-api client — photo→video rendering on the SPARK box.

The server is video-stack/serve.py (Wan 2.2 I2V + RIFE, single GPU worker,
~150 s per beat). Contract: GET /scenes for the preset catalog, POST /jobs
(202) to submit, GET /jobs/{id} to poll, GET /jobs/{id}/result for the mp4.
Mirrors the Ol1nLLM client (lib/services/video_service.dart).
"""

import json

import aiohttp


class VideoError(Exception):
    pass


class VideoJobGone(VideoError):
    """404 on a job — video-api restarted and dropped its in-flight state."""


def strip_data_uri(image: str) -> str:
    """The server accepts both, but plain base64 keeps the payload smallest."""
    if image.startswith("data:"):
        _, _, tail = image.partition(",")
        return tail
    return image


class VideoClient:
    def __init__(self, base_url: str, headers: dict | None = None):
        """`headers` carries CF Access service-token credentials when the
        video-api is reached through its public hostname instead of the LAN."""
        self.base_url = base_url.rstrip("/")
        self.headers = headers or {}

    async def fetch_scenes(self, session: aiohttp.ClientSession) -> list[dict]:
        async with session.get(
            f"{self.base_url}/scenes",
            headers=self.headers,
            timeout=aiohttp.ClientTimeout(total=15),
        ) as resp:
            body = await resp.text()
            if resp.status != 200:
                raise VideoError(f"/scenes HTTP {resp.status}: {body[:200]}")
            return json.loads(body)["scenes"]

    async def submit(
        self, session: aiohttp.ClientSession, scene_id: str, image_b64: str, seed: int
    ) -> dict:
        """Submits a render; returns the 202 body ({job_id, beats, seconds,
        minutes_est}). Anything but 202 is an error (e.g. not enough VRAM)."""
        async with session.post(
            f"{self.base_url}/jobs",
            json={"scene": scene_id, "image": image_b64, "seed": seed},
            headers=self.headers,
            timeout=aiohttp.ClientTimeout(total=60),
        ) as resp:
            body = await resp.text()
            if resp.status != 202:
                raise VideoError(f"/jobs HTTP {resp.status}: {body[:200]}")
            return json.loads(body)

    async def status(self, session: aiohttp.ClientSession, job_id: str) -> dict:
        async with session.get(
            f"{self.base_url}/jobs/{job_id}",
            headers=self.headers,
            timeout=aiohttp.ClientTimeout(total=15),
        ) as resp:
            body = await resp.text()
            if resp.status == 404:
                raise VideoJobGone(job_id)
            if resp.status != 200:
                raise VideoError(f"/jobs/{job_id} HTTP {resp.status}: {body[:200]}")
            return json.loads(body)

    async def download(self, session: aiohttp.ClientSession, job_id: str) -> bytes:
        async with session.get(
            f"{self.base_url}/jobs/{job_id}/result",
            headers=self.headers,
            timeout=aiohttp.ClientTimeout(total=180),
        ) as resp:
            if resp.status != 200:
                raise VideoError(f"/result HTTP {resp.status} for job {job_id}")
            return await resp.read()
