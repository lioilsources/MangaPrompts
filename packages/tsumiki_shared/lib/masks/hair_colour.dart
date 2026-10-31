// Colour word for the hair on a photo. Mirror of the colour half of
// `tgbot/hairmask.py`.

import 'dart:math' as math;

import 'package:image/image.dart' as img;

import 'bool_mask.dart';

/// Below this share of the image there is no hair to take a colour from.
const kHairMinForColour = 0.005;

/// sRGB byte values → CIELAB (D65), `hairmask._srgb_to_lab`.
List<double> srgbToLab(int r, int g, int b) {
  double lin(int c) {
    final v = c / 255.0;
    return v <= 0.04045
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  final rl = lin(r), gl = lin(g), bl = lin(b);
  final x = (0.4124564 * rl + 0.3575761 * gl + 0.1804375 * bl) / 0.95047;
  final y = 0.2126729 * rl + 0.7151522 * gl + 0.0721750 * bl;
  final z = (0.0193339 * rl + 0.1191920 * gl + 0.9503041 * bl) / 1.08883;
  const eps = 216 / 24389, kappa = 24389 / 27;
  double f(double t) =>
      t > eps ? math.pow(t, 1 / 3).toDouble() : (kappa * t + 16) / 116;
  final fx = f(x), fy = f(y), fz = f(z);
  return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
}

String hairColourName(double l, double a, double b) {
  final chroma = math.sqrt(a * a + b * b);
  if (l < 22 && chroma < 10) return 'black';
  if (chroma < 8 && l > 75) return 'white';
  if (chroma < 8 && l > 38) return 'grey';
  // Dyed colours sit outside natural hair's 30–90° hue: read as auburn, a
  // pink or purple head asked for a new cut came back auburn.
  if (chroma >= 15) {
    final hue = (math.atan2(b, a) * 180 / math.pi) % 360;
    if (hue >= 160 && hue < 245) return 'teal';
    if (hue >= 245 && hue < 295) return l < 22 ? 'blue-black' : 'blue';
    if (hue >= 295 && hue < 335) return 'purple';
    if ((hue >= 335 || hue < 25) && l >= 40 && a > 20) return 'pink';
  }
  if (a > 16) return 'auburn';
  if (l < 22) return 'dark brown';
  if (l < 33) return 'brown';
  if (l < 48) return 'light brown';
  if (l < 72) return 'blonde';
  return 'platinum blonde';
}

/// numpy.median.
double medianOf(List<double> v) {
  final s = [...v]..sort();
  final n = s.length;
  return n.isOdd ? s[n ~/ 2] : (s[n ~/ 2 - 1] + s[n ~/ 2]) / 2;
}

/// Colour word for the hair, read from the lit strands (50th–90th luminance
/// rank of the hair core), or null when there is too little hair.
String? estimateHairColour(img.Image rgb, BoolMask hair) {
  if (rgb.width != hair.w || rgb.height != hair.h) {
    throw ArgumentError('hair mask and image differ in size');
  }
  if (hair.mean < kHairMinForColour) return null;
  final core = hair.andNot(dilateMask(hair.inverted(), 3));
  final use = core.count >= 50 ? core : hair;
  final labs = <List<double>>[];
  for (var y = 0; y < hair.h; y++) {
    for (var x = 0; x < hair.w; x++) {
      if (!use.at(x, y)) continue;
      final p = rgb.getPixel(x, y);
      labs.add(srgbToLab(p.r.toInt(), p.g.toInt(), p.b.toInt()));
    }
  }
  // Stable sort by L, like numpy's argsort(kind="stable").
  final order = List<int>.generate(labs.length, (i) => i)
    ..sort((i, j) {
      final c = labs[i][0].compareTo(labs[j][0]);
      return c != 0 ? c : i.compareTo(j);
    });
  final start = (0.5 * order.length).toInt();
  final end = math.max((0.9 * order.length).toInt(), start + 1);
  final lit = [for (final i in order.sublist(start, end)) labs[i]];
  return hairColourName(
    medianOf([for (final v in lit) v[0]]),
    medianOf([for (final v in lit) v[1]]),
    medianOf([for (final v in lit) v[2]]),
  );
}
