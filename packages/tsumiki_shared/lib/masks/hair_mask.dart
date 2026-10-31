// Hair repaint mask from face-parsing masks.
//
// Dart mirror of `tgbot/hairmask.py` — same constants, same steps, same order
// (copied from Ol1nLLM `lib/models/hair_mask.dart`, which moves onto this
// package in phase 2). `tgbot/tests/fixtures/masks` pins both to IoU 1.0; the
// numbers are calibrated by the bench (`docs/hair-matrix.md`).
//
// The repaint mask is:
//   1. old hair + hat, dilated so no stray strands survive;
//   2. a forehead band when the new style has a fringe;
//   3. an envelope where the new hair may grow (a longer cut needs room the
//      old hair never had);
//   4. minus the face, so the pixels that carry identity are never touched.

import 'dart:math' as math;

import '../catalogs/hairstyles.dart';
import 'bool_mask.dart';
import 'face_parse.dart';

// ── Tunables (units are face-box sizes; see hairmask.py for the why) ────────
const kHairDilateFh = 0.06;
const kHairBangBandFh = 0.28;
const kHairFeatureGuardFh = 0.04;

/// (sideways past the face in face widths, above the face top in face
/// heights, below the chin in face heights); null = no envelope.
const kHairEnvelopes = <HairLength, (double, double, double)?>{
  HairLength.keep: null,
  HairLength.short: (0.35, 0.35, 0.0),
  HairLength.medium: (0.5, 0.35, 0.7),
  HairLength.long: (0.6, 0.35, 1.8),
};

/// "blob" = the bounding rounded rectangle of the union (minus the face);
/// "hair" = the union itself. FLUX paints the mask's shape and SDXL left old
/// strands on the shoulders, so the shipped default is the rectangle.
const kHairMaskMode = 'blob';
const kHairUpdoAboveFh = 0.8;
const kHairUpdoSideFw = 0.3;
const kHairCornerFw = 0.3;
const kHairMinFaceH = 0.08;
const kHairMinMaskArea = 0.02;
const kHairWorkSide = kMaskWorkSide;

/// InpaintCropImproved settings of the Tsumiki hair graphs
/// (`flux_hair_inpaint.api.json`): the face is a hole in the mask, and filling
/// holes repainted it; 1.5 is the context window the bench ran with.
const kHairMaskFillHoles = false;
const kHairContextFactor = 1.5;

/// Soft edge of the Kontext composite (`GrowMaskWithBlur` in
/// `flux_hair_kontext.api.json`) as a share of the photo's long side. The
/// graph ships 6 px expand / 12 px blur: right for the bench's 1216 px
/// portraits, half a percent of a 2576 px phone photo — a hard seam there.
/// Mirror of `feather_px` in hairmask.py.
const kHairFeatherExpand = 0.006;
const kHairFeatherBlur = 0.015;

/// (expand, blur) in pixels for a photo of [w]×[h].
(int, int) hairFeatherPx(int w, int h) {
  final side = math.max(w, h);
  return (
    math.max(1, pyRound(kHairFeatherExpand * side)),
    math.max(1, pyRound(kHairFeatherBlur * side)),
  );
}

/// Back-compat name of [MaskResult].
typedef HairMaskResult = MaskResult;

/// The repaint mask for [shape] on this portrait. Throws
/// [HairMaskException] for a photo the step cannot use.
///
/// [mode] `hair` keeps the old silhouette (a colour change on the same cut).
MaskResult buildHairMask(
  HairAnalysis a,
  HairShape shape, {
  String mode = kHairMaskMode,
}) {
  final fullW = a.face.w, fullH = a.face.h;
  final scale = math.min(1.0, kHairWorkSide / math.max(fullH, fullW));
  final w = math.max(1, pyRound(fullW * scale));
  final h = math.max(1, pyRound(fullH * scale));
  BoolMask small(BoolMask m) => scale == 1.0 ? m : resizeMask(m, w, h);

  final face = small(a.face);
  final hair = small(a.hair);
  final hat = small(a.hat);
  final features = small(a.features);

  final box = faceBox(face);
  if (box == null) throw HairMaskException.noFace;
  final (x0, y0, x1, y1) = box;
  final fw = x1 - x0 + 1, fh = y1 - y0 + 1;
  if (fh < kHairMinFaceH * h) throw HairMaskException.faceTooSmall;

  var mask = dilateMask(hair.or(hat), pyRound(kHairDilateFh * fh));

  var band = BoolMask(w, h);
  if (shape.bangs != HairBangs.none) {
    final yEnd = math.min(h, y0 + pyRound(kHairBangBandFh * fh));
    final xEnd = math.min(w, x1 + 1);
    for (var y = math.max(0, y0); y < yEnd; y++) {
      for (var x = math.max(0, x0); x < xEnd; x++) {
        band.set(x, y);
      }
    }
    band = band.andNot(
      dilateMask(features, math.max(2, pyRound(kHairFeatureGuardFh * fh))),
    );
    mask = mask.or(band);
  }

  final env = kHairEnvelopes[shape.length];
  if (env != null) {
    final (side, above, below) = env;
    mask = mask.or(
      roundedRect(
        h,
        w,
        x0 - side * fw,
        y0 - above * fh,
        x1 + side * fw,
        y1 + below * fh,
        kHairCornerFw * fw,
      ),
    );
  }
  if (shape.updo) {
    mask = mask.or(
      roundedRect(
        h,
        w,
        x0 - kHairUpdoSideFw * fw,
        y0 - kHairUpdoAboveFh * fh,
        x1 + kHairUpdoSideFw * fw,
        y0 + 0.2 * fh,
        kHairCornerFw * fw,
      ),
    );
  }

  if (mode == 'blob' && mask.count > 0) {
    var bx0 = w, by0 = h, bx1 = -1, by1 = -1;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (!mask.at(x, y)) continue;
        if (x < bx0) bx0 = x;
        if (x > bx1) bx1 = x;
        if (y < by0) by0 = y;
        if (y > by1) by1 = y;
      }
    }
    mask = mask.or(
      roundedRect(
        h,
        w,
        bx0.toDouble(),
        by0.toDouble(),
        bx1.toDouble(),
        by1.toDouble(),
        kHairCornerFw * fw,
      ),
    );
  }

  mask = mask.andNot(face.andNot(band));
  final area = mask.mean;
  if (area < kHairMinMaskArea) throw HairMaskException.maskTooSmall;

  if (scale != 1.0) {
    mask = resizeMask(
      mask,
      fullW,
      fullH,
    ).andNot(a.face.andNot(resizeMask(band, fullW, fullH)));
  }
  final inv = 1.0 / scale;
  return MaskResult(mask, (
    (x0 * inv).toInt(),
    (y0 * inv).toInt(),
    (x1 * inv).toInt(),
    (y1 * inv).toInt(),
  ), area);
}
