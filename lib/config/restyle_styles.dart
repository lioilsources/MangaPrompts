/// Styles offered by the Restyle card (photo → same person, new look).
///
/// Plain Dart, not a block YAML: these are not prompt-builder axes and the
/// card never mixes them with other blocks. The art-tradition set and the
/// painters are the ones Ol1nLLM measured against SDXL and FLUX models (its
/// `docs/style-matrix.md`, waves one to three): each block moved at least one
/// model visibly away from its unstyled baseline and none duplicated another.
/// Painter ids match Ol1nLLM's so a result can be traced back to the
/// measurement; their blocks are copied verbatim (the `booru` tag variants are
/// not — both Restyle engines read prose). How they behave with an identity
/// adapter in the graph is in `docs/restyle-flux-results.md`. The "Popular"
/// group is contemporary looks added for this card without that measurement.
///
/// The block is appended *after* the medium sentence: CLIP and T5 weight early
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
const kRestyleGroupPainters = 'Painters';
const kRestyleGroupAsia = 'Asia';
const kRestyleGroupEurope = 'Europe';
const kRestyleGroupAmericasOceania = 'Americas & Oceania';
const kRestyleGroupAfricaNearEast = 'Africa & Near East';

// Lab wave 7 (Ol1nLLM tools/lab): artists beyond the 42 measured painters and
// render media. Measured txt2img in the lab and through this card's SDXL
// engine on the bench (tgbot/tools/bench, out/lab7-sdxl), taken in whole.
const kRestyleGroupArtists = 'More artists';
const kRestyleGroupMediaPaint = 'Paint & drawing';
const kRestyleGroupMediaPrint = 'Print & lettering';
const kRestyleGroupMediaTextile = 'Textile & paper';
const kRestyleGroupMediaSculpture = 'Sculpture & craft';
const kRestyleGroupMediaPhotoDigital = 'Photo & digital';

