// Platform seam for the Telegram Mini App JS SDK (telegram-web-app.js).
// Native builds get no-op stubs; the web build binds to `window.Telegram.WebApp`.
export 'telegram_webapp_stub.dart'
    if (dart.library.js_interop) 'telegram_webapp_web.dart';
