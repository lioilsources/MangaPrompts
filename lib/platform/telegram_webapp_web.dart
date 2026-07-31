import 'dart:js_interop';

@JS('Telegram')
external JSObject? get _telegram;

extension type _Telegram(JSObject _) implements JSObject {
  @JS('WebApp')
  external _WebApp? get webApp;
}

extension type _WebApp(JSObject _) implements JSObject {
  external String? get initData;
  external void ready();
  external void expand();
}

class TelegramWebApp {
  static _WebApp? get _wa {
    final t = _telegram;
    if (t == null) return null;
    return _Telegram(t).webApp;
  }

  /// True when the Telegram Mini App SDK is loaded (web inside Telegram only).
  static bool get isAvailable => _wa != null;

  /// Raw signed init data from Telegram; empty outside a Mini App context.
  static String get initData => _wa?.initData ?? '';

  static void ready() => _wa?.ready();

  static void expand() => _wa?.expand();
}
