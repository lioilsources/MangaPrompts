import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../platform/telegram_webapp.dart';
import 'image_generation_service.dart';

/// Web (Telegram Mini App) backend: the SPARK bot service queues the ComfyUI
/// job, sends the finished image to the user's chat, and serves the bytes back
/// to the app. Auth is Telegram initData — no API keys live in the web bundle.
class TelegramBackendService implements ImageGenerationService {
  static const _baseUrl = String.fromEnvironment(
    'TG_BACKEND_URL',
    defaultValue: 'https://tg.ol1n.com',
  );
  static const _devToken = String.fromEnvironment('TG_DEV_TOKEN');

  static const _requestTimeout = Duration(seconds: 30);
  static const _downloadTimeout = Duration(seconds: 120);
  static const _pollInterval = Duration(seconds: 2);
  static const _jobTimeout = Duration(minutes: 5);

  /// ComfyUI workflow key understood by the backend: 'flux' or 'pony'.
  final String workflow;

  TelegramBackendService({required this.workflow});

  Map<String, String> get _authHeaders {
    final initData = TelegramWebApp.initData;
    if (initData.isNotEmpty) return {'Authorization': 'tma $initData'};
    if (_devToken.isNotEmpty) return {'Authorization': 'dev $_devToken'};
    throw Exception('Otevři aplikaci v Telegramu (chybí přihlášení).');
  }

  @override
  Future<GeneratedImage> generateImage({
    required String prompt,
    String negativePrompt = '',
  }) async {
    final headers = _authHeaders;
    final resp = await http
        .post(
          Uri.parse('$_baseUrl/api/generate'),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: jsonEncode({
            'prompt': prompt,
            'negative_prompt': negativePrompt,
            'workflow': workflow,
          }),
        )
        .timeout(_requestTimeout);
    if (resp.statusCode != 200) {
      throw Exception(_errorMessage(resp));
    }
    final jobId =
        (jsonDecode(resp.body) as Map<String, dynamic>)['job_id'] as String;

    final deadline = DateTime.now().add(_jobTimeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(_pollInterval);
      final statusResp = await http
          .get(Uri.parse('$_baseUrl/api/jobs/$jobId'), headers: headers)
          .timeout(_requestTimeout);
      if (statusResp.statusCode != 200) {
        throw Exception(_errorMessage(statusResp));
      }
      final status = jsonDecode(statusResp.body) as Map<String, dynamic>;
      switch (status['status'] as String?) {
        case 'done':
          return _downloadResult(jobId, headers);
        case 'error':
          throw Exception(
              'Generování selhalo: ${status['error'] ?? 'neznámá chyba'}');
      }
    }
    throw Exception('Generování vypršelo — zkus to prosím znovu.');
  }

  Future<GeneratedImage> _downloadResult(
    String jobId,
    Map<String, String> headers,
  ) async {
    final resp = await http
        .get(Uri.parse('$_baseUrl/api/jobs/$jobId/image'), headers: headers)
        .timeout(_downloadTimeout);
    if (resp.statusCode != 200) {
      throw Exception(_errorMessage(resp));
    }
    return GeneratedImage(url: '', bytes: resp.bodyBytes);
  }

  @override
  Future<GeneratedImage> editImage({
    required String prompt,
    required String base64Image,
    String negativePrompt = '',
    String mimeType = 'image/jpeg',
  }) {
    throw UnsupportedError('img2img zatím není na webu k dispozici');
  }

  String _errorMessage(http.Response resp) {
    try {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final detail = body['detail'] ?? body['error'];
      if (detail != null) return 'Server: $detail';
    } catch (_) {}
    return 'Server vrátil HTTP ${resp.statusCode}';
  }
}
