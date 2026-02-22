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

/// Current prompt text for the active permutation index
final currentPromptProvider = Provider<String>((ref) {
  final templateAsync = ref.watch(activeTemplateProvider);
  final categoriesAsync = ref.watch(categoriesProvider);
  final permutations = ref.watch(allPermutationsProvider);
  final index = ref.watch(permutationIndexProvider);

  return templateAsync.when(
    data: (template) {
      return categoriesAsync.when(
        data: (categories) {
          if (permutations.isEmpty) return '';

          final safeIndex = index.clamp(0, permutations.length - 1);
          final perm = permutations[safeIndex];

          // Resolve block IDs to Block objects
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

          return PromptEngine.buildPrompt(
            template: template,
            selections: blockMap,
          );
        },
        loading: () => '',
        error: (_, __) => '',
      );
    },
    loading: () => '',
    error: (_, __) => '',
  );
});
