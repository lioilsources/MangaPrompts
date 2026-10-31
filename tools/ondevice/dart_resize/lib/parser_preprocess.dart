/// Preprocessing and postprocessing of the on-device parser, matching
/// ComfyUI-RMBG FaceSegment/ClothesSegment bit for bit (see ../../README.md).
library;

import 'dart:typed_data';

const int parserSize = 512;
const List<double> imagenetMean = [0.485, 0.456, 0.406];
const List<double> imagenetStd = [0.229, 0.224, 0.225];

const int _precisionBits = 32 - 8 - 2; // Pillow Resample.c

class _Coeffs {
  _Coeffs(this.bounds, this.k, this.ksize);
  final Int32List bounds; // xmin, count per output sample
  final Int32List k; // fixed point weights, ksize per output sample
  final int ksize;
}

double _triangle(double x) {
  final a = x.abs();
  return a < 1.0 ? 1.0 - a : 0.0;
}

// C (int) cast of a double.
int _cInt(double v) => v.truncate();

_Coeffs _coeffs(int inSize, int outSize) {
  final scale = inSize / outSize;
  final filterscale = scale < 1.0 ? 1.0 : scale;
  final support = 1.0 * filterscale;
  final ksize = support.ceil() * 2 + 1;
  final bounds = Int32List(outSize * 2);
  final k = Int32List(outSize * ksize);
  final w = Float64List(ksize);
  for (var xx = 0; xx < outSize; xx++) {
    final center = (xx + 0.5) * scale;
    var xmin = _cInt(center - support + 0.5);
    if (xmin < 0) xmin = 0;
    var xmax = _cInt(center + support + 0.5);
    if (xmax > inSize) xmax = inSize;
    final n = xmax - xmin;
    var ww = 0.0;
    for (var x = 0; x < n; x++) {
      final v = _triangle((x + xmin - center + 0.5) / filterscale);
      w[x] = v;
      ww += v;
    }
    for (var x = 0; x < n; x++) {
      final v = w[x] / ww * (1 << _precisionBits);
      k[xx * ksize + x] = v < 0 ? _cInt(-0.5 + v) : _cInt(0.5 + v);
    }
    bounds[xx * 2] = xmin;
    bounds[xx * 2 + 1] = n;
  }
  return _Coeffs(bounds, k, ksize);
}

int _clip8(int v) {
  final s = v >> _precisionBits;
  return s < 0 ? 0 : (s > 255 ? 255 : s);
}

/// Exact port of Pillow `Image.resize(BILINEAR)` for 8-bit RGB: an antialiased
/// triangle filter, horizontal pass first, rounded to 8 bits between passes.
/// [rgb] is interleaved RGB, width*height*3 bytes. Returns the same layout.
Uint8List pilBilinearResize(Uint8List rgb, int width, int height, int outW, int outH) {
  final h = _coeffs(width, outW);
  final v = _coeffs(height, outH);
  final half = 1 << (_precisionBits - 1);
  final tmp = Uint8List(outW * height * 3);
  for (var y = 0; y < height; y++) {
    final row = y * width * 3;
    var o = y * outW * 3;
    for (var xx = 0; xx < outW; xx++) {
      final xmin = h.bounds[xx * 2], n = h.bounds[xx * 2 + 1], base = xx * h.ksize;
      var r = half, g = half, b = half;
      for (var x = 0; x < n; x++) {
        final c = h.k[base + x];
        final p = row + (xmin + x) * 3;
        r += rgb[p] * c;
        g += rgb[p + 1] * c;
        b += rgb[p + 2] * c;
      }
      tmp[o++] = _clip8(r);
      tmp[o++] = _clip8(g);
      tmp[o++] = _clip8(b);
    }
  }
  final out = Uint8List(outW * outH * 3);
  final stride = outW * 3;
  for (var yy = 0; yy < outH; yy++) {
    final ymin = v.bounds[yy * 2], n = v.bounds[yy * 2 + 1], base = yy * v.ksize;
    var o = yy * stride;
    for (var i = 0; i < stride; i++) {
      var s = half;
      for (var y = 0; y < n; y++) {
        s += tmp[(ymin + y) * stride + i] * v.k[base + y];
      }
      out[o++] = _clip8(s);
    }
  }
  return out;
}

/// 512x512 interleaved RGB -> `pixel_values`, float32 NCHW 1x3x512x512.
Float32List toPixelValues(Uint8List rgb512) {
  final n = parserSize * parserSize;
  final out = Float32List(3 * n);
  for (var i = 0; i < n; i++) {
    for (var c = 0; c < 3; c++) {
      out[c * n + i] = (rgb512[i * 3 + c] / 255.0 - imagenetMean[c]) / imagenetStd[c];
    }
  }
  return out;
}

/// `logits` (1xCxLxL, row-major) -> per-pixel class at [width]x[height]: bilinear
/// upsampling with align_corners=False followed by argmax, without materialising
/// the upsampled logits.
Uint8List upsampleArgmax(Float32List logits, int classes, int size, int width, int height) {
  final x0 = Int32List(width), x1 = Int32List(width);
  final wx = Float32List(width);
  for (var x = 0; x < width; x++) {
    var s = (x + 0.5) * size / width - 0.5;
    if (s < 0) s = 0;
    final i = s.floor();
    x0[x] = i;
    x1[x] = i + 1 < size ? i + 1 : size - 1;
    wx[x] = s - i;
  }
  final out = Uint8List(width * height);
  final plane = size * size;
  for (var y = 0; y < height; y++) {
    var s = (y + 0.5) * size / height - 0.5;
    if (s < 0) s = 0;
    final i = s.floor();
    final r0 = i * size, r1 = (i + 1 < size ? i + 1 : size - 1) * size;
    final wy = s - i;
    final row = y * width;
    for (var x = 0; x < width; x++) {
      final a = x0[x], b = x1[x], w = wx[x];
      var best = 0;
      var bestV = double.negativeInfinity;
      for (var c = 0; c < classes; c++) {
        final o = c * plane;
        final top = logits[o + r0 + a] * (1 - w) + logits[o + r0 + b] * w;
        final bot = logits[o + r1 + a] * (1 - w) + logits[o + r1 + b] * w;
        final v = top * (1 - wy) + bot * wy;
        if (v > bestV) {
          bestV = v;
          best = c;
        }
      }
      out[row + x] = best;
    }
  }
  return out;
}
