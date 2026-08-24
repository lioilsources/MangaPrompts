import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/api_provider.dart';
import 'image_generation_service.dart';
import 'telegram_backend_service.dart';

/// Web (Telegram Mini App) always generates through the bot backend; the
/// xAI / ol1n / ComfyUI direct clients never enter the web import graph.
ImageGenerationService? createActiveImageService(Ref ref) {
  final workflow = ref.watch(effectiveWorkflowProvider);
  return TelegramBackendService(workflow: workflow);
}
