// Platform seam for image-generation backends.
//
// Native builds (io) expose the full xAI / ol1n / ComfyUI switch including the
// baked `Secrets` fallback; the web build compiles none of that (no dart:io,
// no cronet_http, no secrets in the JS bundle) and always talks to the
// Telegram bot backend instead.
export 'backend_factory_stub.dart'
    if (dart.library.io) 'backend_factory_io.dart'
    if (dart.library.js_interop) 'backend_factory_web.dart';
