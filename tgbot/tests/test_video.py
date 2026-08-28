from video import strip_data_uri


def test_strip_data_uri_passthrough():
    assert strip_data_uri("aGVsbG8=") == "aGVsbG8="


def test_strip_data_uri_strips_prefix():
    assert strip_data_uri("data:image/png;base64,aGVsbG8=") == "aGVsbG8="


def test_strip_data_uri_jpeg():
    assert strip_data_uri("data:image/jpeg;base64,/9j/4AAQ") == "/9j/4AAQ"
