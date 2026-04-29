import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/main.dart';

void main() {
  testWidgets('Login page renders key elements', (WidgetTester tester) async {
    await tester.pumpWidget(const StopwatchChallengeApp());

    expect(find.text('ChronoPrecision'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
