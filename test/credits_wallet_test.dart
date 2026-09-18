import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/features/game/data/game_service.dart';
import 'package:stopwatch_game/features/game/data/models/credits_wallet.dart';
import 'package:stopwatch_game/features/game/data/models/start_game_request.dart';

void main() {
  setUpAll(() async {
    await EnvConfig.load(
      overrides: {
        'API_BASE_URL': 'https://example.test',
        'STOPWATCH_SECURITY_HMAC_ENABLED': 'false',
      },
    );
  });

  test('credits wallet preserves server counters and credit sources', () {
    final wallet = CreditsWallet.fromJson(const {
      'msisdn': '255656692469',
      'credits': 1,
      'renewalCredits': 2,
      'availablePlayCredits': [
        {
          'id': 42,
          'amount': 100.0,
          'source': 'interaction',
          'renewalRequestId': 'TOP_PLAYER_2026-09-17',
          'createdAt': '2026-09-17T08:00:00Z',
        },
        {
          'id': 15,
          'amount': 300.0,
          'source': 'renewal',
          'renewalRequestId': 'STPWR20260908120000255656692469',
          'createdAt': '2026-09-16T06:00:00Z',
        },
      ],
    });

    expect(wallet.credits, 1);
    expect(wallet.renewalCredits, 2);
    expect(wallet.forSource(PlayCreditSource.interaction).single.id, 42);
    expect(wallet.forSource(PlayCreditSource.renewal).single.id, 15);
  });

  test('start request emits mutually exclusive billing and credit shapes', () {
    expect(
      const StartGameRequest.billing(
        msisdn: '255656692469',
        channel: 'WEB',
        billingRequestId: 'STPWI20260515104221ABC',
      ).toJson(),
      {
        'msisdn': '255656692469',
        'channel': 'WEB',
        'billingRequestId': 'STPWI20260515104221ABC',
      },
    );
    expect(
      const StartGameRequest.credit(
        msisdn: '255656692469',
        channel: 'WEB',
        entrySource: 'credit',
        playCreditId: 42,
        clientReference: 'web-session-abc',
      ).toJson(),
      {
        'msisdn': '255656692469',
        'channel': 'WEB',
        'entrySource': 'credit',
        'playCreditId': 42,
        'clientReference': 'web-session-abc',
      },
    );
  });

  test('service maps renewal credit to renewal_credit on start', () async {
    late http.Request captured;
    final api = StopwatchApi(
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'id': 100,
            'sessionRef': 'STPWG20260917083000ABC',
            'billingRequestId': null,
            'entrySource': 'renewal_credit',
            'playCreditId': 15,
            'renewalRequestId': 'STPWR20260908120000255656692469',
            'clientReference': 'web-session-abc',
            'msisdn': '255656692469',
            'channel': 'WEB',
            'entryFee': 100.0,
            'targetTimeMs': 15000,
            'status': 'started',
            'startedAt': '2026-09-17T08:30:00Z',
            'endedAt': null,
            'result': null,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(api.close);

    final session = await GameService(api: api).startGameSession(
      msisdn: '255656692469',
      channel: 'WEB',
      playCreditId: 15,
      creditSource: PlayCreditSource.renewal,
      clientReference: 'web-session-abc',
    );

    expect(captured.url.path, '/api/v1/game/start');
    expect(jsonDecode(captured.body), {
      'msisdn': '255656692469',
      'channel': 'WEB',
      'entrySource': 'renewal_credit',
      'playCreditId': 15,
      'clientReference': 'web-session-abc',
    });
    expect(session.sessionRef, 'STPWG20260917083000ABC');
    expect(session.billingRequestId, isNull);
    expect(session.playCreditId, 15);
  });
}
