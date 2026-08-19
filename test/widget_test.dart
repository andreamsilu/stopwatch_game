import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EnvConfig.load();
  });

  testWidgets('Login page renders key elements', (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchChallengeApp());
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Stopwatch Challenge'), findsWidgets);
    expect(find.text('START PLAYING  →'), findsOneWidget);
    expect(find.text('10.00'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
  });
}
