import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/block_loader.dart';
import '../config/models/block_category.dart';
import '../config/models/prompt_template.dart';
import '../config/models/preset.dart';

final categoriesProvider = FutureProvider<List<BlockCategory>>((ref) async {
  return BlockLoader.loadAllCategories();
});

final templatesProvider = FutureProvider<List<PromptTemplate>>((ref) async {
  return BlockLoader.loadTemplates();
});

final presetsProvider = FutureProvider<List<Preset>>((ref) async {
  return BlockLoader.loadPresets();
});

/// Map of category name -> BlockCategory for quick lookup
final categoryMapProvider = Provider<AsyncValue<Map<String, BlockCategory>>>((ref) {
  return ref.watch(categoriesProvider).whenData((categories) {
    return {for (final c in categories) c.category: c};
  });
});
