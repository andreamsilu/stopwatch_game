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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Send verification code'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
