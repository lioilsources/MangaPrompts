import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import i18n  # noqa: E402
from messages import MESSAGES  # noqa: E402


def test_every_key_has_every_language_and_same_placeholders():
    import re

    langs = set(MESSAGES["start"])
    assert len(langs) == 45
    for key, by_lang in MESSAGES.items():
        assert set(by_lang) == langs, key
        ref = set(re.findall(r"\{(\w+)\}", by_lang["en"]))
        for lang, text in by_lang.items():
            assert set(re.findall(r"\{(\w+)\}", text)) == ref, (key, lang)


def test_norm_lang():
    assert i18n.norm_lang(None) == "en"
    assert i18n.norm_lang("pt") == "pt-BR"
    assert i18n.norm_lang("no") == "nb"
    assert i18n.norm_lang("xx") == "en"


def test_t_formats_and_falls_back():
    assert "5" in i18n.t("start", "de", free=5, video_free=1)
    assert i18n.t("open_app", "xx") == i18n.t("open_app", "en")


def test_translate_detail_known_and_unknown():
    en = "wait for your previous generation to finish"
    assert i18n.translate_detail(en, "en") == i18n.t("api_wait_image", "en")
    assert i18n.translate_detail(en, "ru") != en
    assert i18n.translate_detail("something else", "ru") == "something else"
