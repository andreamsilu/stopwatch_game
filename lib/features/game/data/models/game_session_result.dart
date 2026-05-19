class GameSessionResult {
  const GameSessionResult({
    required this.stoppedTimeMs,
    required this.differenceMs,
    required this.winner,
    required this.prizeAmount,
    this.message,
    this.deltaLabel,
    this.prizeLabel,
    this.createdAt,
  });

  factory GameSessionResult.fromJson(Map<String, dynamic> json) {
    return GameSessionResult(
      stoppedTimeMs: json['stoppedTimeMs'] as int,
      differenceMs: json['differenceMs'] as int,
      winner: json['winner'] as bool,
      prizeAmount: (json['prizeAmount'] as num).toInt(),
      message: json['message'] as String?,
      deltaLabel: json['deltaLabel'] as String?,
      prizeLabel: json['prizeLabel'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  final int stoppedTimeMs;
  final int differenceMs;
  final bool winner;
  final int prizeAmount;
  final String? message;
  final String? deltaLabel;
  final String? prizeLabel;
  final String? createdAt;
}
