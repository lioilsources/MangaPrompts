import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/api_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final String imageUrl;
  final String prompt;
  final String revisedPrompt;
  final String? localImagePath;

  const ResultScreen({
    super.key,
    required this.imageUrl,
    required this.prompt,
    this.revisedPrompt = '',
    this.localImagePath,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  String? _localPath;
  bool _isSaving = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _localPath = widget.localImagePath;
    if (_localPath == null) {
      _downloadToTemp();
    }
  }

  Future<void> _downloadToTemp() async {
    setState(() => _isDownloading = true);
    try {
      final imageService = ref.read(imageServiceProvider);
      final file = await imageService.downloadImage(widget.imageUrl);
      if (mounted) {
        setState(() {
          _localPath = file.path;
          _isDownloading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _saveToGallery() async {
    final path = _localPath;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obrázek ještě nebyl stažen')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final imageService = ref.read(imageServiceProvider);
      await imageService.saveToGallery(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uloženo do galerie'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nepodařilo se uložit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Výsledek'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt),
            tooltip: 'Uložit do galerie',
            onPressed: (_isSaving || _localPath == null) ? null : _saveToGallery,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Kopírovat prompt',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.prompt));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prompt zkopírován'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Generated image — prefer local file, fallback to network URL
            AspectRatio(
              aspectRatio: 1,
              child: _localPath != null
                  ? Image.file(
                      File(_localPath!),
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, __) =>
                          widget.imageUrl.isNotEmpty
                              ? _networkImage()
                              : _errorWidget('$error'),
                    )
                  : widget.imageUrl.isNotEmpty
                      ? _networkImage()
                      : _errorWidget('Obrázek není k dispozici'),
            ),
            if (_isDownloading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: LinearProgressIndicator(),
              ),
            // Prompt used
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Použitý prompt:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      widget.prompt,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  if (widget.revisedPrompt.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Revidovaný prompt (Grok):',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        widget.revisedPrompt,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _networkImage() {
    return Image.network(
      widget.imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded /
                    progress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (_, error, __) =>
          _errorWidget('Nepodařilo se načíst: $error'),
    );
  }

  Widget _errorWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}
