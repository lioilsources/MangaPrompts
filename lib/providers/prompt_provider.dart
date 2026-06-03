import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/models/block.dart';
import '../config/models/prompt_template.dart';
import '../services/prompt_engine.dart';
import 'blocks_provider.dart';
import 'selection_provider.dart';

/// Active template object
final activeTemplateProvider = Provider<AsyncValue<PromptTemplate>>((ref) {
  final templateId = ref.watch(activeTemplateIdProvider);
  return ref.watch(templatesProvider).whenData((templates) {
    return templates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => templates.first,
    );
  });
});

/// Total number of permutations from current multi-selections
final permutationCountProvider = Provider<int>((ref) {
  final selections = ref.watch(selectionProvider);
  return PromptEngine.countPermutations(selections);
});

/// All permutation maps (category -> single blockId)
final allPermutationsProvider = Provider<List<Map<String, String>>>((ref) {
  final selections = ref.watch(selectionProvider);
  return PromptEngine.generatePermutations(selections);
});

Map<String, Block> _resolveBlocks(
  List<Map<String, String>> permutations,
  int index,
  List categories,
) {
  final safeIndex = index.clamp(0, permutations.length - 1);
  final perm = permutations[safeIndex];
  final blockMap = <String, Block>{};
  for (final entry in perm.entries) {
    for (final cat in categories) {
      for (final block in cat.blocks) {
        if (block.id == entry.value) {
          blockMap[entry.key] = block;
        }
      }
    }
  }
  return blockMap;
}

/// Current positive prompt text for the active permutation index.
final currentPromptProvider = Provider<String>((ref) {
  final templateAsync = ref.watch(activeTemplateProvider);
  final categoriesAsync = ref.watch(categoriesProvider);
  final permutations = ref.watch(allPermutationsProvider);
  final index = ref.watch(permutationIndexProvider);

  return templateAsync.when(
    data: (template) => categoriesAsync.when(
      data: (categories) {
        if (permutations.isEmpty) return '';
        final blockMap = _resolveBlocks(permutations, index, categories);
        return PromptEngine.buildPrompt(template: template, selections: blockMap);
      },
      loading: () => '',
      error: (_, _) => '',
    ),
    loading: () => '',
    error: (_, _) => '',
  );
});

/// Negative prompt text for the active permutation — passed as a separate API
/// field, NOT appended to the positive prompt.
final currentNegativePromptProvider = Provider<String>((ref) {
  final templateAsync = ref.watch(activeTemplateProvider);
  final categoriesAsync = ref.watch(categoriesProvider);
  final permutations = ref.watch(allPermutationsProvider);
  final index = ref.watch(permutationIndexProvider);

  return templateAsync.when(
    data: (template) => categoriesAsync.when(
      data: (categories) {
        if (permutations.isEmpty) return '';
        final blockMap = _resolveBlocks(permutations, index, categories);
        return PromptEngine.buildNegativePrompt(template: template, selections: blockMap);
      },
      loading: () => '',
      error: (_, _) => '',
    ),
    loading: () => '',
    error: (_, _) => '',
  );
});
