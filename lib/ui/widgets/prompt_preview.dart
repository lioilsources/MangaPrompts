import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/prompt_provider.dart';
import '../../providers/selection_provider.dart';

class PromptPreview extends ConsumerWidget {
  const PromptPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = ref.watch(currentPromptProvider);
    final permCount = ref.watch(permutationCountProvider);
    final permIndex = ref.watch(permutationIndexProvider);

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with copy button and permutation nav
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
            child: Row(
              children: [
                Icon(
                  Icons.text_snippet,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Prompt',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (permCount > 1) ...[
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: permIndex > 0
                        ? () => ref
                            .read(permutationIndexProvider.notifier)
                            .state--
                        : null,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  Text(
                    '${permIndex + 1}/$permCount',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: permIndex < permCount - 1
                        ? () => ref
                            .read(permutationIndexProvider.notifier)
                            .state++
                        : null,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: prompt.isNotEmpty
                      ? () {
                          Clipboard.setData(ClipboardData(text: prompt));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Prompt zkopírován'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      : null,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Kopírovat prompt',
                ),
              ],
            ),
          ),
          // Prompt text
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Text(
              prompt.isEmpty ? 'Vyber kostičky pro sestavení promptu...' : prompt,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: prompt.isEmpty
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : null,
              ),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
