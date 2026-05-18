import 'package:stopwatch_game/features/game/data/models/game_start_response.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

class GameSessionMapper {
  const GameSessionMapper._();

  static RoundResultData? toRoundResult(GameStartResponse session) {
    final result = session.result;
    if (result == null) return null;

    final differenceMs = result.differenceMs;
    final isWin = result.winner;
    final absDifferenceMs = differenceMs.abs();
    final timingDirection = differenceMs < 0 ? 'Early' : 'Late';
    const winToleranceMs = 100;
    final deltaLabel = isWin
        ? 'Great timing! Within +/-$winToleranceMs ms. Prize unlocked!'
        : '$timingDirection by $absDifferenceMs ms';
    const perfectStopPrizeLabel = 'Perfect Stop Reward';

    return RoundResultData(
      outcomeLabel: isWin ? 'WIN' : 'LOSE',
      deltaLabel: deltaLabel,
      finalTimeLabel: _formatDurationMs(result.stoppedTimeMs),
      differenceMs: differenceMs,
      prizeLabel: isWin ? perfectStopPrizeLabel : 'No prize',
      prizeCoins: result.prizeAmount,
      isPrizeAwarded: isWin && result.prizeAmount > 0,
    );
  }

  static String _formatDurationMs(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = duration.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$ms';
  }
}
