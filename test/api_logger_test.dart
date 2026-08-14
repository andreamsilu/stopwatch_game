import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/api/api_logger.dart';

void main() {
  test('redacts credentials and masks phone fields recursively', () {
    final sanitized =
        ApiLogger.sanitizeForLogging({
              'msisdn': '255676589824',
              'otp': '123456',
              'accessToken': 'jwt-value',
              'user': {'username': '255676589824', 'status': 'active'},
            })
            as Map<String, dynamic>;

    expect(sanitized['msisdn'], '255676***824');
    expect(sanitized['otp'], '<redacted>');
    expect(sanitized['accessToken'], '<redacted>');
    expect(
      (sanitized['user'] as Map<String, dynamic>)['username'],
      '255676***824',
    );
    expect((sanitized['user'] as Map<String, dynamic>)['status'], 'active');
  });

  test('masks sensitive URI query parameters', () {
    final sanitized = ApiLogger.sanitizeUriForLogging(
      Uri.parse('http://example.test/api/v1/users?msisdn=255676589824&page=1'),
    );

    expect(sanitized.queryParameters['msisdn'], '255676***824');
    expect(sanitized.queryParameters['page'], '1');
  });
}
