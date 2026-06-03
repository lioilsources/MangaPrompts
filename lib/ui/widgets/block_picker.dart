import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/models/block_category.dart';
import '../../providers/selection_provider.dart';
import '../../services/prompt_engine.dart';
import '../../providers/blocks_provider.dart';

class BlockPicker extends ConsumerWidget {
  final BlockCategory category;

  const BlockPicker({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(selectionProvider);
    final selectedIds = selections[category.category] ?? [];
    final allSelections = ref.watch(selectionProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);

    final selectedLabels = category.blocks
        .where((b) => selectedIds.contains(b.id))
        .map((b) => b.label)
        .join(', ');

    return ExpansionTile(
      leading: Icon(
        _getIcon(category.icon),
        size: 20,
        color: selectedIds.isNotEmpty
            ? Theme.of(context).colorScheme.primary
            : category.isRequired
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Row(
        children: [
          Text(
            category.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: category.isRequired
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
          if (category.isRequired)
            Text(
              ' *',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (selectedIds.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => ref
                  .read(selectionProvider.notifier)
                  .clearCategory(category.category),
              child: Icon(
                Icons.clear,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      subtitle: selectedLabels.isNotEmpty
          ? Text(
              selectedLabels,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      initiallyExpanded: category.isRequired,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: category.blocks.map((block) {
              final isSelected = selectedIds.contains(block.id);
              final categoryMap = categoryMapAsync.whenOrNull(data: (map) => map);
              final conflicts = categoryMap != null
                  ? PromptEngine.getIncompatibleBlocks(
                      block, allSelections, categoryMap)
                  : <String>[];
              final hasConflict = conflicts.isNotEmpty;

              return FilterChip(
                label: Text(
                  block.label,
                  style: TextStyle(
                    fontSize: 13,
                    decoration: hasConflict ? TextDecoration.lineThrough : null,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(selectionProvider.notifier)
                      .toggleBlock(category.category, block.id);
                  ref.read(permutationIndexProvider.notifier).state = 0;
                },
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                tooltip: block.value,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person;
      case 'public':
        return Icons.public;
      case 'accessibility':
        return Icons.accessibility;
      case 'palette':
      case 'brush':
        return Icons.palette;
      case 'face':
        return Icons.face;
      case 'visibility':
        return Icons.visibility;
      case 'content_cut':
        return Icons.content_cut;
      case 'mood':
      case 'sentiment_satisfied':
        return Icons.mood;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'checkroom':
        return Icons.checkroom;
      case 'light_mode':
      case 'lightbulb':
        return Icons.light_mode;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'landscape':
      case 'wallpaper':
        return Icons.landscape;
      case 'camera_alt':
      case 'photo_camera':
        return Icons.camera_alt;
      case 'color_lens':
        return Icons.color_lens;
      case 'high_quality':
      case 'hd':
        return Icons.high_quality;
      case 'block':
      case 'do_not_disturb':
        return Icons.block;
      case 'face_retouching_natural':
        return Icons.face_retouching_natural;
      default:
        return Icons.category;
    }
  }
}
