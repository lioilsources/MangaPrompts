import struct

from imagesize import SDXL_BUCKETS, image_size, latent_for, snap_to_sdxl_bucket


def _png(w: int, h: int) -> bytes:
    return b"\x89PNG\r\n\x1a\n" + struct.pack(">I", 13) + b"IHDR" + struct.pack(">II", w, h) + b"\x08\x06"


def _jpeg(w: int, h: int) -> bytes:
    app0 = b"\xff\xe0" + struct.pack(">H", 16) + b"JFIF\x00" + b"\x00" * 9
    dqt = b"\xff\xdb" + struct.pack(">H", 67) + b"\x00" * 65
    sof0 = b"\xff\xc0" + struct.pack(">H", 17) + b"\x08" + struct.pack(">HH", h, w) + b"\x03" + b"\x00" * 9
    return b"\xff\xd8" + app0 + dqt + sof0 + b"\xff\xda"


def test_png_header():
    assert image_size(_png(434, 884)) == (434, 884)


def test_jpeg_header_walks_past_earlier_segments():
    assert image_size(_jpeg(3024, 4032)) == (3024, 4032)


def test_progressive_jpeg_sof2():
    data = _jpeg(640, 480).replace(b"\xff\xc0", b"\xff\xc2")
    assert image_size(data) == (640, 480)


def test_garbage_and_truncation_are_none():
    assert image_size(b"") is None
    assert image_size(b"not an image at all") is None
    assert image_size(_png(10, 10)[:20]) is None
    assert image_size(_jpeg(10, 10)[:6]) is None


def test_bucket_snap_by_aspect():
    assert snap_to_sdxl_bucket(1000, 1000) == (1024, 1024)
    assert snap_to_sdxl_bucket(434, 884) == (768, 1344)  # 1:2 phone photo
    assert snap_to_sdxl_bucket(3024, 4032) == (896, 1152)  # 3:4
    assert snap_to_sdxl_bucket(4032, 3024) == (1152, 896)
    assert snap_to_sdxl_bucket(1080, 1920) == (768, 1344)  # 9:16
    assert snap_to_sdxl_bucket(2, 3) == (832, 1216)


def test_bucket_snap_symmetric_in_orientation():
    for w, h in SDXL_BUCKETS:
        assert snap_to_sdxl_bucket(w, h) == (w, h)
        assert snap_to_sdxl_bucket(h, w) == (h, w)


def test_bucket_snap_degenerate():
    assert snap_to_sdxl_bucket(0, 10) == SDXL_BUCKETS[0]


def test_latent_for_falls_back_when_unreadable():
    assert latent_for(b"???") == (832, 1216)
    assert latent_for(b"???", fallback=(1024, 1024)) == (1024, 1024)
    assert latent_for(_png(1920, 1080)) == (1344, 768)