/// Display order of the sections.
const kRestyleGroups = <String>[
  kRestyleGroupPopular,
  kRestyleGroupPainters,
  kRestyleGroupArtists,
  kRestyleGroupAsia,
  kRestyleGroupEurope,
  kRestyleGroupAmericasOceania,
  kRestyleGroupAfricaNearEast,
  kRestyleGroupMediaPaint,
  kRestyleGroupMediaPrint,
  kRestyleGroupMediaTextile,
  kRestyleGroupMediaSculpture,
  kRestyleGroupMediaPhotoDigital,
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

  // ── Painters (Ol1nLLM style matrix, third wave, 2026-09-10) ─────────────
  RestyleStyle(
    id: 'botticelli',
    label: 'Botticelli',
    group: kRestyleGroupPainters,
    block:
        'early renaissance tempera painting by Sandro Botticelli, graceful linear contours, long flowing golden hair, pale porcelain skin, transparent fluttering drapery, flowers and orange grove, gentle wistful expression, delicate pastel palette',
  ),
  RestyleStyle(
    id: 'davinci',
    label: 'Da Vinci (sfumato)',
    group: kRestyleGroupPainters,
    block:
        'portrait painting by Leonardo da Vinci, sfumato, soft smoky shadows without hard edges, enigmatic half smile, muted olive umber and dark green palette, hazy distant landscape, high renaissance oil on poplar',
  ),
  RestyleStyle(
    id: 'davinci-chalk',
    label: 'Da Vinci (red chalk study)',
    group: kRestyleGroupPainters,
    block:
        'red chalk figure study by Leonardo da Vinci, sanguine on toned paper, fine parallel hatching, anatomical precision, unfinished sketch edges, faint mirror handwriting notes in the margin',
  ),
  RestyleStyle(
    id: 'elgreco',
    label: 'El Greco',
    group: kRestyleGroupPainters,
    block:
        'mannerist painting by El Greco, dramatically elongated flame-like figure, upturned ecstatic eyes, cold flickering light, stormy grey sky, acid green crimson and silver, restless swirling drapery, spiritual intensity',
  ),
  RestyleStyle(
    id: 'vermeer',
    label: 'Vermeer',
    group: kRestyleGroupPainters,
    block:
        'painting by Johannes Vermeer, soft daylight from a window on the left, pearl earring and turban, ultramarine and lemon yellow, quiet domestic interior, pointillé highlights, calm serene stillness, smooth Dutch golden age oil',
  ),
  RestyleStyle(
    id: 'goya-caprichos',
    label: 'Goya (Caprichos etching)',
    group: kRestyleGroupPainters,
    block:
        'etching and aquatint by Francisco Goya from Los Caprichos, monochrome sepia print, grainy aquatint shadows, satirical grotesque figure, owls and bats in the gloom, hand-written caption below',
  ),
  RestyleStyle(
    id: 'goya-black',
    label: 'Goya (Black Paintings)',
    group: kRestyleGroupPainters,
    block:
        'black painting by Francisco Goya, murky black brown and ochre palette, grotesque haunted figure emerging from darkness, wild frantic brushstrokes, gaping mouth and staring eyes, nightmare mural on plaster',
  ),
  RestyleStyle(
    id: 'monet',
    label: 'Monet',
    group: kRestyleGroupPainters,
    block:
        'plein air painting by Claude Monet, figure with parasol in a windswept meadow, dappled sunlight and moving clouds, loose feathery brushstrokes, lavender and green shadows, bright airy sky, form dissolving in light',
  ),
  RestyleStyle(
    id: 'seurat',
    label: 'Seurat (pointillism)',
    group: kRestyleGroupPainters,
    block:
        'pointillist painting by Georges Seurat, entire image built from tiny dots of pure colour, stiff formal figures in profile, sunny riverside park, optical mixing, calm frozen geometry, soft shimmering surface',
  ),
  RestyleStyle(
    id: 'cezanne',
    label: 'Cezanne',
    group: kRestyleGroupPainters,
    block:
        'painting by Paul Cezanne, figure built from patches of parallel constructive brushstrokes, blue-green ochre and grey-violet palette, solid geometric volumes, slightly tilted perspective, calm weighty stillness',
  ),
  RestyleStyle(
    id: 'vangogh-arles',
    label: 'Van Gogh (Arles)',
    group: kRestyleGroupPainters,
    block:
        'portrait painting by Vincent van Gogh in Arles, thick impasto brushstrokes, vivid complementary colours, yellow and blue, green shadows on the face, flat patterned background, directional hatched strokes following the form, visible paint ridges',
  ),
  RestyleStyle(
    id: 'vangogh-saintremy',
    label: 'Van Gogh (Saint-Remy)',
    group: kRestyleGroupPainters,
    block:
        'late painting by Vincent van Gogh in Saint-Rémy, swirling turbulent brushstrokes, spiralling sky and cypress, rhythmic curling lines around the figure, deep blue and glowing yellow, restless energy, thick oil',
  ),
  RestyleStyle(
    id: 'gauguin',
    label: 'Gauguin (Tahiti)',
    group: kRestyleGroupPainters,
    block:
        'Tahitian painting by Paul Gauguin, flat cloisonné colour areas with dark outlines, saturated warm ochre pink and violet, tropical foliage, calm monumental figure, matte chalky surface, symbolist stillness',
  ),
  RestyleStyle(
    id: 'lautrec-cabaret',
    label: 'Toulouse-Lautrec (cabaret)',
    group: kRestyleGroupPainters,
    block:
        'cabaret painting by Henri de Toulouse-Lautrec, thinned oil on raw cardboard, streaky diagonal strokes, sickly green gaslight on the face, red lips and orange hair, Montmartre bar interior, unfinished sketchy edges, brown cardboard showing through',
  ),
  RestyleStyle(
    id: 'lautrec-poster',
    label: 'Toulouse-Lautrec (poster)',
    group: kRestyleGroupPainters,
    block:
        'lithograph poster by Henri de Toulouse-Lautrec, flat bold colour areas, sinuous black silhouette contours, Moulin Rouge dancer, spattered crachis texture, cropped Japanese composition, bold hand-lettered title, ochre red and black',
  ),
  RestyleStyle(
    id: 'beardsley',
    label: 'Beardsley (ink drawing)',
    group: kRestyleGroupPainters,
    block:
        'pen and ink illustration by Aubrey Beardsley, stark black and white, large flat black areas against blank white, single sinuous ink line, peacock and rose ornament, decadent elegant figure, japanese asymmetry',
  ),
  RestyleStyle(
    id: 'munch',
    label: 'Munch',
    group: kRestyleGroupPainters,
    block:
        'expressionist painting by Edvard Munch, anxious figure, wavy undulating brushstrokes flowing through sky and ground, blood orange sky over dark blue fjord, hollow skull-like face, thinly scrubbed paint, existential dread',
  ),
  RestyleStyle(
    id: 'klimt-golden',
    label: 'Klimt (Golden Phase)',
    group: kRestyleGroupPainters,
    block:
        'golden period painting by Gustav Klimt, figure wrapped in a flat gold leaf robe of spirals and rectangles, realistic softly painted face and hands, mosaic ornament, byzantine gold background, embrace, jewel colours',
  ),
  RestyleStyle(
    id: 'picasso-blue',
    label: 'Picasso (Blue Period)',
    group: kRestyleGroupPainters,
    block:
        'blue period painting by Pablo Picasso, monochrome cold blue and blue-green palette, gaunt melancholic figure, elongated hands, hunched posture, flat sombre background, thin dry paint',
  ),
  RestyleStyle(
    id: 'picasso-rose',
    label: 'Picasso (Rose Period)',
    group: kRestyleGroupPainters,
    block:
        'rose period painting by Pablo Picasso, warm pink ochre and terracotta palette, harlequin diamond costume, circus saltimbanque figure, quiet dignity, flat dusty background, delicate thin paint',
  ),
  RestyleStyle(
    id: 'kandinsky-early',
    label: 'Kandinsky (early tempera)',
    group: kRestyleGroupPainters,
    block:
        'early tempera painting by Wassily Kandinsky before abstraction, fairy-tale folk scene, rider in old Russian costume, jewel-like dabs of colour on dark ground, glowing pointillist dots, medieval towers, night blue with gold and crimson',
  ),
  RestyleStyle(
    id: 'matisse-fauve',
    label: 'Matisse (Fauvism)',
    group: kRestyleGroupPainters,
    block:
        'fauvist painting by Henri Matisse, wild unmixed colour, green stripe down the face, red and turquoise flat planes, loose broad brushstrokes, decorative patterned interior, joyful bold simplicity',
  ),
  RestyleStyle(
    id: 'schiele',
    label: 'Schiele',
    group: kRestyleGroupPainters,
    block:
        'figure drawing by Egon Schiele, nervous jagged contour line, contorted angular pose, bony elongated hands, gouache and watercolour patches of orange red and sickly green on bare paper, empty white background, raw expressionist intensity',
  ),
  RestyleStyle(
    id: 'kubista',
    label: 'Kubista (cubo-expressionism)',
    group: kRestyleGroupPainters,
    block:
        'Czech cubo-expressionist painting by Bohumil Kubista, figure built from sharp crystalline facets, cold blue green and ochre planes, dramatic raking light and deep shadow, tense angular composition, intense staring face, dense heavy oil',
  ),
  RestyleStyle(
    id: 'mucha-slav-epic',
    label: 'Mucha (Slav Epic)',
    group: kRestyleGroupPainters,
    block:
        'monumental egg tempera painting by Alphonse Mucha from the Slav Epic, pale luminous blue and white tones, crowd of Slavic figures in linen folk dress, glowing symbolic figure hovering above, misty historical vision, soft muted fresco-like surface',
  ),
  RestyleStyle(
    id: 'chagall',
    label: 'Chagall',
    group: kRestyleGroupPainters,
    block:
        'dreamlike painting by Marc Chagall, floating lovers drifting over a village, upside-down cow and fiddler, glowing cobalt blue and crimson, soft translucent layers, folk fairy tale, weightless joy',
  ),
  RestyleStyle(
    id: 'josef-capek',
    label: 'Josef Capek (naive cubism)',
    group: kRestyleGroupPainters,
    block:
        'Czech painting by Josef Capek, blocky simplified figure like a wooden toy, rough thick outlines, chunky flat planes of brick red ochre and grey-blue, childlike naive geometry, coarse matte texture, tender humour',
  ),
  RestyleStyle(
    id: 'rivera',
    label: 'Diego Rivera (mural)',
    group: kRestyleGroupPainters,
    block:
        'mural fresco by Diego Rivera, monumental rounded figure with simplified solid volumes, Mexican worker or calla lily seller, earthy terracotta ochre and green, flat matte surface, social realism, crowded composition',
  ),
  RestyleStyle(
    id: 'lempicka',
    label: 'Lempicka (Art Deco)',
    group: kRestyleGroupPainters,
    block:
        'art deco portrait by Tamara de Lempicka, glossy metallic sculpted figure, streamlined drapery in silver green and scarlet, sharp geometric shading, skyscraper backdrop, cool glamorous stare, polished tubular volumes',
  ),
  RestyleStyle(
    id: 'magritte',
    label: 'Magritte',
    group: kRestyleGroupPainters,
    block:
        'surrealist painting by Rene Magritte, bowler hat and dark overcoat, face hidden behind a floating green apple, cloudy blue daytime sky, flat deadpan illustrative rendering, uncanny calm, clean smooth paint',
  ),
  RestyleStyle(
    id: 'hopper',
    label: 'Hopper',
    group: kRestyleGroupPainters,
    block:
        'painting by Edward Hopper, solitary figure in a quiet room or diner, hard raking morning sunlight, long geometric shadows, muted greens and ochres, large window, american realism, melancholy urban stillness',
  ),
  RestyleStyle(
    id: 'dali',
    label: 'Dali (surrealism)',
    group: kRestyleGroupPainters,
    block:
        'surrealist painting by Salvador Dali, figure in a vast empty desert plain under a clear sky, melting soft forms propped on crutches, long shadows, ants and drawers, hyper-smooth academic rendering, uncanny dream logic',
  ),
  RestyleStyle(
    id: 'kahlo',
    label: 'Frida Kahlo',
    group: kRestyleGroupPainters,
    block:
        'self-portrait painting by Frida Kahlo, frontal gaze, joined eyebrows, flowers braided into hair, embroidered Tehuana dress, lush tropical leaves and a small monkey, flat naive Mexican folk retablo style, saturated colours',
  ),
  RestyleStyle(
    id: 'picasso-cubist',
    label: 'Picasso (Cubist portrait)',
    group: kRestyleGroupPainters,
    block:
        'cubist portrait by Pablo Picasso, face shown in profile and frontal view at once, both eyes on one side, fractured angular planes, thick black outlines, bold flat red yellow green and purple, patterned wallpaper',
  ),
  RestyleStyle(
    id: 'lada',
    label: 'Josef Lada',
    group: kRestyleGroupPainters,
    block:
        'Czech folk illustration by Josef Lada, round-faced jolly figure with rosy cheeks, thick black outlines, flat cheerful colours, snowy village with pointed roofs, naive childlike proportions, gentle humour, gouache',
  ),
  RestyleStyle(
    id: 'matisse-cutout',
    label: 'Matisse (cut-outs)',
    group: kRestyleGroupPainters,
    block:
        'paper cut-out by Henri Matisse, figure as a single flat cobalt blue silhouette cut from gouache-painted paper, simplified curving limbs, white background, scissors-cut edges, leaf and star shapes, jazz-like playfulness',
  ),
  RestyleStyle(
    id: 'bacon',
    label: 'Francis Bacon',
    group: kRestyleGroupPainters,
    block:
        'painting by Francis Bacon, smeared distorted figure with blurred twisting face, seated inside a thin drawn cage of lines, flat orange or violet ground, raw fleshy pinks, isolated on a bare stage, visceral unease',
  ),
  RestyleStyle(
    id: 'warhol',
    label: 'Warhol (silkscreen)',
    group: kRestyleGroupPainters,
    block:
        'pop art silkscreen portrait by Andy Warhol, high-contrast photo reduced to flat blocks, misregistered neon colour fills, hot pink turquoise and yellow, repeated grid of the same face, halftone grain, flat glossy celebrity icon',
  ),
  RestyleStyle(
    id: 'lichtenstein',
    label: 'Lichtenstein (comic dots)',
    group: kRestyleGroupPainters,
    block:
        'pop art painting by Roy Lichtenstein, enlarged comic strip panel, Ben-Day dot shading, thick black outlines, primary red yellow and blue, dramatic close-up face, speech bubble with bold text, flat printed look',
  ),
  RestyleStyle(
    id: 'hockney-pool',
    label: 'Hockney (pool)',
    group: kRestyleGroupPainters,
    block:
        '1960s Los Angeles acrylic painting by David Hockney, flat clean colour fields, turquoise swimming pool with stylised ripples, modernist house and palm trees, crisp shadows, bright even sunlight, deadpan cool stillness',
  ),
  RestyleStyle(
    id: 'basquiat',
    label: 'Basquiat',
    group: kRestyleGroupPainters,
    block:
        'neo-expressionist painting by Jean-Michel Basquiat, raw scrawled figure with skull-like head, three-pointed crown, exposed anatomy lines, graffiti text fragments and crossed-out words, oil stick and acrylic on rough canvas, chaotic bright colours',
  ),
  RestyleStyle(
    id: 'haring',
    label: 'Keith Haring',
    group: kRestyleGroupPainters,
    block:
        'painting by Keith Haring, figure as a thick black outline pictogram, radiant motion lines around the body, flat bright red yellow and blue, dancing pose, dense playful pattern, subway chalk graffiti energy',
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
    // Mucha's poster, not a generic description: on Juggernaut the old block
    // was a pale wallpaper (reaction 0.458), this one a halo poster (0.934).
    block:
        'art nouveau lithograph poster by Alphonse Mucha, woman framed by a circular halo motif, flowing decorative hair, ornamental mosaic border, pale pastel tones with gold, elegant whiplash lines, stylised flowers, flat poster colours',
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
  // ── Lab wave 7 (Ol1nLLM tools/lab, restyle bench out/lab7-sdxl) ─────────
  RestyleStyle(
    id: 'durer-engraving',
    label: 'Durer (engraving)',
    group: kRestyleGroupArtists,
    block:
        'copper engraving by Albrecht Dürer, black ink on cream paper, dense cross-hatching, swelling burin lines, sharp contour, fine parallel modelling, northern renaissance precision, crisp printed plate surface',
  ),
  RestyleStyle(
    id: 'bosch',
    label: 'Bosch',
    group: kRestyleGroupArtists,
    block:
        'oil panel painting by Hieronymus Bosch, high panoramic viewpoint, swarming tiny figures across the surface, pale pink and sea-green palette, thin translucent paint, fantastical hybrid forms, crackled oak panel',
  ),
  RestyleStyle(
    id: 'bruegel',
    label: 'Bruegel',
    group: kRestyleGroupArtists,
    block:
        'oil panel painting by Pieter Bruegel the Elder, elevated distant viewpoint, small stocky figures, muted earthy browns with cold grey-green, flat clear daylight, deep receding landscape, thin dry paint on oak panel',
  ),
  RestyleStyle(
    id: 'van-eyck',
    label: 'Van Eyck',
    group: kRestyleGroupArtists,
    block:
        'early netherlandish oil painting by Jan van Eyck, luminous transparent glazes, microscopic detail, jewel-like crimson and deep green, crisp textile folds, cool even light, enamel-smooth panel surface',
  ),
  RestyleStyle(
    id: 'titian',
    label: 'Titian',
    group: kRestyleGroupArtists,
    block:
        'venetian oil painting by Titian, warm glowing colour, deep reds and golden flesh tones, loose broken late brushwork, soft dissolving contours, layered glazes, rough visible canvas weave',
  ),
  RestyleStyle(
    id: 'caravaggio',
    label: 'Caravaggio',
    group: kRestyleGroupArtists,
    block:
        'tenebrist oil painting by Caravaggio, single hard raking light from upper left, figures emerging from pure black, ordinary unidealised models, sharp shadow edge, earthy red and ochre, dark smooth canvas',
  ),
  RestyleStyle(
    id: 'velazquez',
    label: 'Velazquez',
    group: kRestyleGroupArtists,
    block:
        'court portrait painting by Diego Velázquez, silvery grey palette, restrained blacks and rose, loose shorthand brushstrokes that resolve at a distance, airy neutral background, thin fluid oil paint on canvas',
  ),
  RestyleStyle(
    id: 'rubens',
    label: 'Rubens',
    group: kRestyleGroupArtists,
    block:
        'flemish baroque oil painting by Peter Paul Rubens, rosy luminous flesh with pearly blue half-tones, swirling diagonal composition, full fleshy forms, warm reds, fluid sweeping brushwork, thin glowing paint',
  ),
  RestyleStyle(
    id: 'fragonard',
    label: 'Fragonard',
    group: kRestyleGroupArtists,
    block:
        'rococo oil painting by Jean-Honoré Fragonard, feathery playful brushwork, pastel pink, peach and sea-green, frothy foliage light, soft powdery atmosphere, swift flickering touches on canvas',
  ),
  RestyleStyle(
    id: 'david-neoclassical',
    label: 'Jacques-Louis David',
    group: kRestyleGroupArtists,
    block:
        'neoclassical oil painting by Jacques-Louis David, invisible smooth brushwork, sculptural marble-like bodies, frieze-like shallow stage, hard clear outlines, stern red and white accents, plain dark background, polished canvas',
  ),
  RestyleStyle(
    id: 'ingres',
    label: 'Ingres',
    group: kRestyleGroupArtists,
    block:
        'neoclassical oil portrait by Jean-Auguste-Dominique Ingres, porcelain smooth skin, elongated sinuous contours, pure unbroken line, cool pale tones, crisp silk surfaces, enamel-like invisible brushwork',
  ),
  RestyleStyle(
    id: 'friedrich',
    label: 'Caspar David Friedrich',
    group: kRestyleGroupArtists,
    block:
        'german romantic oil painting by Caspar David Friedrich, vast hazy depth, cold grey-blue and violet dusk tones, silhouetted forms against pale sky, still symmetrical composition, thin smooth paint',
  ),
  RestyleStyle(
    id: 'turner',
    label: 'Turner',
    group: kRestyleGroupArtists,
    block:
        'late oil painting by J. M. W. Turner, forms dissolved into blazing light, swirling vortex of yellow and white, scumbled translucent veils, barely any contour, rough scraped impasto surface',
  ),
  RestyleStyle(
    id: 'blake',
    label: 'William Blake',
    group: kRestyleGroupArtists,
    block:
        'colour-printed relief etching by William Blake, elongated muscular figures, flamelike rhythmic outlines, mottled pigment, hand-tinted watercolour washes in ochre and blue, reticulated printed paper surface',
  ),
  RestyleStyle(
    id: 'hokusai',
    label: 'Hokusai (manga sketches)',
    group: kRestyleGroupArtists,
    block:
        'woodblock sketchbook page by Katsushika Hokusai, nimble calligraphic brush line, black outline with pale grey and soft pink tone, comic candid gesture, sparse empty ground, warm washi paper',
  ),
  RestyleStyle(
    id: 'hiroshige',
    label: 'Hiroshige',
    group: kRestyleGroupArtists,
    block:
        'ukiyo-e woodblock landscape print by Utagawa Hiroshige, bokashi gradient from deep indigo into pale sky, flat colour shapes, thin dark outline, slanting fine line rhythm, soft washi paper grain',
  ),
  RestyleStyle(
    id: 'yoshitoshi',
    label: 'Yoshitoshi',
    group: kRestyleGroupArtists,
    block:
        'meiji woodblock print by Tsukioka Yoshitoshi, dramatic twisting pose, nervous elegant line, restrained muted palette with sudden red accent, sparse gradient ground, fine woodgrain printed on paper',
  ),
  RestyleStyle(
    id: 'kuniyoshi',
    label: 'Kuniyoshi',
    group: kRestyleGroupArtists,
    block:
        'ukiyo-e warrior print by Utagawa Kuniyoshi, explosive packed composition filling the sheet, bold swirling black line, dense interlocking patterns, saturated red and indigo, heavy muscular action, woodblock ink texture',
  ),
  RestyleStyle(
    id: 'manet',
    label: 'Manet',
    group: kRestyleGroupArtists,
    block:
        'oil painting by Édouard Manet, flat frontal light, black used as a full colour, abrupt shift between light and dark, pale simplified flesh, broad summary brushwork, creamy paint on canvas',
  ),
  RestyleStyle(
    id: 'renoir',
    label: 'Renoir',
    group: kRestyleGroupArtists,
    block:
        'impressionist oil painting by Pierre-Auguste Renoir, dappled sunlight patches, soft feathery brushstrokes, warm rosy flesh, shimmering blue shadows, blurred contours, creamy vibrating paint surface',
  ),
  RestyleStyle(
    id: 'cassatt',
    label: 'Mary Cassatt',
    group: kRestyleGroupArtists,
    block:
        'pastel by Mary Cassatt, asymmetric japanese-print cropping, high tilted viewpoint, soft hatched chalk strokes, tender pink and pale green, flat patterned areas, velvety toned paper surface',
  ),
  RestyleStyle(
    id: 'whistler',
    label: 'Whistler (nocturne)',
    group: kRestyleGroupArtists,
    block:
        'nocturne by James McNeill Whistler, tonal harmony of blue and silver, thin liquid paint washed across canvas, vague dissolved shapes in fog, near monochrome, sparse flecks of gold, smooth veiled surface',
  ),
  RestyleStyle(
    id: 'sargent',
    label: 'Sargent',
    group: kRestyleGroupArtists,
    block:
        'portrait painting by John Singer Sargent, long bravura wet brushstrokes, glinting white satin highlights, dark tonal background, elegant loose edges, confident impasto accents on smooth canvas',
  ),
  RestyleStyle(
    id: 'sorolla',
    label: 'Sorolla',
    group: kRestyleGroupArtists,
    block:
        'oil painting by Joaquín Sorolla, blazing mediterranean sunlight, luminous whites with violet shadows, broad fluid wet strokes, sparkling reflections, intense warm-cool contrast, thick loose paint',
  ),
  RestyleStyle(
    id: 'zorn',
    label: 'Zorn',
    group: kRestyleGroupArtists,
    block:
        'oil painting by Anders Zorn, limited palette of ochre, vermilion, ivory black and white, ruddy warm flesh, broad decisive slashing strokes, shimmering rippling light, creamy impasto on canvas',
  ),
  RestyleStyle(
    id: 'repin',
    label: 'Repin',
    group: kRestyleGroupArtists,
    block:
        'russian realist oil painting by Ilya Repin, psychological character study, weathered faces, sombre browns and grey daylight, solid vigorous brushwork, open-air naturalism, thick earthy canvas surface',
  ),
  RestyleStyle(
    id: 'bilibin',
    label: 'Bilibin (Russian fairy tales)',
    group: kRestyleGroupArtists,
    block:
        'russian fairytale illustration by Ivan Bilibin, thick black contour lines, flat watercolour fills, decorative ornamental border, folk embroidery patterns, muted ochre and teal, printed book page surface',
  ),
  RestyleStyle(
    id: 'vrubel',
    label: 'Vrubel',
    group: kRestyleGroupArtists,
    block:
        'symbolist oil painting by Mikhail Vrubel, crystalline faceted brush planes, mosaic of shattered strokes, deep violet and dusky blue with gleaming pearl, heavy palette-knife impasto',
  ),
  RestyleStyle(
    id: 'kirchner',
    label: 'Kirchner',
    group: kRestyleGroupArtists,
    block:
        'german expressionist oil painting by Ernst Ludwig Kirchner, sharp jagged angles, acid pink and poison green, elongated masklike faces, slashing hatched brushstrokes, raw unblended paint',
  ),
  RestyleStyle(
    id: 'marc',
    label: 'Franz Marc',
    group: kRestyleGroupArtists,
    block:
        'expressionist painting by Franz Marc, prismatic intersecting colour planes, saturated cobalt blue, crimson and yellow, curved rhythmic contours, crystalline fractured space, flat bright oil paint',
  ),
  RestyleStyle(
    id: 'klee',
    label: 'Paul Klee',
    group: kRestyleGroupArtists,
    block:
        'painting by Paul Klee, grid of soft glowing colour squares, childlike thin wandering line, hieroglyphic signs, muted warm watercolour washes, dry chalky textured ground',
  ),
  RestyleStyle(
    id: 'leger',
    label: 'Leger',
    group: kRestyleGroupArtists,
    block:
        'painting by Fernand Léger, tubular machine-like figures, thick black outline, flat red, yellow and blue, stark white ground, offset colour bands, smooth poster-flat paint',
  ),
  RestyleStyle(
    id: 'de-chirico',
    label: 'De Chirico',
    group: kRestyleGroupArtists,
    block:
        'metaphysical painting by Giorgio de Chirico, deep empty perspective, long raking shadows, arcades, featureless mannequin forms, dark green-blue sky, hot ochre ground, flat dry paint',
  ),
  RestyleStyle(
    id: 'miro',
    label: 'Miro',
    group: kRestyleGroupArtists,
    block:
        'painting by Joan Miró, floating biomorphic shapes, thin black wire lines, spots of pure red, blue and yellow, scattered star signs, open washed ground, childlike flatness',
  ),
  RestyleStyle(
    id: 'rousseau',
    label: 'Henri Rousseau (jungle)',
    group: kRestyleGroupArtists,
    block:
        'naive oil painting by Henri Rousseau, oversized flat layered leaves, dozens of graded greens, stiff frontal figures, crisp hard-edged shapes, dense airless space, smooth enamel paint',
  ),
  RestyleStyle(
    id: 'ensor',
    label: 'Ensor (masks)',
    group: kRestyleGroupArtists,
    block:
        'expressionist painting by James Ensor, grotesque masklike faces, acid reds, greens and whites, crowded shallow space, scratchy nervous line, crusted raw impasto',
  ),
  RestyleStyle(
    id: 'hammershoi',
    label: 'Hammershoi',
    group: kRestyleGroupArtists,
    block:
        'oil painting by Vilhelm Hammershøi, near monochrome pearl greys, soft cool window light, empty stillness, reduced geometric composition, blurred quiet edges, muted thin dry brushwork',
  ),
  RestyleStyle(
    id: 'larsson',
    label: 'Carl Larsson',
    group: kRestyleGroupArtists,
    block:
        'watercolour illustration by Carl Larsson, firm flowing ink outline, clear light washes, swedish red and pale green, airy white ground, flat decorative patterning, fresh sunlit paper',
  ),
  RestyleStyle(
    id: 'wyspianski',
    label: 'Wyspianski',
    group: kRestyleGroupArtists,
    block:
        'polish art nouveau pastel by Stanisław Wyspiański, sensitive sweeping contour, bare toned paper left unworked, soft blue and ochre chalk strokes, decorative outline, delicate dry powdery texture',
  ),
  RestyleStyle(
    id: 'malczewski',
    label: 'Malczewski',
    group: kRestyleGroupArtists,
    block:
        'polish symbolist oil painting by Jacek Malczewski, hard sharp academic drawing, dry bright daylight, grassy ochre and cold blue, flat theatrical staging, enigmatic stillness, thin precise paint',
  ),
  RestyleStyle(
    id: 'beksinski',
    label: 'Beksinski',
    group: kRestyleGroupArtists,
    block:
        'dystopian oil painting by Zdzisław Beksiński, rust brown and bone ochre haze, crumbling eroded forms, skeletal decay, dry luminous dust, meticulous fine brushwork on hardboard',
  ),
  RestyleStyle(
    id: 'wyeth',
    label: 'Andrew Wyeth',
    group: kRestyleGroupArtists,
    block:
        'egg tempera painting by Andrew Wyeth, thousands of fine dry hatched strokes, faded straw and umber, cold pale light, sparse austere composition, chalky matte panel surface',
  ),
  RestyleStyle(
    id: 'grant-wood',
    label: 'Grant Wood',
    group: kRestyleGroupArtists,
    block:
        'american regionalist oil painting by Grant Wood, smooth rounded sculpted forms, hard precise detail, flemish-style polish, soft green and ochre, decorative patterned stippling, enamel-smooth panel surface',
  ),
  RestyleStyle(
    id: 'jacob-lawrence',
    label: 'Jacob Lawrence',
    group: kRestyleGroupArtists,
    block:
        'painting by Jacob Lawrence, casein tempera on hardboard, flat matte colour shapes, angular faceted figures, saturated red, yellow and blue with black, rhythmic repeated forms',
  ),
  RestyleStyle(
    id: 'bearden',
    label: 'Romare Bearden (collage)',
    group: kRestyleGroupArtists,
    block:
        'photomontage collage by Romare Bearden, cut magazine photographs and coloured paper, fragmented mismatched faces, abrupt scale shifts, flat torn shapes, visible glue seams',
  ),
  RestyleStyle(
    id: 'kehinde-wiley',
    label: 'Kehinde Wiley',
    group: kRestyleGroupArtists,
    block:
        'portrait painting by Kehinde Wiley, photorealistic frontal figure, saturated ornamental baroque floral wallpaper behind, tendrils growing over the body, glossy oil, crisp high-contrast skin',
  ),
  RestyleStyle(
    id: 'kusama',
    label: 'Yayoi Kusama',
    group: kRestyleGroupArtists,
    block:
        'painting by Yayoi Kusama, obsessive polka dots covering every surface, repeating infinity net loops, stark yellow and black, hypnotic all-over pattern, flat glossy acrylic',
  ),
  RestyleStyle(
    id: 'murakami',
    label: 'Takashi Murakami (superflat)',
    group: kRestyleGroupArtists,
    block:
        'superflat painting by Takashi Murakami, seamless flat colour, repeating grinning flower pattern, candy rainbow palette, thick clean outline, glossy lacquered surface',
  ),
  RestyleStyle(
    id: 'moebius',
    label: 'Moebius',
    group: kRestyleGroupArtists,
    block:
        'french comic art by Moebius, fine even pen line, delicate stippling and hatching, soft pastel flat colour, spacious clean composition, airy luminous light, smooth printed paper',
  ),
  RestyleStyle(
    id: 'frazetta',
    label: 'Frazetta',
    group: kRestyleGroupArtists,
    block:
        'fantasy oil painting by Frank Frazetta, explosive muscular anatomy, dynamic twisting action, warm umber darkness, glowing flesh against black, loose rapid brushwork, rough canvas',
  ),
  RestyleStyle(
    id: 'giger',
    label: 'Giger (biomechanical)',
    group: kRestyleGroupArtists,
    block:
        'biomechanical airbrush painting by H. R. Giger, monochrome grey ink, fused organic and machine forms, ribbed tubular surfaces, smooth sprayed gradients, stencilled edges',
  ),
  RestyleStyle(
    id: 'rackham',
    label: 'Arthur Rackham',
    group: kRestyleGroupArtists,
    block:
        'edwardian book illustration by Arthur Rackham, sinuous sepia pen line, muted transparent watercolour washes, gnarled knotty contours, dusty brown and grey-green, aged paper',
  ),
  RestyleStyle(
    id: 'dore',
    label: 'Gustave Dore',
    group: kRestyleGroupArtists,
    block:
        'wood engraving after Gustave Doré, dense parallel hatching, dramatic theatrical light against deep black, sweeping vast depth, black ink on white book paper',
  ),
  RestyleStyle(
    id: 'sorayama',
    label: 'Sorayama (chrome)',
    group: kRestyleGroupArtists,
    block:
        'airbrush illustration by Hajime Sorayama, liquid mirror chrome surfaces, razor sharp specular reflections, smooth sprayed gradients, soft studio glow, flawless polished finish',
  ),
  RestyleStyle(
    id: 'burian',
    label: 'Zdenek Burian',
    group: kRestyleGroupArtists,
    block:
        'illustration by Zdeněk Burian, warm naturalistic realism, broad confident brushwork, rich amber and earth tones, soft atmospheric depth, matte painted book plate surface',
  ),
  RestyleStyle(
    id: 'born',
    label: 'Adolf Born',
    group: kRestyleGroupArtists,
    block:
        'czech caricature illustration by Adolf Born, tall elongated figures, long noses, scratchy nervous pen line, soft pastel watercolour washes, witty flat staging, grainy paper',
  ),
  RestyleStyle(
    id: 'trnka',
    label: 'Jiri Trnka',
    group: kRestyleGroupArtists,
    block:
        'czech fairytale illustration by Jiří Trnka, soft rounded puppet-like figures, tender simple faces, muted warm tempera, gentle folk colour, dreamy blurred background, matte textured paper',
  ),
  RestyleStyle(
    id: 'ales',
    label: 'Mikolas Ales',
    group: kRestyleGroupArtists,
    block:
        'czech pen drawing by Mikoláš Aleš, hard firm contour, lunette-like decorative composition, simple sparse hatching, flat folk ornament, restrained ochre tint, sgraffito-like cream surface',
  ),
  RestyleStyle(
    id: 'toyen',
    label: 'Toyen',
    group: kRestyleGroupArtists,
    block:
        'czech surrealist painting by Toyen, smoky diffused grey and sand tones, sprayed veiled forms, ghostly dissolving outlines, empty open space, smooth matte canvas surface',
  ),
  RestyleStyle(
    id: 'kupka-early',
    label: 'Kupka (early)',
    group: kRestyleGroupArtists,
    block:
        'symbolist painting by František Kupka, figure modelled in vertical planes of colour, spectral rainbow shifts, thin rhythmic drawn contour, glowing violet and orange, smooth dreamlike paint',
  ),
  RestyleStyle(
    id: 'preisler',
    label: 'Jan Preisler',
    group: kRestyleGroupArtists,
    block:
        'czech art nouveau symbolist oil painting by Jan Preisler, muted blue-green and dusky turquoise, soft decorative contours, flattened dreamy space, melancholy stillness, thin matte brushwork',
  ),
  RestyleStyle(
    id: 'prerafael',
    label: 'Pre-Raphaelite',
    group: kRestyleGroupEurope,
    block:
        'pre-raphaelite oil painting, bright jewel glazes over wet white ground, crisp botanical detail in every flower of the meadow, medieval gowns, copper red flowing hair, viridian and madder',
  ),
  RestyleStyle(
    id: 'inuit-printmaking',
    label: 'Inuit stonecut (Kinngait)',
    group: kRestyleGroupAmericasOceania,
    block:
        'inuit stonecut and stencil print on white washi paper, flat silhouette figures with no shading, feathered shapes radiating outward, two or three inks of black, red and blue, wide empty ground',
  ),
  RestyleStyle(
    id: 'cave-painting',
    label: 'Cave painting (Lascaux)',
    group: kRestyleGroupEurope,
    block:
        'paleolithic cave painting on rough limestone wall, charcoal contour and blown red and yellow ochre, profile animal silhouettes, twisted perspective horns, cracked rock surface',
  ),
  RestyleStyle(
    id: 'cycladic',
    label: 'Cycladic figurine',
    group: kRestyleGroupEurope,
    block:
        'cycladic marble idol, polished white stone body, folded arms across the abdomen, lyre-shaped head with only a ridge nose, flat geometric planes, plain grey background',
  ),
  RestyleStyle(
    id: 'greek-vase-black',
    label: 'Greek vase (black-figure)',
    group: kRestyleGroupEurope,
    block:
        'attic black-figure pottery, glossy black silhouette figures on orange terracotta, fine incised lines, added white and purple details, meander border band',
  ),
  RestyleStyle(
    id: 'greek-vase-red',
    label: 'Greek vase (red-figure)',
    group: kRestyleGroupEurope,
    block:
        'attic red-figure pottery, orange terracotta figures reserved on lustrous black glaze, thin relief lines for anatomy and drapery folds, palmette and meander border',
  ),
  RestyleStyle(
    id: 'etruscan-tomb',
    label: 'Etruscan tomb fresco',
    group: kRestyleGroupEurope,
    block:
        'etruscan tomb wall fresco on pale plaster, profile dancers with almond eyes and long pointed hands, red-brown male and cream female skin, black contours, striped wave and laurel bands',
  ),
  RestyleStyle(
    id: 'roman-mosaic',
    label: 'Roman mosaic',
    group: kRestyleGroupEurope,
    block:
        'roman floor mosaic of small stone tesserae, visible grout lines, figure built from cut cubes, terracotta, ochre, black and white stones, guilloche braid border',
  ),
  RestyleStyle(
    id: 'scythian-gold',
    label: 'Scythian gold',
    group: kRestyleGroupEurope,
    block:
        'scythian gold plaque, hammered repousse relief, animal style with coiled panther and stag folded legs, curling antlers into scrolls, solid gold on black, granulated edges',
  ),
  RestyleStyle(
    id: 'moche',
    label: 'Moche pottery',
    group: kRestyleGroupAmericasOceania,
    block:
        'moche fineline pottery, cream slip with red-brown painted figures, thin calligraphic line, profile warriors and runners, stirrup spout vessel curve, dotted background fillers',
  ),
  RestyleStyle(
    id: 'nazca',
    label: 'Nazca polychrome',
    group: kRestyleGroupAmericasOceania,
    block:
        'nazca polychrome slip pottery, flat burnished colors in black outline, stylized hummingbirds and spotted cats, cream, terracotta, grey and violet-black, rounded bowl band',
  ),
  RestyleStyle(
    id: 'kells',
    label: 'Book of Kells',
    group: kRestyleGroupEurope,
    block:
        'insular gospel manuscript on vellum, interlace knotwork and triskele spirals, staring figure with stacked ribbon hair, orpiment yellow, verdigris, red lead and lichen purple, red dots',
  ),
  RestyleStyle(
    id: 'bayeux',
    label: 'Bayeux Tapestry',
    group: kRestyleGroupEurope,
    block:
        'bayeux embroidery, wool stem stitch on bare linen strip, flat profile figures, terracotta, mustard and blue-green thread, horizontal frieze with narrow animal borders, stitched latin captions',
  ),
  RestyleStyle(
    id: 'romanesque-fresco',
    label: 'Romanesque fresco',
    group: kRestyleGroupEurope,
    block:
        'romanesque catalan apse fresco, hard black contours, staring frontal figure in almond mandorla, parallel fold lines, ultramarine, ochre and vermilion horizontal bands',
  ),
  RestyleStyle(
    id: 'gothic-altarpiece',
    label: 'Gothic altarpiece',
    group: kRestyleGroupEurope,
    block:
        'gothic altarpiece panel, egg tempera on wood, tooled and punched gilt ground with halo patterns, soft rounded figures, carved tracery pinnacles, vermilion and azurite drapery',
  ),
  RestyleStyle(
    id: 'danse-macabre',
    label: 'Danse macabre',
    group: kRestyleGroupEurope,
    block:
        'late gothic woodcut, heavy black cut lines, parallel hatching, dancing skeletons leading the living by the hand, plain hand-colored ochre and red washes, gothic banner',
  ),
  RestyleStyle(
    id: 'urnes-viking',
    label: 'Urnes (Viking)',
    group: kRestyleGroupEurope,
    block:
        'urnes style viking wood carving, weathered dark oak relief, slender ribbon beast in looping figure-eight interlace, thin and thick lines contrast, tar-black ground',
  ),
  RestyleStyle(
    id: 'pskov-icon',
    label: 'Pskov icon',
    group: kRestyleGroupEurope,
    block:
        'russian pskov icon, egg tempera on linden panel, cinnabar red ground, dark olive shadows with sharp white highlight strokes, faceted angular drapery, square-shouldered figure',
  ),
  RestyleStyle(
    id: 'armenian-manuscript',
    label: 'Armenian manuscript',
    group: kRestyleGroupAfricaNearEast,
    block:
        'cilician armenian gospel manuscript on vellum, lapis blue fields, tall canon tables, slender figures, vine and peacock marginalia, bird-shaped initial letters, carmine and gold',
  ),
  RestyleStyle(
    id: 'flemish-still-life',
    label: 'Flemish still life (vanitas)',
    group: kRestyleGroupEurope,
    block:
        'dutch and flemish vanitas oil painting, near-black ground, tight glazes, reflections on a glass roemer, peeled lemon, tarnished silver, snuffed candle, single raking window light',
  ),
  RestyleStyle(
    id: 'rococo',
    label: 'Rococo',
    group: kRestyleGroupEurope,
    block:
        'rococo oil painting, feathery brushwork, powder pink, pale blue and pistachio, gilded rocaille shell scrolls framing the scene, floating putti, silk ruffles, swing garden',
  ),
  RestyleStyle(
    id: 'neoclassicism',
    label: 'Neoclassicism',
    group: kRestyleGroupEurope,
    block:
        'neoclassical oil painting, invisible polished brushwork, marble-smooth sculpted figure, white chiton, doric columns, shallow frieze-like stage, cool grey wall, clear even light',
  ),
  RestyleStyle(
    id: 'romanticism-storm',
    label: 'Romantic storm',
    group: kRestyleGroupEurope,
    block:
        'romantic oil painting, thick impasto sky, wrecked ship and towering waves, sulphur yellow and bruised indigo clouds, tiny figure against the sea, sweeping diagonal spray',
  ),
  RestyleStyle(
    id: 'hudson-river',
    label: 'Hudson River School',
    group: kRestyleGroupAmericasOceania,
    block:
        'hudson river school oil landscape, wide valley vista, tiny figure at the foreground crag, gnarled oak frame, golden hazy sunset light, glassy river, crisp distant ridges',
  ),
  RestyleStyle(
    id: 'orientalism',
    label: 'Orientalism (19th century)',
    group: kRestyleGroupEurope,
    block:
        'nineteenth century academic oil painting, cool blue iznik tile walls, carved mashrabiya screen light, brass lamp, silk carpet, polished detailed brushwork, warm amber interior',
  ),
  RestyleStyle(
    id: 'arts-and-crafts',
    label: 'Arts and Crafts (Morris)',
    group: kRestyleGroupEurope,
    block:
        'arts and crafts woodblock wallpaper, flat dense interlaced acanthus and willow leaves, no empty ground, indigo, madder and weld yellow, stylized thrush among strawberries, thick even outline',
  ),
  RestyleStyle(
    id: 'victorian-fairy',
    label: 'Victorian fairy painting',
    group: kRestyleGroupEurope,
    block:
        'victorian fairy painting, minute oil detail, tiny winged folk among oversized foxgloves and mushrooms, moonlit dark green undergrowth, iridescent wings, sharp grass blades',
  ),
  RestyleStyle(
    id: 'symbolism',
    label: 'Symbolism',
    group: kRestyleGroupEurope,
    block:
        'symbolist oil painting, jewel-dark ground incised with thin gold arabesque lines, pale androgynous figure, half-closed eyes, sphinx throne, lapis and garnet glazes',
  ),
  RestyleStyle(
    id: 'nabis',
    label: 'Nabis',
    group: kRestyleGroupEurope,
    block:
        'nabi interior painting on cardboard, flat matte patches of oil, patterned wallpaper merging with patterned dress, mustard, plum and dull rose, dark contours, tilted floor',
  ),
  RestyleStyle(
    id: 'expressionism-painting',
    label: 'Expressionism',
    group: kRestyleGroupEurope,
    block:
        'german expressionist oil painting, slashing visible strokes, thick black contours, unnatural cobalt and vermilion skin, acid yellow background, angular mask-like face',
  ),
  RestyleStyle(
    id: 'dada-collage',
    label: 'Dada collage',
    group: kRestyleGroupEurope,
    block:
        'dada photomontage, cut black and white newspaper photographs, mismatched scale, torn paper edges, gluey magazine lettering, gears and fragments of faces, red accent shapes',
  ),
  RestyleStyle(
    id: 'de-stijl',
    label: 'De Stijl',
    group: kRestyleGroupEurope,
    block:
        'de stijl neoplastic composition, thick black orthogonal grid, flat red, blue and yellow rectangles on white, no curves, no shading, figure reduced to rectangular planes',
  ),
  RestyleStyle(
    id: 'bauhaus-poster',
    label: 'Bauhaus poster',
    group: kRestyleGroupEurope,
    block:
        'bauhaus lithograph poster, circle, square and triangle construction, red, black and cream, diagonal sans-serif bars, figure built from ruled geometry, flat ink',
  ),
  RestyleStyle(
    id: 'precisionism',
    label: 'Precisionism',
    group: kRestyleGroupAmericasOceania,
    block:
        'american precisionist oil painting, razor-clean factory edges, smokestacks and steel ducts, flattened planes, smooth unbrushed surface, pale steel blue, rust red and cream',
  ),
  RestyleStyle(
    id: 'socialist-realism',
    label: 'Socialist realism',
    group: kRestyleGroupEurope,
    block:
        'socialist realist oil painting, broad academic brushwork, low heroic viewpoint, worker in overalls, wheat field and red banners, sunlit vermilion and cobalt, upward gaze',
  ),
  RestyleStyle(
    id: 'polish-poster',
    label: 'Polish poster school',
    group: kRestyleGroupEurope,
    block:
        'polish poster school gouache, rough dry-brush shapes, single surreal visual metaphor, hand-scrawled lettering, ragged paper grain, muted background with one acid accent',
  ),
  RestyleStyle(
    id: 'psychedelic-poster',
    label: 'Psychedelic poster',
    group: kRestyleGroupAmericasOceania,
    block:
        '1960s psychedelic concert poster, swelling melting letterforms, flowing hair turning into lines, vibrating complementary orange and electric blue, magenta and lime, screenprinted flat ink',
  ),
  RestyleStyle(
    id: 'memphis-80s',
    label: 'Memphis (80s)',
    group: kRestyleGroupEurope,
    block:
        '1980s memphis design, flat pastel mint and pink fields, black squiggle bacterio laminate, black dots, zigzag bands, terrazzo chips, primitive geometric blocks, hard shadows',
  ),
  RestyleStyle(
    id: 'pin-up-50s',
    label: 'Pin-up (50s)',
    group: kRestyleGroupAmericasOceania,
    block:
        '1950s american pin-up calendar illustration, smooth glossy gouache and oil skin modeling, soft airbrush gradient background, candy red and cream, playful surprised pose, fine rim light',
  ),
  RestyleStyle(
    id: 'nihonga',
    label: 'Nihonga',
    group: kRestyleGroupAsia,
    block:
        'nihonga painting on silk, granular crushed mineral pigments, soft outlineless modeling, pale flattened face, oyster white gofun, malachite and azurite, thin silver leaf mist',
  ),
  RestyleStyle(
    id: 'yamato-e',
    label: 'Yamato-e scroll',
    group: kRestyleGroupAsia,
    block:
        'yamato-e picture scroll, blown-off roof view from above, diagonal tatami and beams, band mist clouds of gold, tiny line-eye hook-nose court faces, heaped layered robes',
  ),
  RestyleStyle(
    id: 'enso-zen',
    label: 'Enso (Zen)',
    group: kRestyleGroupAsia,
    block:
        'zen ink painting on raw white paper, a single black enso circle of one dry brushstroke, vast empty space, splintering bristle marks, one small red seal',
  ),
  RestyleStyle(
    id: 'kano-screen',
    label: 'Kano folding screen',
    group: kRestyleGroupAsia,
    block:
        'kano school folding screen, blazing gold cloud ground, massive gnarled pine trunk in angular black ink strokes, muscular brush outline, malachite needles, panel seams',
  ),
  RestyleStyle(
    id: 'nianhua',
    label: 'Nianhua (New Year print)',
    group: kRestyleGroupAsia,
    block:
        'chinese new year woodblock print, black key lines, hand-stenciled magenta, emerald and yellow, plump peony and carp, gold lucky symbols, symmetrical door panel layout',
  ),
  RestyleStyle(
    id: 'peking-opera-mask',
    label: 'Peking opera mask',
    group: kRestyleGroupAsia,
    block:
        'peking opera lianpu painted face, symmetrical bold makeup in red, black and white, sweeping brow and cheek shapes, pheasant feather headdress, embroidered silk collar',
  ),
  RestyleStyle(
    id: 'tang-sancai',
    label: 'Tang sancai',
    group: kRestyleGroupAsia,
    block:
        'tang dynasty sancai glazed earthenware figurine, amber, cream and copper green lead glazes dripping over each other, molded robe folds, unglazed pale face, crackle sheen',
  ),
  RestyleStyle(
    id: 'madhubani',
    label: 'Madhubani',
    group: kRestyleGroupAsia,
    block:
        'madhubani painting on handmade paper, double black outlines hatched inside, every gap filled with fish and leaf patterns, flat turmeric yellow, indigo, vermilion and leaf green',
  ),
  RestyleStyle(
    id: 'warli',
    label: 'Warli',
    group: kRestyleGroupAsia,
    block:
        'warli painting, white rice paste on dark red-brown mud wall, stick figures made of two joined triangles, circular dance rows, simple dotted border',
  ),
  RestyleStyle(
    id: 'pattachitra',
    label: 'Pattachitra',
    group: kRestyleGroupAsia,
    block:
        'pattachitra painted on chalk-primed cloth, hard black outline, large elongated eyes, flat vermilion background, conch white, indigo and lamp black, lotus and floral border',
  ),
  RestyleStyle(
    id: 'benin-bronze',
    label: 'Benin bronze plaque',
    group: kRestyleGroupAfricaNearEast,
    block:
        'benin court brass plaque, lost-wax cast high relief, frontal figure with stacked coral bead collar, punched quatrefoil ground, dark green-brown patina, rosette corner studs',
  ),
  RestyleStyle(
    id: 'ndebele',
    label: 'Ndebele mural',
    group: kRestyleGroupAfricaNearEast,
    block:
        'ndebele house mural, thick black outlines on white limewash, stepped geometric architectural panels, saturated yellow, turquoise, magenta and green, razor-straight painted edges',
  ),
  RestyleStyle(
    id: 'kuba-cloth',
    label: 'Kuba cloth',
    group: kRestyleGroupAfricaNearEast,
    block:
        'kuba raffia cut-pile velvet cloth, tufted soft surface, interrupted diamond and zigzag grids, dark brown on natural straw, deliberate irregular pattern breaks',
  ),
  RestyleStyle(
    id: 'tingatinga',
    label: 'Tingatinga',
    group: kRestyleGroupAfricaNearEast,
    block:
        'tingatinga bicycle enamel paint on square board, glossy flat color, plain bright sky background, naive giraffes and birds with dotted skin, thick outline, turquoise and tangerine',
  ),
  RestyleStyle(
    id: 'san-rock-art',
    label: 'San rock art',
    group: kRestyleGroupAfricaNearEast,
    block:
        'san rock art on sandstone overhang, red ochre and white shaded eland, thin elongated running figures with bows, fine brush line, flaking stone surface',
  ),
  RestyleStyle(
    id: 'haida-formline',
    label: 'Haida formline',
    group: kRestyleGroupAmericasOceania,
    block:
        'haida formline painting, swelling black primary lines, ovoid eyes and u-forms, red secondary lines, unpainted cream cedar ground, split symmetrical crest figure',
  ),
  RestyleStyle(
    id: 'navajo-sand',
    label: 'Navajo sandpainting',
    group: kRestyleGroupAmericasOceania,
    block:
        'navajo sandpainting, fine colored sand on tan ground, tall rectangular yei figures in symmetrical rows, white, black, blue, yellow and red, encircling rainbow guardian',
  ),
  RestyleStyle(
    id: 'kamasan-bali',
    label: 'Kamasan (Bali)',
    group: kRestyleGroupAsia,
    block:
        'kamasan balinese painting on primed cotton cloth, wayang profile figures with curling hands, fine black line, ochre, indigo and brick red, cloud swirl and flame fillers',
  ),
  RestyleStyle(
    id: 'oil-impasto',
    label: 'Oil (impasto)',
    group: kRestyleGroupMediaPaint,
    block:
        'impasto oil painting on canvas, thick ridges of paint, palette knife marks, heavy raised strokes, glossy wet oil sheen',
  ),
  RestyleStyle(
    id: 'oil-glazing',
    label: 'Oil (old-master glazes)',
    group: kRestyleGroupMediaPaint,
    block:
        'oil glazing on dark imprimatura panel, smooth invisible brushwork, translucent layered glazes, sfumato soft edges, fine craquelure varnish surface',
  ),
  RestyleStyle(
    id: 'oil-alla-prima',
    label: 'Oil (alla prima)',
    group: kRestyleGroupMediaPaint,
    block:
        'alla prima oil painting on canvas, broad wet-on-wet strokes, colors blending on the surface, unfinished loose edges, bare canvas showing through',
  ),
  RestyleStyle(
    id: 'palette-knife',
    label: 'Palette knife',
    group: kRestyleGroupMediaPaint,
    block:
        'palette knife painting on canvas, flat scraped slabs of oil paint, no brush marks, broken planes with sharp ridged edges, thick buttery surface',
  ),
  RestyleStyle(
    id: 'acrylic-flat',
    label: 'Acrylic (flat)',
    group: kRestyleGroupMediaPaint,
    block:
        'flat acrylic painting on board, even opaque brushwork, saturated colors with crisp hard edges, matte smooth surface without texture',
  ),
  RestyleStyle(
    id: 'acrylic-pour',
    label: 'Acrylic pour',
    group: kRestyleGroupMediaPaint,
    block:
        'acrylic pour on canvas, poured fluid paint without brush, marbled swirls and cell patterns, metallic pigment veins, glossy resin-like surface',
  ),
  RestyleStyle(
    id: 'watercolor-wet',
    label: 'Watercolor (wet-on-wet)',
    group: kRestyleGroupMediaPaint,
    block:
        'wet-on-wet watercolor on cold-press paper, soft loaded brush washes, bleeding edges and pigment blooms, white of the paper preserved, granulating pigment',
  ),
  RestyleStyle(
    id: 'watercolor-dry',
    label: 'Watercolor (dry brush)',
    group: kRestyleGroupMediaPaint,
    block:
        'dry-brush watercolor on rough paper, scratchy broken strokes, grainy skipped pigment with layered washed shadows, tooth of the paper visible',
  ),
  RestyleStyle(
    id: 'watercolor-ink-line',
    label: 'Watercolor and ink line',
    group: kRestyleGroupMediaPaint,
    block:
        'watercolor and ink line on sketchbook paper, thin loose pen line, light transparent wash overrunning the outlines, white paper left open',
  ),
  RestyleStyle(
    id: 'gouache',
    label: 'Gouache',
    group: kRestyleGroupMediaPaint,
    block:
        'gouache painting on illustration board, flat opaque brushwork, matte even color with clean poster-like shapes, slightly chalky surface',
  ),
  RestyleStyle(
    id: 'egg-tempera',
    label: 'Egg tempera',
    group: kRestyleGroupMediaPaint,
    block:
        'egg tempera on gessoed wooden panel, fine hatched strokes from a small brush, thin opaque layers, matte dry luminous surface',
  ),
  RestyleStyle(
    id: 'casein',
    label: 'Casein',
    group: kRestyleGroupMediaPaint,
    block:
        'casein painting on board, quick direct brush strokes, soft pastel-toned opaque color, velvety matte surface',
  ),
  RestyleStyle(
    id: 'encaustic',
    label: 'Encaustic wax',
    group: kRestyleGroupMediaPaint,
    block:
        'encaustic painting on wooden panel, molten pigmented wax, scratched incised lines, depth of fused translucent layers, milky waxy sheen',
  ),
  RestyleStyle(
    id: 'fresco-buon',
    label: 'Fresco',
    group: kRestyleGroupMediaPaint,
    block:
        'buon fresco on wet lime plaster, broad brushwork, matte chalky mineral pigments, visible giornata seams, cracked and flaking plaster surface',
  ),
  RestyleStyle(
    id: 'airbrush',
    label: 'Airbrush',
    group: kRestyleGroupMediaPaint,
    block:
        'airbrush illustration on smooth board, no visible strokes, seamless gradients and fine spray falloff, polished chrome-like highlights, 1980s finish',
  ),
  RestyleStyle(
    id: 'spray-stencil',
    label: 'Spray stencil',
    group: kRestyleGroupMediaPaint,
    block:
        'spray paint through stencil on concrete wall, hard cut edges, fine overspray halo, paint drips, rough surface showing through',
  ),
  RestyleStyle(
    id: 'finger-paint',
    label: 'Finger paint',
    group: kRestyleGroupMediaPaint,
    block:
        'finger painting on paper, visible fingerprints and smeared daubs, no brush marks, saturated childlike poster paint, thick uneven smudges',
  ),
  RestyleStyle(
    id: 'miniature-gouache',
    label: 'Ivory miniature',
    group: kRestyleGroupMediaPaint,
    block:
        'portrait miniature in watercolor on ivory, tiny stippled brush dots, smooth delicate color, glossy ivory support, oval format',
  ),
  RestyleStyle(
    id: 'graphite',
    label: 'Pencil',
    group: kRestyleGroupMediaPaint,
    block:
        'graphite pencil drawing on white paper, tonal hatching, smudged soft shadows, silver-grey sheen, fine paper grain',
  ),
  RestyleStyle(
    id: 'graphite-hard',
    label: 'Technical pencil',
    group: kRestyleGroupMediaPaint,
    block:
        'hard pencil technical drawing on white paper, thin even line, visible construction lines, no shading, clean precise edges',
  ),
  RestyleStyle(
    id: 'charcoal',
    label: 'Charcoal',
    group: kRestyleGroupMediaPaint,
    block:
        'charcoal drawing on textured paper, velvety black strokes, smudged tonal masses, kneaded eraser highlights, loose charcoal dust',
  ),
  RestyleStyle(
    id: 'conte',
    label: 'Conte on toned paper',
    group: kRestyleGroupMediaPaint,
    block:
        'conte crayon drawing on grey toned paper, black and white chalk strokes, red-brown accents, hatched modelling, paper tone as midtone',
  ),
  RestyleStyle(
    id: 'silverpoint',
    label: 'Silverpoint',
    group: kRestyleGroupMediaPaint,
    block:
        'silverpoint drawing on warm prepared ground, fine pale silver-grey line, delicate parallel hatching, no erasure or corrections, tarnished subtle surface',
  ),
  RestyleStyle(
    id: 'ballpoint',
    label: 'Ballpoint pen',
    group: kRestyleGroupMediaPaint,
    block:
        'ballpoint pen drawing on paper, blue ink, dense cross-hatching, built-up tone from fine strokes, glossy ink sheen in darks',
  ),
  RestyleStyle(
    id: 'fineliner',
    label: 'Fineliner',
    group: kRestyleGroupMediaPaint,
    block:
        'fineliner pen drawing on white paper, thin uniform black lines, stippled dots for tone, no washes, crisp clean edges',
  ),
  RestyleStyle(
    id: 'nib-ink',
    label: 'Dip pen and ink',
    group: kRestyleGroupMediaPaint,
    block:
        'dip nib pen and india ink on paper, swelling variable line width, dense hatching, ink splatters, hard wet black edges',
  ),
  RestyleStyle(
    id: 'brush-ink',
    label: 'Brush and ink',
    group: kRestyleGroupMediaPaint,
    block:
        'brush and black ink on paper, expressive tapered strokes, dry-brush streaks, solid spotted blacks, comic inking edges',
  ),
  RestyleStyle(
    id: 'marker',
    label: 'Alcohol markers',
    group: kRestyleGroupMediaPaint,
    block:
        'alcohol marker drawing on smooth paper, flat layered tones, visible overlapping stroke bands, streaky saturated color, white gel pen highlights',
  ),
  RestyleStyle(
    id: 'crayon',
    label: 'Wax crayon',
    group: kRestyleGroupMediaPaint,
    block:
        'wax crayon drawing on paper, rough grainy strokes, uneven childlike scribbled fill, paper showing through, waxy sheen',
  ),
  RestyleStyle(
    id: 'soft-pastel',
    label: 'Soft pastel',
    group: kRestyleGroupMediaPaint,
    block:
        'soft pastel drawing on toned sanded paper, powdery strokes, finger-blended transitions, velvety chalky color, loose pigment dust',
  ),
  RestyleStyle(
    id: 'oil-pastel',
    label: 'Oil pastel',
    group: kRestyleGroupMediaPaint,
    block:
        'oil pastel drawing on paper, thick greasy strokes, sgraffito scratched lines, saturated smeared color, waxy glossy surface',
  ),
  RestyleStyle(
    id: 'chalkboard',
    label: 'Chalkboard',
    group: kRestyleGroupMediaPaint,
    block:
        'chalk drawing on blackboard, white and pastel chalk strokes, dusty soft edges, smudged eraser haze, matte black surface',
  ),
  RestyleStyle(
    id: 'scratchboard',
    label: 'Scratchboard',
    group: kRestyleGroupMediaPaint,
    block:
        'scratchboard engraving on black clay board, fine white scratched lines, dense directional hatching, stark black ground, engraved sharp surface',
  ),
  RestyleStyle(
    id: 'calligraphy-chinese',
    label: 'Chinese calligraphy (kaishu)',
    group: kRestyleGroupMediaPrint,
    block:
        'chinese regular script calligraphy on xuan paper, angular brush strokes in black ink, vertical columns, red seal stamp, absorbent paper grain',
  ),
  RestyleStyle(
    id: 'calligraphy-cursive',
    label: 'Chinese wild cursive',
    group: kRestyleGroupMediaPrint,
    block:
        'chinese wild cursive calligraphy on paper, continuous sweeping brush strokes, flying dry-brush streaks, ink spatter, rhythmic linked marks',
  ),
  RestyleStyle(
    id: 'calligraphy-arabic',
    label: 'Arabic calligraphy (thuluth)',
    group: kRestyleGroupMediaPrint,
    block:
        'arabic thuluth calligraphy on burnished paper, elongated strokes from an angled reed pen, gold illuminated ornament, deep blue ink',
  ),
  RestyleStyle(
    id: 'blackletter',
    label: 'Blackletter',
    group: kRestyleGroupMediaPrint,
    block:
        'blackletter textura calligraphy on parchment, broken angular broad-nib strokes, dense black rhythm, red initial capital, slightly rough vellum surface',
  ),
  RestyleStyle(
    id: 'copperplate',
    label: 'Copperplate script',
    group: kRestyleGroupMediaPrint,
    block:
        'copperplate script on cream paper, pointed nib, hairline upstrokes and swelling downstrokes, looping flourishes, crisp iron-gall ink',
  ),
  RestyleStyle(
    id: 'brush-lettering',
    label: 'Brush lettering',
    group: kRestyleGroupMediaPrint,
    block:
        'brush lettering on paper, flexible brush pen, thick downstrokes and thin upstrokes, watercolor gradient inside strokes, dry streaked ends',
  ),
  RestyleStyle(
    id: 'hangul-calligraphy',
    label: 'Korean calligraphy',
    group: kRestyleGroupMediaPrint,
    block:
        'korean hangul calligraphy on hanji paper, round circular brush strokes, black ink, soft feathered edges, fibrous mulberry paper surface',
  ),
  RestyleStyle(
    id: 'graffiti-wildstyle',
    label: 'Graffiti wildstyle',
    group: kRestyleGroupMediaPrint,
    block:
        'graffiti wildstyle on concrete wall, spray can lines, interlocking lettering with arrows, 3d block shadow, bold outline and fade fills',
  ),
  RestyleStyle(
    id: 'linocut',
    label: 'Linocut',
    group: kRestyleGroupMediaPrint,
    block:
        'linocut print on paper, thick white gouged grooves, solid black ink areas, chattered carving marks, slightly uneven pressed ink',
  ),
  RestyleStyle(
    id: 'etching',
    label: 'Etching',
    group: kRestyleGroupMediaPrint,
    block:
        'etching print on cotton paper, fine parallel bitten lines, tone from line density, plate mark border, warm black ink',
  ),
  RestyleStyle(
    id: 'drypoint',
    label: 'Drypoint',
    group: kRestyleGroupMediaPrint,
    block:
        'drypoint print on paper, needle-scratched lines, velvety soft burr, rich fuzzy blacks, plate tone haze',
  ),
  RestyleStyle(
    id: 'lithograph',
    label: 'Lithograph',
    group: kRestyleGroupMediaPrint,
    block:
        'lithograph print on paper, greasy crayon strokes, grain of limestone, soft tonal areas, slightly mottled ink surface',
  ),
  RestyleStyle(
    id: 'letterpress',
    label: 'Letterpress',
    group: kRestyleGroupMediaPrint,
    block:
        'letterpress print on thick cotton paper, debossed impression, single ink color, slightly uneven ink density, soft fibrous surface',
  ),
  RestyleStyle(
    id: 'monotype',
    label: 'Monotype',
    group: kRestyleGroupMediaPrint,
    block:
        'monotype print on paper, single pressing from inked plate, wiped smeared areas, faint ghost image, soft mottled ink texture',
  ),
  RestyleStyle(
    id: 'cyanotype',
    label: 'Cyanotype',
    group: kRestyleGroupMediaPrint,
    block:
        'cyanotype print on watercolor paper, prussian blue tone, white silhouetted shapes, brushed uneven emulsion edges, soft paper grain',
  ),
  RestyleStyle(
    id: 'gyotaku',
    label: 'Gyotaku (fish print)',
    group: kRestyleGroupMediaPrint,
    block:
        'gyotaku ink rubbing on rice paper, pressed direct impression, scale-like imprinted texture, unprinted blank eye, soft black ink and fibrous paper',
  ),
  RestyleStyle(
    id: 'block-print-textile',
    label: 'Block-printed textile',
    group: kRestyleGroupMediaPrint,
    block:
        'hand block print on cotton cloth, repeated carved stamp pattern, uneven pressure and ink density, indigo dye, visible woven fabric',
  ),
  RestyleStyle(
    id: 'halftone-newsprint',
    label: 'Newsprint halftone',
    group: kRestyleGroupMediaPrint,
    block:
        'halftone newspaper print on yellowed newsprint, coarse CMYK dots, slight misregistration, ink show-through, cheap fibrous paper',
  ),
  RestyleStyle(
    id: 'engraving-banknote',
    label: 'Banknote engraving',
    group: kRestyleGroupMediaPrint,
    block:
        'banknote intaglio engraving on security paper, guilloche rosette lines, fine cross-hatching, single-color ink, raised crisp linework',
  ),
  RestyleStyle(
    id: 'embroidery',
    label: 'Embroidery',
    group: kRestyleGroupMediaTextile,
    block:
        'hand embroidery on linen, dense satin stitches, visible thread sheen, directional stitching following forms, woven cloth showing',
  ),
  RestyleStyle(
    id: 'cross-stitch',
    label: 'Cross-stitch',
    group: kRestyleGroupMediaTextile,
    block:
        'cross-stitch on aida cloth, tiny x-shaped stitches on a square grid, stepped pixel-like edges, cotton floss, visible cloth holes',
  ),
  RestyleStyle(
    id: 'tapestry-weave',
    label: 'Woven tapestry',
    group: kRestyleGroupMediaTextile,
    block:
        'woven tapestry on loom, visible weft ribs, matte wool colors, stepped jagged shape edges, coarse textile surface',
  ),
  RestyleStyle(
    id: 'quilt',
    label: 'Patchwork quilt',
    group: kRestyleGroupMediaTextile,
    block:
        'patchwork quilt, stitched pieces of printed fabric, visible quilting lines, seams between cloth patches, soft padded surface',
  ),
  RestyleStyle(
    id: 'batik',
    label: 'Batik',
    group: kRestyleGroupMediaTextile,
    block:
        'batik on cotton cloth, hot wax resist lines, crackled dye veins, indigo and brown dye, softly bleeding edges',
  ),
  RestyleStyle(
    id: 'tie-dye',
    label: 'Tie-dye',
    group: kRestyleGroupMediaTextile,
    block:
        'tie-dye on cotton fabric, bound and dyed folds, spiral radiating rings, bleeding rainbow dye edges, soft cloth surface',
  ),
  RestyleStyle(
    id: 'felt',
    label: 'Needle felt',
    group: kRestyleGroupMediaTextile,
    block:
        'needle felted wool, soft fuzzy fibers, rounded puffy shapes, matte heathered wool color, tiny needle dimples',
  ),
  RestyleStyle(
    id: 'knitted',
    label: 'Knitted',
    group: kRestyleGroupMediaTextile,
    block:
        'hand knitted wool, rows of stitch loops, cable knit pattern, chunky yarn, soft fuzzy textile surface',
  ),
  RestyleStyle(
    id: 'lace',
    label: 'Lace',
    group: kRestyleGroupMediaTextile,
    block:
        'bobbin lace, fine white openwork threads, delicate looped mesh, pierced negative shapes, on dark background',
  ),
  RestyleStyle(
    id: 'beadwork-loom',
    label: 'Loom beadwork',
    group: kRestyleGroupMediaTextile,
    block:
        'loom beadwork, shiny glass seed beads in a tight grid, stepped pixel-like edges, reflective rounded surface, visible thread rows',
  ),
  RestyleStyle(
    id: 'cardboard',
    label: 'Cardboard',
    group: kRestyleGroupMediaTextile,
    block:
        'corrugated cardboard craft, cut ragged edges exposing flutes, brown kraft surface, layered sheets, packing tape joints',
  ),
  RestyleStyle(
    id: 'origami',
    label: 'Origami',
    group: kRestyleGroupMediaTextile,
    block:
        'origami folded paper, crisp creases, sharp geometric facets, single sheet of matte washi',
  ),
  RestyleStyle(
    id: 'quilling',
    label: 'Quilling',
    group: kRestyleGroupMediaTextile,
    block:
        'paper quilling, rolled coils of thin paper strips, standing on edge, spiral filled shapes, crisp shadowed relief',
  ),
  RestyleStyle(
    id: 'pop-up-book',
    label: 'Pop-up book',
    group: kRestyleGroupMediaTextile,
    block:
        'pop-up book, cut paper flats standing in layered depth, visible fold tabs and creases, printed illustrated card surface',
  ),
  RestyleStyle(
    id: 'paper-sculpture-layered',
    label: 'Layered paper cut',
    group: kRestyleGroupMediaTextile,
    block:
        'layered cut paper light box, stacked silhouette sheets in depth, glowing backlight between layers, soft shadow gradients',
  ),
  RestyleStyle(
    id: 'kirigami',
    label: 'Kirigami',
    group: kRestyleGroupMediaTextile,
    block:
        'kirigami, cut and folded white paper, crisp slit edges, raised geometric planes, soft cast shadows',
  ),
  RestyleStyle(
    id: 'sticker-collage',
    label: 'Sticker collage',
    group: kRestyleGroupMediaTextile,
    block:
        'sticker collage, glossy die-cut stickers, thick white border around each shape, overlapping layers, slight peeling edges',
  ),
  RestyleStyle(
    id: 'marble',
    label: 'Marble statue',
    group: kRestyleGroupMediaSculpture,
    block:
        'carved white marble sculpture, faint chisel marks in rough areas, smooth polished transitions, soft stone translucency',
  ),
  RestyleStyle(
    id: 'bronze',
    label: 'Bronze',
    group: kRestyleGroupMediaSculpture,
    block:
        'cast bronze sculpture, modelled tool marks, green-brown patina in recesses, polished highlights on raised edges, dark metal surface',
  ),
  RestyleStyle(
    id: 'terracotta',
    label: 'Terracotta',
    group: kRestyleGroupMediaSculpture,
    block:
        'fired terracotta sculpture, hand-modelled clay marks, brick-red matte body, fine surface cracks',
  ),
  RestyleStyle(
    id: 'wood-carving',
    label: 'Wood carving',
    group: kRestyleGroupMediaSculpture,
    block:
        'hand wood carving, visible gouge marks, faceted cuts, wood grain rings, warm oiled timber surface',
  ),
  RestyleStyle(
    id: 'soapstone',
    label: 'Soapstone',
    group: kRestyleGroupMediaSculpture,
    block:
        'carved soapstone sculpture, rounded smooth simplified forms, faint file marks, grey-green waxy stone surface',
  ),
  RestyleStyle(
    id: 'ice-sculpture',
    label: 'Ice sculpture',
    group: kRestyleGroupMediaSculpture,
    block:
        'carved ice sculpture, chainsaw and chisel cuts, clear refracting ice, trapped bubbles, cool blue wet surface',
  ),
  RestyleStyle(
    id: 'sand-sculpture',
    label: 'Sand relief',
    group: kRestyleGroupMediaSculpture,
    block:
        'sand sculpture relief, packed ochre grains, sharp carved edges, crumbling granular surface',
  ),
  RestyleStyle(
    id: 'claymation',
    label: 'Claymation',
    group: kRestyleGroupMediaSculpture,
    block:
        'plasticine claymation, stop-motion puppet look, thumbprints in clay, matte saturated color, slightly lumpy hand-shaped surface',
  ),
  RestyleStyle(
    id: 'porcelain-figurine',
    label: 'Porcelain figurine',
    group: kRestyleGroupMediaSculpture,
    block:
        'glazed porcelain figurine, hand-painted pastel enamel colors, gilded trim, smooth glassy glaze highlights',
  ),
  RestyleStyle(
    id: 'blue-white-porcelain',
    label: 'Blue and white porcelain',
    group: kRestyleGroupMediaSculpture,
    block:
        'blue and white porcelain, hand-painted cobalt underglaze, white body, soft pooled brushwork, fine crackle glaze',
  ),
  RestyleStyle(
    id: 'ceramic-raku',
    label: 'Raku ceramic',
    group: kRestyleGroupMediaSculpture,
    block:
        'raku ceramic, crackled white glaze, smoke-blackened carbon lines, iridescent metallic copper flashes, rough fired surface',
  ),
  RestyleStyle(
    id: 'mosaic-tesserae',
    label: 'Mosaic',
    group: kRestyleGroupMediaSculpture,
    block:
        'mosaic of stone and glass tesserae, small hand-cut cubes, dark grout lines, gold tesserae glints, uneven reflective surface',
  ),
  RestyleStyle(
    id: 'cloisonne',
    label: 'Cloisonne enamel',
    group: kRestyleGroupMediaSculpture,
    block:
        'cloisonne enamel, thin gold wire partitions, saturated vitreous color fields, polished glassy surface',
  ),
  RestyleStyle(
    id: 'glass-blown',
    label: 'Blown glass',
    group: kRestyleGroupMediaSculpture,
    block:
        'blown glass, molten-formed transparent body, colored swirling veins, trapped bubbles, sharp specular reflections',
  ),
  RestyleStyle(
    id: 'wax-figure',
    label: 'Wax figure',
    group: kRestyleGroupMediaSculpture,
    block:
        'wax museum figure, translucent waxy skin surface, soft subsurface glow, inserted glass eyes, hand-painted tint',
  ),
  RestyleStyle(
    id: 'wire-sculpture',
    label: 'Wire sculpture',
    group: kRestyleGroupMediaSculpture,
    block:
        'bent wire sculpture, single thin metal line drawing in space, twisted joints, open contour, crisp cast shadow',
  ),
  RestyleStyle(
    id: 'repousse-metal',
    label: 'Repousse metal',
    group: kRestyleGroupMediaSculpture,
    block:
        'repousse metalwork, forms hammered up from thin sheet, small chasing punch marks, burnished gold and copper sheen',
  ),
  RestyleStyle(
    id: 'daguerreotype',
    label: 'Daguerreotype',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'daguerreotype on mirrored silver plate, long exposure softness, silvery tonal sheen, tarnished edges, oval mat',
  ),
  RestyleStyle(
    id: 'tintype',
    label: 'Tintype',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'tintype wet collodion on dark metal plate, shallow plate focus, chemical streaks and blotches, dull grey-brown tones',
  ),
  RestyleStyle(
    id: 'polaroid',
    label: 'Polaroid',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'instant film photograph, white print border, faded washed-out color, soft on-camera flash, slight emulsion blur',
  ),
  RestyleStyle(
    id: 'lomography',
    label: 'Lomography',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'lomography cross-processed film photograph, heavy vignette, shifted saturated color, blown highlights, light leaks',
  ),
  RestyleStyle(
    id: 'pinhole',
    label: 'Pinhole camera',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'pinhole camera photograph, soft edgeless focus, long exposure blur, strong corner vignette, muted film grain',
  ),
  RestyleStyle(
    id: 'infrared-film',
    label: 'Infrared film',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'infrared film photograph, near-white glowing greens, blackened blues, soft halation around highlights, coarse grain',
  ),
  RestyleStyle(
    id: 'double-exposure',
    label: 'Double exposure',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'double exposure photograph, two translucent overlapping images, second image filling a dark silhouette, soft film blending',
  ),
  RestyleStyle(
    id: 'photogram',
    label: 'Photogram',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'photogram on silver gelatin paper, cameraless contact print, white shadow silhouettes on black, soft graded edges',
  ),
  RestyleStyle(
    id: 'xray',
    label: 'X-ray',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'x-ray radiograph on film, blue-black negative, translucent layered densities, glowing internal structure, soft edges',
  ),
  RestyleStyle(
    id: 'thermal',
    label: 'Thermal camera',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'thermal camera image, false color rainbow heat scale, blurred low-resolution blobs, glowing hot areas on cold blue-purple',
  ),
  RestyleStyle(
    id: 'low-poly',
    label: 'Low poly',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'low poly 3d render, flat triangular facets, hard faceted shading, visible polygon edges',
  ),
  RestyleStyle(
    id: 'vector-flat',
    label: 'Flat vector',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'flat vector illustration, clean geometric shapes, solid color fills, no gradients, no outlines',
  ),
  RestyleStyle(
    id: 'cel-shaded',
    label: 'Cel shading',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'cel shaded render, two-step hard shadows, flat paint fills, thick clean black outline',
  ),
  RestyleStyle(
    id: 'ascii-art',
    label: 'ASCII art',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'ascii art, monospaced text characters as tone, rows of glyphs, green phosphor on black terminal screen',
  ),
  RestyleStyle(
    id: 'blueprint',
    label: 'Blueprint',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'blueprint on cyanotype paper, thin white technical lines, dimension marks, fine grid, deep blue ground',
  ),
  RestyleStyle(
    id: 'neon-sign',
    label: 'Neon sign',
    group: kRestyleGroupMediaPhotoDigital,
    block:
        'neon sign, bent glowing glass tubes, single continuous line, colored halo reflecting on wet dark wall',
  ),
  RestyleStyle(
    id: 'pyrography',
    label: 'Pyrography',
    group: kRestyleGroupMediaSculpture,
    block:
        'pyrography on wood, burnt brown lines, hot-tip shaded gradients, scorched darks, visible wood grain',
  ),
  RestyleStyle(
    id: 'marquetry',
    label: 'Marquetry',
    group: kRestyleGroupMediaSculpture,
    block:
        'wood marquetry, inlaid veneer pieces of different timbers, knife-cut seams, smooth polished lacquer-like surface',
  ),
  RestyleStyle(
    id: 'stained-concrete',
    label: 'Concrete',
    group: kRestyleGroupMediaSculpture,
    block:
        'cast concrete, rough grey surface, board-formed imprint lines, air holes and stained seepage',
  ),
  RestyleStyle(
    id: 'rust-patina',
    label: 'Rust and patina',
    group: kRestyleGroupMediaSculpture,
    block:
        'rusted metal, flaking orange rust, blue-green verdigris patina, pitted corroded surface',
  ),
  RestyleStyle(
    id: 'gingerbread',
    label: 'Gingerbread',
    group: kRestyleGroupMediaSculpture,
    block:
        'baked gingerbread, brown spiced cookie surface, piped white royal icing lines, sugar decoration, crumbly edges',
  ),
  RestyleStyle(
    id: 'pressed-flowers',
    label: 'Pressed flowers',
    group: kRestyleGroupMediaTextile,
    block:
        'pressed flower art on paper, dried translucent petals, flattened glued shapes, faded natural colors, herbarium sheet',
  ),
  RestyleStyle(
    id: 'sand-painting',
    label: 'Sand painting',
    group: kRestyleGroupMediaSculpture,
    block:
        'colored sand painting, poured granular lines, visible mineral grains, flat geometric color fields, matte dry surface',
  ),
  RestyleStyle(
    id: 'tattoo-flash',
    label: 'Tattoo flash',
    group: kRestyleGroupMediaPrint,
    block:
        'old school tattoo flash on yellowed paper, thick black outline, limited red green yellow palette, whip shading dots, aged sheet',
  ),
];

RestyleStyle? restyleStyleById(String? id) {
  if (id == null) return null;
  for (final s in kRestyleStyles) {
    if (s.id == id) return s;
  }
  return null;
}

/// Search box filter: label or section name, case-insensitive.
bool restyleStyleMatchesQuery(RestyleStyle style, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return style.label.toLowerCase().contains(q) ||
      style.group.toLowerCase().contains(q);
}

/// Styles of one section, in catalog order.
List<RestyleStyle> restyleStylesIn(String group) =>
    kRestyleStyles.where((s) => s.group == group).toList(growable: false);

// Medium sentences. "a person" on purpose: the face comes from the identity
// adapter and the body from the depth map, so the prompt must not argue gender
// or framing with the photo. "fully clothed, wearing the clothes from the
// photo" is not decoration: a depth map carries a body's silhouette but not its
// clothes, and FLUX (no negative prompt at cfg 1) rendered the dancer
// reference nude on the unstyled baseline (bench restyle-a, 2026-09-13).
const _photoMedium =
    'a photorealistic photograph of a fully clothed person wearing the clothes '
    'from the photo, natural skin texture, realistic lighting, true-to-life detail';
const _illustrationMedium =
    'a painted illustration of a fully clothed person, artwork';

// Juggernaut's own negative (Ol1nLLM's preset), plus the other medium so the
// toggle actually bites: in photo mode a woodblock style should read as
// costume and set, not turn the photo into a print. SDXL only — FLUX ignores
// the negative, which is why the clothing lives in the positive above.
const _baseNegative =
    'nude, naked, nsfw, bad quality, worst quality, low quality, jpeg artifacts, blurry, '
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
