import 'package:image_picker/image_picker.dart';

import 'image_service.dart';

ImageService createImageService() => _UnsupportedImageService();

class _UnsupportedImageService implements ImageService {
  Never _unsupported() =>
      throw UnsupportedError('Práce s lokálními soubory není na webu podporována');

  @override
  Future<String?> pickImagePath({ImageSource source = ImageSource.gallery}) =>
      _unsupported();

  @override
  Future<String> imageToBase64FromPath(String path) => _unsupported();

  @override
  String getMimeTypeFromPath(String path) => _unsupported();

  @override
  Future<String> downloadImageToPath(String url) => _unsupported();

  @override
  Future<void> saveToGallery(String filePath) => _unsupported();
}
