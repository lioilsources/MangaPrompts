import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The package runs on the phone and in the Mini App: no platform libraries,
/// no Telegram, no ONNX runtime, Flutter only in the widgets.
void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('there is something to check', () => expect(files, isNotEmpty));

  test('no dart:io, no dart:js_interop, no dart:html', () {
    final banned = RegExp(r'''['"]dart:(io|js_interop|js|html|ffi)['"]''');
    for (final f in files) {
      expect(banned.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
    }
  });

  test('no Telegram anywhere', () {
    for (final f in files) {
      expect(
        f.readAsStringSync().toLowerCase().contains('telegram'),
        isFalse,
        reason: f.path,
      );
    }
  });

  test('no ONNX import: FaceParse takes finished class maps', () {
    final banned = RegExp(r'''import\s+['"]package:(onnx|flutter_onnx)''');
    for (final f in files) {
      expect(banned.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
    }
  });

  test('Flutter only in lib/ui', () {
    final flutter = RegExp(r'''import\s+['"]package:flutter/''');
    for (final f in files) {
      if (f.path.contains('lib/ui/')) continue;
      expect(flutter.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
    }
  });
}
