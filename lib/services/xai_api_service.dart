import 'dart:convert';
import 'package:http/http.dart' as http;

class XaiApiException implements Exception {
  final String message;
  final int? statusCode;
  XaiApiException(this.message, {this.statusCode});

  @override
  String toString() => 'XaiApiException($statusCode): $message';
}

class GeneratedImage {
  final String url;
  final String revisedPrompt;

  GeneratedImage({required this.url, this.revisedPrompt = ''});
}

class XaiApiService {
  static const _baseUrl = 'https://api.x.ai/v1';
  final String apiKey;

  XaiApiService({required this.apiKey});

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  /// Text-to-image generation
  Future<GeneratedImage> generateImage({
    required String prompt,
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
      }),
    );

    return _parseImageResponse(response);
  }

  /// Image-to-image editing (base image + prompt)
  Future<GeneratedImage> editImage({
    required String prompt,
    required String base64Image,
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
    print('[xAI] Status: ${response.statusCode}');
    print('[xAI] Body: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

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
    print('[xAI] Parsed body type: ${body.runtimeType}');
    print('[xAI] Keys: ${body is Map ? body.keys.toList() : 'N/A'}');

    final data = body['data'];
    print('[xAI] data type: ${data.runtimeType}, value: ${data is List ? 'List(${data.length})' : data}');

    if (data is! List || data.isEmpty) {
      throw XaiApiException('No images returned. Body: ${response.body.substring(0, 200)}');
    }

    final first = data[0];
    print('[xAI] first item type: ${first.runtimeType}');
    if (first is Map) {
      print('[xAI] first keys: ${first.keys.toList()}');
    }

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
