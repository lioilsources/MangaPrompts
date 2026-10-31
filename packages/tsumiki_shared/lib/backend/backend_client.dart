// HTTP client of the render backend. Auth is pluggable: the phone app sends
// `app <token>` + `X-User`, behind Cloudflare Access. Pure `package:http`, so
// it runs on the phone, in a test and on the web alike.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'account.dart';
import 'job_status.dart';
import 'render_plan.dart';

/// Request headers that identify the caller.
abstract interface class AuthProvider {
  Map<String, String> headers();
}

/// `AUTH_MODE=app`: shared app token, a user name for the quota, and the
/// Cloudflare Access service token when the host sits behind Access.
class AppAuth implements AuthProvider {
  const AppAuth({
    required this.token,
    required this.user,
    this.cfAccessClientId = '',
    this.cfAccessClientSecret = '',
  });

  final String token;

  /// `^[a-z0-9_-]{2,32}$`.
  final String user;
  final String cfAccessClientId;
  final String cfAccessClientSecret;

  @override
  Map<String, String> headers() => {
    'Authorization': 'app $token',
    'X-User': user,
    if (cfAccessClientId.isNotEmpty) 'CF-Access-Client-Id': cfAccessClientId,
    if (cfAccessClientSecret.isNotEmpty)
      'CF-Access-Client-Secret': cfAccessClientSecret,
  };
}

/// A non-2xx answer; [message] is the server's `detail` when it sent one.
class BackendException implements Exception {
  const BackendException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  /// 402: quota used up.
  bool get paymentRequired => statusCode == 402;

  /// 429: a render of this user is still running.
  bool get busy => statusCode == 429;

  /// 404 on a job: the server restarted and lost it; the plan can run again.
  bool get notFound => statusCode == 404;

  @override
  String toString() => message;
}

class BackendClient {
  BackendClient({
    required String baseUrl,
    required this.auth,
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 30),
    this.uploadTimeout = const Duration(seconds: 120),
    this.downloadTimeout = const Duration(seconds: 120),
  }) : _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;
  final AuthProvider auth;
  final Duration requestTimeout;
  final Duration uploadTimeout;
  final Duration downloadTimeout;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Never _fail(http.Response resp) {
    var message = 'Request failed (${resp.statusCode})';
    try {
      final body = jsonDecode(resp.body);
      if (body is Map && body['detail'] is String) {
        message = body['detail'] as String;
      }
    } on FormatException {
      // Not JSON: a proxy's error page; the status line says enough.
    }
    throw BackendException(resp.statusCode, message);
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    final resp = await _client
        .get(_uri(path), headers: auth.headers())
        .timeout(requestTimeout);
    if (resp.statusCode != 200) _fail(resp);
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<Account> account() async =>
      Account.fromJson(await _getJson('/api/me'));

  /// Queues [plan] on [source] (the original photo).
  Future<RenderJob> startRender(Uint8List source, RenderPlan plan) async {
    final resp = await _client
        .post(
          _uri('/api/render'),
          headers: {...auth.headers(), 'Content-Type': 'application/json'},
          body: jsonEncode(plan.toRequest(source)),
        )
        .timeout(uploadTimeout);
    if (resp.statusCode != 200) _fail(resp);
    return RenderJob.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<RenderJobStatus> jobStatus(String jobId) async =>
      RenderJobStatus.fromJson(await _getJson('/api/jobs/$jobId'));

  /// PNG or mp4 of a finished step; 404 until it is `done`.
  Future<Uint8List> stepOutput(String jobId, String stepId) async {
    final resp = await _client
        .get(_uri('/api/jobs/$jobId/step/$stepId'), headers: auth.headers())
        .timeout(downloadTimeout);
    if (resp.statusCode != 200) _fail(resp);
    return resp.bodyBytes;
  }

  /// Snapshots of [jobId] every [interval] until it finishes (the last event
  /// is the finished one). A failing poll ends the stream with its error; the
  /// caller's resume logic restarts it.
  Stream<RenderJobStatus> pollJob(
    String jobId, {
    Duration interval = const Duration(seconds: 3),
  }) async* {
    while (true) {
      final status = await jobStatus(jobId);
      yield status;
      if (status.finished) return;
      await Future<void>.delayed(interval);
    }
  }

  void close() => _client.close();
}
