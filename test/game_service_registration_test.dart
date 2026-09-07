import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/features/game/data/game_service.dart';
import 'package:stopwatch_game/features/game/data/models/subscription_status_response.dart';

void main() {
  setUpAll(() async {
    await EnvConfig.load(
      overrides: {
        'API_BASE_URL': 'https://example.test',
        'STOPWATCH_SECURITY_HMAC_ENABLED': 'false',
      },
    );
  });

  test('subscription response reads activityStatus from current API', () {
    final response = SubscriptionStatusResponse.fromJson(const {
      'msisdn': '255676589824',
      'activityStatus': 'INACTIVE',
      'subscribed': false,
    });

    expect(response.status, 'INACTIVE');
    expect(response.isActive, isFalse);
  });

  test(
    'registration polls until SMS confirmation activates subscription',
    () async {
      var checks = 0;
      final paths = <String>[];
      final api = StopwatchApi(
        client: MockClient((request) async {
          paths.add(request.url.path);
          if (request.url.path.endsWith('/register')) {
            return http.Response('{}', 200);
          }
          checks++;
          return http.Response(
            jsonEncode({
              'msisdn': '255676589824',
              'activityStatus': checks < 3 ? 'INACTIVE' : 'ACTIVE',
              'subscribed': checks >= 3,
            }),
            200,
          );
        }),
      );
      addTearDown(api.close);
      final service = GameService(api: api);

      await service.requestSubscriptionRegistration(msisdn: '255676589824');
      final result = await service.waitForSubscriptionActivation(
        msisdn: '255676589824',
        pollInterval: Duration.zero,
        timeout: const Duration(seconds: 1),
      );

      expect(result?.isActive, isTrue);
      expect(paths, [
        '/api/v1/app/register',
        ...List.filled(3, '/api/v1/app/subscription-status'),
      ]);
    },
  );

  test(
    'unconfirmed registration times out without another status request',
    () async {
      var checks = 0;
      final api = StopwatchApi(
        client: MockClient((request) async {
          checks++;
          return http.Response(
            '{"activityStatus":"INACTIVE","subscribed":false}',
            200,
          );
        }),
      );
      addTearDown(api.close);

      final result = await GameService(api: api).waitForSubscriptionActivation(
        msisdn: '255676589824',
        pollInterval: const Duration(seconds: 1),
        timeout: const Duration(milliseconds: 20),
      );

      expect(result, isNull);
      expect(checks, 1);
    },
  );

  test(
    'cancellation ignores confirmation from an in-flight status request',
    () async {
      var cancelled = false;
      final response = Completer<http.Response>();
      final requested = Completer<void>();
      final api = StopwatchApi(
        client: MockClient((request) {
          requested.complete();
          return response.future;
        }),
      );
      addTearDown(api.close);

      final polling = GameService(api: api).waitForSubscriptionActivation(
        msisdn: '255676589824',
        isCancelled: () => cancelled,
      );
      final assertion = expectLater(polling, throwsStateError);
      await requested.future;
      cancelled = true;
      response.complete(
        http.Response('{"activityStatus":"ACTIVE","subscribed":true}', 200),
      );
      await assertion;
    },
  );

  test('inactive registration posts msisdn to app register endpoint', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'id': 1,
          'msisdn': '255676589824',
          'activityStatus': 'INACTIVE',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final api = StopwatchApi(client: client);
    final service = GameService(api: api);

    await service.requestSubscriptionRegistration(msisdn: '255676589824');

    expect(captured.method, 'POST');
    expect(captured.url.path, '/api/v1/app/register');
    expect(jsonDecode(captured.body), {'msisdn': '255676589824'});
    api.close();
  });
}
