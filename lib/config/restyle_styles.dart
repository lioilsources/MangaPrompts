/// Styles offered by the Restyle card (photo → same person, new look).
///
/// Plain Dart, not a block YAML: these are not prompt-builder axes and the
/// card never mixes them with other blocks. The art-tradition set is the one
/// Ol1nLLM measured against SDXL models (its `docs/style-matrix.md`): each
/// block moved at least one model visibly away from its unstyled baseline
/// and none duplicated another. The "Popular" group is contemporary looks
/// added for this card without that measurement — prune what does not hold
/// up on the server.
///
/// The block is appended *after* the medium sentence: CLIP weights early
/// tokens most, and the medium is the one thing that must not be argued
/// with. The style id is what the app sends in the chat caption, never the
/// block text.
class RestyleStyle {
  const RestyleStyle({
    required this.id,
    required this.label,
    required this.group,
    required this.block,
  });

  final String id;
  final String label;
  final String group;

  /// Prompt fragment describing the look.
  final String block;
}

/// Photo vs. drawn. The only place the render medium is declared — the same
/// rule the prompt builder's `medium` axis follows.
enum RestyleMedium {
  photo('Photo', 'photo'),
  illustration('Illustration', 'illustration');

  const RestyleMedium(this.label, this.wire);

  /// Button text.
  final String label;

  /// Value sent to the backend (it routes the checkpoint by it).
  final String wire;
}

const kRestyleGroupPopular = 'Popular';
const kRestyleGroupAsia = 'Asia';
const kRestyleGroupEurope = 'Europe';
const kRestyleGroupAmericasOceania = 'Americas & Oceania';
const kRestyleGroupAfricaNearEast = 'Africa & Near East';

/// Display order of the sections.
const kRestyleGroups = <String>[
  kRestyleGroupPopular,
  kRestyleGroupAsia,
  kRestyleGroupEurope,
  kRestyleGroupAmericasOceania,
  kRestyleGroupAfricaNearEast,
];

