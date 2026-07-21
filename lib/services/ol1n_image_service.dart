import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'image_generation_service.dart';

class OlinkApiException implements Exception {
  final String message;
  final int? statusCode;
  OlinkApiException(this.message, {this.statusCode});

  @override
  String toString() => 'OlinkApiException($statusCode): $message';
}

/// Image generation via https://llm.ol1n.com (AiStack Flux/Qwen backend).
///
/// The backend uses an async job model — POST returns a job_id immediately,
/// the client polls /v1/images/jobs/{id} until done, then fetches raw PNG bytes.
///
/// Authentication: Cloudflare Access service tokens.  Values passed at
/// construction take precedence; if empty, falls back to compile-time
/// --dart-define=CF_ACCESS_CLIENT_ID / CF_ACCESS_CLIENT_SECRET.
class OlinkImageService implements ImageGenerationService {
  static const _baseUrl = 'https://llm.ol1n.com';
  static const _cfIdEnv = String.fromEnvironment('CF_ACCESS_CLIENT_ID');
  static const _cfSecretEnv = String.fromEnvironment('CF_ACCESS_CLIENT_SECRET');

  static const _submitTimeout = Duration(seconds: 30);
  static const _pollTimeout = Duration(seconds: 15);
  static const _pollInterval = Duration(seconds: 2);
  static const _downloadTimeout = Duration(seconds: 120);

  final String cfId;
  final String cfSecret;
  final http.Client _client;

  OlinkImageService({required this.cfId, required this.cfSecret})
      : _client = http.Client();

  String get _effectiveCfId => cfId.isNotEmpty ? cfId : _cfIdEnv;
  String get _effectiveCfSecret => cfSecret.isNotEmpty ? cfSecret : _cfSecretEnv;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'CF-Access-Client-Id': _effectiveCfId,
        'CF-Access-Client-Secret': _effectiveCfSecret,
      };

  @override
  Future<GeneratedImage> generateImage({
    required String prompt,
    String negativePrompt = '',
    String size = '1024x1024',
    int n = 1,
  }) async {
    final body = <String, dynamic>{
      'prompt': prompt,
      'n': n,
      'size': size,
    };
    if (negativePrompt.isNotEmpty) body['negative_prompt'] = negativePrompt;
    final jobId = await _submitJob('/v1/images/generations', body);
    return _waitAndDownload(jobId);
  }

  @override
  Future<GeneratedImage> editImage({
    required String prompt,
    required String base64Image,
    String negativePrompt = '',
    String mimeType = 'image/jpeg',
    String size = '1024x1024',
    int n = 1,
  }) async {
    final body = <String, dynamic>{
      'image': base64Image,
      'prompt': prompt,
      'n': n,
      'size': size,
    };
    if (negativePrompt.isNotEmpty) body['negative_prompt'] = negativePrompt;
    final jobId = await _submitJob('/v1/images/edits', body);
    return _waitAndDownload(jobId);
  }

  Future<String> _submitJob(String path, Map<String, dynamic> body) async {
    final url = '$_baseUrl$path';
    debugPrint('[ol1n] POST $url');
    final response = await _client
        .post(Uri.parse(url), headers: _headers, body: jsonEncode(body))
        .timeout(_submitTimeout);
    debugPrint('[ol1n] POST $path → ${response.statusCode}');
    if (response.statusCode != 202) {
      throw OlinkApiException(_parseError(response), statusCode: response.statusCode);
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final jobId = json['id'] as String;
    debugPrint('[ol1n] job_id=$jobId');
    return jobId;
  }

  Future<GeneratedImage> _waitAndDownload(String jobId) async {
    while (true) {
      await Future.delayed(_pollInterval);

      http.Response response;
      try {
        response = await _client
            .get(
              Uri.parse('$_baseUrl/v1/images/jobs/$jobId'),
              headers: _headers,
            )
            .timeout(_pollTimeout);
      } catch (e) {
        debugPrint('[ol1n] poll network error: $e — retrying');
        continue;
      }

      if (response.statusCode == 404) {
        throw OlinkApiException('Job vypršel nebo neexistuje');
      }
      if (response.statusCode != 200) {
        debugPrint('[ol1n] poll → ${response.statusCode}, retrying');
        continue;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as String;
      debugPrint('[ol1n] poll $jobId → $status');

      switch (status) {
        case 'queued':
        case 'running':
          continue;

        case 'done':
          final resultUrl = json['result_url'] as String;
          final bytes = await _downloadResult(resultUrl);
          final tempDir = await getTemporaryDirectory();
          await tempDir.create(recursive: true);
          final file = File(
            '${tempDir.path}/manga_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          await file.writeAsBytes(bytes);
          debugPrint('[ol1n] saved to ${file.path}');
          return GeneratedImage(url: '', localPath: file.path);

        case 'error':
          final msg = json['error'] as String? ?? 'Neznámá chyba';
          throw OlinkApiException(msg);

        default:
          debugPrint('[ol1n] unknown status "$status"');
      }
    }
  }

  Future<Uint8List> _downloadResult(String resultUrl) async {
    final uri = Uri.parse('$_baseUrl$resultUrl');
    debugPrint('[ol1n] GET $resultUrl (result download)');
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(_downloadTimeout);
    debugPrint(
      '[ol1n] result → ${response.statusCode} (${response.bodyBytes.length} B)',
    );
    if (response.statusCode != 200) {
      throw OlinkApiException(
        'HTTP ${response.statusCode} při stahování výsledku',
      );
    }
    return response.bodyBytes;
  }

  static String _parseError(http.Response response) {
    final code = response.statusCode;
    // Cloudflare / proxy errors return HTML — give a human-readable message.
    if (code == 502 || code == 503 || code == 504) {
      return 'Backend nedostupný ($code) — zkontroluj server llm.ol1n.com';
    }
    if (code == 401 || code == 403) {
      return 'Chyba autentizace ($code) — zkontroluj CF Access token';
    }
    try {
      final msg = (jsonDecode(response.body) as Map)['detail']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    } catch (_) {}
    final body = response.body;
    return body.length > 200 ? '${body.substring(0, 200)}…' : body;
  }

  void dispose() => _client.close();
}
