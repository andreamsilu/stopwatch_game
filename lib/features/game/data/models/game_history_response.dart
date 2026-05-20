import 'package:stopwatch_game/features/game/data/models/game_history_play.dart';

/// Response from `GET /api/v1/game/history`.
class GameHistoryResponse {
  const GameHistoryResponse({
    required this.msisdn,
    required this.userId,
    required this.plays,
  });

  factory GameHistoryResponse.fromJson(Map<String, dynamic> json) {
    final playsJson = json['plays'] as List<dynamic>? ?? const [];
    return GameHistoryResponse(
      msisdn: json['msisdn'] as String? ?? '',
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      plays: playsJson
          .map((e) => GameHistoryPlay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String msisdn;
  final int userId;
  final List<GameHistoryPlay> plays;
}
