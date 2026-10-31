// Dumps 512x512 RGB (.rgb, 786432 bytes) of each input for parity.py:
//   dart run bin/resize.dart <outdir> <image>...
// Variants: pil (our port), and package:image copyResize linear/average/cubic/nearest.
// A .jpg input is decoded by package:image, which is what the phone would use.
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:ondevice_dart_resize/parser_preprocess.dart';

Uint8List rgbBytes(img.Image im) {
  final out = Uint8List(im.width * im.height * 3);
  var o = 0;
  for (final p in im) {
    out[o++] = p.r.toInt();
    out[o++] = p.g.toInt();
    out[o++] = p.b.toInt();
  }
  return out;
}

void main(List<String> args) {
  final outDir = args.first;
  Directory(outDir).createSync(recursive: true);
  for (final path in args.skip(1)) {
    final stem = path.split('/').last;
    final src = img.decodeImage(File(path).readAsBytesSync())!.convert(format: img.Format.uint8, numChannels: 3);
    final raw = rgbBytes(src);
    File('$outDir/$stem.pil.rgb').writeAsBytesSync(pilBilinearResize(raw, src.width, src.height, 512, 512));
    for (final (name, mode) in [
      ('linear', img.Interpolation.linear),
      ('average', img.Interpolation.average),
      ('cubic', img.Interpolation.cubic),
      ('nearest', img.Interpolation.nearest),
    ]) {
      final r = img.copyResize(src, width: 512, height: 512, maintainAspect: false, interpolation: mode);
      File('$outDir/$stem.$name.rgb').writeAsBytesSync(rgbBytes(r));
    }
  }
}
