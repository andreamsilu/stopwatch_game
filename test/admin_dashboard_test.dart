import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:stopwatch_game/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EnvConfig.load();
  });

  testWidgets('/admin opens the demo administration dashboard', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const StopwatchChallengeApp(initialRoute: '/admin'),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Session Trace'), findsOneWidget);
    expect(find.textContaining('Demo mode'), findsWidgets);
    expect(find.text('Active users'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);

    await tester.tap(find.text('Session Trace'));
    await tester.pump();
    expect(find.text('Current browser session'), findsOneWidget);
    expect(find.text('Requests, responses and events'), findsOneWidget);
    expect(find.text('auth.login_succeeded'), findsOneWidget);

    await tester.tap(find.text('Users'));
    await tester.pump();
    expect(find.text('Total users'), findsOneWidget);
    expect(find.text('User directory'), findsOneWidget);

    await tester.tap(find.text('Billing'));
    await tester.pump();
    expect(find.text('Collected today'), findsOneWidget);
    expect(find.text('Recent transactions'), findsOneWidget);

    await tester.tap(find.text('Security'));
    await tester.pump();
    expect(find.text('OTP failures'), findsOneWidget);
    expect(find.text('Access and integrity events'), findsOneWidget);
  });

  testWidgets('admin dashboard fits a mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));
    await tester.pump();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
