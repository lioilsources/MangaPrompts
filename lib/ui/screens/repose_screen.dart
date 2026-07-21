import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/api_provider.dart';
import '../../providers/repose_provider.dart';
import '../../services/image_generation_service.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

/// Standalone "Repose" mode: upload a face, pick a pose depth template,
/// write prompt + NEGATIVE, generate an image of that person in that pose.
class ReposeScreen extends ConsumerStatefulWidget {
  const ReposeScreen({super.key});

  @override
  ConsumerState<ReposeScreen> createState() => _ReposeScreenState();
}

class _ReposeScreenState extends ConsumerState<ReposeScreen> {
  late final TextEditingController _promptCtl;
  late final TextEditingController _negCtl;
  bool _isGenerating = false;

  /// Bundled pose depth templates (assets/poses/pose_depth/N.png).
  static const _poseCount = 7;
  static String _poseAsset(int n) => 'assets/poses/pose_depth/$n.png';

  @override
  void initState() {
    super.initState();
    _promptCtl = TextEditingController(text: ref.read(reposePromptProvider));
    _negCtl = TextEditingController(text: ref.read(reposeNegativeProvider));
  }

  @override
  void dispose() {
    _promptCtl.dispose();
    _negCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facePath = ref.watch(faceImagePathProvider);
    final poseAsset = ref.watch(reposePoseAssetProvider);
    final canGenerate =
        facePath != null && poseAsset != null && !_isGenerating;

    return Scaffold(
      appBar: AppBar(title: const Text('Repose — obličej v póze')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _sectionTitle(context, 'Model'),
          _modelDropdown(context),
          const SizedBox(height: 24),
          _sectionTitle(context, '1. Obličej'),
          _facePicker(context, facePath),
          const SizedBox(height: 24),
          _sectionTitle(context, '2. Póza'),
          _poseGrid(context, poseAsset),
          const SizedBox(height: 24),
          _sectionTitle(context, '3. Prompt'),
          TextField(
            controller: _promptCtl,
            minLines: 2,
            maxLines: 4,
            onChanged: (v) => ref.read(reposePromptProvider.notifier).state = v,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'photo of a woman, full body, natural light…',
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle(context, 'NEGATIVE'),
          TextField(
            controller: _negCtl,
            minLines: 2,
            maxLines: 4,
            onChanged: (v) => ref.read(reposeNegativeProvider.notifier).state = v,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canGenerate ? _generate : null,
        backgroundColor: canGenerate ? null : Theme.of(context).disabledColor,
        icon: _isGenerating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_isGenerating ? 'Generuji…' : 'Generovat'),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _modelDropdown(BuildContext context) {
    final async = ref.watch(availableCheckpointsProvider);
    final selected = ref.watch(reposeCheckpointProvider);
    return async.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(
        'Nelze načíst modely: $e',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const Text('Žádné modely (zkontroluj CF creds v Nastavení).');
        }
        final value = list.contains(selected) ? selected : list.first;
        if (value != selected) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => ref.read(reposeCheckpointProvider.notifier).state = value,
          );
        }
        return DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: [
            for (final c in list)
              DropdownMenuItem(
                value: c,
                child: Text(c, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) {
            if (v != null) {
              ref.read(reposeCheckpointProvider.notifier).state = v;
            }
          },
        );
      },
    );
  }

  Widget _facePicker(BuildContext context, String? facePath) {
    if (facePath == null) {
      return OutlinedButton.icon(
        onPressed: () => _showFaceOptions(context),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Nahrát obličej'),
      );
    }
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(facePath),
              width: 72, height: 72, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showFaceOptions(context),
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text('Změnit obličej'),
          ),
        ),
      ],
    );
  }

  Widget _poseGrid(BuildContext context, String? selected) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(_poseCount, (i) {
        final asset = _poseAsset(i + 1);
        final isSel = asset == selected;
        final primary = Theme.of(context).colorScheme.primary;
        return GestureDetector(
          onTap: () => ref.read(reposePoseAssetProvider.notifier).state = asset,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(asset, fit: BoxFit.cover),
              ),
              // selection overlay drawn OVER the image (border + tint)
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSel ? primary : Theme.of(context).dividerColor,
                    width: isSel ? 4 : 1,
                  ),
                  color: isSel ? primary.withValues(alpha: 0.22) : null,
                ),
              ),
              if (isSel)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(Icons.check_circle, size: 22, color: primary),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  void _showFaceOptions(BuildContext context) {
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
                _pickFace(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Vyfotit'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFace(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFace(ImageSource source) async {
    final file = await ref.read(imageServiceProvider).pickImage(source: source);
    if (file != null) {
      ref.read(faceImagePathProvider.notifier).state = file.path;
    }
  }

  Future<void> _generate() async {
    final service = ref.read(reposeServiceProvider);
    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nastav Cloudflare Access údaje v nastavení'),
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
    final facePath = ref.read(faceImagePathProvider);
    final poseAsset = ref.read(reposePoseAssetProvider);
    if (facePath == null || poseAsset == null) return;

    setState(() => _isGenerating = true);
    try {
      final faceBytes = await File(facePath).readAsBytes();
      final poseData = await rootBundle.load(poseAsset);
      final poseBytes = poseData.buffer.asUint8List();
      final prompt = _promptCtl.text.trim();

      final GeneratedImage result = await service.generateRepose(
        prompt: prompt,
        negativePrompt: _negCtl.text.trim(),
        faceBytes: faceBytes,
        poseBytes: poseBytes,
        checkpoint: ref.read(reposeCheckpointProvider),
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imageUrl: result.url,
              prompt: prompt,
              revisedPrompt: result.revisedPrompt,
              localImagePath: result.localPath,
            ),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('[Repose] Exception: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Chyba: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}
