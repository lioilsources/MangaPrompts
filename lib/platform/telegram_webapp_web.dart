import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

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
  external void disableVerticalSwipes();
  external void openInvoice(String url, JSFunction callback);
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

  /// Stops Telegram from reading a downward drag inside the app as the
  /// collapse/close gesture, which otherwise fights every attempt to scroll
  /// the content back up. Bot API 7.7+; older clients simply do not have the
  /// method, so probe before calling.
  static void disableVerticalSwipes() {
    final wa = _wa;
    if (wa == null) return;
    if (!wa.has('disableVerticalSwipes')) return;
    wa.disableVerticalSwipes();
  }

  /// Opens a Telegram Stars invoice; resolves with the final status
  /// ('paid' / 'cancelled' / 'failed' / 'pending' / 'unavailable').
  static Future<String> openInvoice(String url) {
    final wa = _wa;
    if (wa == null) return Future.value('unavailable');
    final completer = Completer<String>();
    wa.openInvoice(
      url,
      ((JSString status) {
        if (!completer.isCompleted) completer.complete(status.toDart);
      }).toJS,
    );
    return completer.future;
  }
}
