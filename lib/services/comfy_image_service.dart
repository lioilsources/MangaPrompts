import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, WebSocket, File;
import 'dart:math';
import 'dart:typed_data';

import 'package:cronet_http/cronet_http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'image_generation_service.dart';

enum ComfyWorkflow { flux, pony }

class ComfyImageService implements ImageGenerationService {
  static const _baseUrl = 'https://comfyui.ol1n.com';
  static const _wsUrl = 'wss://comfyui.ol1n.com/ws';

  static const _fluxTxt2img = 'assets/comfyui/flux_manga_txt2img.api.json';
  static const _fluxImg2img = 'assets/comfyui/flux_manga_img2img.api.json';
  static const _ponyTxt2img = 'assets/comfyui/pony_txt2img.api.json';
  static const _ponyImg2img = 'assets/comfyui/pony_img2img.api.json';

  static const _submitTimeout = Duration(seconds: 30);
  static const _pollTimeout = Duration(seconds: 15);
  static const _pollInterval = Duration(seconds: 2);
  static const _wsConnectTimeout = Duration(seconds: 10);
  static const _downloadTimeout = Duration(seconds: 120);

  final String cfId;
  final String cfSecret;
  final ComfyWorkflow workflow;

  final String _clientId = const Uuid().v4();
  late final http.Client _client;
  final Map<String, Map<String, dynamic>> _templateCache = {};

  ComfyImageService({
    required this.cfId,
    required this.cfSecret,
    this.workflow = ComfyWorkflow.flux,
  }) : _client = _makeClient();

  static http.Client _makeClient() {
    try {
      if (Platform.isAndroid) return CronetClient.defaultCronetEngine();
    } catch (_) {}
    return http.Client();
  }

  Map<String, String> get _authHeaders => {
        'CF-Access-Client-Id': cfId,
        'CF-Access-Client-Secret': cfSecret,
      };

  Map<String, String> get _jsonHeaders => {
        ..._authHeaders,
        'Content-Type': 'application/json',
      };

  String get _txt2imgAsset =>
      workflow == ComfyWorkflow.pony ? _ponyTxt2img : _fluxTxt2img;
  String get _img2imgAsset =>
      workflow == ComfyWorkflow.pony ? _ponyImg2img : _fluxImg2img;

  @override
  Future<GeneratedImage> generateImage({
    required String prompt,
    String negativePrompt = '',
  }) async {
    final tpl = await _template(_txt2imgAsset);
    final wf = _prepare(tpl, prompt: prompt, negativePrompt: negativePrompt, batch: 1);
    return _runToResult(wf);
  }

  @override
  Future<GeneratedImage> editImage({
    required String prompt,
    required String base64Image,
    String negativePrompt = '',
    String mimeType = 'image/jpeg',
  }) async {
    final imageBytes = base64Decode(base64Image);
    final imageName = await _uploadImage(imageBytes);
    final tpl = await _template(_img2imgAsset);
    final wf = _prepare(
      tpl,
      prompt: prompt,
      negativePrompt: negativePrompt,
      batch: 1,
      imageName: imageName,
    );
    return _runToResult(wf);
  }

  Future<GeneratedImage> _runToResult(Map<String, dynamic> workflow) async {
    final promptId = await _queuePrompt(workflow);
    debugPrint('[comfy] prompt_id=$promptId');

    final images = await _waitForImages(promptId);
    if (images.isEmpty) throw Exception('ComfyUI: žádné výstupní obrázky');

    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/comfy_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(images.first);
    debugPrint('[comfy] saved to ${file.path}');
    return GeneratedImage(url: '', localPath: file.path);
  }

