# MangaPrompts

LEGO-style prompt builder for AI image generation (Grok). Users compose manga-style character prompts by selecting from building blocks in a cross-matrix format, generating complete image prompts for head styles, manga styles, and historical styles.

## Platforms

| Platform | Status |
|----------|--------|
| iOS | Supported |
| Android | Supported |
| macOS | Supported |
| Linux | Supported |
| Web | Supported |

## Features

- Cross-matrix block selection for prompt composition
- Manga style, head style, historical style categories
- LEGO-style composable prompt blocks
- Export complete Grok Image prompt

## Tech Stack

- Flutter / Dart 3.10.7
- Riverpod 2.6.1 + Freezed (immutable models)
- json_annotation, image_picker, shared_preferences

## Build

```bash
# Code generation
dart run build_runner build

# Run
flutter run -d ios
```

## Documentation

- [CHANGELOG.md](CHANGELOG.md) — development history
- [GALLERY.md](GALLERY.md) — screenshots and videos
