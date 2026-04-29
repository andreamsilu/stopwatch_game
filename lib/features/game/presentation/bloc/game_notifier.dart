import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

class GameController extends StateNotifier<GameState> {
  GameController() : super(const GameState.initial());

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  void selectTab(GameTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void openRoundBoard() {
    state = state.copyWith(
      selectedTab: GameTab.home,
      showRoundBoard: true,
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
      showRoundBoard: true,
    );
  }

  Future<void> onStopPressed() async {
    if (!state.isRunning || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true);
    _stopwatch.stop();
    _ticker?.cancel();

    await stopGame();

    final backendResult = await fetchRoundResultFromBackend();
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
      elapsed: _stopwatch.elapsed,
      latestResult: backendResult,
      history: nextHistory,
    );
  }

  void onResetPressed() {
    if (state.isSubmitting) return;

    _stopwatch.stop();
    _stopwatch.reset();
    _ticker?.cancel();

    state = state.copyWith(isRunning: false, elapsed: Duration.zero);
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

  Future<RoundResultData> fetchRoundResultFromBackend() async {
    // TODO: Replace with backend response payload.
    // Do not derive official result on frontend. Backend should own scoring.
    return const RoundResultData(
      outcomeLabel: 'LOSE',
      deltaLabel: 'Early by 3958 ms',
      finalTimeLabel: '00:04.375',
      differenceMs: -3958,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }
}