const kRestyleStyles = <RestyleStyle>[
  // ── Popular (contemporary; not from the measured matrix) ────────────────
  RestyleStyle(
    id: 'anime',
    label: 'Anime',
    group: kRestyleGroupPopular,
    block:
        'anime style, clean cel-shaded linework, vibrant flat colors, expressive anime features, soft gradient shading',
  ),
  RestyleStyle(
    id: 'comic',
    label: 'Comic book',
    group: kRestyleGroupPopular,
    block:
        'western comic-book style, bold inked outlines, flat cel shading, halftone dot shading, dramatic color blocks',
  ),
  RestyleStyle(
    id: 'watercolor',
    label: 'Watercolor',
    group: kRestyleGroupPopular,
    block:
        'loose watercolor painting, soft wet-on-wet washes, bleeding pigment edges, visible paper grain, light airy palette',
  ),
  RestyleStyle(
    id: 'oilportrait',
    label: 'Oil painting',
    group: kRestyleGroupPopular,
    block:
        'classical oil painting, visible brushstrokes, rich layered glazes, warm gallery lighting, canvas texture',
  ),
  RestyleStyle(
    id: 'pencil',
    label: 'Pencil sketch',
    group: kRestyleGroupPopular,
    block:
        'graphite pencil sketch, fine hatching and cross-hatching, soft smudged shading, white paper, monochrome',
  ),
  RestyleStyle(
    id: 'popart',
    label: 'Pop art',
    group: kRestyleGroupPopular,
    block:
        'pop art style, bold flat primary colors, thick black outlines, ben-day dots, high-contrast graphic composition',
  ),
  RestyleStyle(
    id: 'cyberpunk',
    label: 'Cyberpunk',
    group: kRestyleGroupPopular,
    block:
        'cyberpunk aesthetic, neon-soaked night city, magenta and cyan rim light, rain-slick reflections, high-tech dystopian mood',
  ),
  RestyleStyle(
    id: 'noir',
    label: 'Film noir',
    group: kRestyleGroupPopular,
    block:
        'film noir style, high-contrast black and white, hard chiaroscuro lighting, venetian blind shadows, cinematic 1940s mood',
  ),

  // ── Asia ────────────────────────────────────────────────────────────────
  RestyleStyle(
    id: 'ukiyoe',
    label: 'Ukiyo-e woodblock',
    group: kRestyleGroupAsia,
    block:
        'ukiyo-e style, bold black outlines, flat color areas, elegant curved lines, stylized hair and clothing folds, limited color palette, japanese woodblock print aesthetic',
  ),
  RestyleStyle(
    id: 'chineseink',
    label: 'Chinese ink wash',
    group: kRestyleGroupAsia,
    block:
        'traditional chinese ink wash painting, flowing black ink brushstrokes, minimal color, elegant empty space, soft gradients, expressive line work, misty atmosphere',
  ),
  RestyleStyle(
    id: 'persian',
    label: 'Persian miniature',
    group: kRestyleGroupAsia,
    block:
        'persian miniature style, highly detailed decorative patterns, rich jewel tones, flattened perspective, elegant elongated figures, intricate clothing and background ornaments',
  ),
  RestyleStyle(
    id: 'indian',
    label: 'Indian miniature',
    group: kRestyleGroupAsia,
    block:
        'detailed indian miniature painting, flat vibrant colors, intricate decorative patterns, stylized elongated figures, ornate borders, rich reds and golds',
  ),
  RestyleStyle(
    id: 'burmese',
    label: 'Burmese temple painting',
    group: kRestyleGroupAsia,
    block:
        'traditional burmese temple painting style, flowing elegant lines, rich gold and red tones, ornate decorative details, soft idealized faces, luminous atmosphere',
  ),
  RestyleStyle(
    id: 'thangka',
    label: 'Tibetan thangka',
    group: kRestyleGroupAsia,
    block:
        'tibetan thangka painting style, precise symmetrical composition, rich mineral pigments, gold outlines, ornate halo and cloud motifs, flat stylized figures',
  ),
  RestyleStyle(
    id: 'rinpa',
    label: 'Rinpa gold screen',
    group: kRestyleGroupAsia,
    block:
        'japanese rinpa screen style, gold leaf background, bold flat silhouettes, stylized waves and grasses, mineral pigments, decorative asymmetry',
  ),
  RestyleStyle(
    id: 'dunhuang',
    label: 'Dunhuang cave mural',
    group: kRestyleGroupAsia,
    block:
        'dunhuang cave mural style, flowing celestial ribbons, ochre and lapis pigments, weathered plaster texture, serene stylized figures, flat halo',
  ),
  RestyleStyle(
    id: 'minhwa',
    label: 'Korean minhwa',
    group: kRestyleGroupAsia,
    block:
        'korean minhwa folk painting style, flat cheerful colours, naive charming proportions, decorative peonies and tigers motifs, hanji paper texture',
  ),
  RestyleStyle(
    id: 'papercut',
    label: 'Paper cut',
    group: kRestyleGroupAsia,
    block:
        'traditional paper cut style, single flat colour silhouette, intricate symmetrical cutouts, sharp negative space, decorative floral lattice',
  ),
  RestyleStyle(
    id: 'filipino',
    label: 'Traditional Filipino',
    group: kRestyleGroupAsia,
    block:
        'traditional filipino style, intricate weaving patterns, soft warm colors, graceful elongated figures, decorative textile motifs',
  ),

  // ── Europe ──────────────────────────────────────────────────────────────
  RestyleStyle(
    id: 'romanfresco',
    label: 'Roman fresco',
    group: kRestyleGroupEurope,
    block:
        'roman fresco style, soft pastel colors, slightly weathered texture, classical drapery, calm idealized faces, muted earth and ochre palette, wall-painting look',
  ),
  RestyleStyle(
    id: 'greek',
    label: 'Classical Greek',
    group: kRestyleGroupEurope,
    block:
        'classical greek inspired painting, idealized muscular anatomy, clean marble-like skin, balanced composition, soft drapery folds, harmonious proportions, muted earth tones',
  ),
  RestyleStyle(
    id: 'minoan',
    label: 'Minoan fresco',
    group: kRestyleGroupEurope,
    block:
        'minoan fresco style, flowing curved contours, terracotta and marine blue, stylized profile with large eye, spiral and wave motifs, plaster texture',
  ),
  RestyleStyle(
    id: 'byzantine',
    label: 'Byzantine icon',
    group: kRestyleGroupEurope,
    block:
        'byzantine icon style, flat gold leaf ground, elongated solemn figures, stylized drapery folds, red and deep blue robes, hieratic frontal composition',
  ),
  RestyleStyle(
    id: 'illumination',
    label: 'Illuminated manuscript',
    group: kRestyleGroupEurope,
    block:
        'medieval illuminated manuscript style, gold leaf, ornate vine border, flat jewel colours, stylized figure inside a decorated initial, vellum texture',
  ),
  RestyleStyle(
    id: 'stainedglass',
    label: 'Stained glass',
    group: kRestyleGroupEurope,
    block:
        'gothic stained glass window style, bold black lead lines, luminous saturated colour panels, flat shapes, backlit glow, geometric tracery',
  ),
  RestyleStyle(
    id: 'baroque',
    label: 'Dramatic Baroque',
    group: kRestyleGroupEurope,
    block:
        'dramatic baroque painting, strong chiaroscuro lighting, deep shadows, rich dark colors, dynamic composition, emotional intensity, detailed fabric folds',
  ),
  RestyleStyle(
    id: 'impressionist',
    label: 'Impressionist',
    group: kRestyleGroupEurope,
    block:
        'impressionist plein air painting, broken brushstrokes, vibrating complementary colours, soft daylight, loose edges, atmospheric immediacy',
  ),
  RestyleStyle(
    id: 'artnouveau',
    label: 'Art Nouveau',
    group: kRestyleGroupEurope,
    block:
        'art nouveau style, flowing organic lines, decorative floral motifs, elegant elongated figures, soft pastel colors, ornamental details, graceful curves',
  ),
  RestyleStyle(
    id: 'secession',
    label: 'Vienna Secession',
    group: kRestyleGroupEurope,
    block:
        'vienna secession style, flat gilded ornament, geometric mosaic patterns, elongated figure, decorative square motifs, gold and muted green',
  ),
  RestyleStyle(
    id: 'artdeco',
    label: 'Art Deco poster',
    group: kRestyleGroupEurope,
    block:
        'art deco poster style, streamlined geometric forms, strong symmetry, metallic gold and black, flat colour blocks, elegant stylized figure',
  ),
  RestyleStyle(
    id: 'constructivist',
    label: 'Constructivist poster',
    group: kRestyleGroupEurope,
    block:
        'russian constructivist poster style, bold diagonal composition, red black and cream, geometric shapes, photomontage feel, heavy sans-serif blocks',
  ),
  RestyleStyle(
    id: 'woodcut',
    label: 'Expressionist woodcut',
    group: kRestyleGroupEurope,
    block:
        'german expressionist woodcut print, harsh carved lines, stark black and white, angular distorted forms, visible gouge marks, raw emotional energy',
  ),

  // ── Americas & Oceania ──────────────────────────────────────────────────
  RestyleStyle(
    id: 'maya',
    label: 'Maya mural',
    group: kRestyleGroupAmericasOceania,
    block:
        'classic maya mural style, formal profile and three-quarter views, intricate geometric patterns, jade green and deep red colors, hieroglyphic decorative elements, stylized proportions',
  ),
  RestyleStyle(
    id: 'aztec',
    label: 'Aztec codex',
    group: kRestyleGroupAmericasOceania,
    block:
        'aztec codex and stone relief style, bold black outlines, vibrant red turquoise and gold accents, geometric feather and sun motifs, formal stylized figures',
  ),
  RestyleStyle(
    id: 'inca',
    label: 'Inca textile & goldwork',
    group: kRestyleGroupAmericasOceania,
    block:
        'inca textile and goldwork inspired style, precise geometric patterns, rich gold and deep red tones, formal frontal composition, stylized strong bodies',
  ),
  RestyleStyle(
    id: 'ledger',
    label: 'Plains ledger art',
    group: kRestyleGroupAmericasOceania,
    block:
        'plains ledger art style, bold outlines, flat colors, dynamic movement lines, symbolic geometric patterns, earth tones with bright accents',
  ),
  RestyleStyle(
    id: 'huichol',
    label: 'Huichol yarn painting',
    group: kRestyleGroupAmericasOceania,
    block:
        'huichol yarn painting style, dense parallel yarn lines, vivid contrasting colours, symbolic peyote and deer motifs, flat filled forms',
  ),
  RestyleStyle(
    id: 'aboriginal',
    label: 'Aboriginal dot painting',
    group: kRestyleGroupAmericasOceania,
    block:
        'australian aboriginal dot painting style, intricate dot patterns, earth pigment colors, x-ray style internal forms, symbolic story elements, flat ceremonial composition',
  ),
  RestyleStyle(
    id: 'polynesian',
    label: 'Traditional Polynesian',
    group: kRestyleGroupAmericasOceania,
    block:
        'traditional polynesian style, bold geometric tattoos, strong black outlines, stylized powerful bodies, warm skin tones, carved wood aesthetic',
  ),

  // ── Africa & Near East ──────────────────────────────────────────────────
  RestyleStyle(
    id: 'egyptian',
    label: 'Ancient Egyptian',
    group: kRestyleGroupAfricaNearEast,
    block:
        'ancient egyptian wall painting style, strict side profile views, flat bold colors, hierarchical proportions, black outlines, ochre skin tones, hieroglyphic decorative elements, formal composition',
  ),
  RestyleStyle(
    id: 'ashanti',
    label: 'Ashanti (Ghana)',
    group: kRestyleGroupAfricaNearEast,
    block:
        'ashanti inspired style, rich gold tones, geometric textile patterns, strong stylized figures, decorative symbols, warm earth and gold palette',
  ),
  RestyleStyle(
    id: 'dogon',
    label: 'Dogon (Mali)',
    group: kRestyleGroupAfricaNearEast,
    block:
        'dogon sculptural style, elongated stylized figures, abstract geometric forms, strong vertical lines, earthy wood-like tones, ritualistic presence',
  ),
  RestyleStyle(
    id: 'himba',
    label: 'Himba (Namibia)',
    group: kRestyleGroupAfricaNearEast,
    block:
        'himba inspired style, rich red ochre skin tones, minimal clothing emphasis, strong natural anatomy, warm desert light, textured skin details',
  ),
  RestyleStyle(
    id: 'maasai',
    label: 'Maasai',
    group: kRestyleGroupAfricaNearEast,
    block:
        'maasai inspired style, bold red and beadwork patterns, elongated elegant figures, strong vertical composition, vibrant contrasting colors',
  ),
  RestyleStyle(
    id: 'assyrian',
    label: 'Assyrian palace relief',
    group: kRestyleGroupAfricaNearEast,
    block:
        'assyrian palace relief style, strong black outlines, low-relief shading, formal profile views, detailed hair and beard patterns, monumental composition',
  ),
  RestyleStyle(
    id: 'mesopotamian',
    label: 'Mesopotamian relief',
    group: kRestyleGroupAfricaNearEast,
    block:
        'mesopotamian relief style, composite profile views, formal hierarchical proportions, detailed patterned hair, carved stone texture, earthy tones',
  ),
  RestyleStyle(
    id: 'arabian',
    label: 'Pre-Islamic Arabian',
    group: kRestyleGroupAfricaNearEast,
    block:
        'pre-islamic arabian style, elegant elongated figures, soft desert tones, flowing drapery, refined facial features, calm monumental presence',
  ),
  RestyleStyle(
    id: 'hebrew',
    label: 'Ancient Hebrew',
    group: kRestyleGroupAfricaNearEast,
    block:
        'ancient near eastern hebrew inspired style, simple strong outlines, modest earth palette, solemn dignified figures, subtle patterned textiles, formal composition',
  ),
];

