import importlib.util
import io
import os
import subprocess
import sys
from pathlib import Path

import pytest
from PIL import Image

import nsfw

HAS_NUDENET = importlib.util.find_spec("nudenet") is not None
TGBOT = Path(__file__).resolve().parent.parent


def png(im: Image.Image) -> bytes:
    buf = io.BytesIO()
    im.save(buf, "PNG")
    return buf.getvalue()


# The real detector runs in a child process: NudeNet pulls in cv2, and
# test_bench_tasks checks that this test process never imports it.
REAL = """
import io, sys
from PIL import Image, ImageDraw
import nsfw

def png(im):
    buf = io.BytesIO(); im.save(buf, "PNG"); return buf.getvalue()

im = Image.new("RGB", (512, 768), (40, 90, 120))
d = ImageDraw.Draw(im)
d.ellipse((180, 80, 330, 260), fill=(220, 180, 160))   # a face
d.rectangle((120, 260, 390, 768), fill=(30, 30, 90))   # a coat
assert nsfw.findings(png(im)) == [], "clothed"
for mode in ("RGB", "RGBA", "L"):
    assert nsfw.findings(png(Image.new(mode, (64, 96)))) == [], mode
print("ok")
"""


@pytest.mark.skipif(not HAS_NUDENET, reason="nudenet not installed")
def test_real_detector_passes_clothed_and_reads_every_png_mode():
    env = {**os.environ, "PYTHONPATH": os.pathsep.join([str(TGBOT), *sys.path])}
    out = subprocess.run(
        [sys.executable, "-c", REAL], cwd=TGBOT, env=env, capture_output=True, text=True, timeout=120
    )
    assert out.returncode == 0 and out.stdout.strip() == "ok", out.stderr[-2000:]


def test_threshold_filters_and_only_exposed_labels_count(monkeypatch):
    class Fake:
        def detect(self, image):
            assert image.shape[2] == 4  # NudeNet converts RGBA itself
            return [
                {"class": "FEMALE_BREAST_EXPOSED", "score": 0.6},
                {"class": "BUTTOCKS_EXPOSED", "score": 0.2},
                {"class": "FACE_FEMALE", "score": 0.99},
                {"class": "FEMALE_BREAST_COVERED", "score": 0.9},
            ]

    monkeypatch.setattr(nsfw, "_detector", Fake())
    assert nsfw.findings(png(Image.new("RGB", (8, 8))), threshold=0.35) == [
        ("FEMALE_BREAST_EXPOSED", 0.6)
    ]
