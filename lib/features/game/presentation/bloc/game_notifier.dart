import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

class GameController extends StateNotifier<GameState> {
  GameController() : super(const GameState.initial());

  final Stopwatch _stopwatch = Stopwatch();
  final Random _random = Random();
  Timer? _ticker;

  void selectTab(GameTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void openRoundBoard() {
    state = state.copyWith(
      selectedTab: GameTab.play,
      targetTime: _generateRandomTargetTime(),
      clearLatestResult: true,
    );
  }

  Future<void> onStartPressed() async {
    if (state.isRunning || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true);
    await startGame();

    _stopwatch.start();
    _ticker?.cancel();
    _ticker = Timer.periodic(GameConstants.timerTickInterval, (_) {
      state = state.copyWith(elapsed: _stopwatch.elapsed);
    });
    state = state.copyWith(
      isRunning: true,
      isSubmitting: false,
      elapsed: _stopwatch.elapsed,
    );
  }

  Future<void> onStopPressed() async {
    if (!state.isRunning || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true);
    _stopwatch.stop();
    _ticker?.cancel();
    final stoppedElapsed = _stopwatch.elapsed;

    await stopGame();

    final backendResult = await fetchRoundResultFromBackend(
      actualElapsed: stoppedElapsed,
      targetTime: state.targetTime,
    );
    final nextHistory = [
      HistoryEntry(
        timestamp: DateTime.now(),
        timeLabel: backendResult.finalTimeLabel,
        outcome: backendResult.outcomeLabel,
      ),
      ...state.history,
    ];

    state = state.copyWith(
      isRunning: false,
      isSubmitting: false,
      elapsed: stoppedElapsed,
      latestResult: backendResult,
      history: nextHistory,
    );
  }

  void onResetPressed() {
    if (state.isSubmitting) return;

    _stopwatch.stop();
    _stopwatch.reset();
    _ticker?.cancel();

    state = state.copyWith(
      isRunning: false,
      elapsed: Duration.zero,
      targetTime: _generateRandomTargetTime(),
    );
  }

  void dismissResultDialog() {
    state = state.copyWith(clearLatestResult: true);
  }

  Future<void> startGame() async {
    // TODO: Integrate backend start endpoint here.
    // This is intentionally kept as a placeholder so game result logic
    // remains server-owned, not frontend-owned.
  }

  Future<void> stopGame() async {
    // TODO: Integrate backend stop endpoint here.
    // This is intentionally kept as a placeholder so game result logic
    // remains server-owned, not frontend-owned.
  }

  Future<RoundResultData> fetchRoundResultFromBackend({
    required Duration actualElapsed,
    required Duration targetTime,
  }) async {
    // TODO: Replace with backend response payload when endpoint is available.
    // For now, derive result from local stopwatch and target.
    final differenceMs =
        actualElapsed.inMilliseconds - targetTime.inMilliseconds;
    const winToleranceMs = 50;
    final isWin = differenceMs.abs() <= winToleranceMs;
    final absDifferenceMs = differenceMs.abs();
    final timingDirection = differenceMs < 0 ? 'Early' : 'Late';
    final deltaLabel = isWin
        ? 'Perfect stop on target'
        : '$timingDirection by $absDifferenceMs ms';

    return RoundResultData(
      outcomeLabel: isWin ? 'WIN' : 'LOSE',
      deltaLabel: deltaLabel,
      finalTimeLabel: _formatDurationWithMilliseconds(actualElapsed),
      differenceMs: differenceMs,
    );
  }

  Duration _generateRandomTargetTime() {
    const minMilliseconds = 3000;
    const maxMilliseconds = 12000;
    final randomMilliseconds =
        minMilliseconds +
        _random.nextInt(maxMilliseconds - minMilliseconds + 1);

    // Keep values on 10ms steps so stopwatch precision remains readable.
    final snappedToTenMs = (randomMilliseconds ~/ 10) * 10;
    return Duration(milliseconds: snappedToTenMs);
  }

  String _formatDurationWithMilliseconds(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = value.inMilliseconds.remainder(1000).toString().padLeft(
      3,
      '0',
    );
    return '$minutes:$seconds.$milliseconds';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }
}