RestyleStyle? restyleStyleById(String? id) {
  if (id == null) return null;
  for (final s in kRestyleStyles) {
    if (s.id == id) return s;
  }
  return null;
}

/// Styles of one section, in catalog order.
List<RestyleStyle> restyleStylesIn(String group) =>
    kRestyleStyles.where((s) => s.group == group).toList(growable: false);

// Medium sentences. "a person" on purpose: the face comes from InstantID and
// the body from the depth map, so the prompt must not argue gender or
// framing with the photo.
const _photoMedium =
    'a photorealistic photograph of a person, natural skin texture, '
    'realistic lighting, true-to-life detail';
const _illustrationMedium = 'a painted illustration of a person, artwork';

// Juggernaut's own negative (Ol1nLLM's preset), plus the other medium so the
// toggle actually bites: in photo mode a woodblock style should read as
// costume and set, not turn the photo into a print.
const _baseNegative =
    'bad quality, worst quality, low quality, jpeg artifacts, blurry, '
    'watermark, deformed, disfigured, bad anatomy, bad hands';
const _photoNegative =
    'illustration, painting, drawing, cartoon, anime, 3d render, $_baseNegative';
const _illustrationNegative =
    'photograph, photorealistic, photo, 3d render, $_baseNegative';

/// Positive prompt for the backend: medium first, style block last.
String restylePrompt(RestyleStyle style, RestyleMedium medium) {
  final head = switch (medium) {
    RestyleMedium.photo => _photoMedium,
    RestyleMedium.illustration => _illustrationMedium,
  };
  return '$head, ${style.block}';
}

/// Negative prompt for the backend, per medium.
String restyleNegative(RestyleMedium medium) => switch (medium) {
      RestyleMedium.photo => _photoNegative,
      RestyleMedium.illustration => _illustrationNegative,
    };
