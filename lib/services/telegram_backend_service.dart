import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../platform/telegram_webapp.dart';
import 'image_generation_service.dart';

/// Thrown when the backend answers 402: free quota exhausted and no credits.
class PaymentRequiredException implements Exception {
  final String message;
  const PaymentRequiredException(this.message);
  @override
  String toString() => message;
}

class TgPackage {
  final String id;
  final int credits;
  final int stars;
  final String label;

  const TgPackage({
    required this.id,
    required this.credits,
    required this.stars,
    required this.label,
  });

  factory TgPackage.fromJson(Map<String, dynamic> json) => TgPackage(
        id: json['id'] as String,
        credits: json['credits'] as int,
        stars: json['stars'] as int,
        label: json['label'] as String,
      );
}

class TgAccount {
  final int credits;
  final int freeRemaining;
  final int freeLimit;
  final List<TgPackage> packages;
  final int videoCredits;
  final int videoFreeRemaining;
  final int videoFreeLimit;
  final List<TgPackage> videoPackages;

  const TgAccount({
    required this.credits,
    required this.freeRemaining,
    required this.freeLimit,
    required this.packages,
    this.videoCredits = 0,
    this.videoFreeRemaining = 0,
    this.videoFreeLimit = 0,
    this.videoPackages = const [],
  });

  int get totalRemaining => credits + freeRemaining;
  int get videoTotalRemaining => videoCredits + videoFreeRemaining;

  factory TgAccount.fromJson(Map<String, dynamic> json) => TgAccount(
        credits: json['credits'] as int,
        freeRemaining: json['free_remaining'] as int,
        freeLimit: json['free_limit'] as int,
        packages: (json['packages'] as List)
            .map((p) => TgPackage.fromJson((p as Map).cast<String, dynamic>()))
            .toList(),
        videoCredits: json['video_credits'] as int? ?? 0,
        videoFreeRemaining: json['video_free_remaining'] as int? ?? 0,
        videoFreeLimit: json['video_free_limit'] as int? ?? 0,
        videoPackages: (json['video_packages'] as List? ?? const [])
            .map((p) => TgPackage.fromJson((p as Map).cast<String, dynamic>()))
            .toList(),
      );
}

/// A server-defined animation preset (the catalog lives on the video-api;
/// mirror of Ol1nLLM's VideoScene).
class TgVideoScene {
  final String id;
  final String label;
  final String desc;
  final int beats;
  final double seconds;
  final int minutesEst;

  const TgVideoScene({
    required this.id,
    required this.label,
    required this.desc,
    required this.beats,
    required this.seconds,
    required this.minutesEst,
  });

  factory TgVideoScene.fromJson(Map<String, dynamic> json) => TgVideoScene(
        id: json['id'] as String,
        label: json['label'] as String,
        desc: json['desc'] as String? ?? '',
        beats: json['beats'] as int? ?? 0,
        seconds: (json['seconds'] as num?)?.toDouble() ?? 0,
        minutesEst: json['minutes_est'] as int? ?? 0,
      );
}

/// The accepted animation job (POST /api/animate 200 body).
class TgVideoJob {
  final String jobId;
  final int beats;
  final double seconds;
  final int minutesEst;

  const TgVideoJob({
    required this.jobId,
    required this.beats,
    required this.seconds,
    required this.minutesEst,
  });

  factory TgVideoJob.fromJson(Map<String, dynamic> json) => TgVideoJob(
        jobId: json['job_id'] as String,
        beats: json['beats'] as int? ?? 0,
        seconds: (json['seconds'] as num?)?.toDouble() ?? 0,
        minutesEst: json['minutes_est'] as int? ?? 0,
      );
}

/// Poll snapshot of an animation job (GET /api/jobs/{id}).
class TgVideoStatus {
  final String status; // queued | running | done | error
  final String? error;
  final int beat;
  final int beats;
  final String? phase;
  final int? position;

  const TgVideoStatus({
    required this.status,
    this.error,
    this.beat = 0,
    this.beats = 0,
    this.phase,
    this.position,
  });

