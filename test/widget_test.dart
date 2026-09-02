import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EnvConfig.load();
  });

  testWidgets('Landing page is the game and opens login before payment', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StopwatchChallengeApp());
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('sw'));
    expect(find.text('Cheza'), findsWidgets);
    expect(find.text('Uko tayari kujaribu bahati yako?'), findsOneWidget);
    expect(find.textContaining('10.00'), findsWidgets);
    expect(find.text('Cheza raundi'), findsOneWidget);
    expect(find.text('Namba ya simu'), findsNothing);

    await tester.tap(find.text('Msaada'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('YAS Customer Care'), findsOneWidget);
    expect(find.text('PIGA SIMU'), findsOneWidget);
    expect(find.text('0714 100 100'), findsOneWidget);
    expect(find.text('customercare@yas.co.tz'), findsOneWidget);
    expect(find.text('Duka la YAS'), findsOneWidget);
    expect(find.text('Maswali na Majibu'), findsOneWidget);
    expect(find.text('Ninawezaje kucheza?'), findsOneWidget);

    await tester.ensureVisible(find.text('Ninawezaje kucheza?'));
    await tester.tap(find.text('Ninawezaje kucheza?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ingia kwa namba yako ya YAS'), findsOneWidget);

    await tester.tap(find.text('Cheza'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('Badilisha lugha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    final englishApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(englishApp.locale, const Locale('en'));
    expect(find.text('Play'), findsWidgets);
    expect(find.text('Ready for the challenge?'), findsOneWidget);
    expect(find.text('PAY FOR ROUND'), findsOneWidget);

    await tester.ensureVisible(find.text('PAY FOR ROUND'));
    await tester.pump();
    await tester.tap(find.text('PAY FOR ROUND'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Ready to play?'), findsOneWidget);
  });
}
