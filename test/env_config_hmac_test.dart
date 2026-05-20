import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/config/env_config.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(
      fileInput: '''
STOPWATCH_SECURITY_HMAC_ENABLED=false
STOPWATCH_SECURITY_HMAC_SECRET=secret
''',
    );
    await EnvConfig.load();
  });

  test('hmacEnabled is false when env is false', () {
    expect(EnvConfig.hmacEnabled, isFalse);
  });
}