  factory TgVideoStatus.fromJson(Map<String, dynamic> json) => TgVideoStatus(
        status: json['status'] as String? ?? 'error',
        error: json['error'] as String?,
        beat: json['beat'] as int? ?? 0,
        beats: json['beats'] as int? ?? 0,
        phase: json['phase'] as String?,
        position: json['position'] as int?,
      );
}

/// Web (Telegram Mini App) backend: the bot service on JODA queues the ComfyUI
/// job on SPARK, sends the finished image to the user's chat, and serves the
/// bytes back to the app. Auth is Telegram initData — no API keys on the web.
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

  static Map<String, String> get _authHeaders {
    final initData = TelegramWebApp.initData;
    if (initData.isNotEmpty) return {'Authorization': 'tma $initData'};
    if (_devToken.isNotEmpty) return {'Authorization': 'dev $_devToken'};
    throw Exception('Open the app inside Telegram (not signed in).');
  }

  /// Credit balance, free quota and the package price list.
  static Future<TgAccount> fetchAccount() async {
    final resp = await http
        .get(Uri.parse('$_baseUrl/api/me'), headers: _authHeaders)
        .timeout(_requestTimeout);
    if (resp.statusCode != 200) {
      throw Exception(_errorMessage(resp));
    }
    return TgAccount.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  /// Creates a Telegram Stars invoice link for [packageId].
  static Future<String> createInvoiceLink(String packageId) async {
    final resp = await http
        .post(
          Uri.parse('$_baseUrl/api/invoice'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({'package': packageId}),
        )
        .timeout(_requestTimeout);
    if (resp.statusCode != 200) {
      throw Exception(_errorMessage(resp));
    }
    return (jsonDecode(resp.body) as Map<String, dynamic>)['link'] as String;
  }

  /// Animation preset catalog; throws when the video backend is unreachable
  /// (callers hide the feature).
  static Future<List<TgVideoScene>> fetchVideoScenes() async {
    final resp = await http
        .get(Uri.parse('$_baseUrl/api/video/scenes'), headers: _authHeaders)
        .timeout(_requestTimeout);
    if (resp.statusCode != 200) {
      throw Exception(_errorMessage(resp));
    }
    return ((jsonDecode(resp.body) as Map<String, dynamic>)['scenes'] as List)
        .map((sc) => TgVideoScene.fromJson((sc as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Submits a photo animation. The finished video is delivered by the bot
  /// into the user's chat; the app only tracks progress via [videoJobStatus].
  static Future<TgVideoJob> startAnimation({
    required String sceneId,
    required Uint8List imageBytes,
  }) async {
    final resp = await http
        .post(
          Uri.parse('$_baseUrl/api/animate'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({
            'scene': sceneId,
            'image': base64Encode(imageBytes),
          }),
        )
        // multi-MB base64 upload through the CF tunnel — give it room
        .timeout(const Duration(seconds: 60));
    if (resp.statusCode == 402) {
      throw PaymentRequiredException(_errorMessage(resp));
    }
    if (resp.statusCode != 200) {
      throw Exception(_errorMessage(resp));
    }
    return TgVideoJob.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  static Future<TgVideoStatus> videoJobStatus(String jobId) async {
    final resp = await http
        .get(Uri.parse('$_baseUrl/api/jobs/$jobId'), headers: _authHeaders)
        .timeout(_requestTimeout);
    if (resp.statusCode != 200) {
      throw Exception(_errorMessage(resp));
    }
    return TgVideoStatus.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
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
    if (resp.statusCode == 402) {
      throw PaymentRequiredException(_errorMessage(resp));
    }
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
              'Generation failed: ${status['error'] ?? 'unknown error'}');
      }
    }
    throw Exception('Generation timed out — please try again.');
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
    throw UnsupportedError('img2img is not available on the web yet');
  }

  static String _errorMessage(http.Response resp) {
    try {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final detail = body['detail'] ?? body['error'];
      if (detail != null) return 'Server: $detail';
    } catch (_) {}
    return 'Server returned HTTP ${resp.statusCode}';
  }
}
