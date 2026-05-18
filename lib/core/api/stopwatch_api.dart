import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stopwatch_game/core/api/api_exception.dart';
import 'package:stopwatch_game/core/api/api_json.dart';
import 'package:stopwatch_game/core/api/api_logger.dart';
import 'package:stopwatch_game/core/api/api_response.dart';

/// HTTP transport — JSON request bodies and JSON response decoding.
class StopwatchApi {
  StopwatchApi({http.Client? client}) : _client = client ?? http.Client();

  factory StopwatchApi.create() => StopwatchApi();

  final http.Client _client;

  static Map<String, String> get jsonHeaders => ApiJson.jsonHeaders;

  Future<ApiResponse> get(
    Uri uri, {
    Map<String, String>? headers,
    bool allowNotFound = false,
  }) async {
    const method = 'GET';
    ApiLogger.logRequest(method: method, uri: uri);

    final started = DateTime.now();
    try {
      final response = await _client.get(
        uri,
        headers: headers ?? jsonHeaders,
      );
      _logHttpResponse(
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        started: started,
      );
      return _toApiResponse(response, allowNotFound: allowNotFound);
    } catch (e, stack) {
      _logHttpError(method: method, uri: uri, error: e, started: started);
      _rethrowTransportError(e, stack);
    }
  }

  Future<ApiResponse> post(
    Uri uri, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    bool allowNotFound = false,
  }) async {
    const method = 'POST';
    ApiLogger.logRequest(method: method, uri: uri, body: body);

    final started = DateTime.now();
    try {
      final response = await _client.post(
        uri,
        headers: headers ?? jsonHeaders,
        body: ApiJson.encodeBody(body),
      );
      _logHttpResponse(
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        started: started,
      );
      return _toApiResponse(response, allowNotFound: allowNotFound);
    } catch (e, stack) {
      _logHttpError(method: method, uri: uri, error: e, started: started);
      _rethrowTransportError(e, stack);
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
        'for http://localhost:8080.',
      );
    }

    Error.throwWithStackTrace(error, stack);
  }

  void _logHttpResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
    required DateTime started,
  }) {
    ApiLogger.logResponse(
      method: method,
      uri: uri,
      statusCode: statusCode,
      body: body,
      durationMs: DateTime.now().difference(started).inMilliseconds,
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final trimmed = response.body.trim();
      final json = trimmed.isEmpty
          ? null
          : ApiJson.decodeObject(trimmed);
      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
        json: json,
      );
    }

    throw ApiException(
      ApiJson.messageFromErrorBody(response.body) ??
          'Request failed (${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }
}
