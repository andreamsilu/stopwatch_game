import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/features/admin/presentation/widgets/admin_game_settings_panel.dart';

void main() {
  testWidgets(
    'configuration validates and previews without enabling API actions',
    (tester) async {
      final draft = AdminGameSettingsDraft();
      addTearDown(draft.dispose);
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AdminGameSettingsPanel(draft: draft),
            ),
          ),
        ),
      );
      expect(find.text('API integration pending'), findsOneWidget);
      expect(find.text('Timer runs at 1.00×'), findsOneWidget);
      await tester.tap(find.text('Fast (1.5×)'));
      await tester.pump();
      expect(find.text('Timer runs at 1.50×'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Near-win tolerance (± ms)'),
        '0',
      );
      await tester.pump();
      expect(find.text('Enter a whole number from 1 to 5000.'), findsOneWidget);
      expect(
        find.text('Enter valid values to preview the configuration.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Near-win tolerance (± ms)'),
        '75',
      );
      await tester.pump();
      expect(find.text('Near-win tolerance: ±75 ms'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNothing);
      for (final button in tester.widgetList<FilledButton>(
        find.byType(FilledButton),
      )) {
        expect(button.onPressed, isNull);
      }
      expect(tester.takeException(), isNull);
      for (final width in [320.0, 390.0, 900.0]) {
        tester.view.physicalSize = Size(width, 844);
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Configuration fits $width pixels',
        );
      }
    },
  );
}
