import '../config/models/block.dart';
import '../config/models/block_category.dart';
import '../config/models/prompt_template.dart';

class PromptEngine {
  /// Build a single prompt from selected blocks using the template slot order.
  /// [selections] maps category -> single Block for this particular permutation.
  static String buildPrompt({
    required PromptTemplate template,
    required Map<String, Block> selections,
  }) {
    final parts = <String>[];

    for (final category in template.slotOrder) {
      final block = selections[category];
      if (block != null && block.value.isNotEmpty) {
        parts.add(block.value);
      }
    }

    // Append negative prompt at the end if selected
    final negativeBlock = selections[template.negativeSlot];
    if (negativeBlock != null && negativeBlock.value.isNotEmpty) {
      parts.add(negativeBlock.value);
    }

    return parts.join(template.separator);
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
