import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/blocks_provider.dart';
import '../../providers/selection_provider.dart';

class PresetsScreen extends ConsumerWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(presetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Presety')),
      body: presetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Chyba: $e')),
        data: (presets) => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: presets.length,
          itemBuilder: (context, index) {
            final preset = presets[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text(preset.label),
                subtitle: Text(
                  preset.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ref.read(selectionProvider.notifier).loadPreset(preset);
                  ref.read(activeTemplateIdProvider.notifier).state =
                      preset.template;
                  ref.read(permutationIndexProvider.notifier).state = 0;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Preset "${preset.label}" načten'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
