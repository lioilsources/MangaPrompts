# MangaPrompts — Flutter LEGO Prompt Builder

## Context

Projekt obsahuje 4 markdown soubory s vocabuláři, šablonami, maticemi a příklady promptů pro AI image generátor (Grok). Cílem je vytvořit Flutter mobilní aplikaci, kde uživatel skládá prompt z "kostiček" (LEGO bloků) — oči, vlasy, styl, výraz atd. — vybere base fotku a jedním kliknutím odešle prompt + obrázek do xAI API pro generování.

YAML konfigurační soubory zajistí snadné přidávání nových kostiček bez změny kódu.

---

## Architektura

```
manga_prompts/
├── android/
├── ios/
├── assets/
│   └── config/
│       ├── blocks/
│       │   ├── subject.yaml
│       │   ├── style.yaml
│       │   ├── face.yaml
│       │   ├── eyes.yaml
│       │   ├── eyebrows.yaml
│       │   ├── hair.yaml
│       │   ├── expression.yaml
│       │   ├── pose.yaml
│       │   ├── clothing.yaml
│       │   ├── lighting.yaml
│       │   ├── effects.yaml
│       │   ├── background.yaml
│       │   ├── camera.yaml
│       │   ├── palette.yaml
│       │   ├── quality.yaml
│       │   └── negative.yaml
│       ├── templates.yaml
│       └── presets.yaml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── block_loader.dart          # YAML parsing, hot-reload
│   │   └── models/
│   │       ├── block.dart             # Block model (freezed)
│   │       ├── block_category.dart    # Category model
│   │       ├── prompt_template.dart   # Template model
│   │       └── preset.dart            # Preset model
│   ├── providers/
│   │   ├── blocks_provider.dart       # Riverpod: loaded blocks per category
│   │   ├── selection_provider.dart    # Riverpod: user's current selection
│   │   ├── prompt_provider.dart       # Riverpod: computed final prompt
│   │   ├── template_provider.dart     # Riverpod: active template
│   │   └── api_provider.dart          # Riverpod: xAI API client
│   ├── services/
│   │   ├── xai_api_service.dart       # HTTP calls to xAI REST API
│   │   ├── image_service.dart         # image_picker + base64 conversion
│   │   └── prompt_engine.dart         # Template slot filling + permutation
│   └── ui/
│       ├── screens/
│       │   ├── home_screen.dart       # Main builder screen
│       │   ├── result_screen.dart     # Generated image display
│       │   ├── presets_screen.dart    # Preset management
│       │   └── settings_screen.dart   # API key, preferences
│       └── widgets/
│           ├── block_picker.dart      # Chip selector for one category
│           ├── prompt_preview.dart    # Live prompt text preview
│           ├── image_base_picker.dart # Photo selection widget
│           └── category_rail.dart     # Sidebar/tab navigation
└── pubspec.yaml
```

---

## Krok 1: Inicializace Flutter projektu

- `flutter create manga_prompts`
- Nastavit `pubspec.yaml` s dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  yaml: ^3.1.2
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  freezed_annotation: ^2.4.6
  json_annotation: ^4.9.0
  image_picker: ^1.1.2
  http: ^1.2.2
  shared_preferences: ^2.3.3
  path_provider: ^2.1.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.9.0
  riverpod_generator: ^2.6.3
```

- Registrovat `assets/config/` v pubspec.yaml

---

## Krok 2: YAML datové soubory — struktura kostiček

Každý soubor v `assets/config/blocks/` má jednotnou strukturu:

```yaml
# assets/config/blocks/eyes.yaml
category: eyes
label: "Oči"
icon: eye                    # icon name pro UI
required: true
blocks:
  - id: eyes_shojo_innocent
    label: "Shojo nevinné"
    tags: [shojo, innocent, romantic]
    value: "large round gradient violet eyes with strong catchlight, sparkle in eyes"
    mood: [sweet, nostalgic]
    incompatible: [expression_maniac, expression_ahegao]

  - id: eyes_cold_sharp
    label: "Chladné ostré"
    tags: [cold, badass, seinen]
    value: "sharp narrow gray eyes with dark limbal ring, heavy lidded"
    mood: [dark, technical]
    incompatible: []

  - id: eyes_action_focused
    label: "Akční soustředěné"
    tags: [action, shonen, intense]
    value: "focused amber eyes with glint, furrowed brows"
    mood: [action, technical]
    incompatible: []