  Future<List<Uint8List>> _waitForImages(String promptId) async {
    // Try WebSocket first for real-time progress; fall back to polling.
    WebSocket? ws;
    try {
      ws = await WebSocket.connect(
        '$_wsUrl?clientId=$_clientId',
        headers: _authHeaders,
      ).timeout(_wsConnectTimeout);
    } catch (e) {
      debugPrint('[comfy] ws connect failed ($e) — polling');
    }

    if (ws != null) {
      var finished = false;
      try {
        await for (final raw in ws) {
          if (raw is! String) continue;
          Map<String, dynamic> msg;
          try {
            msg = jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {
            continue;
          }
          final type = msg['type'] as String?;
          final data = (msg['data'] as Map?)?.cast<String, dynamic>() ?? const {};
          final pid = data['prompt_id'] as String?;

          switch (type) {
            case 'executing':
              if (pid == promptId && data['node'] == null) finished = true;
            case 'execution_error':
              if (pid == promptId) {
                final t = data['exception_type'] ?? '';
                final m = data['exception_message'] ?? 'unknown';
                throw Exception('ComfyUI chyba — $t: $m');
              }
            case 'execution_interrupted':
              if (pid == promptId) throw Exception('Zrušeno');
          }
          if (finished) break;
        }
      } catch (e) {
        if (e is Exception) rethrow;
        debugPrint('[comfy] ws error ($e) — polling fallback');
      } finally {
        await ws.close();
      }
      if (finished) return _downloadOutputs(promptId);
    }

    // Polling fallback
    while (true) {
      await Future.delayed(_pollInterval);
      Map<String, dynamic>? hist;
      try {
        hist = await _history(promptId);
      } catch (e) {
        debugPrint('[comfy] poll error ($e) — retrying');
        continue;
      }
      if (hist == null) continue;
      final statusStr = ((hist['status'] as Map?)?['status_str']) as String?;
      if (statusStr == 'error') {
        throw Exception('ComfyUI: generování selhalo');
      }
      return _downloadOutputs(promptId, hist: hist);
    }
  }

  Future<List<Uint8List>> _downloadOutputs(
    String promptId, {
    Map<String, dynamic>? hist,
  }) async {
    hist ??= await _history(promptId);
    if (hist == null) throw Exception('ComfyUI: history prázdná');

    final outputs = (hist['outputs'] as Map?)?.cast<String, dynamic>() ?? const {};
    final refs = <Map<String, dynamic>>[];
    for (final node in outputs.values) {
      final images = ((node as Map?)?['images'] as List?) ?? const [];
      for (final img in images) {
        final m = (img as Map).cast<String, dynamic>();
        if (m['type'] == 'temp') continue;
        refs.add(m);
      }
    }
    if (refs.isEmpty) throw Exception('ComfyUI: žádné výstupní obrázky ve workflow');

    final out = <Uint8List>[];
    for (final r in refs) {
      out.add(await _view(
        r['filename'] as String,
        (r['subfolder'] as String?) ?? '',
        (r['type'] as String?) ?? 'output',
      ));
    }
    return out;
  }

  Future<String> _queuePrompt(Map<String, dynamic> workflow) async {
    final resp = await _client
        .post(
          Uri.parse('$_baseUrl/prompt'),
          headers: _jsonHeaders,
          body: jsonEncode({'prompt': workflow, 'client_id': _clientId}),
        )
        .timeout(_submitTimeout);
    debugPrint('[comfy] POST /prompt → ${resp.statusCode}');
    if (resp.statusCode != 200) {
      throw Exception('ComfyUI /prompt HTTP ${resp.statusCode}: ${_snippet(resp.body)}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final nodeErrors = json['node_errors'];
    if (nodeErrors is Map && nodeErrors.isNotEmpty) {
      throw Exception('ComfyUI workflow error: ${jsonEncode(nodeErrors)}');
    }
    return json['prompt_id'] as String;
  }

  Future<Map<String, dynamic>?> _history(String promptId) async {
    final resp = await _client
        .get(Uri.parse('$_baseUrl/history/$promptId'), headers: _authHeaders)
        .timeout(_pollTimeout);
    if (resp.statusCode != 200) return null;
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return (json[promptId] as Map?)?.cast<String, dynamic>();
  }

  Future<Uint8List> _view(String filename, String subfolder, String type) async {
    final uri = Uri.parse('$_baseUrl/view').replace(
      queryParameters: {'filename': filename, 'subfolder': subfolder, 'type': type},
    );
    final resp = await _client.get(uri, headers: _authHeaders).timeout(_downloadTimeout);
    if (resp.statusCode != 200) {
      throw Exception('ComfyUI /view HTTP ${resp.statusCode} for $filename');
    }
    return resp.bodyBytes;
  }

  Future<String> _uploadImage(Uint8List bytes) async {
    final req = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload/image'))
      ..headers.addAll(_authHeaders)
      ..fields['overwrite'] = 'true'
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'manga_input_${DateTime.now().millisecondsSinceEpoch}.png',
      ));
    final streamed = await _client.send(req).timeout(_submitTimeout);
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200) {
      throw Exception('ComfyUI /upload/image HTTP ${resp.statusCode}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final name = json['name'] as String;
    final subfolder = json['subfolder'] as String? ?? '';
    return subfolder.isEmpty ? name : '$subfolder/$name';
  }

  Future<Map<String, dynamic>> _template(String asset) async {
    final cached = _templateCache[asset];
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(asset);
    final tpl = jsonDecode(raw) as Map<String, dynamic>;
    _templateCache[asset] = tpl;
    return tpl;
  }

  Map<String, dynamic> _prepare(
    Map<String, dynamic> template, {
    required String prompt,
    required String negativePrompt,
    required int batch,
    String? imageName,
  }) {
    final wf = jsonDecode(jsonEncode(template)) as Map<String, dynamic>;
    final seed = Random().nextInt(1 << 31);

    for (final entry in wf.values) {
      final node = (entry as Map).cast<String, dynamic>();
      final cls = node['class_type'] as String?;
      final inputs = (node['inputs'] as Map?)?.cast<String, dynamic>();
      if (inputs == null) continue;

      inputs.forEach((key, value) {
        if (value == '__PROMPT__') inputs[key] = prompt;
        if (value == '__NEGATIVE__') inputs[key] = negativePrompt;
        if (value == '__IMAGE__' && imageName != null) inputs[key] = imageName;
      });

      switch (cls) {
        case 'EmptySD3LatentImage':
        case 'EmptyLatentImage':
          if (inputs.containsKey('batch_size')) inputs['batch_size'] = batch;
        case 'RepeatLatentBatch':
          if (inputs.containsKey('amount')) inputs['amount'] = batch;
      }
      if (inputs.containsKey('seed')) inputs['seed'] = seed;
      if (inputs.containsKey('noise_seed')) inputs['noise_seed'] = seed;
    }
    return wf;
  }

  String _snippet(String body) {
    final s = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s.length > 160 ? '${s.substring(0, 160)}…' : s;
  }

  void dispose() => _client.close();
}
