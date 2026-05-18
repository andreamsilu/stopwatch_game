import 'dart:convert';

import 'package:stopwatch_game/core/api/api_exception.dart';

/// Shared JSON encode/decode for all HTTP traffic.
class ApiJson {
  ApiJson._();

  static const jsonContentType = 'application/json; charset=utf-8';

  static Map<String, String> get jsonHeaders => const {
    'accept': 'application/json',
    'Content-Type': jsonContentType,
  };

  static String encodeBody(Map<String, dynamic> body) {
    return jsonEncode(body);
  }

  /// Decodes a JSON object or throws [ApiException] with a clear message.
  static Map<String, dynamic> decodeObject(
    String body, {
    String? context,
  }) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ApiException(
        context != null
            ? '$context: response body was empty.'
            : 'Response body was empty.',
      );
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
      throw FormatException('Expected JSON object, got ${decoded.runtimeType}');
    } on ApiException {
      rethrow;
    } on FormatException catch (e) {
      throw ApiException(
        context != null
            ? '$context: invalid JSON (${e.message}).'
            : 'Invalid JSON response (${e.message}).',
      );
    } catch (e) {
      throw ApiException(
        context != null ? '$context: could not parse JSON.' : 'Could not parse JSON.',
      );
    }
  }

  static String? messageFromErrorBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        return _messageFromMap(json);
      }
      if (json is Map) {
        return _messageFromMap(json.map((k, v) => MapEntry(k.toString(), v)));
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static String? _messageFromMap(Map<String, dynamic> json) {
    final nested = json['error'];
    if (nested is Map && nested['message'] is String) {
      return nested['message'] as String;
    }
    if (json['message'] is String) return json['message'] as String;

    // Spring Boot default error body: { status, error, path }
    if (nested is String) {
      final status = json['status'];
      final path = json['path'];
      final buffer = StringBuffer(nested);
      if (status is int) buffer.write(' ($status)');
      if (path is String) buffer.write(': $path');
      return buffer.toString();
    }
    return null;
  }
}
