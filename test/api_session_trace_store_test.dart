import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/services/api_session_trace_store.dart';

void main() {
  setUp(ApiSessionTraceStore.instance.clear);

  test('captures one sanitized API exchange with masked MSISDN', () {
    final store = ApiSessionTraceStore.instance;
    final traceId = store.beginApiRequest(
      method: 'POST',
      uri: Uri.parse('/api/v1/auth/login'),
      body: {
        'msisdn': '255676589824',
        'otp': '123456',
        'accessToken': 'request-token',
      },
    );

    store.completeApiRequest(
      traceId: traceId,
      statusCode: 200,
      responseBody:
          '{"msisdn":"255676589824","otp":"123456","accessToken":"response-token"}',
    );

    final record = store.records.single;
    final request = record.request! as Map<String, dynamic>;
    final response = record.response! as Map<String, dynamic>;
    expect(record.maskedMsisdn, '255676***824');
    expect(request['otp'], '<redacted>');
    expect(request['accessToken'], '<redacted>');
    expect(response['msisdn'], '255676***824');
    expect(response['otp'], '<redacted>');
    expect(response['accessToken'], '<redacted>');
  });

  test('caps the local session trace', () {
    final store = ApiSessionTraceStore.instance;
    for (var index = 0; index < ApiSessionTraceStore.maxRecords + 5; index++) {
      store.recordEvent('test.event', {'index': index});
    }

    expect(store.records, hasLength(ApiSessionTraceStore.maxRecords));
  });
}
