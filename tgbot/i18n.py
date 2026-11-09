"""Chat-message localization for the bot.

The Mini App localizes itself from Telegram's `language_code`; the bot does the
same for the messages it sends into the chat. Unknown codes fall back to English.
"""

from messages import MESSAGES

# Languages the catalog ships (BCP 47, as in the Mini App).
SUPPORTED = frozenset(next(iter(MESSAGES.values())))

_ALIASES = {"no": "nb", "nn": "nb", "iw": "he", "in": "id", "pt": "pt-BR"}


def norm_lang(code: str | None) -> str:
    """Maps a Telegram/BCP 47 language code onto a shipped catalog language."""
    if not code:
        return "en"
    parts = code.strip().replace("_", "-").split("-")
    lang = _ALIASES.get(parts[0].lower(), parts[0].lower())
    rest = [p.lower() for p in parts[1:]]
    if lang == "zh":
        traditional = "hant" in rest or any(r in ("tw", "hk", "mo") for r in rest)
        return "zh-Hant" if traditional else "zh-Hans"
    if lang == "pt-BR":
        return "pt-PT" if "pt" in rest else "pt-BR"
    return lang if lang in SUPPORTED else "en"


def t(key: str, lang: str | None = "en", **kwargs) -> str:
    """Looks up a message in `lang` (English fallback) and formats it."""
    table = MESSAGES[key]
    text = table.get(norm_lang(lang), table["en"])
    return text.format(**kwargs) if kwargs else text


# English `detail` strings of the API errors the Mini App shows to users, mapped
# to their catalog key. Anything not listed (ids, internal errors) stays as is.
API_DETAILS = {
    "wait for your previous generation to finish": "api_wait_image",
    "wait for your previous animation to finish": "api_wait_video",
    "your free daily limit is used up and you have no credits": "api_limit_image",
    "your free animation for today is used up and you have no animation credits": "api_limit_video",
    "ComfyUI is unavailable": "api_comfy_down",
    "video server is unavailable": "api_video_down",
    "could not read the photo analysis": "api_photo_analysis",
    "pick a new haircut or a new colour": "api_pick_hair",
    "image is not valid base64": "api_bad_image",
    "image is empty": "api_bad_image",
    "No face found \u2014 use a clear, front-facing portrait of one person.": "api_no_face",
    "The face is too small \u2014 crop closer to the head and shoulders.": "api_face_small",
    "Not enough hair to restyle in this photo.": "api_no_hair",
}


def translate_detail(detail, lang: str | None):
    """Localizes a known English API error `detail`; other values pass through."""
    key = API_DETAILS.get(detail) if isinstance(detail, str) else None
    return t(key, lang) if key else detail


def request_lang(authorization: str | None, accept_language: str | None = None) -> str:
    """Best-effort language of an API caller: the Telegram user's language_code
    from the Mini App initData, else the first Accept-Language tag. The
    signature is validated elsewhere; this only reads the language."""
    import json
    from urllib.parse import parse_qsl

    scheme, _, value = (authorization or "").partition(" ")
    if scheme == "tma" and value:
        try:
            user = json.loads(dict(parse_qsl(value)).get("user", "{}"))
            if user.get("language_code"):
                return norm_lang(user["language_code"])
        except (ValueError, AttributeError):
            pass
    if accept_language:
        return norm_lang(accept_language.split(",")[0].split(";")[0])
    return "en"
