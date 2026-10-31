// On-device probe: full parser path (decode -> PIL resize -> ORT -> upsample ->
// argmax) on a real device, timed per phase and compared with the Python golden
// class map. Prints one `PROBE {json}` line per model/provider. See README.md.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

import 'parser_preprocess.dart'; // copy of ../dart_resize/lib/parser_preprocess.dart

const models = ['face_b0.fp16', 'face_b5.int8conv', 'face_b5.fp16', 'clothes_b2.fp16'];
const runs = 3;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Probe()));
}

class Probe extends StatefulWidget {
  const Probe({super.key});
  @override
  State<Probe> createState() => _ProbeState();
}

class _ProbeState extends State<Probe> {
  final lines = <String>[];

  void log(String s) {
    // ignore: avoid_print
    print('PROBE $s');
    setState(() => lines.add(s));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => run());
  }

  Future<void> run() async {
    final ort = OnnxRuntime();
    log(jsonEncode({'providers': (await ort.getAvailableProviders()).map((p) => p.name).toList()}));
    final sw = Stopwatch()..start();
    final png = (await rootBundle.load('assets/src.png')).buffer.asUint8List();
    final decoded = img.decodePng(png)!.convert(format: img.Format.uint8, numChannels: 3);
    final decodeMs = sw.elapsedMilliseconds;
    final w = decoded.width, h = decoded.height;
    final rgb = Uint8List(w * h * 3);
    var o = 0;
    for (final p in decoded) {
      rgb[o++] = p.r.toInt();
      rgb[o++] = p.g.toInt();
      rgb[o++] = p.b.toInt();
    }
    sw.reset();
    final resized = pilBilinearResize(rgb, w, h, parserSize, parserSize);
    final pixels = toPixelValues(resized);
    final preMs = sw.elapsedMilliseconds;
    log(jsonEncode({'decode_ms': decodeMs, 'resize_norm_ms': preMs, 'w': w, 'h': h}));

    for (final name in models) {
      final key = 'assets/models/$name.onnx';
      for (final prov in [OrtProvider.CPU, OrtProvider.CORE_ML]) {
        final row = <String, dynamic>{'model': name, 'provider': prov.name};
        try {
          sw.reset();
          final session = await ort.createSessionFromAsset(key,
              options: OrtSessionOptions(providers: prov == OrtProvider.CPU ? [OrtProvider.CPU] : [prov, OrtProvider.CPU]));
          row['load_ms'] = sw.elapsedMilliseconds;
          final times = <int>[];
          Float32List? logits;
          for (var i = 0; i < runs + 1; i++) {
            final input = await OrtValue.fromList(pixels, [1, 3, parserSize, parserSize]);
            sw.reset();
            final out = await session.run({'pixel_values': input});
            final t = sw.elapsedMilliseconds;
            if (i == 0) {
              row['first_ms'] = t;
            } else {
              times.add(t);
            }
            final v = out['logits']!;
            if (i == runs) {
              final flat = await v.asFlattenedList();
              logits = Float32List.fromList(flat.cast<double>());
              row['shape'] = v.shape;
            }
            await v.dispose();
            await input.dispose();
          }
          times.sort();
          row['run_ms'] = times;
          sw.reset();
          final classes = row['shape'][1] as int;
          final seg = upsampleArgmax(logits!, classes, row['shape'][2] as int, w, h);
          row['upsample_argmax_ms'] = sw.elapsedMilliseconds;
          await session.close();
          row.addAll(await compare(name, seg));
        } catch (e) {
          row['error'] = '$e';
        }
        log(jsonEncode(row));
      }
    }
    log('{"done":true}');
  }

  /// Exact pixel agreement with the golden Python class map of the same model.
  Future<Map<String, dynamic>> compare(String name, Uint8List seg) async {
    final base = name.split('.').first;
    final ByteData data;
    try {
      data = await rootBundle.load('assets/golden/$base.png');
    } catch (_) {
      return {};
    }
    final g = img.decodePng(data.buffer.asUint8List())!;
    var same = 0, i = 0;
    for (final p in g) {
      if (p.r.toInt() == seg[i++]) same++;
    }
    return {'golden_pixel_agreement': same / seg.length};
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: ListView(children: [for (final l in lines) Text(l, style: const TextStyle(fontSize: 10))])),
      );
}
