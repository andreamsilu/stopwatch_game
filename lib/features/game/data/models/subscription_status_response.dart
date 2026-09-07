class SubscriptionStatusResponse {
  const SubscriptionStatusResponse({
    required this.msisdn,
    required this.status,
    required this.subscribed,
  });

  factory SubscriptionStatusResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusResponse(
      msisdn: json['msisdn'] as String? ?? '',
      status: json['status'] as String? ?? '',
      subscribed: json['subscribed'] as bool? ?? false,
    );
  }

  final String msisdn;
  final String status;
  final bool subscribed;

  /// Both fields must confirm activation; inconsistent responses fail closed.
  bool get isActive => subscribed && status.trim().toUpperCase() == 'ACTIVE';
}
