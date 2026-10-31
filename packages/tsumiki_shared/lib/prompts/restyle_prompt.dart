// Restyle prompt with the new look in it: medium → look → style. What is not in
// the prompt the restyle graphs throw away, so beard, glasses and hair travel
// here. Order and wording are bench axes (`param.lookPosition`).

import '../catalogs/beards.dart';
import '../catalogs/glasses.dart';
import '../catalogs/hairstyles.dart';
import '../catalogs/restyle_styles.dart';

/// What the edit steps changed. Each field is a finished English fragment.
class RestyleLook {
  const RestyleLook({this.beard, this.glasses, this.hair});

  /// From the catalog picks; null = that step was skipped.
  factory RestyleLook.of({
    Beard? beard,
    Glasses? glasses,
    String? finish,
    Hairstyle? hair,
    String? hairColour,
  }) => RestyleLook(
    beard: beard == null
        ? null
        : beard.id == kCleanShavenId
        ? 'clean-shaven'
        : 'with a ${beard.block}',
    glasses: glasses == null || glasses.id == kNoGlassesId
        ? null
        : 'wearing ${finish == null ? '' : '$finish '}${glasses.block}',
    hair: hair == null || hair.id == kKeepCutId
        ? (hairColour == null ? null : 'with $hairColour hair')
        : 'with a ${hair.block}${hairColour == null ? '' : ', $hairColour hair'}',
  );

  final String? beard;
  final String? glasses;
  final String? hair;

  List<String> get parts => [?beard, ?glasses, ?hair];
}

/// [restylePrompt] with [look] between the medium and the style.
String restyleLookPrompt(
  RestyleStyle style,
  RestyleMedium medium, {
  RestyleLook look = const RestyleLook(),
}) => [restyleMediumHead(medium), ...look.parts, style.block].join(', ');