```

Přidání nové kostičky = přidání nového `-` záznamu do YAML. Přidání celé nové kategorie = nový YAML soubor + záznam v `templates.yaml`.

### Templates — definice pořadí slotů

```yaml
# assets/config/templates.yaml
templates:
  - id: portrait
    label: "Detailní portrét"
    slots:
      - category: quality
        required: true
      - category: subject
        required: true
      - category: face
        required: false
      - category: eyes
        required: true
      - category: eyebrows
        required: false
      - category: hair
        required: true
      - category: expression
        required: true
      - category: clothing
        required: false
      - category: pose
        required: false
      - category: effects
        required: false
      - category: lighting
        required: true
      - category: background
        required: false
      - category: camera
        required: true
      - category: palette
        required: false
      - category: negative
        required: true
    separator: ", "

  - id: action_scene
    label: "Akční scéna"
    slots:
      - category: quality
        required: true
      - category: subject
        required: true
      - category: pose
        required: true
      - category: effects
        required: true
      - category: style
        required: true
      - category: lighting
        required: true
      - category: palette
        required: false
      - category: background
        required: true
      - category: camera
        required: true
      - category: negative
        required: true
    separator: ", "
```

### Presets — uložené kombinace

```yaml
# assets/config/presets.yaml
presets:
  - id: shojo_heroine
    label: "Shojo hrdinka"
    template: portrait
    selections:
      subject: subject_woman_20s
      eyes: eyes_shojo_innocent
      hair: hair_long_black_blue
      expression: expression_gentle_smile
      lighting: lighting_golden_hour
      camera: camera_canon_r5_85mm
      quality: quality_8k_hyper
      negative: negative_no_cartoon
```

---

## Krok 3: Data modely (Dart + Freezed)

### Block model
```dart
@freezed
class Block with _$Block {
  const factory Block({
    required String id,
    required String label,
    required String value,        // prompt fragment
    @Default([]) List<String> tags,
    @Default([]) List<String> mood,
    @Default([]) List<String> incompatible,
  }) = _Block;
}
```

### BlockCategory model
```dart
@freezed
class BlockCategory with _$BlockCategory {
  const factory BlockCategory({
    required String category,     // "eyes", "hair", ...
    required String label,        // "Oči", "Vlasy", ...
    required String icon,
    @Default(false) bool required_,
    @Default([]) List<Block> blocks,
  }) = _BlockCategory;
}
```

### PromptTemplate model
```dart
@freezed
class PromptTemplate with _$PromptTemplate {
  const factory PromptTemplate({
    required String id,
    required String label,
    required List<TemplateSlot> slots,
    @Default(", ") String separator,
  }) = _PromptTemplate;
}

