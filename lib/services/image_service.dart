import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final xfile = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (xfile == null) return null;
    return File(xfile.path);
  }

  Future<String> imageToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  String getMimeType(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<File> downloadImage(String url) async {
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
    return file;
  }

  Future<void> saveToGallery(String filePath) async {
    await Gal.putImage(filePath, album: 'MangaPrompts');
  }
}
