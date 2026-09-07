import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/round_play_panel.dart';

void main() {
  testWidgets('elapsed time remains visible and updates while running', (
    tester,
  ) async {
    Widget panel(String time, {bool running = true}) => MaterialApp(
      home: Scaffold(
        body: RoundPlayPanel(
          targetTimeLabel: '00:08.250',
          currentTimeLabel: time,
          elapsed: const Duration(seconds: 2),
          targetTime: const Duration(milliseconds: 8250),
          isRunning: running,
          isBusy: false,
          isSubmitting: false,
          isLoadingTarget: false,
          preparePhase: RoundPreparePhase.idle,
          isSoundEnabled: false,
          startButtonVisualOffset: Offset.zero,
          startButtonHitboxOffset: Offset.zero,
          onReset: () {},
          onToggleSound: () {},
          onStartControlPointerDown: (_, {isTrusted}) {},
          onStartControlPointerMove: (_) {},
          onStartControlPointerUp: (_, {isTrusted}) {},
          hasBillingForRound: true,
          onPlayRound: () async {},
          onStartOrStopRound: () async {},
          totalWins: 0,
          result: null,
          onPlayAgain: () async {},
          onViewHistory: () {},
        ),
      ),
    );

    await tester.pumpWidget(panel('00:02.000'));
    expect(find.text('00:02.000'), findsOneWidget);
    expect(find.text('8.250'), findsOneWidget);
    await tester.pumpWidget(panel('00:02.250'));
    expect(find.text('00:02.250'), findsOneWidget);
    expect(find.text('00:02.000'), findsNothing);
    await tester.pumpWidget(panel('00:02.250', running: false));
    await tester.pumpAndSettle();
    expect(find.text('00:02.250'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
