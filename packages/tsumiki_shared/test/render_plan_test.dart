import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiki_shared/tsumiki_shared.dart';

void main() {
  final mask = Uint8List.fromList([1, 2, 3]);

  RenderStep edit(String id, String input) => RenderStep(
    id: id,
    graph: RenderGraph.kontextEdit,
    input: input,
    prompt: 'p',
    mask: mask,
  );
  RenderStep style(String id, String input) => RenderStep(
    id: id,
    graph: RenderGraph.restyleFlux,
    input: input,
    prompt: 'p',
  );

  test('the chain serialises to the server contract', () {
    final plan = RenderPlan([
      edit('beard', 'source'),
      edit('hair', 'beard'),
      const RenderStep(
        id: 's1',
        graph: RenderGraph.restyleSdxl,
        input: 'hair',
        prompt: 'p',
        negative: 'n',
        medium: RestyleMedium.illustration,
      ),
      const RenderStep(
        id: 'live',
        graph: RenderGraph.livePortrait,
        input: 'hair',
        motion: 'blink',
      ),
    ]);
    final body = plan.toRequest(Uint8List.fromList([9]));
    expect(body['source'], base64Encode([9]));
    final steps = body['steps'] as List;
    expect(steps[0], {
      'id': 'beard',
      'graph': 'kontext_edit',
      'input': 'source',
      'prompt': 'p',
      'mask': base64Encode(mask),
    });
    expect(steps[2], {
      'id': 's1',
      'graph': 'restyle_sdxl',
      'input': 'hair',
      'prompt': 'p',
      'negative': 'n',
      'medium': 'illustration',
    });
    expect(steps[3], {
      'id': 'live',
      'graph': 'live_portrait',
      'input': 'hair',
      'motion': 'blink',
    });
    expect(plan.cost, 4);
  });

  test('plan survives storage', () {
    final plan = RenderPlan([edit('hair', 'source'), style('s1', 'hair')]);
    final back = RenderPlan.fromJson(
      jsonDecode(jsonEncode(plan.toJson())) as List,
    );
    expect(back.toJson(), plan.toJson());
    expect(back.steps.first.mask, mask);
  });

  test('wan is priced apart', () {
    final plan = RenderPlan([
      const RenderStep(
        id: 'w',
        graph: RenderGraph.wanMotion,
        input: 'source',
        motion: 'hair-breeze',
      ),
    ]);
    expect(plan.cost, kRenderWanCost);
  });

  test('refuses what the server answers 422 for', () {
    void bad(List<RenderStep> steps) =>
        expect(() => RenderPlan(steps), throwsArgumentError);
    bad([]);
    bad([for (var i = 0; i < 13; i++) style('s$i', 'source')]);
    bad([style('Bad Id', 'source')]);
    bad([style('source', 'source')]);
    bad([style('a', 'source'), style('a', 'source')]);
    bad([style('a', 'b'), style('b', 'source')]); // forward reference
    bad([style('a', 'nope')]);
    bad([
      const RenderStep(
        id: 'e',
        graph: RenderGraph.kontextEdit,
        input: 'source',
        prompt: 'p',
      ),
    ]);
    bad([
      RenderStep(
        id: 'e',
        graph: RenderGraph.restyleFlux,
        input: 'source',
        prompt: 'p',
        mask: mask,
      ),
    ]);
    bad([
      const RenderStep(
        id: 'e',
        graph: RenderGraph.restyleFlux,
        input: 'source',
        prompt: 'p',
        medium: RestyleMedium.photo,
      ),
    ]);
    bad([
      const RenderStep(
        id: 'l',
        graph: RenderGraph.livePortrait,
        input: 'source',
      ),
    ]);
    bad([
      const RenderStep(
        id: 'e',
        graph: RenderGraph.restyleFlux,
        input: 'source',
        prompt: 'p',
        motion: 'blink',
      ),
    ]);
    bad([
      const RenderStep(
        id: 'e',
        graph: RenderGraph.restyleFlux,
        input: 'source',
      ),
    ]);
    bad([
      const RenderStep(
        id: 'x',
        graph: RenderGraph.restyleSdxl,
        input: 'source',
        prompt: 'p',
      ),
    ]);
    bad([style('s', 'source'), edit('e', 's')]); // restyle moved the geometry
    bad([
      const RenderStep(
        id: 'l',
        graph: RenderGraph.livePortrait,
        input: 'source',
        motion: 'blink',
      ),
      style('s', 'l'), // an mp4 cannot be an input
    ]);
  });
}
