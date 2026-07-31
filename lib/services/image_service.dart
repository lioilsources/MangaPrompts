import 'package:image_picker/image_picker.dart';

import 'image_service_stub.dart'
    if (dart.library.io) 'image_service_io.dart'
    if (dart.library.js_interop) 'image_service_web.dart' as platform;

/// Local image handling (pick / temp download / gallery save), path-based so
/// callers never touch dart:io. The web MVP hides every feature that would
/// call this (base image picker, save to gallery), so its impl just throws.
abstract class ImageService {
  factory ImageService() => platform.createImageService();

  Future<String?> pickImagePath({ImageSource source = ImageSource.gallery});

  Future<String> imageToBase64FromPath(String path);

  String getMimeTypeFromPath(String path);

  /// Downloads [url] into a temp file and returns its path.
  Future<String> downloadImageToPath(String url);

  Future<void> saveToGallery(String filePath);
}
