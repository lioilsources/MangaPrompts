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

/// Display order of the sections.
const kRestyleGroups = <String>[
  kRestyleGroupPopular,
  kRestyleGroupPainters,
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
