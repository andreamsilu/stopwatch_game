import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stopwatch_game/core/api/api_exception.dart';
import 'package:stopwatch_game/core/api/api_response.dart';

/// HTTP transport only — [GET]/[POST], status handling, JSON decode.
/// Domain parsing and workflows live in feature services.
class StopwatchApi {
  StopwatchApi({http.Client? client}) : _client = client ?? http.Client();

  factory StopwatchApi.create() => StopwatchApi();

  final http.Client _client;

  static const jsonHeaders = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static const acceptJsonHeaders = {'accept': 'application/json'};

  Future<ApiResponse> get(
    Uri uri, {
    Map<String, String>? headers,
    bool allowNotFound = false,
  }) async {
    final response = await _client.get(
      uri,
      headers: headers ?? jsonHeaders,
    );
    return _toApiResponse(response, allowNotFound: allowNotFound);
  }

  Future<ApiResponse> post(
    Uri uri, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool allowNotFound = false,
  }) async {
    final response = await _client.post(
      uri,
      headers: headers ?? jsonHeaders,
      body: body == null ? null : jsonEncode(body),
    );
    return _toApiResponse(response, allowNotFound: allowNotFound);
  }

  void close() => _client.close();

  ApiResponse _toApiResponse(
    http.Response response, {
    required bool allowNotFound,
  }) {
    if (allowNotFound && response.statusCode == 404) {
      return ApiResponse(statusCode: 404, body: response.body, json: null);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
        json: _decodeJsonBody(response.body),
      );
    }

    throw ApiException(
      _messageFromBody(response.body) ?? 'Request failed (${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic>? _decodeJsonBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    final decoded = jsonDecode(trimmed);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  String? _messageFromBody(String body) {
    if (body.isEmpty) return null;
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final error = json['error'];
        if (error is Map && error['message'] is String) {
          return error['message'] as String;
        }
        if (json['message'] is String) return json['message'] as String;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
