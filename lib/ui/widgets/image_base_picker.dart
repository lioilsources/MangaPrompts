import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/api_provider.dart';
import '../../providers/selection_provider.dart';

class ImageBasePicker extends ConsumerWidget {
  const ImageBasePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(baseImagePathProvider);

    if (imagePath != null) {
      return GestureDetector(
        onTap: () => _showOptions(context, ref),
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  File(imagePath),
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Base obrázek vybrán',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () =>
                    ref.read(baseImagePathProvider.notifier).state = null,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: OutlinedButton.icon(
        onPressed: () => _showOptions(context, ref),
        icon: const Icon(Icons.add_photo_alternate, size: 18),
        label: const Text('Base obrázek (volitelné)'),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Vybrat z galerie'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ref, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Vyfotit'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ref, ImageSource.camera);
              },
            ),
            if (ref.read(baseImagePathProvider) != null)
              ListTile(
                leading: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                title: Text('Odebrat',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(baseImagePathProvider.notifier).state = null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(WidgetRef ref, ImageSource source) async {
    final imageService = ref.read(imageServiceProvider);
    final file = await imageService.pickImage(source: source);
    if (file != null) {
      ref.read(baseImagePathProvider.notifier).state = file.path;
    }
  }
}
