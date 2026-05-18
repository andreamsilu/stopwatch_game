class StartGameRequest {
  const StartGameRequest({
    required this.msisdn,
    required this.billingRequestId,
    required this.channel,
  });

  final String msisdn;
  final String billingRequestId;
  final String channel;

  Map<String, dynamic> toJson() => {
    'msisdn': msisdn,
    'billingRequestId': billingRequestId,
    'channel': channel,
  };
}
