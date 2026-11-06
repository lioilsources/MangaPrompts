import io
import json

import numpy as np
from PIL import Image, ImageDraw

import composite
import config


def to_png(im: Image.Image) -> bytes:
    buf = io.BytesIO()
    im.save(buf, "PNG")
    return buf.getvalue()


def face(shift=0, scale=1.0, size=(400, 500)) -> Image.Image:
    """Grey portrait with a 'face': an oval, two brows and a mouth."""
    w, h = size
    im = Image.new("RGB", size, (128, 128, 128))
    d = ImageDraw.Draw(im)
    cx, cy = w // 2, h // 2 + shift
    fw, fh = 100 * scale, 140 * scale
    d.ellipse((cx - fw, cy - fh, cx + fw, cy + fh), fill=(220, 180, 160))
    for sx in (-1, 1):
        bx = cx + sx * 45 * scale
        d.rectangle((bx - 25 * scale, cy - 50 * scale, bx + 25 * scale, cy - 40 * scale), fill=(60, 40, 30))
    d.rectangle((cx - 35 * scale, cy + 60 * scale, cx + 35 * scale, cy + 70 * scale), fill=(160, 60, 60))
    return im


def edit_mask(size=(400, 500)) -> Image.Image:
    """255 everywhere but the face oval of `face()`."""
    w, h = size
    m = Image.new("L", size, 255)
    ImageDraw.Draw(m).ellipse((w // 2 - 100, h // 2 - 140, w // 2 + 100, h // 2 + 140), fill=0)
    return m


def with_new_hair(im: Image.Image) -> Image.Image:
    out = im.copy()
    d = ImageDraw.Draw(out)
    d.rectangle((0, 0, im.width, 80), fill=(40, 25, 15))
    d.rectangle((0, 0, 70, im.height), fill=(40, 25, 15))
    d.rectangle((im.width - 70, 0, im.width, im.height), fill=(40, 25, 15))
    return out


def test_raw_output_points_save_at_the_aligned_edit():
    wf = json.loads((config.WORKFLOW_DIR / "flux_hair_kontext.api.json").read_text())
    assert composite.raw_output(wf)
    comp = next(n for n in wf.values() if n["class_type"] == "ImageCompositeMasked")
    save = next(n for n in wf.values() if n["class_type"] == "SaveImage")
    assert save["inputs"]["images"] == comp["inputs"]["source"]
    assert not composite.raw_output({"1": {"class_type": "SaveImage", "inputs": {"images": ["2", 0]}}})


def pixel(png: bytes, xy) -> tuple:
    return Image.open(io.BytesIO(png)).convert("RGB").getpixel(xy)


def test_aligned_edit_gets_the_source_face_back():
    src = face()
    ed = with_new_hair(face())
    # Kontext's re-render of the face: a slight tone shift plus noise, no move
    rng = np.random.default_rng(1)
    noisy = np.asarray(ed, dtype=np.int16) + 6 + rng.integers(-12, 13, size=(500, 400, 3))
    ed = Image.fromarray(noisy.clip(0, 255).astype(np.uint8))
    res = composite.paste_back(to_png(src), to_png(ed), to_png(edit_mask()))
    assert res.pasted and res.drift < 0.2
    # face centre is the source's, the new hair stays the edit's
    assert pixel(res.png, (200, 250)) == src.getpixel((200, 250))
    assert pixel(res.png, (10, 10)) == ed.getpixel((10, 10))


def test_moved_face_never_shows_the_old_brows():
    src = face()
    ed = with_new_hair(face(shift=18, scale=1.12))  # rescaled, brows lower
    res = composite.paste_back(to_png(src), to_png(ed), to_png(edit_mask()))
    out = np.asarray(Image.open(io.BytesIO(res.png)).convert("RGB")).astype(int)
    # where the source had a brow and the edit has skin, the edit wins
    sx, sy = 155, 250 - 45  # left brow of the source
    assert np.abs(out[sy, sx] - np.asarray(ed.getpixel((sx, sy)))).max() <= 3
    assert np.abs(out[sy, sx] - np.asarray(src.getpixel((sx, sy)))).max() > 60


def test_new_hair_over_the_kept_forehead_stays():
    """Round 3: the source's bare forehead pasted over a new fringe."""
    src = face()
    ed = with_new_hair(face())
    ImageDraw.Draw(ed).rectangle((120, 110, 260, 170), fill=(40, 25, 15))  # fringe inside the kept oval
    res = composite.paste_back(to_png(src), to_png(ed), to_png(edit_mask()))
    assert np.abs(np.asarray(pixel(res.png, (190, 140))) - (40, 25, 15)).max() <= 3


def test_size_mismatch_follows_the_source():
    src = face()
    ed = with_new_hair(face()).resize((200, 250))
    res = composite.paste_back(to_png(src), to_png(ed), to_png(edit_mask()))
    assert Image.open(io.BytesIO(res.png)).size == src.size
