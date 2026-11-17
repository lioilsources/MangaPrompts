# Architektura a platformy

Přesunuto z CLAUDE.md (obsah beze změny).

## Platforms

iOS, Android, macOS, Linux, Web.

Web ships as a **Telegram Mini App**: generation goes through `tgbot/`
(FastAPI + aiogram on the JODA NAS → ComfyUI on the SPARK box over
LAN/CF-Access), never through the direct xAI/ol1n/ComfyUI clients.
Photo animation follows the same path against the **video-api on SPARK:8096**
(video-stack repo; Wan 2.2 I2V): Mini App uploads a photo + scene, the bot
delivers the mp4 into the chat. Separate video ledger (users.video_credits,
package `v1` = 10⭐/animation, VIDEO_FREE_DAILY_LIMIT=1/day free).
The third card, **Restyle a photo** (`restyle_screen.dart`, `POST /api/restyle`),
keeps the face and pose (depth ControlNet) of an uploaded photo and renders it
in a picked style (`lib/config/restyle_styles.dart`: popular looks, 42 measured
painters from Ol1nLLM's style matrix, art traditions, and the 228 lab
wave-7 artists, cultures and media (bench `out/lab7-sdxl`); medium toggle
photo/illustration); it is billed as an ordinary image generation. The medium
picks the **engine** (`RESTYLE_ENGINES` in `tgbot/config.py`): photo runs
`flux_restyle.api.json` (FLUX.1-dev + PuLID + InstantX depth), illustration
`sdxl_restyle.api.json` (InstantID + xinsir union depth, checkpoint from
`RESTYLE_CHECKPOINTS`). Measurements: `docs/restyle-flux-results.md`.
The fourth card, **Try a haircut** (`hair_screen.dart`, `POST /api/hair`),
repaints only the hair of a portrait: a free analysis pass (face parsing,
`hair_analyse.api.json`; hair = `FaceSegment` ∪ `ClothesSegment`, because the
face parser stops at the chest on a phone selfie) feeds `tgbot/hairmask.py`,
which builds the inpaint mask from the style's shape — a down style never has
`length: keep`, that is for fringes, updos and colour only
(`test_bench_catalog.py`) — and reads the hair colour; the prompt is written
server-side per `HAIR_ENGINE` (`tgbot/hairprompt.py`), optionally with a new
colour (`tgbot/haircolours.py`; style id `keep-cut` = colour only, mask of the old
hair without an envelope); billing starts only after
the analysis accepted the photo. The catalog (`lib/config/hairstyle_catalog.dart`)
is generated from the bench gate (`docs/hair-matrix.md`) and the card stays
hidden while it is empty. Each style is picked from a card with a **preview**
(`assets/hair/<id>.jpg`, `Hairstyle.preview`): the bench's own output for that
style on the group's primary synthetic portrait, so every card shows the same
face and the eye compares hair only — no stock photos, no personal data. A
colour chip carries a **swatch** (`HairColour.swatch`): the hair colour the
bench *measured* on the accepted cells, not the target range. Both come out of
`export_catalog.py --bench/--colours-bench`; `test/hairstyles_test.dart`
fails on a catalog entry without them. Ol1nLLM mirrors the mask in `lib/models/hair_mask.dart`.
The cards share `TsumikiAppBar` (`TsumikiScreen` enum drives the shop chip
and the card switcher; `screenOffered` hides animate without scenes and hair
without hairstyles). Monetization: Telegram Stars credits (SQLite ledger in tgbot/db.py, packages
in tgbot/config.py, paywall UI in lib/ui/widgets/paywall_sheet.dart). Platform seams use conditional imports
(`backend_factory.dart`, `image_service.dart`, `repose_entry.dart`,
`local_image.dart`, `platform/telegram_webapp.dart`) — anything importing
dart:io/cronet_http/gal/path_provider must stay out of the web import graph.
Web deploys ONLY from CI (`.github/workflows/deploy-web.yml` → Cloudflare
Pages); local `lib/config/secrets.dart` may hold skip-worktree creds that a
local web deploy would leak. Manual release steps: `docs/telegram-release.md`.
