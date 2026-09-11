import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/game_message_dialog.dart';

void main() {
  testWidgets('portal message fits mobile and both close controls dismiss it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const message =
        'Huna salio la kutosha kulipia mchezo wa Stop Watch (TZS 100). Tafadhali ongeza salio na ujaribu tena.';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const GameMessageDialog(message: message),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    for (final useIcon in [false, true]) {
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(
        useIcon ? find.byIcon(Icons.close) : find.byType(ElevatedButton),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GameMessageDialog), findsNothing);
    }
  });
}
