/// Motion presets of the living portrait (`09-PLAN-zivy-portret.md`). The
/// server resolves [Motion.id] to a driver clip or a Wan prompt
/// (`assets/drivers/manifest.json`); the app only offers what passed the
/// bench gate ([kMotions], `motions_catalog.dart`).
library;

import 'motions_catalog.dart';

export 'motions_catalog.dart' show kMotions;

enum MotionEngine {
  /// LivePortrait: seconds, cheap, `live_portrait` step.
  live,

  /// Wan via the video-api: minutes, `wan_motion` step.
  wan,
}

class Motion {
  const Motion({
    required this.id,
    required this.label,
    required this.cs,
    required this.seconds,
    required this.engine,
    required this.loop,
  });

  final String id;
  final String label;
  final String cs;
  final double seconds;
  final MotionEngine engine;

  /// The clip returns to its first frame, so it can repeat.
  final bool loop;
}

Motion? motionById(String? id) {
  if (id == null) return null;
  for (final m in kMotions) {
    if (m.id == id) return m;
  }
  return null;
}
