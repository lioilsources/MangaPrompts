import 'dart:convert';
import 'package:http/http.dart' as http;
import 'image_generation_service.dart';

class XaiApiException implements Exception {
  final String message;
  final int? statusCode;
  XaiApiException(this.message, {this.statusCode});

  @override
  String toString() => 'XaiApiException($statusCode): $message';
}

class XaiApiService implements ImageGenerationService {
  static const _baseUrl = 'https://api.x.ai/v1';
  final String apiKey;

  XaiApiService({required this.apiKey});

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

  @override
  Future<GeneratedImage> generateImage({
    required String prompt,
    String negativePrompt = '',
    String model = 'grok-imagine-image',
    String aspectRatio = '1:1',
    String resolution = '2k',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/images/generations'),
      headers: _headers,
      body: jsonEncode({
        'model': model,
        'prompt': prompt,
        'aspect_ratio': aspectRatio,
        'resolution': resolution,
        // X.AI Grok does not currently expose a negative_prompt field.
      }),
    );
    return _parseImageResponse(response);
  }

  @override
  Future<GeneratedImage> editImage({
    required String prompt,
    required String base64Image,
    String negativePrompt = '',
    String mimeType = 'image/jpeg',
    String model = 'grok-imagine-image',
  }) async {
    final dataUri = 'data:$mimeType;base64,$base64Image';
    final response = await http.post(
      Uri.parse('$_baseUrl/images/edits'),
      headers: _headers,
      body: jsonEncode({
        'model': model,
        'prompt': prompt,
        'image_url': dataUri,
      }),
    );
    return _parseImageResponse(response);
  }

  GeneratedImage _parseImageResponse(http.Response response) {
    if (response.statusCode != 200) {
      String errorMsg;
      try {
        final body = jsonDecode(response.body);
        errorMsg = body['error']?['message'] ?? 'Unknown error';
      } catch (_) {
        errorMsg = response.body;
      }
      throw XaiApiException(errorMsg, statusCode: response.statusCode);
    }

    final body = jsonDecode(response.body);
    final data = body['data'];
    if (data is! List || data.isEmpty) {
      throw XaiApiException('No images returned. Body: ${response.body.substring(0, 200)}');
    }

    final first = data[0];
    if (first is Map) {
      return GeneratedImage(
        url: (first['url'] ?? first['b64_json']) as String,
        revisedPrompt: first['revised_prompt'] as String? ?? '',
      );
    } else if (first is String) {
      return GeneratedImage(url: first);
    } else {
      throw XaiApiException('Unexpected response format: ${first.runtimeType}');
    }
  }
}
