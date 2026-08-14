import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/config/env_config.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.load(
      overrides: {
        'STOPWATCH_SECURITY_HMAC_ENABLED': 'false',
        'STOPWATCH_SECURITY_HMAC_SECRET': 'secret',
      },
    );
  });

  test('hmacEnabled is false when env is false', () {
    expect(EnvConfig.hmacEnabled, isFalse);
  });
}
