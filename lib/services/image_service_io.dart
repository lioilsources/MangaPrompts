import 'dart:convert';
import 'dart:io';

import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'image_service.dart';

ImageService createImageService() => IoImageService();

class IoImageService implements ImageService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickImagePath({
    ImageSource source = ImageSource.gallery,
  }) async {
    final xfile = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    return xfile?.path;
  }

  @override
  Future<String> imageToBase64FromPath(String path) async {
    final bytes = await File(path).readAsBytes();
    return base64Encode(bytes);
  }

  @override
  String getMimeTypeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  @override
  Future<String> downloadImageToPath(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Stažení selhalo (${response.statusCode})');
    }
    final tempDir = await getTemporaryDirectory();
    await tempDir.create(recursive: true);
    final file = File(
      '${tempDir.path}/manga_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  @override
  Future<void> saveToGallery(String filePath) async {
    await Gal.putImage(filePath, album: 'Tsumiki');
  }
}
