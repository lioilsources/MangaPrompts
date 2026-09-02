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


def test_video_timeout_floors_short_scenes():
    from app import _video_timeout
    import config

    # a 1-beat scene estimates ~4 min; the floor still applies
    assert _video_timeout({"minutes_est": 4}) == config.VIDEO_JOB_TIMEOUT


def test_video_timeout_follows_long_scenes():
    from app import _video_timeout

    # 12-beat scene: 35 min estimated, 38.6 min observed — the fixed 30 min
    # deadline used to drop the finished render on the floor
    assert _video_timeout({"minutes_est": 35}) == 35 * 60 * 2
    assert _video_timeout({"minutes_est": 35}) > 39 * 60


def test_video_timeout_survives_a_missing_estimate():
    from app import _video_timeout
    import config

    assert _video_timeout({}) == config.VIDEO_JOB_TIMEOUT
    assert _video_timeout({"minutes_est": None}) == config.VIDEO_JOB_TIMEOUT


def test_video_timeout_is_capped():
    from app import _video_timeout
    import config

    assert _video_timeout({"minutes_est": 10_000}) == config.VIDEO_JOB_TIMEOUT_MAX
