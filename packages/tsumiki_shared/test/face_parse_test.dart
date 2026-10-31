import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki_shared/tsumiki_shared.dart';

void main() {
  FaceParse one(int faceClass, [int? clothesClass]) => FaceParse(
    face: Uint8List.fromList([faceClass]),
    clothes: clothesClass == null ? null : Uint8List.fromList([clothesClass]),
    width: 1,
    height: 1,
  );

  test('hair is the union of both parsers', () {
    expect(one(FaceClass.hair).toAnalysis().hair.count, 1);
    expect(one(0, ClothesClass.hair).toAnalysis().hair.count, 1);
    expect(one(0, 0).toAnalysis().hair.count, 0);
  });

  test('hat comes from the clothes parser, never class 14', () {
    expect(one(FaceClass.hat).toAnalysis().hat.count, 0);
    expect(one(FaceClass.hat, 0).toAnalysis().hat.count, 0);
    expect(one(0, ClothesClass.hat).toAnalysis().hat.count, 1);
  });

  test('face and features follow the graph', () {
    for (final id in [1, 2, 3, 4, 5, 6, 7, 10, 11, 12]) {
      expect(one(id).toAnalysis().face.count, 1, reason: '$id');
    }
    for (final id in [0, 8, 9, 13, 14, 15, 16, 17, 18]) {
      expect(one(id).toAnalysis().face.count, 0, reason: '$id');
    }
    for (final id in [3, 4, 5, 6, 7]) {
      expect(one(id).toAnalysis().features.count, 1, reason: '$id');
    }
    for (final id in [1, 2, 10, 11, 12]) {
      expect(one(id).toAnalysis().features.count, 0, reason: '$id');
    }
  });

  test('lips, nose, ears, glasses', () {
    for (final id in [10, 11, 12]) {
      expect(one(id).toAnalysis().lips.count, 1);
    }
    expect(one(2).toAnalysis().nose.count, 1);
    expect(one(8).toAnalysis().ears.count, 1);
    expect(one(9).toAnalysis().ears.count, 1);
    expect(one(3).toAnalysis().glasses.count, 1);
  });

  test('a map of the wrong size is refused', () {
    expect(
      () => FaceParse(face: Uint8List(3), width: 2, height: 2),
      throwsArgumentError,
    );
  });

  test('resized keeps the class ids', () {
    final p = FaceParse(
      face: Uint8List.fromList([13, 1, 2, 3]),
      width: 2,
      height: 2,
    ).resized(4, 4);
    expect(p.face.toSet(), {13, 1, 2, 3});
    expect(p.width, 4);
  });
}
