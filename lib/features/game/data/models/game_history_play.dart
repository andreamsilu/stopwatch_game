import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

/// One row from `GET /api/v1/game/history` → `plays[]`.
class GameHistoryPlay {
  const GameHistoryPlay({
    required this.playedAt,
    required this.sessionRef,
    required this.targetTimeMs,
    required this.stoppedTimeMs,
    required this.winner,
  });

  factory GameHistoryPlay.fromJson(Map<String, dynamic> json) {
    return GameHistoryPlay(
      playedAt: DateTime.parse(json['playedAt'] as String),
      sessionRef: json['sessionRef'] as String,
      targetTimeMs: (json['targetTimeMs'] as num).toInt(),
      stoppedTimeMs: (json['stoppedTimeMs'] as num).toInt(),
      winner: json['winner'] as bool,
    );
  }

  final DateTime playedAt;
  final String sessionRef;
  final int targetTimeMs;
  final int stoppedTimeMs;
  final bool winner;

  String get outcomeLabel => winner ? 'WIN' : 'LOSE';

  String get stoppedTimeLabel =>
      GameState.formatTargetTime(Duration(milliseconds: stoppedTimeMs));

  String get targetTimeLabel =>
      GameState.formatTargetTime(Duration(milliseconds: targetTimeMs));
}
