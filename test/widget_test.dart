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

  testWidgets('Homepage opens login form as a modal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StopwatchChallengeApp());
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Stopwatch Challenge'), findsWidgets);
    expect(find.text('START PLAYING  →'), findsOneWidget);
    expect(find.text('10.00'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Phone number'), findsNothing);

    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Ready to play?'), findsOneWidget);
  });
}
