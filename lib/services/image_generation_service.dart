import 'dart:typed_data';

/// Shared result type and abstract interface for image generation backends.
class GeneratedImage {
  final String url;
  final String revisedPrompt;
  /// Local temp file path — set by backends that return raw bytes (ol1n).
  /// When non-null, home_screen skips the network download step.
  final String? localPath;
  /// Raw image bytes — set by backends that can't touch the filesystem (web).
  final Uint8List? bytes;

  const GeneratedImage({
    required this.url,
    this.revisedPrompt = '',
    this.localPath,
    this.bytes,
  });
}

abstract class ImageGenerationService {
  Future<GeneratedImage> generateImage({
    required String prompt,
    String negativePrompt = '',
  });
  Future<GeneratedImage> editImage({
    required String prompt,
    required String base64Image,
    String negativePrompt = '',
    String mimeType = 'image/jpeg',
  });
}
