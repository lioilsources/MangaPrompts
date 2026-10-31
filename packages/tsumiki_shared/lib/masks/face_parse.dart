// Face parsing results as masks. This file knows no model: the app runs ONNX
// and hands over finished class maps. The mapping below has to stay what
// `assets/comfyui/hair_analyse.api.json` saves, because the mask constants are
// calibrated on that graph; `gen_fixtures.analysis_from_parse` is its Python
// twin and the fixtures compare the two.

import 'dart:typed_data';

import 'bool_mask.dart';

/// Classes of the face parser (FaceSegment, CelebAMask-HQ).
abstract final class FaceClass {
  static const background = 0;
  static const skin = 1;
  static const nose = 2;
  static const eyeglasses = 3;
  static const leftEye = 4;
  static const rightEye = 5;
  static const leftBrow = 6;
  static const rightBrow = 7;
  static const leftEar = 8;
  static const rightEar = 9;
  static const mouth = 10;
  static const upperLip = 11;
  static const lowerLip = 12;
  static const hair = 13;
  static const hat = 14;
  static const earring = 15;
  static const necklace = 16;
  static const neck = 17;
  static const cloth = 18;
}

/// Classes of the clothes parser (ClothesSegment, ATR) that masks read.
abstract final class ClothesClass {
  static const background = 0;
  static const hat = 1;
  static const hair = 2;
  static const sunglasses = 3;
  static const upperClothes = 4;
}

/// Boolean masks of one portrait, all the same size (`hairmask.HairAnalysis`).
class HairAnalysis {
  HairAnalysis({
    required this.hair,
    required this.face,
    required this.hat,
    BoolMask? features,
    BoolMask? lips,
    BoolMask? nose,
    BoolMask? ears,
    BoolMask? glasses,
  }) : features = features ?? BoolMask(face.w, face.h),
       lips = lips ?? BoolMask(face.w, face.h),
       nose = nose ?? BoolMask(face.w, face.h),
       ears = ears ?? BoolMask(face.w, face.h),
       glasses = glasses ?? BoolMask(face.w, face.h) {
    for (final m in [
      hair,
      hat,
      this.features,
      this.lips,
      this.nose,
      this.ears,
      this.glasses,
    ]) {
      if (m.w != face.w || m.h != face.h) {
        throw ArgumentError('analysis masks differ in size');
      }
    }
  }

  final BoolMask hair;

  /// Skin, nose, eyes, brows, mouth, lips, glasses.
  final BoolMask face;
  final BoolMask hat;

  /// Eyes + brows + glasses.
  final BoolMask features;

  /// Mouth + both lips.
  final BoolMask lips;
  final BoolMask nose;
  final BoolMask ears;
  final BoolMask glasses;

  /// The name the glasses module uses for [lips].
  BoolMask get mouth => lips;
}

/// Class maps of one portrait. [face] and [clothes] are row-major, one class
/// id per pixel, `width * height` long; [clothes] is optional (without it there
/// is no hair past the chest and no hat).
class FaceParse {
  FaceParse({
    required this.face,
    required this.width,
    required this.height,
    this.clothes,
  }) {
    if (face.length != width * height ||
        (clothes != null && clothes!.length != width * height)) {
      throw ArgumentError('class map does not match $width×$height');
    }
  }

  final Uint8List face;
  final Uint8List? clothes;
  final int width;
  final int height;

  /// Nearest-neighbour rescale of a class map; parsers run at a fixed size,
  /// masks are built at the size of the photo.
  static Uint8List resizeClassMap(
    Uint8List map,
    int fromW,
    int fromH,
    int toW,
    int toH,
  ) => resizeMask(BoolMask(fromW, fromH, map), toW, toH).data;

  /// The same parse at another size.
  FaceParse resized(int toW, int toH) => FaceParse(
    face: resizeClassMap(face, width, height, toW, toH),
    clothes: clothes == null
        ? null
        : resizeClassMap(clothes!, width, height, toW, toH),
    width: toW,
    height: toH,
  );

  BoolMask _pick(Uint8List map, Set<int> ids) {
    final out = BoolMask(width, height);
    for (var i = 0; i < map.length; i++) {
      if (ids.contains(map[i])) out.data[i] = 1;
    }
    return out;
  }

  /// Mask of face-parser classes ([FaceClass]).
  BoolMask mask(Set<int> ids) => _pick(face, ids);

  /// Mask of clothes-parser classes ([ClothesClass]); empty without [clothes].
  BoolMask clothesMask(Set<int> ids) =>
      clothes == null ? BoolMask(width, height) : _pick(clothes!, ids);

  /// Hair is Hair of both parsers (FaceSegment stops at the chest); the hat
  /// comes from the clothes parser, as in the graph, never from [FaceClass.hat].
  HairAnalysis toAnalysis() => HairAnalysis(
    hair: mask({FaceClass.hair}).or(clothesMask({ClothesClass.hair})),
    face: mask({
      FaceClass.skin,
      FaceClass.nose,
      FaceClass.leftEye,
      FaceClass.rightEye,
      FaceClass.leftBrow,
      FaceClass.rightBrow,
      FaceClass.mouth,
      FaceClass.upperLip,
      FaceClass.lowerLip,
      FaceClass.eyeglasses,
    }),
    hat: clothesMask({ClothesClass.hat}),
    features: mask({
      FaceClass.leftEye,
      FaceClass.rightEye,
      FaceClass.leftBrow,
      FaceClass.rightBrow,
      FaceClass.eyeglasses,
    }),
    lips: mask({FaceClass.mouth, FaceClass.upperLip, FaceClass.lowerLip}),
    nose: mask({FaceClass.nose}),
    ears: mask({FaceClass.leftEar, FaceClass.rightEar}),
    glasses: mask({FaceClass.eyeglasses}),
  );
}
