import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.load();
  });

  testWidgets('Login page renders key elements', (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchChallengeApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Send verification code'), findsOneWidget);
  });
}
