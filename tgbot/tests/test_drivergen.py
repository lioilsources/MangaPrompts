import json
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "tools" / "bench" / "drivers"))

import drivergen  # noqa: E402


def test_composed_presets_come_after_their_parts():
    manifest = json.loads((drivergen.DRIVERS / "manifest.json").read_text())
    names = drivergen.order(manifest)
    assert "hair-breeze" not in names
    for part in manifest["alive"]["parts"]:
        assert names.index(part) < names.index("alive")


@pytest.mark.skipif(shutil.which("ffmpeg") is None, reason="no ffmpeg")
def test_ffmpeg_commands_produce_the_length(tmp_path):
    raw = tmp_path / "raw.mp4"
    subprocess.run(
        ["ffmpeg", "-y", "-loglevel", "error", "-f", "lavfi", "-i", "testsrc=size=128x128:rate=25:duration=5", str(raw)],
        check=True,
    )
    clip = tmp_path / "clip.mp4"
    subprocess.run(drivergen.trim_cmd(raw, clip, 3), check=True)
    both = tmp_path / "both.mp4"
    subprocess.run(drivergen.concat_cmd([clip, clip], both), check=True)
    duration = lambda p: float(subprocess.run(  # noqa: E731
        ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(p)],
        capture_output=True, text=True, check=True,
    ).stdout)
    assert duration(clip) == pytest.approx(3, abs=0.1)
    assert duration(both) == pytest.approx(6, abs=0.2)
