import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tsumiki_shared/tsumiki_shared.dart';

void main() {
  const auth = AppAuth(
    token: 'tok',
    user: 'ondra',
    cfAccessClientId: 'id',
    cfAccessClientSecret: 'secret',
  );
  BackendClient client(MockClientHandler h) => BackendClient(
    baseUrl: 'https://api.test/',
    auth: auth,
    client: MockClient(h),
  );
  final plan = RenderPlan([
    const RenderStep(
      id: 's1',
      graph: RenderGraph.restyleFlux,
      input: 'source',
      prompt: 'p',
    ),
  ]);

  test('headers carry the app scheme, the user and Cloudflare Access', () {
    expect(auth.headers(), {
      'Authorization': 'app tok',
      'X-User': 'ondra',
      'CF-Access-Client-Id': 'id',
      'CF-Access-Client-Secret': 'secret',
    });
    expect(const AppAuth(token: 't', user: 'u').headers().length, 2);
  });

  test('account', () async {
    final c = client((r) async {
      expect(r.url.toString(), 'https://api.test/api/me');
      expect(r.headers['Authorization'], 'app tok');
      return http.Response(
        jsonEncode({
          'credits': 2,
          'free_remaining': 3,
          'free_limit': 40,
          'packages': [],
        }),
        200,
      );
    });
    final a = await c.account();
    expect(a.totalRemaining, 5);
    expect(a.freeLimit, 40);
  });

  test('startRender posts the plan', () async {
    final c = client((r) async {
      expect(r.method, 'POST');
      expect(r.url.path, '/api/render');
      final body = jsonDecode(r.body) as Map;
      expect(body['source'], base64Encode([7]));
      expect((body['steps'] as List).length, 1);
      return http.Response(
        jsonEncode({'job_id': 'j', 'steps_total': 1, 'cost': 1}),
        200,
      );
    });
    final job = await c.startRender(Uint8List.fromList([7]), plan);
    expect(job.jobId, 'j');
  });

  test('errors keep the status and the detail', () async {
    for (final code in [402, 429, 422, 404]) {
      final c = client(
        (_) async => http.Response(jsonEncode({'detail': 'no'}), code),
      );
      await expectLater(
        c.startRender(Uint8List(1), plan),
        throwsA(
          isA<BackendException>()
              .having((e) => e.statusCode, 'status', code)
              .having((e) => e.message, 'message', 'no'),
        ),
      );
    }
    final c = client((_) async => http.Response('<html>bad gateway', 502));
    await expectLater(
      c.account(),
      throwsA(
        isA<BackendException>().having((e) => e.statusCode, 'status', 502),
      ),
    );
    expect(const BackendException(402, '').paymentRequired, isTrue);
    expect(const BackendException(429, '').busy, isTrue);
    expect(const BackendException(404, '').notFound, isTrue);
  });

  test('pollJob runs until the job finishes', () async {
    var polls = 0;
    final c = client((r) async {
      polls++;
      return http.Response(
        jsonEncode({
          'status': polls < 3 ? 'running' : 'done',
          'done': polls - 1,
          'total': 2,
          'steps': {
            'a': {'status': 'done', 'kind': 'image'},
            'b': {'status': 'skipped', 'kind': 'video', 'error': 'x'},
          },
        }),
        200,
      );
    });
    final seen = await c.pollJob('j', interval: Duration.zero).toList();
    expect(seen.length, 3);
    expect(seen.last.finished, isTrue);
    expect(seen.last.steps['b']!.kind, 'video');
    expect(seen.last.steps['b']!.finished, isTrue);
  });

  test('stepOutput returns the bytes', () async {
    final c = client((r) async {
      expect(r.url.path, '/api/jobs/j/step/s1');
      return http.Response.bytes([1, 2], 200);
    });
    expect(await c.stepOutput('j', 's1'), [1, 2]);
  });
}
