"""In-memory job store.

Image jobs are intentionally not persisted: the finished image also lands in
the user's Telegram chat, so losing in-flight state on restart is acceptable.
Video jobs additionally mirror into the video_jobs SQLite table (db.py) so a
bot restart mid-render can re-attach the watcher — a 10-star, ~12-minute
artifact is too expensive to drop on every deploy.
"""

import time
import uuid
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class Job:
    user_id: int
    prompt: str
    workflow: str
    id: str = field(default_factory=lambda: uuid.uuid4().hex)
    status: str = "queued"  # queued | running | done | error
    error: str | None = None
    image_path: Path | None = None
    prompt_id: str | None = None
    created: float = field(default_factory=time.time)
    # video jobs (kind == "video"); all defaulted so the image path is untouched
    kind: str = "image"  # image | video
    scene_label: str = ""
    remote_id: str | None = None  # video-api job id
    beat: int = 0
    beats: int = 0
    phase: str | None = None
    position: int | None = None
    video_path: Path | None = None
    # Seconds allowed for the render, sized from the scene's own estimate at
    # submit time; 0 means "fall back to the configured floor".
    timeout: float = 0.0


class JobStore:
    def __init__(self):
        self._jobs: dict[str, Job] = {}

    def add(self, job: Job) -> None:
        self._jobs[job.id] = job

    def get(self, job_id: str) -> Job | None:
        return self._jobs.get(job_id)

    def active_count(self, user_id: int, kind: str | None = None) -> int:
        return sum(
            1
            for j in self._jobs.values()
            if j.user_id == user_id
            and j.status in ("queued", "running")
            and (kind is None or j.kind == kind)
        )
