class BillingTransactionResponse {
  const BillingTransactionResponse({
    required this.id,
    required this.msisdn,
    required this.requestId,
    required this.billingType,
    required this.amount,
    required this.status,
    this.ackStatusCode,
    this.ackDescription,
    this.callbackStatusCode,
    this.callbackDescription,
    this.ackReceivedTime,
    this.callbackReceivedTime,
    this.createdAt,
    this.updatedAt,
  });

  factory BillingTransactionResponse.fromJson(Map<String, dynamic> json) {
    return BillingTransactionResponse(
      id: json['id'] as int,
      msisdn: json['msisdn'] as String,
      requestId: json['requestId'] as String,
      billingType: json['billingType'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      ackStatusCode: json['ackStatusCode'] as String?,
      ackDescription: json['ackDescription'] as String?,
      callbackStatusCode: json['callbackStatusCode'] as String?,
      callbackDescription: json['callbackDescription'] as String?,
      ackReceivedTime: json['ackReceivedTime'] as String?,
      callbackReceivedTime: json['callbackReceivedTime'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final int id;
  final String msisdn;
  final String requestId;
  final String billingType;
  final double amount;
  final String status;
  final String? ackStatusCode;
  final String? ackDescription;
  final String? callbackStatusCode;
  final String? callbackDescription;
  final String? ackReceivedTime;
  final String? callbackReceivedTime;
  final String? createdAt;
  final String? updatedAt;

  String get normalizedStatus => status.toLowerCase();

  bool get isBillingSuccess => normalizedStatus == 'success';

  bool get isBillingFailed => normalizedStatus == 'failed';

  bool get isBillingTerminal => isBillingSuccess || isBillingFailed;
}
