"""In-memory job store.

Jobs are intentionally not persisted: the finished image also lands in the
user's Telegram chat, so losing in-flight state on restart is acceptable.
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


class JobStore:
    def __init__(self):
        self._jobs: dict[str, Job] = {}

    def add(self, job: Job) -> None:
        self._jobs[job.id] = job

    def get(self, job_id: str) -> Job | None:
        return self._jobs.get(job_id)

    def active_count(self, user_id: int) -> int:
        return sum(
            1
            for j in self._jobs.values()
            if j.user_id == user_id and j.status in ("queued", "running")
        )
