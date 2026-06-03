import '../config/models/block.dart';
import '../config/models/block_category.dart';
import '../config/models/prompt_template.dart';

// Single-person detail slots. Dropped for group subjects so they don't fight
// the group composition signal.
const _individualDetailSlots = {'face', 'eyes', 'eyebrows', 'hair', 'body_type'};

// Slots that only make sense for a photographic medium.
const _photoOnlySlots = {'camera'};

class PromptEngine {

  /// Build the positive prompt from selected blocks using the template slot order.
  ///
  /// The medium block (photoreal / anime / manga / comic) is the master axis and
  /// is front-loaded by the template. Every other block stays medium-agnostic;
  /// blocks that would contradict the chosen medium are gated out here so FLUX
  /// never receives conflicting "photo + manga" style signals.
  ///
  /// Negative prompt is kept separate — use [buildNegativePrompt] and pass it as
  /// a dedicated API field so it does not dilute the positive signal.
  static String buildPrompt({
    required PromptTemplate template,
    required Map<String, Block> selections,
  }) {
    final parts = <String>[];

    final isPhotoreal = _isPhotoreal(selections);
    final hasMedium = selections['medium'] != null;
    final isGroupSubject =
        selections['subject']?.tags.contains('group') ?? false;

    for (final category in template.slotOrder) {
      // Drop single-person detail slots for group subjects.
      if (isGroupSubject && _individualDetailSlots.contains(category)) continue;

      // Camera (and any other photo-only slot) is meaningless for illustration.
      if (hasMedium && !isPhotoreal && _photoOnlySlots.contains(category)) {
        continue;
      }

      final block = selections[category];
      if (block == null || block.value.isEmpty) continue;
      if (!_blockMatchesMedium(block, isPhotoreal, hasMedium)) continue;

      parts.add(block.value);
    }

    return parts.join(template.separator);
  }

  /// Extract the negative prompt text for use as a separate API field.
  ///
  /// Medium-specific guards (tagged `photo_only` / `illustration_only`) are
  /// dropped when they would fight the chosen medium — e.g. a "no anime" guard
  /// is removed for an anime render.
  ///
  /// Do NOT append this to the positive prompt — on distilled FLUX (CFG ≈ 1)
  /// it has no effect there and can attract the unwanted content instead.
  static String buildNegativePrompt({
    required PromptTemplate template,
    required Map<String, Block> selections,
  }) {
    final negativeBlock = selections[template.negativeSlot];
    if (negativeBlock == null || negativeBlock.value.isEmpty) return '';

    final isPhotoreal = _isPhotoreal(selections);
    final hasMedium = selections['medium'] != null;
    if (!_blockMatchesMedium(negativeBlock, isPhotoreal, hasMedium)) return '';

    return negativeBlock.value;
  }

  /// True when the selected medium is photographic.
  static bool _isPhotoreal(Map<String, Block> selections) {
    return selections['medium']?.tags.contains('photoreal') ?? false;
  }

  /// Whether a block's medium-affinity tags are compatible with the active medium.
  ///
  /// - `photo_only`         → only when photoreal
  /// - `illustration_only`  → only when NOT photoreal (and a medium is chosen)
  /// - `manga_fx`           → ink/manga drawing effects, dropped for photoreal
  static bool _blockMatchesMedium(Block block, bool isPhotoreal, bool hasMedium) {
    if (block.tags.contains('photo_only') && hasMedium && !isPhotoreal) {
      return false;
    }
    if (block.tags.contains('illustration_only') && isPhotoreal) {
      return false;
    }
    if (block.tags.contains('manga_fx') && isPhotoreal) {
      return false;
    }
    return true;
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
