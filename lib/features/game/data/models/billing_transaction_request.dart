class BillingTransactionRequest {
  const BillingTransactionRequest({
    required this.msisdn,
    required this.amount,
  });

  final String msisdn;
  final double amount;

  Map<String, dynamic> toJson() => {
    'msisdn': msisdn,
    'amount': amount,
  };
}
