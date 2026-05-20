import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/api/stopwatch_hmac.dart';

void main() {
  test('buildPayload concatenates in server order', () {
    expect(
      StopwatchHmac.buildPayload(
        method: 'post',
        requestUri: '/api/v1/game/start',
        body: '{"msisdn":"255712345678"}',
        timestamp: '2026-05-19T14:00:00.000Z',
        nonce: 'test-nonce',
      ),
      'POST/api/v1/game/start{"msisdn":"255712345678"}2026-05-19T14:00:00.000Ztest-nonce',
    );
  });

  test('GET uses empty body in payload', () {
    expect(
      StopwatchHmac.buildPayload(
        method: 'GET',
        requestUri: '/api/v1/billing/transactions/abc',
        body: '',
        timestamp: '2026-05-19T14:00:00Z',
        nonce: 'n1',
      ),
      'GET/api/v1/billing/transactions/abc2026-05-19T14:00:00Zn1',
    );
  });

  test('isExcluded skips auth login and verify-otp', () {
    expect(StopwatchHmac.isExcluded('/api/v1/auth/login'), isTrue);
    expect(StopwatchHmac.isExcluded('/api/v1/auth/verify-otp'), isTrue);
    expect(StopwatchHmac.isExcluded('/api/v1/billing/transactions'), isFalse);
  });

  test('hmacSha256Hex is lowercase hex', () {
    final hex = StopwatchHmac.hmacSha256Hex('payload', 'secret');
    expect(hex, matches(RegExp(r'^[0-9a-f]{64}$')));
  });
}
