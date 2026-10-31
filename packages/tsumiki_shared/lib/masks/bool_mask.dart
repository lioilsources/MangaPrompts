// Mask primitives shared by the hair, beard and glasses masks. Dart mirror of
// the numpy helpers in `tgbot/hairmask.py`; the file fixtures in
// `tgbot/tests/fixtures/masks` pin both sides to IoU 1.0.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Long side the masks are processed at (`hairmask.WORK_SIDE`).
const kMaskWorkSide = 768;

/// A photo a mask step cannot work with; [message] is shown to the user,
/// [code] matches `hairmask.HairMaskError.code` and its siblings.
class HairMaskException implements Exception {
  const HairMaskException(this.code, this.message);

  final String code;
  final String message;

  static const noFace = HairMaskException(
    'no_face',
    'Na fotce není tvář — použij čelní portrét jednoho člověka.',
  );
  static const faceTooSmall = HairMaskException(
    'face_too_small',
    'Tvář je moc malá — ořízni fotku blíž k hlavě a ramenům.',
  );
  static const maskTooSmall = HairMaskException(
    'mask_too_small',
    'Na fotce není dost vlasů, které by šlo přestříhat.',
  );
  static const nothingToChange = HairMaskException(
    'mask_too_small',
    'Na téhle fotce není co změnit.',
  );
  static const mouthNotVisible = HairMaskException(
    'mouth_not_visible',
    'Ústa musí být vidět — dívej se do objektivu, bez ruky před tváří.',
  );
  static const noBeardToShave = HairMaskException(
    'no_beard_to_shave',
    'Na fotce nejsou vousy k oholení.',
  );
  static const eyesNotVisible = HairMaskException(
    'eyes_not_visible',
    'Oči musí být vidět — dívej se do objektivu, bez ruky a vlasů přes oči.',
  );
  static const maskTooLarge = HairMaskException(
    'mask_too_large',
    'Tvář je moc blízko — drž telefon dál.',
  );
  static const noGlassesToRemove = HairMaskException(
    'no_glasses_to_remove',
    'Na fotce nejsou brýle.',
  );

  @override
  String toString() => message;
}

/// Row-major boolean mask; `data[y * w + x]` is 1 inside.
class BoolMask {
  BoolMask(this.w, this.h, [Uint8List? data]) : data = data ?? Uint8List(w * h);

  final int w;
  final int h;
  final Uint8List data;

  bool at(int x, int y) => data[y * w + x] != 0;
  void set(int x, int y) => data[y * w + x] = 1;

  BoolMask copy() => BoolMask(w, h, Uint8List.fromList(data));

  int get count {
    var n = 0;
    for (final v in data) {
      n += v;
    }
    return n;
  }

  double get mean => count / data.length;

  BoolMask or(BoolMask o) {
    final out = copy();
    for (var i = 0; i < data.length; i++) {
      out.data[i] |= o.data[i];
    }
    return out;
  }

  BoolMask and(BoolMask o) {
    final out = copy();
    for (var i = 0; i < data.length; i++) {
      out.data[i] &= o.data[i];
    }
    return out;
  }

  BoolMask andNot(BoolMask o) {
    final out = copy();
    for (var i = 0; i < data.length; i++) {
      out.data[i] &= 1 - o.data[i];
    }
    return out;
  }

  BoolMask inverted() {
    final out = BoolMask(w, h);
    for (var i = 0; i < data.length; i++) {
      out.data[i] = 1 - data[i];
    }
    return out;
  }
}

/// What every mask builder returns.
class MaskResult {
  const MaskResult(this.mask, this.faceBox, this.area);

  /// True = repaint, at the size of the analysis.
  final BoolMask mask;

  /// (x0, y0, x1, y1) in image pixels.
  final (int, int, int, int) faceBox;

  /// Share of the image repainted, measured at the working size.
  final double area;
}

/// Python's round(): half to even. Keeps pixel counts identical to hairmask.py.
int pyRound(double v) {
  final f = v.floorToDouble();
  final diff = v - f;
  if (diff > 0.5) return f.toInt() + 1;
  if (diff < 0.5) return f.toInt();
  return f.toInt().isEven ? f.toInt() : f.toInt() + 1;
}

/// A saved ComfyUI mask (white = inside) → [BoolMask].
BoolMask decodeMaskPng(Uint8List png) {
  final image = img.decodeImage(png);
  if (image == null) throw const FormatException('mask is not an image');
  final out = BoolMask(image.width, image.height);
  // Masks are grey (MaskToImage writes r = g = b), so the red channel is the
  // luminance hairmask.py thresholds — and what ImageToMask reads.
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).r >= 128) out.set(x, y);
    }
  }
  return out;
}

/// [BoolMask] → black/white PNG, the `__MASK__` convention.
Uint8List maskToPng(BoolMask mask) {
  final image = img.Image(width: mask.w, height: mask.h, numChannels: 1);
  for (var y = 0; y < mask.h; y++) {
    for (var x = 0; x < mask.w; x++) {
      image.setPixelR(x, y, mask.at(x, y) ? 255 : 0);
    }
  }
  return img.encodePng(image);
}

/// numpy's `_lerp`, rounding included: from the far end when [t] >= 0.5. The
/// result is used as a float edge of a rectangle (glasses, beard), where the
/// last bit decides a boundary pixel.
double _lerp(int a, int b, double t) {
  final diff = b - a;
  return t >= 0.5 ? b - diff * (1 - t) : a + diff * t;
}

