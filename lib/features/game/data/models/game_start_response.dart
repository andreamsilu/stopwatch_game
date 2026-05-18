import 'package:stopwatch_game/features/game/data/models/game_session_result.dart';

class GameStartResponse {
  const GameStartResponse({
    required this.id,
    required this.sessionRef,
    required this.billingRequestId,
    required this.msisdn,
    required this.channel,
    required this.entryFee,
    required this.targetTimeMs,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.result,
  });

  factory GameStartResponse.fromJson(Map<String, dynamic> json) {
    final resultJson = json['result'];
    return GameStartResponse(
      id: json['id'] as int,
      sessionRef: json['sessionRef'] as String,
      billingRequestId: json['billingRequestId'] as String,
      msisdn: json['msisdn'] as String,
      channel: json['channel'] as String,
      entryFee: json['entryFee'] as int,
      targetTimeMs: json['targetTimeMs'] as int,
      status: json['status'] as String,
      startedAt: json['startedAt'] as String?,
      endedAt: json['endedAt'] as String?,
      result: resultJson is Map<String, dynamic>
          ? GameSessionResult.fromJson(resultJson)
          : null,
    );
  }

  final int id;
  final String sessionRef;
  final String billingRequestId;
  final String msisdn;
  final String channel;
  final int entryFee;
  final int targetTimeMs;
  final String status;
  final String? startedAt;
  final String? endedAt;
  final GameSessionResult? result;
}
