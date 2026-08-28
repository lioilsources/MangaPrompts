from video import strip_data_uri


def test_strip_data_uri_passthrough():
    assert strip_data_uri("aGVsbG8=") == "aGVsbG8="


def test_strip_data_uri_strips_prefix():
    assert strip_data_uri("data:image/png;base64,aGVsbG8=") == "aGVsbG8="


def test_strip_data_uri_jpeg():
    assert strip_data_uri("data:image/jpeg;base64,/9j/4AAQ") == "/9j/4AAQ"


def test_english_prefers_en_fields():
    from app import _english

    out = _english({
        "id": "wink", "label": "Mrknutí na kameru", "desc": "Pohled do kamery.",
        "label_en": "Wink at the camera", "desc_en": "A look into the camera.",
        "beats": 3,
    })
    assert out["label"] == "Wink at the camera"
    assert out["desc"] == "A look into the camera."
    # the split must not leak to the Mini App
    assert "label_en" not in out and "desc_en" not in out
    assert out["beats"] == 3


def test_english_falls_back_to_czech():
    from app import _english

    # a scene added before the split (or a stale server) must still render
    out = _english({"id": "x", "label": "Tanec", "desc": "Popis.", "beats": 5})
    assert out["label"] == "Tanec"
    assert out["desc"] == "Popis."
