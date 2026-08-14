import 'package:data_table_2/data_table_2.dart';
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
    expect(find.text('Admin sign in'), findsOneWidget);
    await _signInAsDummyAdmin(tester);

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Session Trace'), findsNothing);
    expect(find.textContaining('Demo mode'), findsWidgets);
    expect(find.text('Active users'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);

    await tester.tap(find.text('Play Evidence'));
    await tester.pump();
    expect(find.text('Play-access evidence register'), findsOneWidget);
    expect(find.text('Search evidence'), findsOneWidget);
    expect(find.text('Access time'), findsOneWidget);
    expect(find.text('255676589824'), findsOneWidget);
    expect(find.byIcon(Icons.unfold_more_rounded), findsWidgets);
    final evidenceGrid = tester.widget<DataTable2>(
      find.byType(DataTable2).first,
    );
    expect(evidenceGrid.border, isNotNull);
    expect(find.text('Action'), findsOneWidget);

    await tester.tap(find.byTooltip('View evidence').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Evidence · EVD-260814-1042'), findsOneWidget);
    expect(find.text('MO-7B29F1 · 10:58:12'), findsOneWidget);
    expect(find.text('Evidence chain'), findsOneWidget);
    final detailsTable = find
        .ancestor(of: find.text('Field'), matching: find.byType(DataTable2))
        .first;
    expect(tester.getSize(detailsTable).width, greaterThan(800));
    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).last, 'MO-6C18A0');
    await tester.pump();
    expect(find.text('1 evidence record'), findsOneWidget);
    expect(find.text('EVD-260814-1029'), findsWidgets);

    await tester.tap(find.text('Users'));
    await tester.pump();
    expect(find.text('Total users'), findsOneWidget);
    expect(find.text('User directory'), findsOneWidget);

    await tester.tap(find.text('Billing'));
    await tester.pump();
    expect(find.text('Collected today'), findsOneWidget);
    expect(find.text('Recent transactions'), findsOneWidget);
    expect(find.text('Provider performance'), findsNothing);

    await tester.tap(find.text('Security'));
    await tester.pump();
    expect(find.text('OTP failures'), findsOneWidget);
    expect(find.text('Access and integrity events'), findsOneWidget);

    await tester.tap(find.byTooltip('Admin logout'));
    await tester.pump();
    expect(find.text('Admin sign in'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('admin rejects invalid dummy credentials', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));
    await tester.enterText(
      find.byKey(const ValueKey('admin-email')),
      'wrong@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('admin-password')),
      'wrong-password',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Invalid admin email or password.'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('admin dashboard fits a mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));
    await tester.pump();
    await _signInAsDummyAdmin(tester);

    expect(find.text('Dashboard'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Open admin navigation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Play Evidence'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Play-access evidence register'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin evidence fits the narrow desktop breakpoint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));
    await tester.pump();
    await _signInAsDummyAdmin(tester);
    await tester.tap(find.text('Play Evidence'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Play-access evidence register'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _signInAsDummyAdmin(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const ValueKey('admin-email')),
    'admin@greentelecom.co.tz',
  );
  await tester.enterText(
    find.byKey(const ValueKey('admin-password')),
    'admin123',
  );
  await tester.tap(find.text('Sign in'));
  await tester.pump(const Duration(milliseconds: 300));
}
