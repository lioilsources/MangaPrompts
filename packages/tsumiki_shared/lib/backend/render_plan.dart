// The request body of `POST /api/render` (tgbot/render.py). The checks below are
// the ones the server answers 422 for: a plan that fails here costs no upload.

import 'dart:convert';
import 'dart:typed_data';

import '../catalogs/restyle_styles.dart';

/// Whitelisted server graphs; [wire] is the `graph` field.
enum RenderGraph {
  kontextEdit('kontext_edit'),
  restyleFlux('restyle_flux'),
  restyleSdxl('restyle_sdxl'),
  livePortrait('live_portrait'),
  wanMotion('wan_motion');

  const RenderGraph(this.wire);

  final String wire;

  bool get isVideo => this == livePortrait || this == wanMotion;

  static RenderGraph fromWire(String wire) =>
      values.firstWhere((g) => g.wire == wire);
}

/// `RENDER_MAX_STEPS`.
const kRenderMaxSteps = 12;

/// `RENDER_VIDEO_COST`: generations a `wan_motion` step costs.
const kRenderWanCost = 5;

const kRenderSource = 'source';

final _stepId = RegExp(r'^[a-z0-9_-]{1,16}$');

class RenderStep {
  const RenderStep({
    required this.id,
    required this.graph,
    required this.input,
    this.prompt = '',
    this.negative = '',
    this.mask,
    this.medium,
    this.motion,
  });

  /// `^[a-z0-9_-]{1,16}$`.
  final String id;
  final RenderGraph graph;

  /// [kRenderSource] or the id of an earlier step.
  final String input;
  final String prompt;
  final String negative;

  /// Mask PNG; `kontext_edit` only, where it is required.
  final Uint8List? mask;

  /// `restyle_sdxl` only: picks the checkpoint.
  final RestyleMedium? medium;

  /// Motion preset id; required by `live_portrait` and `wan_motion`.
  final String? motion;

  Map<String, Object?> toJson() => {
    'id': id,
    'graph': graph.wire,
    'input': input,
    if (prompt.isNotEmpty) 'prompt': prompt,
    if (negative.isNotEmpty) 'negative': negative,
    if (mask != null) 'mask': base64Encode(mask!),
    if (medium != null) 'medium': medium!.wire,
    if (motion != null) 'motion': motion,
  };

  factory RenderStep.fromJson(Map<String, dynamic> json) => RenderStep(
    id: json['id'] as String,
    graph: RenderGraph.fromWire(json['graph'] as String),
    input: json['input'] as String,
    prompt: json['prompt'] as String? ?? '',
    negative: json['negative'] as String? ?? '',
    mask: json['mask'] == null ? null : base64Decode(json['mask'] as String),
    medium: json['medium'] == null
        ? null
        : RestyleMedium.values.firstWhere((m) => m.wire == json['medium']),
    motion: json['motion'] as String?,
  );
}

/// Steps in submission order. Throws [ArgumentError] on anything the server
/// would refuse.
class RenderPlan {
  RenderPlan(List<RenderStep> steps) : steps = List.unmodifiable(steps) {
    _validate();
  }

  final List<RenderStep> steps;

  /// Generations this plan spends.
  int get cost => steps.fold(
    0,
    (sum, s) => sum + (s.graph == RenderGraph.wanMotion ? kRenderWanCost : 1),
  );

  void _validate() {
    if (steps.isEmpty || steps.length > kRenderMaxSteps) {
      throw ArgumentError('a plan has 1..$kRenderMaxSteps steps');
    }
    final seen = <String>{};
    final images = <String>{kRenderSource};
    final edits = <String>{kRenderSource};
    for (final s in steps) {
      if (!_stepId.hasMatch(s.id) || s.id == kRenderSource) {
        throw ArgumentError('bad step id "${s.id}"');
      }
      if (!seen.add(s.id)) throw ArgumentError('duplicate step "${s.id}"');
      if (!images.contains(s.input)) {
        throw ArgumentError(
          'step "${s.id}" reads "${s.input}", not the source or an earlier image step',
        );
      }
      if (!s.graph.isVideo) images.add(s.id);
      if (s.graph == RenderGraph.kontextEdit) {
        // Masks are made on the source; only an edit keeps its geometry.
        if (!edits.contains(s.input)) {
          throw ArgumentError(
            'step "${s.id}": the mask does not fit the output of "${s.input}"',
          );
        }
        edits.add(s.id);
      }
      if ((s.graph == RenderGraph.kontextEdit) != (s.mask != null)) {
        throw ArgumentError(
          'step "${s.id}": a mask belongs on kontext_edit and nowhere else',
        );
      }
      if ((s.medium != null) != (s.graph == RenderGraph.restyleSdxl)) {
        throw ArgumentError('step "${s.id}": medium belongs on restyle_sdxl');
      }
      if (s.graph.isVideo != (s.motion != null)) {
        throw ArgumentError(
          'step "${s.id}": motion belongs on the video graphs and nowhere else',
        );
      }
      if (!s.graph.isVideo && s.prompt.trim().isEmpty) {
        throw ArgumentError('step "${s.id}" has no prompt');
      }
    }
  }

  /// The `steps` array; what a project stores to run a plan again.
  List<Map<String, Object?>> toJson() => [for (final s in steps) s.toJson()];

  factory RenderPlan.fromJson(List<dynamic> json) => RenderPlan([
    for (final s in json) RenderStep.fromJson((s as Map).cast()),
  ]);

  /// Full body of `POST /api/render`.
  Map<String, Object?> toRequest(Uint8List source) => {
    'source': base64Encode(source),
    'steps': toJson(),
  };
}
