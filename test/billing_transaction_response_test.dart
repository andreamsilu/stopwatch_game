import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/features/game/data/models/billing_transaction_response.dart';

void main() {
  const message =
      'Huna salio la kutosha kulipia mchezo wa Stop Watch (TZS 100). Tafadhali ongeza salio na ujaribu tena.';
  final response = <String, dynamic>{
    'id': 24,
    'msisdn': '255000000000',
    'requestId': 'test-billing-request',
    'billingType': 'Payment',
    'amount': 100,
    'status': 'failed',
    'ackDescription': 'Payment under process',
    'callbackDescription': 'Billing Failure due to low balance for Msisdn',
    'portalMessage': message,
  };

  test('billing errors use portal message instead of callback description', () {
    final billing = BillingTransactionResponse.fromJson(response);
    expect(billing.isBillingFailed, isTrue);
    expect(billing.portalMessage, message);
    expect(billing.userMessage, message);
  });

  test('older responses without portal copy retain their fallback', () {
    for (final portalMessage in [null, '', '   ']) {
      final billing = BillingTransactionResponse.fromJson({
        ...response,
        'portalMessage': portalMessage,
      });
      expect(billing.userMessage, response['callbackDescription']);
    }
  });
}
