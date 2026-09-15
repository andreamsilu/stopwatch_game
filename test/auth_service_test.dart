import 'package:stopwatch_game/core/config/env_config.dart';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/features/auth/data/auth_service.dart';
import 'package:stopwatch_game/features/auth/data/models/auth_login_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(
    () => EnvConfig.load(
      overrides: {
        'API_BASE_URL': 'https://example.test',
        'STOPWATCH_SECURITY_HMAC_ENABLED': 'false',
      },
    ),
  );
  test('OTP-required login stops without another request or session', () async {
    final requests = <http.Request>[];
    final auth = AuthService(
      api: StopwatchApi(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({'status': 'OTP_REQUIRED', 'otp': '123456'}),
            200,
          );
        }),
      ),
    );

    await expectLater(
      auth.login(msisdn: '255700000123'),
      throwsA(isA<ApiException>()),
    );
    expect(requests, hasLength(1));
    expect(requests.single.url.path, endsWith('/auth/login'));
    expect(jsonDecode(requests.single.body), {'msisdn': '255700000123'});
    expect(auth.currentSession, isNull);
  });

  test('direct login stores the returned session', () async {
    final auth = AuthService(
      api: StopwatchApi(
        client: MockClient((request) async {
          expect(request.url.path, endsWith('/auth/login'));
          return http.Response(
            jsonEncode({
              'accessToken': 'test-token',
              'tokenType': 'Bearer',
              'expiresInSeconds': 3600,
              'user': {
                'id': 1,
                'msisdn': '255700000123',
                'status': 'active',
                'createdAt': '2026-09-15T00:00:00Z',
                'updatedAt': '2026-09-15T00:00:00Z',
              },
            }),
            200,
          );
        }),
      ),
    );

    expect(await auth.login(msisdn: '255700000123'), isA<AuthLoginCompleted>());
    expect(auth.currentSession?.accessToken, 'test-token');
    expect(auth.currentSession?.user.id, 1);
  });
}