/// numpy.percentile (linear) over values given as a per-value histogram.
double _percentileFromHist(List<int> hist, int n, double p) {
  final pos = p / 100 * (n - 1);
  final lo = pos.floor();
  final frac = pos - lo;
  int valueAt(int rank) {
    var cum = 0;
    for (var i = 0; i < hist.length; i++) {
      cum += hist[i];
      if (cum > rank) return i;
    }
    return hist.length - 1;
  }

  final a = valueAt(lo);
  if (frac == 0) return a.toDouble();
  return _lerp(a, valueAt(math.min(lo + 1, n - 1)), frac);
}

/// numpy.percentile (linear) of [sorted] ascending values.
double percentileOfSorted(List<int> sorted, double p) {
  final n = sorted.length;
  final pos = p / 100 * (n - 1);
  final lo = pos.floor();
  final frac = pos - lo;
  final a = sorted[lo];
  if (frac == 0) return a.toDouble();
  return _lerp(a, sorted[math.min(lo + 1, n - 1)], frac);
}

/// Box of the set pixels by the 1st/99th percentile, or null with fewer than
/// [minPixels] of them (`beardmask._span`, `hairmask.face_box`).
(int, int, int, int)? maskSpan(BoolMask m, {int minPixels = 1}) {
  final xs = List<int>.filled(m.w, 0);
  final ys = List<int>.filled(m.h, 0);
  var n = 0;
  for (var y = 0; y < m.h; y++) {
    for (var x = 0; x < m.w; x++) {
      if (m.at(x, y)) {
        xs[x]++;
        ys[y]++;
        n++;
      }
    }
  }
  if (n < minPixels) return null;
  return (
    _percentileFromHist(xs, n, 1).toInt(),
    _percentileFromHist(ys, n, 1).toInt(),
    _percentileFromHist(xs, n, 99).toInt(),
    _percentileFromHist(ys, n, 99).toInt(),
  );
}

/// Face box from the 1st/99th percentile of the face pixels: a few mislabelled
/// pixels elsewhere in the frame must not stretch it.
(int, int, int, int)? faceBox(BoolMask face) => maskSpan(face, minPixels: 50);

/// Source index per output index, the way Pillow's ImagingScaleAffine does it:
/// the position is summed step by step, not multiplied, and the sum's rounding
/// decides pixels that land on a boundary (0.4997 × 768.5 = 383.9999…).
List<int> _nearestTable(int from, int to) {
  final step = from / to;
  var pos = step * 0.5;
  return List<int>.generate(to, (_) {
    final i = math.min(from - 1, pos.toInt());
    pos += step;
    return i;
  }, growable: false);
}

/// Nearest-neighbour resize, pixel for pixel Pillow's NEAREST.
BoolMask resizeMask(BoolMask m, int w, int h) {
  final out = BoolMask(w, h);
  final xs = _nearestTable(m.w, w);
  final ys = _nearestTable(m.h, h);
  for (var y = 0; y < h; y++) {
    final row = ys[y] * m.w;
    for (var x = 0; x < w; x++) {
      out.data[y * w + x] = m.data[row + xs[x]];
    }
  }
  return out;
}

/// Grow by about [radius] px: alternating 4- and 8-neighbour steps.
BoolMask dilateMask(BoolMask mask, int radius) {
  var out = mask;
  final w = mask.w, h = mask.h;
  for (var i = 0; i < radius; i++) {
    final src = out.data;
    final grown = Uint8List.fromList(src);
    for (var y = 0; y < h; y++) {
      final row = y * w;
      for (var x = 0; x < w; x++) {
        if (src[row + x] == 0) continue;
        if (y > 0) grown[row - w + x] = 1;
        if (y < h - 1) grown[row + w + x] = 1;
        if (x > 0) grown[row + x - 1] = 1;
        if (x < w - 1) grown[row + x + 1] = 1;
        if (i.isOdd) {
          if (y > 0 && x > 0) grown[row - w + x - 1] = 1;
          if (y > 0 && x < w - 1) grown[row - w + x + 1] = 1;
          if (y < h - 1 && x > 0) grown[row + w + x - 1] = 1;
          if (y < h - 1 && x < w - 1) grown[row + w + x + 1] = 1;
        }
      }
    }
    out = BoolMask(w, h, grown);
  }
  return out;
}

/// Rounded rectangle, inclusive bounds, clipped to the image.
BoolMask roundedRect(
  int h,
  int w,
  double x0,
  double y0,
  double x1,
  double y1,
  double radius,
) {
  final out = BoolMask(w, h);
  final r = math.max(
    0.0,
    math.min(radius, math.min((x1 - x0) / 2, (y1 - y0) / 2)),
  );
  final ys0 = math.max(0, y0.ceil()), ys1 = math.min(h - 1, y1.floor());
  final xs0 = math.max(0, x0.ceil()), xs1 = math.min(w - 1, x1.floor());
  for (var y = ys0; y <= ys1; y++) {
    for (var x = xs0; x <= xs1; x++) {
      if (r > 0) {
        final dx = math.max(math.max(x0 + r - x, 0.0), x - (x1 - r));
        final dy = math.max(math.max(y0 + r - y, 0.0), y - (y1 - r));
        if (dx * dx + dy * dy > r * r) continue;
      }
      out.set(x, y);
    }
  }
  return out;
}
