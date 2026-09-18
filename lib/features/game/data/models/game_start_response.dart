import 'package:stopwatch_game/features/game/data/models/game_session_result.dart';

class GameStartResponse {
  const GameStartResponse({
    required this.id,
    required this.sessionRef,
    this.billingRequestId,
    this.entrySource,
    this.playCreditId,
    this.renewalRequestId,
    this.clientReference,
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
      billingRequestId: json['billingRequestId'] as String?,
      entrySource: json['entrySource'] as String?,
      playCreditId: (json['playCreditId'] as num?)?.toInt(),
      renewalRequestId: json['renewalRequestId'] as String?,
      clientReference: json['clientReference'] as String?,
      msisdn: json['msisdn'] as String,
      channel: json['channel'] as String,
      entryFee: (json['entryFee'] as num).toInt(),
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
  final String? billingRequestId;
  final String? entrySource;
  final int? playCreditId;
  final String? renewalRequestId;
  final String? clientReference;
  final String msisdn;
  final String channel;
  final int entryFee;
  final int targetTimeMs;
  final String status;
  final String? startedAt;
  final String? endedAt;
  final GameSessionResult? result;
}
