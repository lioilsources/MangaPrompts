// Composite mask for the beard step: the lower face.
//
// Dart mirror of `tgbot/beardmask.py` — same constants, same steps, same order;
// `tgbot/tests/fixtures/masks` pins both to IoU 1.0. The why of each constant
// is in the Python.

import 'dart:math' as math;

import 'package:image/image.dart' as img;

import '../catalogs/beards.dart';
import 'bool_mask.dart';
import 'face_parse.dart';
import 'hair_colour.dart';

const kBeardMoustacheInsetFw = 0.15;
const kBeardMoustacheOverLipFh = 0.03;
const kBeardChinOverLipFh = 0.05;
const kBeardJawSideFw = 0.06;
const kBeardFullSideFw = 0.08;
const kBeardCornerFw = 0.05;
const kBeardLipsGuardFh = 0.02;
const kBeardHairAllowanceFh = 0.06;
const kBeardEarMaxFw = 0.25;
const kBeardShaveBelowChin = 0.1;
const kBeardMinLipsPx = 20;
const kBeardMinSkinPx = 200;
const kBeardDarkerL = 12.0;
const kBeardSmoothDarkerL = 5.0;
const kBeardNoisySpreadL = 12.0;

/// (x0, y0, x1, y1): y0 = the bottom of the nose, y1 = the chin, the sides of
/// the face box. Null without a face.
(int, int, int, int)? lowerFaceBox(
  BoolMask face,
  BoolMask nose,
  BoolMask lips,
) {
  final box = faceBox(face);
  if (box == null) return null;
  final (x0, y0, x1, y1) = box;
  final fh = y1 - y0 + 1;
  final noseSpan = maskSpan(nose), lipsSpan = maskSpan(lips);
  final int top;
  if (noseSpan != null) {
    top = noseSpan.$4;
  } else if (lipsSpan != null) {
    top = math.max(y0, lipsSpan.$2 - pyRound(0.1 * fh));
  } else {
    top = y0 + pyRound(0.6 * fh);
  }
  return (x0, top, x1, y1);
}

/// Whether the lower face reads as bearded, from the CIELAB L of bare skin
/// ([skin] leaves out lips, nose and eyes). Null = cannot tell, and callers
/// then behave as "no beard, no refusal".
bool? hasBeardOn(img.Image rgb, BoolMask skin, (int, int, int, int) lowerBox) {
  if (rgb.width != skin.w || rgb.height != skin.h) {
    throw ArgumentError('face mask and image differ in size');
  }
  final (x0, y0, x1, y1) = lowerBox;
  final upper = <double>[], lower = <double>[];
  for (var y = 0; y < skin.h; y++) {
    for (var x = 0; x < skin.w; x++) {
      if (!skin.at(x, y)) continue;
      final isUpper = y < y0;
      if (!isUpper && (y > y1 || x < x0 || x > x1)) continue;
      final p = rgb.getPixel(x, y);
      (isUpper ? upper : lower).add(
        srgbToLab(p.r.toInt(), p.g.toInt(), p.b.toInt())[0],
      );
    }
  }
  if (upper.length < kBeardMinSkinPx || lower.length < kBeardMinSkinPx) {
    return null;
  }
  final mean = upper.reduce((a, b) => a + b) / upper.length;
  var sq = 0.0;
  for (final v in upper) {
    sq += (v - mean) * (v - mean);
  }
  if (math.sqrt(sq / upper.length) > kBeardNoisySpreadL) return null;
  final darker = medianOf(upper) - medianOf(lower);
  if (darker >= kBeardDarkerL) return true;
  if (darker <= kBeardSmoothDarkerL) return false;
  return null;
}

/// [hasBeardOn] of a whole portrait; null when there is no face to read.
bool? detectBeard(img.Image rgb, HairAnalysis a) {
  final box = lowerFaceBox(a.face, a.nose, a.lips);
  if (box == null) return null;
  return hasBeardOn(
    rgb,
    a.face.andNot(a.lips).andNot(a.nose).andNot(a.features),
    box,
  );
}

/// Inner edge of each visible ear, as (left, right).
(double?, double?) _earSides(BoolMask ears, (int, int, int, int) box) {
  final (x0, _, x1, _) = box;
  final fw = x1 - x0 + 1;
  final lo = x0 - kBeardEarMaxFw * fw, hi = x1 + kBeardEarMaxFw * fw;
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
    near.length >= 10 ? percentileOfSorted(near, 99) : null,
    far.length >= 10 ? percentileOfSorted(far, 1) : null,
  );
}

