# Changelog

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
