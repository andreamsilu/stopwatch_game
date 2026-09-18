class StartGameRequest {
  const StartGameRequest.billing({
    required this.msisdn,
    required this.channel,
    required this.billingRequestId,
  }) : entrySource = null,
       playCreditId = null,
       clientReference = null;

  const StartGameRequest.credit({
    required this.msisdn,
    required this.channel,
    required this.entrySource,
    required this.playCreditId,
    required this.clientReference,
  }) : billingRequestId = null,
       assert(playCreditId != null),
       assert(clientReference != null);

  final String msisdn;
  final String channel;
  final String? billingRequestId;
  final String? entrySource;
  final int? playCreditId;
  final String? clientReference;

  Map<String, dynamic> toJson() => {
    'msisdn': msisdn,
    'channel': channel,
    if (billingRequestId != null) 'billingRequestId': billingRequestId,
    if (entrySource != null) 'entrySource': entrySource,
    if (playCreditId != null) 'playCreditId': playCreditId,
    if (clientReference != null) 'clientReference': clientReference,
  };
}
