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

  /// Decodes a JSON object or throws [ApiException] using the response body when possible.
  static Map<String, dynamic> decodeObject(
    String body, {
    String? context,
  }) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ApiException(
        messageFromErrorBody(body) ??
            (context != null
                ? '$context: response body was empty.'
                : 'Response body was empty.'),
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
        messageFromErrorBody(body) ??
            (context != null
                ? '$context: invalid JSON (${e.message}).'
                : 'Invalid JSON response (${e.message}).'),
      );
    } catch (_) {
      throw ApiException(
        messageFromErrorBody(body) ??
            (context != null
                ? '$context: could not parse JSON.'
                : 'Could not parse JSON.'),
      );
    }
  }

  static String? messageFromErrorBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        return messageFromMap(json);
      }
      if (json is Map) {
        return messageFromMap(json.map((k, v) => MapEntry(k.toString(), v)));
      }
    } catch (_) {
      final trimmed = body.trim();
      if (trimmed.length <= 280 && !trimmed.startsWith('{')) {
        return trimmed;
      }
    }
    return null;
  }

  static String? messageFromMap(Map<String, dynamic> json) {
    for (final key in const ['message', 'detail', 'title', 'errorMessage']) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }

    final nested = json['error'];
    if (nested is Map) {
      final nestedMap = nested.map((k, v) => MapEntry(k.toString(), v));
      final nestedMessage = messageFromMap(Map<String, dynamic>.from(nestedMap));
      if (nestedMessage != null) return nestedMessage;
    }
    if (nested is String && nested.trim().isNotEmpty) {
      final status = json['status'];
      final path = json['path'];
      final buffer = StringBuffer(nested.trim());
      if (status is int) buffer.write(' ($status)');
      if (path is String) buffer.write(': $path');
      return buffer.toString();
    }

    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      final parts = <String>[];
      for (final item in errors) {
        if (item is String && item.trim().isNotEmpty) {
          parts.add(item.trim());
        } else if (item is Map) {
          final itemMap = item.map((k, v) => MapEntry(k.toString(), v));
          final part = messageFromMap(Map<String, dynamic>.from(itemMap));
          if (part != null) parts.add(part);
        }
      }
      if (parts.isNotEmpty) return parts.join(' ');
    }

    return null;
  }
}
