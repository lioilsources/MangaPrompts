import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/telegram_backend_service.dart';

/// Animation preset catalog from the bot backend (which proxies the video-api
/// on SPARK). Error state means the feature is hidden — same behavior as
/// Ol1nLLM's studio, where the button disappears when the catalog is empty.
final videoScenesProvider = FutureProvider<List<TgVideoScene>>((ref) {
  return TelegramBackendService.fetchVideoScenes();
});