/// The composite mask for [region]. [shave] is the clean-shaven style: it
/// refuses a photo that plainly has no beard. [hasBeard] ([detectBeard]) true
/// grows a narrow region to `full`, otherwise the old cheeks would survive.
/// Throws [HairMaskException] for a photo the step cannot use.
MaskResult buildBeardMask(
  HairAnalysis a,
  BeardRegion region, {
  bool shave = false,
  bool? hasBeard,
}) {
  final fullW = a.face.w, fullH = a.face.h;
  final scale = math.min(1.0, kMaskWorkSide / math.max(fullH, fullW));
  final w = math.max(1, pyRound(fullW * scale));
  final h = math.max(1, pyRound(fullH * scale));
  BoolMask small(BoolMask m) => scale == 1.0 ? m : resizeMask(m, w, h);

  final face = small(a.face);
  final hair = small(a.hair);
  final features = small(a.features);
  final lips = small(a.lips);
  final nose = small(a.nose);
  final ears = small(a.ears);

  final box = faceBox(face);
  if (box == null) throw HairMaskException.noFace;
  final (x0, y0, x1, y1) = box;
  final fw = x1 - x0 + 1, fh = y1 - y0 + 1;
  if (fh < 0.08 * h) throw HairMaskException.faceTooSmall;
  if (lips.count < kBeardMinLipsPx) throw HairMaskException.mouthNotVisible;
  if (shave && hasBeard == false) throw HairMaskException.noBeardToShave;

  final (lx0, ly0, lx1, ly1) = lowerFaceBox(face, nose, lips)!;
  final (mx0, my0, mx1, my1) = maskSpan(lips)!;

  var kind = region.kind;
  var below = region.belowChin;
  var withMoustache = region.moustache;
  var withSides = region.chinSides;
  if (hasBeard == true && kind != BeardRegionKind.full) {
    kind = BeardRegionKind.full;
    below = math.max(below, kBeardShaveBelowChin);
    withMoustache = false;
    withSides = false;
  }

  BoolMask rect(double rx0, double ry0, double rx1, double ry1) =>
      roundedRect(h, w, rx0, ry0, rx1, ry1, kBeardCornerFw * fw);

  final moustache = rect(
    lx0 + kBeardMoustacheInsetFw * fw,
    ly0.toDouble(),
    lx1 - kBeardMoustacheInsetFw * fw,
    my0 + kBeardMoustacheOverLipFh * fh,
  );
  final third = (lx1 - lx0) / 3;
  final chin = rect(
    lx0 + third,
    my1 - kBeardChinOverLipFh * fh,
    lx1 - third,
    ly1 + below * fh,
  );

  BoolMask mask;
  switch (kind) {
    case BeardRegionKind.moustache:
      mask = moustache;
      if (withSides) {
        mask = mask
            .or(
              rect(
                lx0 + kBeardMoustacheInsetFw * fw,
                ly0.toDouble(),
                mx0.toDouble(),
                ly1.toDouble(),
              ),
            )
            .or(
              rect(
                mx1.toDouble(),
                ly0.toDouble(),
                lx1 - kBeardMoustacheInsetFw * fw,
                ly1.toDouble(),
              ),
            );
      }
    case BeardRegionKind.chin:
      mask = withMoustache ? chin.or(moustache) : chin;
    case BeardRegionKind.jaw:
      mask = chin.or(
        rect(
          lx0 - kBeardJawSideFw * fw,
          (ly0 + ly1) / 2,
          lx1 + kBeardJawSideFw * fw,
          ly1 + below * fh,
        ),
      );
      if (withMoustache) mask = mask.or(moustache);
    case BeardRegionKind.full:
      var left = lx0 - kBeardFullSideFw * fw;
      var right = lx1 + kBeardFullSideFw * fw;
      final (earLeft, earRight) = _earSides(ears, box);
      if (earLeft != null) left = math.min(left, earLeft);
      if (earRight != null) right = math.max(right, earRight);
      mask = rect(left, ly0.toDouble(), right, ly1 + below * fh).or(moustache);
  }

  mask = mask.andNot(dilateMask(lips, pyRound(kBeardLipsGuardFh * fh)));
  mask = mask.andNot(nose).andNot(features);
  // Hair stays, bar the allowance at its edge where a sideburn meets it.
  mask = mask.andNot(
    hair.andNot(
      dilateMask(hair.inverted(), pyRound(kBeardHairAllowanceFh * fh)),
    ),
  );

  final area = mask.mean;
  if (mask.count == 0) throw HairMaskException.nothingToChange;

  if (scale != 1.0) {
    mask = resizeMask(
      mask,
      fullW,
      fullH,
    ).andNot(a.lips).andNot(a.nose).andNot(a.features);
  }
  final inv = 1.0 / scale;
  return MaskResult(mask, (
    (x0 * inv).toInt(),
    (y0 * inv).toInt(),
    (x1 * inv).toInt(),
    (y1 * inv).toInt(),
  ), area);
}
