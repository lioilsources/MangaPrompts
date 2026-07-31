import config
import payments


def test_payload_roundtrip():
    raw = payments.build_payload(123456789, "m")
    assert len(raw.encode()) <= 128
    assert payments.parse_payload(raw) == (123456789, "m")


def test_parse_rejects_unknown_package():
    assert payments.parse_payload('{"u":1,"p":"xxl","n":"abc"}') is None


def test_parse_rejects_garbage():
    assert payments.parse_payload("not json") is None
    assert payments.parse_payload('{"u":"NaN","p":"m"}') is None


def test_pre_checkout_ok():
    raw = payments.build_payload(42, "s")
    stars = config.PACKAGES["s"]["stars"]
    assert payments.validate_pre_checkout(raw, payer_id=42, total_amount=stars) is None


def test_pre_checkout_wrong_payer():
    raw = payments.build_payload(42, "s")
    stars = config.PACKAGES["s"]["stars"]
    assert payments.validate_pre_checkout(raw, payer_id=43, total_amount=stars) is not None


def test_pre_checkout_wrong_amount():
    raw = payments.build_payload(42, "s")
    assert payments.validate_pre_checkout(raw, payer_id=42, total_amount=1) is not None
