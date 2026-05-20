/// Placeholder sent only to pass API validation (`InitiateBillingRequest.amount`).
///
/// The server applies `stopwatch.billing.entry-fee` and ignores this value.
const double billingRequestAmountPlaceholder = 0.01;

class BillingTransactionRequest {
  const BillingTransactionRequest({
    required this.msisdn,
    double? amount,
  }) : amount = amount ?? billingRequestAmountPlaceholder;

  final String msisdn;

  /// Required by OpenAPI validation; not used for the actual charge.
  final double amount;

  Map<String, dynamic> toJson() => {
    'msisdn': msisdn,
    'amount': amount,
  };
}
