# Changelog

## [31/10/2026] — Restyler backend, shared package, beards, live portrait
- `packages/tsumiki_shared`: catalogs, masks, prompts and render client shared with the Restyler app; Tsumiki now depends on it
- `POST /api/render`: step DAG over a graph whitelist, per-step refund, `AUTH_MODE=app` for a bot-less instance
- Beards: `beardmask.py`, `beardprompt.py`, candidate catalog (no card yet, the bench gate has not run)
- Live portrait: `POST /api/live`, `live_portrait` and `wan_motion` render steps (LivePortrait is not installed on SPARK yet)
- `tools/ondevice`: ONNX export and parity of the face parsers

## [09/09/2026] — Restyle a photo (Mini App card)
- New card **Restyle a photo**: upload a photo, pick a style, get the same person in the same pose in that style (InstantID keeps the face, a depth ControlNet keeps the pose)
- **Photo / Illustration** toggle — the medium leads the prompt, the style block follows; negatives push away from the other medium
- 48 styles in five groups (the measured art-tradition set from Ol1nLLM plus contemporary looks)
- Billed exactly like image generation (same free quota, credits, one job at a time); the result also lands in the Telegram chat
- Backend: `POST /api/restyle`, ComfyUI image upload, SDXL bucket snap from the photo header, node exception surfaced as the job error ("no face detected")
- Title bar: card switcher (prompt builder / restyle / animate) replaces the two-way toggle

## [03/06/2026] — Prompt builder redesign (orthogonal axes)
- Removed cross-block collisions that confused FLUX (photo + manga signals at once)
- New master axis **medium** (photoreal / anime / manga / comic) — declared once, front-loaded
- New **framing** axis (portrait / full body / cowboy / close-up) — single source of truth; poses no longer carry framing words
- **subject** reworked to describe only count + gender (solo / pair / trio / quad / 5+, boys & girls & mixed); medium words removed
- **style** is now pure genre/mood; camera incompatibility matrices deleted
- Engine medium-gating: camera dropped for illustration, manga FX dropped for photoreal, single-person detail slots dropped for groups, medium-aware negative guard
- Layered, multi-select clothing: outfit / top / bottom / legwear / underwear (added crop tops, tank tops, miniskirts, shorts, socks, pantyhose, panties, ...)
- Templates & presets migrated to the new model

## [22/02/2026]
- Initial commit: MangaPrompts Flutter app

# Dev Notes

## [22/02/2026]
- Cross matrix building blocks into Grok Image complete prompt
- Manga style
- Head style
- Historical style
