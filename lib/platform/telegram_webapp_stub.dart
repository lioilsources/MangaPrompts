class TelegramWebApp {
  /// True when the Telegram Mini App SDK is loaded (web inside Telegram only).
  static bool get isAvailable => false;

  /// Raw signed init data from Telegram; empty outside a Mini App context.
  static String get initData => '';

  static void ready() {}

  static void expand() {}

  static void disableVerticalSwipes() {}

  /// Opens a Telegram Stars invoice; resolves with the final status
  /// ('paid' / 'cancelled' / 'failed' / 'pending' / 'unavailable').
  static Future<String> openInvoice(String url) async => 'unavailable';
}
