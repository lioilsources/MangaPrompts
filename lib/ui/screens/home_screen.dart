import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/blocks_provider.dart';
import '../../providers/selection_provider.dart';
import '../../providers/prompt_provider.dart';
import '../../providers/api_provider.dart';
import '../../services/xai_api_service.dart';
import '../widgets/block_picker.dart';
import '../widgets/prompt_preview.dart';
import '../widgets/image_base_picker.dart';
import 'result_screen.dart';
import 'settings_screen.dart';
import 'presets_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final templatesAsync = ref.watch(templatesProvider);
    final activeTemplateAsync = ref.watch(activeTemplateProvider);
    final activeTemplateId = ref.watch(activeTemplateIdProvider);
    final prompt = ref.watch(currentPromptProvider);
    final apiService = ref.watch(xaiApiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MangaPrompts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks),
            tooltip: 'Presety',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PresetsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Nastavení',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Chyba: $e')),
        data: (categories) => Column(
          children: [
            // Template selector
            templatesAsync.when(
              data: (templates) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  initialValue: activeTemplateId,
                  decoration: const InputDecoration(
                    labelText: 'Šablona',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: templates
                      .map((t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.label),
                          ))
                      .toList(),
                  onChanged: (id) {
                    if (id != null) {
                      ref.read(activeTemplateIdProvider.notifier).state = id;
                    }
                  },
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            // Base image picker
            const ImageBasePicker(),
            const SizedBox(height: 8),
            // Block pickers list
            Expanded(
              child: activeTemplateAsync.when(
                data: (template) {
                  // Show categories in template slot order
                  final orderedCategories = <dynamic>[];
                  for (final slot in template.slotOrder) {
                    final cat = categories
                        .where((c) => c.category == slot)
                        .firstOrNull;
                    if (cat != null) orderedCategories.add(cat);
                  }
                  // Also add negative slot
                  final negCat = categories
                      .where((c) => c.category == template.negativeSlot)
                      .firstOrNull;
                  if (negCat != null) orderedCategories.add(negCat);

                  return ListView.builder(
                    itemCount: orderedCategories.length,
                    itemBuilder: (context, index) {
                      return BlockPicker(category: orderedCategories[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return BlockPicker(category: categories[index]);
                  },
                ),
              ),
            ),
            // Prompt preview
            const PromptPreview(),
          ],
        ),
      ),
      // Generate button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (prompt.isEmpty || _isGenerating)
            ? null
            : () => _generate(context, ref, prompt, apiService),
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_isGenerating ? 'Generuji...' : 'Generovat'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _generate(
    BuildContext context,
    WidgetRef ref,
    String prompt,
    XaiApiService? apiService,
  ) async {
    if (apiService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nastav API klíč v nastavení'),
          action: SnackBarAction(
            label: 'Nastavení',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final baseImagePath = ref.read(baseImagePathProvider);
      GeneratedImage result;

      if (baseImagePath != null) {
        // Image-to-image
        final file = File(baseImagePath);
        final imageService = ref.read(imageServiceProvider);
        final base64 = await imageService.imageToBase64(file);
        final mimeType = imageService.getMimeType(file);
        result = await apiService.editImage(
          prompt: prompt,
          base64Image: base64,
          mimeType: mimeType,
        );
      } else {
        // Text-to-image
        result = await apiService.generateImage(prompt: prompt);
      }

      // Download to temp file as backup against URL expiration
      String? localPath;
      try {
        final imgService = ref.read(imageServiceProvider);
        final file = await imgService.downloadImage(result.url);
        localPath = file.path;
      } catch (e, stack) {
        print('[Generate] Download to temp failed: $e');
        print('[Generate] Stack: $stack');
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imageUrl: result.url,
              prompt: prompt,
              revisedPrompt: result.revisedPrompt,
              localImagePath: localPath,
            ),
          ),
        );
      }
    } on XaiApiException catch (e, stack) {
      print('[Generate] XaiApiException: $e');
      print('[Generate] Stack: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API chyba (${e.statusCode}): ${e.message}')),
        );
      }
    } catch (e, stack) {
      print('[Generate] Exception: $e');
      print('[Generate] Type: ${e.runtimeType}');
      print('[Generate] Stack: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba [${e.runtimeType}]: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
