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
    await tester.pumpWidget(
      const StopwatchChallengeApp(initialRoute: '/admin'),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Admin Console'), findsOneWidget);
    expect(find.textContaining('Demo mode'), findsOneWidget);
    expect(find.text('Active users'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
  });

  testWidgets('admin dashboard fits a mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));
    await tester.pump();

    expect(find.text('Admin Console'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
