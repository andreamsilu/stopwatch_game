class TargetTimeResponse {
  const TargetTimeResponse({
    required this.msisdn,
    required this.targetTimeMs,
    this.billingRequestId,
  });

  factory TargetTimeResponse.fromJson(Map<String, dynamic> json) {
    return TargetTimeResponse(
      msisdn: json['msisdn'] as String,
      targetTimeMs: json['targetTimeMs'] as int,
      billingRequestId: json['billingRequestId'] as String?,
    );
  }

  final String msisdn;
  final int targetTimeMs;
  final String? billingRequestId;
}
