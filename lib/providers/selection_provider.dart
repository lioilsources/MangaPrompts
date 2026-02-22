import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/models/block.dart';
import '../config/models/preset.dart';
import 'blocks_provider.dart';

/// Currently active template ID
final activeTemplateIdProvider = StateProvider<String>((ref) {
  return 'template_portrait';
});

/// Current block selections: category -> list of selected block IDs
/// Multiple blocks per category enable permutations
class SelectionNotifier extends StateNotifier<Map<String, List<String>>> {
  SelectionNotifier() : super({});

  void toggleBlock(String category, String blockId) {
    final current = state[category] ?? [];
    if (current.contains(blockId)) {
      state = {
        ...state,
        category: current.where((id) => id != blockId).toList(),
      };
    } else {
      state = {
        ...state,
        category: [...current, blockId],
      };
    }
  }

  void setBlock(String category, String blockId) {
    state = {
      ...state,
      category: [blockId],
    };
  }

  void clearCategory(String category) {
    state = {...state, category: []};
  }

  void clearAll() {
    state = {};
  }

  void loadPreset(Preset preset) {
    state = preset.blocks.map((category, blockId) =>
        MapEntry(category, [blockId]));
  }
}

final selectionProvider =
    StateNotifierProvider<SelectionNotifier, Map<String, List<String>>>((ref) {
  return SelectionNotifier();
});

/// Currently selected base image path (null = text-to-image mode)
final baseImagePathProvider = StateProvider<String?>((ref) => null);

/// Permutation index for browsing through variants
final permutationIndexProvider = StateProvider<int>((ref) => 0);

/// Find Block object by its ID across all categories
final blockByIdProvider = Provider.family<Block?, String>((ref, blockId) {
  final categoriesAsync = ref.watch(categoriesProvider);
  return categoriesAsync.whenOrNull(data: (categories) {
    for (final cat in categories) {
      for (final block in cat.blocks) {
        if (block.id == blockId) return block;
      }
    }
    return null;
  });
});
