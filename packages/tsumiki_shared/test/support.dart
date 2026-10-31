import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tsumiki_shared/tsumiki_shared.dart';

const fixtures = 'test/fixtures';
const missingFixtures =
    'test/fixtures missing: run tools/sync_fixtures.sh in the repo root';

/// Raw palette indices of an indexed PNG.
Uint8List classMap(String path) {
  final image = img.decodePng(File(path).readAsBytesSync())!;
  final out = Uint8List(image.width * image.height);
  var i = 0;
  for (final p in image) {
    out[i++] = p.index.toInt();
  }
  return out;
}

class FixtureCase {
  FixtureCase(this.json);

  final Map<String, dynamic> json;

  String get name => json['case'] as String;
  String get dir => '$fixtures/masks/$name';
  int get width => json['width'] as int;
  int get height => json['height'] as int;
  bool get hasPhoto => json['photo'] as bool;
  List<Map<String, dynamic>> expected(String kind) => [
    for (final e in json['expected'] as List)
      if ((e as Map)['kind'] == kind) e.cast<String, dynamic>(),
  ];

  FaceParse parse() => FaceParse(
    face: classMap('$dir/parse.png'),
    clothes: json['clothes'] as bool ? classMap('$dir/clothes.png') : null,
    width: width,
    height: height,
  );

  img.Image photo() => img.decodePng(File('$dir/photo.png').readAsBytesSync())!;
}

List<FixtureCase> loadCases() {
  final file = File('$fixtures/masks/cases.json');
  if (!file.existsSync()) throw StateError(missingFixtures);
  final doc = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return [
    for (final c in doc['cases'] as List)
      FixtureCase((c as Map).cast<String, dynamic>()),
  ];
}

Map<String, dynamic> loadPrompts() =>
    jsonDecode(File('$fixtures/prompts.json').readAsStringSync())
        as Map<String, dynamic>;

/// Intersection over union of two masks of one size. Two empty masks agree.
double iou(BoolMask a, BoolMask b) {
  if (a.w != b.w || a.h != b.h) return 0;
  var both = 0, either = 0;
  for (var i = 0; i < a.data.length; i++) {
    both += a.data[i] & b.data[i];
    either += a.data[i] | b.data[i];
  }
  return either == 0 ? 1 : both / either;
}