@freezed
class TemplateSlot with _$TemplateSlot {
  const factory TemplateSlot({
    required String category,
    @Default(false) bool required_,
  }) = _TemplateSlot;
}
```

---

## Krok 4: YAML Loader — `block_loader.dart`

- Na startu appky načte všechny YAML soubory z `assets/config/blocks/`
- Parsuje je přes `yaml` package do `BlockCategory` modelů
- Načte `templates.yaml` a `presets.yaml`
- Exponuje data přes Riverpod providers
- Podporuje reload (pro dev — pro produkci stačí restart)

Klíč: `rootBundle.loadString('assets/config/blocks/eyes.yaml')` pro každý soubor. Seznam souborů bude definován v manifest YAML nebo hardcoded list názvů kategorií.

---

## Krok 5: Prompt Engine — `prompt_engine.dart`

### Sestavení jednoho promptu
1. Vezmi aktivní template → jeho `slots` (pořadí kategorií)
2. Pro každý slot najdi vybraný block z `selection_provider`
3. Spoj `block.value` v pořadí slotů pomocí `separator`
4. Výsledek = finální prompt string

### Permutace
Pokud uživatel vybere více bloků v jedné kategorii:
- Kartézský součin přes všechny multi-selecty
- Provider `permutationsProvider` počítá celkový počet a aktuální index
- Uživatel naviguje šipkami nebo exportuje všechny

### Validace kompatibility
- Při výběru bloku kontroluj `incompatible` seznam
- Nekompatibilní bloky v jiných kategoriích zobraz šedě / s warningem

---

## Krok 6: xAI API Service — `xai_api_service.dart`

### Text-to-image
```
POST https://api.x.ai/v1/images/generations
{
  "model": "grok-imagine-image",
  "prompt": "<assembled prompt>",
  "aspect_ratio": "16:9",
  "resolution": "2k"
}
Header: Authorization: Bearer <API_KEY>
```

### Image-to-image (base foto + prompt)
```
POST https://api.x.ai/v1/images/edits
{
  "model": "grok-imagine-image",
  "prompt": "<assembled prompt>",
  "image_url": "data:image/jpeg;base64,<base64_data>"
}
Header: Authorization: Bearer <API_KEY>
```

- API klíč uložen v `SharedPreferences` (encrypted)
- Uživatel ho zadá v Settings screen
- Response obsahuje URL vygenerovaného obrázku (dočasné — stáhnout ihned)

---

## Krok 7: UI — 4 hlavní obrazovky

### HomeScreen (hlavní builder)
- Nahoře: výběr template (dropdown)
- Uprostřed: vertikální seznam kategorií, každá se scrollovatelným řádkem chipů (block_picker)
- Dole: live prompt preview (scrollovatelný text)
- FAB: "Generovat" tlačítko
- Appbar action: načíst base fotku (image_base_picker)

### ResultScreen
- Zobrazí vygenerovaný obrázek
- Tlačítka: uložit do galerie, sdílet, zpět na builder
- Zobrazí použitý prompt

### PresetsScreen
- Seznam uložených presetů (z YAML + uživatelské)
- Klik = načte výběr do builderu
- Možnost uložit aktuální výběr jako nový preset

### SettingsScreen
- xAI API klíč (secure input)
- Default template
- Default aspect ratio / resolution

---

## Krok 8: Naplnění YAML dat z existujících .md souborů

Převod obsahu ze 4 markdown souborů do YAML bloků:

| Zdroj | Cílový YAML |
|-------|-------------|
| `templates.md` sekce 1 (7 stylů) | `style.yaml` — 7 bloků |
| `templates.md` sekce 2.1 (oči) | `eyes.yaml` — ~15 bloků |
| `templates.md` sekce 2.2 (vlasy) | `hair.yaml` — ~12 bloků |
| `templates.md` sekce 3 (výrazy) | `expression.yaml` — ~15 bloků |
| `context.md` (styly, žánry) | doplnění `style.yaml` |
| `matrix.md` (mood matice) | validační data pro `mood` fieldy |
| `matrix.md` (foto termíny) | `camera.yaml`, `quality.yaml` |
| `matrix.md` (negativní prompty) | `negative.yaml` |
| `prompts.md` (hotové příklady) | `presets.yaml` — 4 preset kombinace |

---

## Implementační pořadí

1. **Flutter projekt + pubspec.yaml + asset registrace**
2. **Data modely** (Block, BlockCategory, PromptTemplate, Preset) s freezed
3. **YAML soubory** — naplnit z .md souborů (eyes, hair, expression, style, subject, face, lighting, camera, quality, negative, effects, background, pose, clothing, palette, eyebrows)
4. **block_loader.dart** — YAML parsing
5. **Riverpod providers** — blocks, selection, template, prompt
6. **prompt_engine.dart** — sestavení promptu, permutace, validace
7. **UI widgets** — block_picker, prompt_preview, image_base_picker
8. **UI screens** — HomeScreen, SettingsScreen
9. **xai_api_service.dart** — API volání
10. **ResultScreen** — zobrazení výsledku
11. **Presets** — load/save
12. **Polish** — error handling, loading states, empty states

---

## Verifikace

1. **YAML loading**: spustit app, ověřit že se načtou všechny kategorie a bloky
2. **Prompt assembly**: vybrat bloky v UI, ověřit že preview odpovídá příkladům z `prompts.md`
3. **Permutace**: vybrat 2+ bloky ve 2+ kategoriích, ověřit počet variant
4. **Kompatibilita**: vybrat nekompatibilní bloky, ověřit warning
5. **API integrace**: zadat API klíč, vygenerovat obrázek z textu (text-to-image)
6. **Image-to-image**: načíst base fotku, vygenerovat editovaný obrázek
7. **Přidání nové kostičky**: přidat blok do YAML, restartovat app, ověřit že se objeví v UI
8. **Přidání nové kategorie**: vytvořit nový YAML soubor + slot v template, ověřit funkčnost
