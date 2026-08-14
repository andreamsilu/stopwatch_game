import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stopwatch_game/core/api/api_exception.dart';
import 'package:stopwatch_game/core/api/api_json.dart';
import 'package:stopwatch_game/core/api/api_messages.dart';
import 'package:stopwatch_game/core/api/api_logger.dart';
import 'package:stopwatch_game/core/api/api_response.dart';
import 'package:stopwatch_game/core/api/stopwatch_hmac.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/core/services/api_session_trace_store.dart';

/// HTTP transport — JSON request bodies, optional HMAC signing, response decoding.
class StopwatchApi {
  StopwatchApi({http.Client? client, String? Function()? accessTokenProvider})
    : _client = client ?? http.Client(),
      _accessTokenProvider = accessTokenProvider ?? (() => null);

  factory StopwatchApi.create({String? Function()? accessTokenProvider}) =>
      StopwatchApi(accessTokenProvider: accessTokenProvider);

  final http.Client _client;
  final String? Function() _accessTokenProvider;

  Map<String, String> _buildHeaders([Map<String, String>? extra]) {
    final headers = <String, String>{...ApiJson.jsonHeaders, ...?extra};
    final token = _accessTokenProvider();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, String> _hmacHeaders({
    required String method,
    required Uri uri,
    required String body,
  }) {
    if (!EnvConfig.hmacEnabled) return const {};

    final requestUri = uri.path;
    if (StopwatchHmac.isExcluded(requestUri)) return const {};

    return StopwatchHmac.sign(
      method: method,
      requestUri: requestUri,
      body: body,
      secret: EnvConfig.hmacSecret,
    );
  }

  Future<ApiResponse> get(
    Uri uri, {
    Map<String, String>? headers,
    bool allowNotFound = false,
  }) async {
    return _send(
      method: 'GET',
      uri: uri,
      headers: headers,
      allowNotFound: allowNotFound,
    );
  }

  Future<ApiResponse> post(
    Uri uri, {
    Map<String, dynamic> body = const {},
    Map<String, String>? headers,
    bool allowNotFound = false,
  }) async {
    return _send(
      method: 'POST',
      uri: uri,
      body: body,
      headers: headers,
      allowNotFound: allowNotFound,
    );
  }

  Future<ApiResponse> _send({
    required String method,
    required Uri uri,
    Map<String, dynamic> body = const {},
    Map<String, String>? headers,
    bool allowNotFound = false,
  }) async {
    final bodyText = method == 'GET' ? '' : ApiJson.encodeBody(body);
    final requestHeaders = {
      ..._buildHeaders(headers),
      ..._hmacHeaders(method: method, uri: uri, body: bodyText),
    };

    final traceId = ApiSessionTraceStore.instance.beginApiRequest(
      method: method,
      uri: uri,
      body: body,
    );

    ApiLogger.logRequest(
      method: method,
      uri: uri,
      headers: requestHeaders,
      body: method == 'GET' ? null : body,
    );

    final started = DateTime.now();
    try {
      final response = await _dispatch(
        method: method,
        uri: uri,
        headers: requestHeaders,
        body: bodyText,
      );
      ApiSessionTraceStore.instance.completeApiRequest(
        traceId: traceId,
        statusCode: response.statusCode,
        responseBody: response.body,
      );
      _logHttpResponse(
        method: method,
        uri: uri,
        response: response,
        started: started,
      );
      return _toApiResponse(response, allowNotFound: allowNotFound);
    } catch (e, stack) {
      ApiSessionTraceStore.instance.failApiRequest(traceId: traceId, error: e);
      _logHttpError(method: method, uri: uri, error: e, started: started);
      _rethrowTransportError(e, stack);
    }
  }

  Future<http.Response> _dispatch({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) {
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: body);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  void close() => _client.close();

  Never _rethrowTransportError(Object error, StackTrace stack) {
    if (error is ApiException) {
      Error.throwWithStackTrace(error, stack);
    }

    final message = error.toString();
    if (kIsWeb &&
        (message.contains('Failed to fetch') ||
            message.contains('XMLHttpRequest'))) {
      throw ApiException(
        'Browser blocked the API call (CORS). '
        'Run with "Windows (desktop)" in VS Code, or enable CORS on the server '
        'for the current web origin (${Uri.base.origin}).',
      );
    }

    Error.throwWithStackTrace(error, stack);
  }

  void _logHttpResponse({
    required String method,
    required Uri uri,
    required http.Response response,
    required DateTime started,
  }) {
    ApiLogger.logResponse(
      method: method,
      uri: uri,
      statusCode: response.statusCode,
      body: response.body,
      durationMs: DateTime.now().difference(started).inMilliseconds,
      responseHeaders: response.headers,
    );
  }

  void _logHttpError({
    required String method,
    required Uri uri,
    required Object error,
    required DateTime started,
  }) {
    ApiLogger.logError(
      method: method,
      uri: uri,
      error: error,
      durationMs: DateTime.now().difference(started).inMilliseconds,
    );
  }

  ApiResponse _toApiResponse(
    http.Response response, {
    required bool allowNotFound,
  }) {
    if (allowNotFound && response.statusCode == 404) {
      return ApiResponse(statusCode: 404, body: response.body, json: null);
    }

    if (response.statusCode == 204) {
      return ApiResponse(statusCode: 204, body: response.body, json: null);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final trimmed = response.body.trim();
      final json = trimmed.isEmpty ? null : ApiJson.decodeObject(trimmed);
      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
        json: json,
      );
    }

    throw ApiException(
      ApiMessages.fromResponse(
        ApiResponse(
          statusCode: response.statusCode,
          body: response.body,
          json: null,
        ),
      ),
      statusCode: response.statusCode,
    );
  }
}
