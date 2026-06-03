import '../config/models/block.dart';
import '../config/models/block_category.dart';
import '../config/models/prompt_template.dart';

// Poses that carry their own framing — full body injection is skipped for these.
const _portraitFramingPoseIds = {
  'pose_close_up_portrait',
  'pose_bust_shot',
  'pose_cowboy_shot',
  'pose_selfie',
};

// Full-body framing injected at the start of every non-portrait prompt.
// Repeated / front-loaded because FLUX weights early tokens more heavily.
const _fullBodyFraming =
    'full body photograph, head-to-toe framing, entire figure visible, wide shot, '
    'subject centered, full body within frame, feet visible, '
    'ample space above and below, shot from across the room, '
    'photographer standing back, wide framing';

// Individual-detail category slots that describe a single person.
// Skipped when a group subject is selected to avoid signal dilution.
const _individualDetailSlots = {'face', 'eyes', 'eyebrows', 'hair', 'body_type'};

class PromptEngine {

  /// Build the positive prompt from selected blocks using the template slot order.
  /// Negative prompt is kept separate — use [buildNegativePrompt] and pass it
  /// as a dedicated API field so it does not dilute the positive signal.
  static String buildPrompt({
    required PromptTemplate template,
    required Map<String, Block> selections,
  }) {
    final parts = <String>[];

    // Inject full-body framing unless a portrait-framing pose is explicitly chosen.
    final poseBlock = selections['pose'];
    final isPortraitFraming =
        poseBlock != null && _portraitFramingPoseIds.contains(poseBlock.id);
    if (!isPortraitFraming) {
      parts.add(_fullBodyFraming);
    }

    // When subject is a group, skip individual-detail slots — they describe a
    // single person and will contradict the group composition signal.
    final subjectBlock = selections['subject'];
    final isGroupSubject = subjectBlock?.tags.contains('group') ?? false;

    for (final category in template.slotOrder) {
      if (isGroupSubject && _individualDetailSlots.contains(category)) continue;
      final block = selections[category];
      if (block != null && block.value.isNotEmpty) {
        parts.add(block.value);
      }
    }

    return parts.join(template.separator);
  }

  /// Extract the negative prompt text for use as a separate API field.
  /// Do NOT append this to the positive prompt — on distilled FLUX (CFG ≈ 1)
  /// it has no effect there and can attract the unwanted content instead.
  static String buildNegativePrompt({
    required PromptTemplate template,
    required Map<String, Block> selections,
  }) {
    final negativeBlock = selections[template.negativeSlot];
    if (negativeBlock != null && negativeBlock.value.isNotEmpty) {
      return negativeBlock.value;
    }
    return '';
  }

  /// Generate all permutations from multi-selections.
  /// [multiSelections] maps category -> list of block IDs
  /// Returns list of single-selection maps (category -> single block ID)
  static List<Map<String, String>> generatePermutations(
    Map<String, List<String>> multiSelections,
  ) {
    final categories = multiSelections.entries
        .where((e) => e.value.isNotEmpty)
        .toList();

    if (categories.isEmpty) return [];

    List<Map<String, String>> results = [{}];

    for (final entry in categories) {
      final category = entry.key;
      final blockIds = entry.value;
      final newResults = <Map<String, String>>[];

      for (final existing in results) {
        for (final blockId in blockIds) {
          newResults.add({...existing, category: blockId});
        }
      }

      results = newResults;
    }

    return results;
  }

  /// Count total permutations without generating them
  static int countPermutations(Map<String, List<String>> multiSelections) {
    int count = 1;
    for (final blockIds in multiSelections.values) {
      if (blockIds.isNotEmpty) {
        count *= blockIds.length;
      }
    }
    return multiSelections.values.any((v) => v.isNotEmpty) ? count : 0;
  }

  /// Check if a block is compatible with current selections
  static List<String> getIncompatibleBlocks(
    Block candidate,
    Map<String, List<String>> currentSelections,
    Map<String, BlockCategory> categoryMap,
  ) {
    final conflicts = <String>[];

    for (final entry in currentSelections.entries) {
      for (final selectedId in entry.value) {
        if (candidate.incompatible.contains(selectedId)) {
          conflicts.add(selectedId);
        }
      }
    }

    return conflicts;
  }
}
