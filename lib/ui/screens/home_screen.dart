import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/blocks_provider.dart';
import '../../providers/selection_provider.dart';
import '../../providers/prompt_provider.dart';
import '../../providers/api_provider.dart';
import '../../providers/account_provider.dart';
import '../../services/image_generation_service.dart';
import '../../services/telegram_backend_service.dart';
import '../widgets/block_picker.dart';
import '../widgets/prompt_preview.dart';
import '../widgets/image_base_picker.dart';
import '../widgets/paywall_sheet.dart';
import 'result_screen.dart';
import 'settings_screen.dart';
import 'presets_screen.dart';
import 'repose_entry.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isGenerating = false;

  /// The block list is long and, inside a Telegram Mini App, dragging *down*
  /// is claimed by Telegram's collapse gesture — so scrolling back up by hand
  /// is the awkward direction. This jumps there instead.
  final _scrollController = ScrollController();
  bool _showTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final show = _scrollController.offset > 320;
    if (show != _showTopButton) setState(() => _showTopButton = show);
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final templatesAsync = ref.watch(templatesProvider);
    final activeTemplateAsync = ref.watch(activeTemplateProvider);
    final activeTemplateId = ref.watch(activeTemplateIdProvider);
    final prompt = ref.watch(currentPromptProvider);
    final apiService = ref.watch(activeImageServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tsumiki'),
        actions: [
          if (kIsWeb) _creditsChip(),
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.accessibility_new),
              tooltip: 'Repose (face in a pose)',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReposeScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            tooltip: 'Presets',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PresetsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) => Column(
          children: [
            // Template selector
            templatesAsync.when(
              data: (templates) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: activeTemplateId,
                  decoration: const InputDecoration(
                    labelText: 'Template',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: templates
                      .map(
                        (t) =>
                            DropdownMenuItem(value: t.id, child: Text(t.label)),
                      )
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
            // Base image picker (img2img is not available on web yet)
            if (!kIsWeb) ...[
              const ImageBasePicker(),
              const SizedBox(height: 8),
            ],
            // Block pickers list
            Expanded(
              child: Stack(
                children: [
                  // The docked "nahoru" button sits over the list rather than
                  // in the FAB slot, which the Generovat button already owns.
                  Positioned.fill(
                    child: activeTemplateAsync.when(
                      data: (template) {
                        final orderedCategories = <dynamic>[];
                        for (final slot in template.slotOrder) {
                          final cat = categories
                              .where((c) => c.category == slot)
                              .firstOrNull;
                          if (cat != null) orderedCategories.add(cat);
                        }
                        final negCat = categories
                            .where((c) => c.category == template.negativeSlot)
                            .firstOrNull;
                        if (negCat != null) orderedCategories.add(negCat);

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: orderedCategories.length,
                          itemBuilder: (context, index) {
                            return BlockPicker(
                              category: orderedCategories[index],
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => ListView.builder(
                        controller: _scrollController,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return BlockPicker(category: categories[index]);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: AnimatedOpacity(
                      opacity: _showTopButton ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: IgnorePointer(
                        ignoring: !_showTopButton,
                        child: FloatingActionButton.small(
                          heroTag: 'scrollTop',
                          tooltip: 'Back to top',
                          onPressed: _scrollToTop,
                          child: const Icon(Icons.keyboard_double_arrow_up),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Prompt preview
            const PromptPreview(),
          ],
        ),
      ),
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
        label: Text(_isGenerating ? 'Generating…' : 'Generate'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _creditsChip() {
    final account = ref.watch(accountProvider);
    final label = account.when(
      data: (a) => '⚡ ${a.totalRemaining}',
      loading: () => '⚡ …',
      error: (_, _) => '⚡ ?',
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: ActionChip(
          label: Text(label),
          visualDensity: VisualDensity.compact,
          tooltip: 'Credits and packages',
          onPressed: () => PaywallSheet.show(context),
        ),
      ),
    );
  }

  Future<void> _generate(
    BuildContext context,
    WidgetRef ref,
    String prompt,
    ImageGenerationService? apiService,
  ) async {
    if (apiService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Set an API key or credentials in Settings',
          ),
          action: SnackBarAction(
            label: 'Settings',
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
      final negativePrompt = ref.read(currentNegativePromptProvider);
      GeneratedImage result;

      if (baseImagePath != null) {
        final imageService = ref.read(imageServiceProvider);
        final base64 = await imageService.imageToBase64FromPath(baseImagePath);
        final mimeType = imageService.getMimeTypeFromPath(baseImagePath);
        result = await apiService.editImage(
          prompt: prompt,
          negativePrompt: negativePrompt,
          base64Image: base64,
          mimeType: mimeType,
        );
      } else {
        result = await apiService.generateImage(
          prompt: prompt,
          negativePrompt: negativePrompt,
        );
      }

      // ol1n service downloads directly to a temp file; xAI returns a URL.
      String? localPath = result.localPath;
      if (!kIsWeb && localPath == null && result.url.isNotEmpty) {
        try {
          final imgService = ref.read(imageServiceProvider);
          localPath = await imgService.downloadImageToPath(result.url);
        } catch (e) {
          print('[Generate] Download to temp failed: $e');
        }
      }

      if (kIsWeb) ref.invalidate(accountProvider);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imageUrl: result.url,
              prompt: prompt,
              revisedPrompt: result.revisedPrompt,
              localImagePath: localPath,
              imageBytes: result.bytes,
            ),
          ),
        );
      }
    } on PaymentRequiredException {
      if (mounted) {
        ref.invalidate(accountProvider);
        PaywallSheet.show(context);
      }
    } catch (e, stack) {
      print('[Generate] Exception: $e');
      print('[Generate] Stack: $stack');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
