// Composite mask for the glasses step: a band around the eyes.
//
// Dart mirror of `tgbot/glassesmask.py` (`06-PLAN-bryle.md` §2); the file
// fixtures pin both once that module is in the tree. Unlike the hair mask this
// one covers the face: a frame has to sit on it. The mouth is always out.

import 'dart:math' as math;

import '../catalogs/glasses.dart';
import 'bool_mask.dart';
import 'face_parse.dart';

const kGlassesDilateFh = 0.04;
const kGlassesSide = 0.10;
const kGlassesEarMaxFw = 0.25;
const kGlassesAbove = 0.06;
const kGlassesBelow = <GlassesSize, double>{
  GlassesSize.small: 0.12,
  GlassesSize.regular: 0.20,
  GlassesSize.oversized: 0.32,
};
const kGlassesCornerFw = 0.15;
const kGlassesMinEyesFh = 0.08;
const kGlassesMaxMaskArea = 0.35;
const kGlassesMinArea = 0.0005;

/// Box of eyes + brows + old glasses by the 1st/99th percentile.
(int, int, int, int)? eyeBox(BoolMask features, BoolMask glasses) =>
    maskSpan(features.or(glasses), minPixels: 20);

/// Left and right end of the band: the outer edge of each visible ear, else
/// [kGlassesSide] past the face.
(double, double) _sides(BoolMask ears, (int, int, int, int) box) {
  final (x0, _, x1, _) = box;
  final fw = x1 - x0 + 1;
  final lo = x0 - kGlassesEarMaxFw * fw, hi = x1 + kGlassesEarMaxFw * fw;
  final centre = (x0 + x1) / 2;
  final near = <int>[], far = <int>[];
  for (var y = 0; y < ears.h; y++) {
    for (var x = 0; x < ears.w; x++) {
      if (!ears.at(x, y) || x < lo || x > hi) continue;
      (x < centre ? near : far).add(x);
    }
  }
  near.sort();
  far.sort();
  return (
    near.length >= 10 ? percentileOfSorted(near, 1) : x0 - kGlassesSide * fw,
    far.length >= 10 ? percentileOfSorted(far, 99) : x1 + kGlassesSide * fw,
  );
}

/// The composite mask for [fit]; [remove] keeps only the old glasses. Throws
/// [HairMaskException] for a photo the step cannot use.
MaskResult buildGlassesMask(
  HairAnalysis a,
  GlassesFit fit, {
  bool remove = false,
}) {
  final fullW = a.face.w, fullH = a.face.h;
  final scale = math.min(1.0, kMaskWorkSide / math.max(fullH, fullW));
  final w = math.max(1, pyRound(fullW * scale));
  final h = math.max(1, pyRound(fullH * scale));
  BoolMask small(BoolMask m) => scale == 1.0 ? m : resizeMask(m, w, h);

  final face = small(a.face);
  final features = small(a.features);
  final glasses = small(a.glasses);
  final ears = small(a.ears);
  final mouth = small(a.mouth);

  final box = faceBox(face);
  if (box == null) throw HairMaskException.noFace;
  final (x0, y0, x1, y1) = box;
  final fw = x1 - x0 + 1, fh = y1 - y0 + 1;
  if (fh < 0.08 * h) throw HairMaskException.faceTooSmall;
  final eyes = eyeBox(features, glasses);
  if (eyes == null || eyes.$4 - eyes.$2 + 1 < kGlassesMinEyesFh * fh) {
    throw HairMaskException.eyesNotVisible;
  }

  final wearing = glasses.mean >= kGlassesMinArea;
  final base = wearing
      ? dilateMask(glasses, pyRound(kGlassesDilateFh * fh))
      : BoolMask(w, h);
  BoolMask mask;
  if (remove) {
    if (!wearing) throw HairMaskException.noGlassesToRemove;
    mask = base;
  } else {
    final (left, right) = _sides(ears, box);
    mask = base.or(
      roundedRect(
        h,
        w,
        left,
        eyes.$2 - kGlassesAbove * fh,
        right,
        eyes.$4 + kGlassesBelow[fit.size]! * fh,
        kGlassesCornerFw * fw,
      ),
    );
  }
  mask = mask.andNot(mouth);

  final area = mask.mean;
  if (area > kGlassesMaxMaskArea) throw HairMaskException.maskTooLarge;

  if (scale != 1.0) {
    mask = resizeMask(mask, fullW, fullH).andNot(a.mouth);
  }
  final inv = 1.0 / scale;
  return MaskResult(mask, (
    (x0 * inv).toInt(),
    (y0 * inv).toInt(),
    (x1 * inv).toInt(),
    (y1 * inv).toInt(),
  ), area);
}
