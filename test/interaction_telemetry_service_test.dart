import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/services/interaction_telemetry_service.dart';

void main() {
  test('removes sensitive telemetry properties recursively', () {
    final sanitized = InteractionTelemetryService.sanitizeProperties({
      'sessionRef': 'session-1',
      'msisdn': '255676589824',
      'nested': {'otp': '123456', 'winner': true},
      'samples': [1, 2, 3],
    });

    expect(sanitized['sessionRef'], 'session-1');
    expect(sanitized.containsKey('msisdn'), isFalse);
    expect(
      (sanitized['nested'] as Map<String, dynamic>).containsKey('otp'),
      isFalse,
    );
    expect((sanitized['nested'] as Map<String, dynamic>)['winner'], isTrue);
    expect(sanitized['samples'], [1, 2, 3]);
  });
}
