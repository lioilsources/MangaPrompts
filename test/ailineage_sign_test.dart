import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki/services/comfy_image_service.dart';

/// AILineage: every SaveImage becomes the signing node, keeping the image
/// edge and filename prefix that output collection relies on.
void main() {
  test('every template SaveImage becomes AILineageSaveImage', () {
    for (final f in Directory('assets/comfyui').listSync().whereType<File>()) {
      if (!f.path.endsWith('.api.json')) continue;
      final wf = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      final before = {
        for (final e in wf.entries)
          if ((e.value as Map)['class_type'] == 'SaveImage')
            e.key: Map.of((e.value as Map)['inputs'] as Map),
      };
      ComfyImageService.signOutputs(wf, prompt: 'a manga fox');
      for (final e in before.entries) {
        final node = wf[e.key] as Map;
        expect(node['class_type'], ComfyImageService.kAiLineageNode, reason: f.path);
        final inputs = node['inputs'] as Map;
        expect(inputs['images'], e.value['images']);
        expect(inputs['filename_prefix'], e.value['filename_prefix']);
        expect(inputs['prompt_text'], 'a manga fox');
      }
      expect(wf.values.where((n) => (n as Map)['class_type'] == 'SaveImage'), isEmpty);
    }
  });
}
