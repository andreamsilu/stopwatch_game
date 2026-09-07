class SubscriptionStatusRequest {
  const SubscriptionStatusRequest({required this.msisdn});

  final String msisdn;

  Map<String, dynamic> toJson() => {'msisdn': msisdn};
}
