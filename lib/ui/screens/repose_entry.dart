// Platform seam for the Repose screen. The real screen (and through it
// repose_provider → comfy_image_service → dart:io/cronet_http) never enters
// the web import graph; web gets an inert stub it also never navigates to.
export 'repose_screen.dart'
    if (dart.library.js_interop) 'repose_screen_stub.dart';
