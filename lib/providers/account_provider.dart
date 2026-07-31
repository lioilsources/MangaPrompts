import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/telegram_backend_service.dart';

/// Credit balance + free quota + price list from the bot backend.
/// Only watched on web (Telegram Mini App); invalidate to refresh after
/// a payment or a finished generation.
final accountProvider = FutureProvider<TgAccount>((ref) {
  return TelegramBackendService.fetchAccount();
});
