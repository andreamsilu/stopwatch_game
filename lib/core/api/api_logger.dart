import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Privacy-safe console logging for [StopwatchApi] request/response traffic.
class ApiLogger {
  ApiLogger._();

  /// When false, no HTTP lines are printed.
  static bool enabled = true;

  static const _name = 'StopwatchApi';
  static const _maxBodyLength = 8000;
  static const _redacted = '<redacted>';
  static const _secretKeys = {
    'accesstoken',
    'authorization',
    'cookie',
    'hmacsecret',
    'otp',
    'password',
    'refreshtoken',
    'secret',
    'setcookie',
    'signature',
    'token',
    'xnonce',
    'xsignature',
  };
  static const _phoneKeys = {'msisdn', 'phone', 'phonenumber', 'username'};

  static void _emit(String message, {int level = 800}) {
    debugPrint('[$_name] $message');
    if (!kIsWeb) {
      developer.log(message, name: _name, level: level);
    }
  }

  static void logRequest({
    required String method,
    required Uri uri,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer()
      ..writeln('→ $method ${sanitizeUriForLogging(uri)}');
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('  headers: ${_prettyJson(_redactHeaders(headers))}');
    }
    if (body != null) {
      buffer.writeln('  request: ${_prettyJson(sanitizeForLogging(body))}');
    }
    _emit(buffer.toString().trimRight());
  }

  static void logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
    required int durationMs,
    Map<String, String>? responseHeaders,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer()
      ..writeln(
        '← $method $statusCode (${durationMs}ms) '
        '${sanitizeUriForLogging(uri)}',
      );
    if (responseHeaders != null && responseHeaders.isNotEmpty) {
      buffer.writeln(
        '  response-headers: ${_prettyJson(_redactHeaders(responseHeaders))}',
      );
    }
    buffer.writeln(
      body.trim().isEmpty
          ? '  response: <empty>'
          : '  response: ${_prettyBody(body)}',
    );
    _emit(buffer.toString().trimRight());
  }

  static void logError({
    required String method,
    required Uri uri,
    required Object error,
    required int durationMs,
  }) {
    if (!enabled) return;
    _emit(
      '✕ $method ERROR (${durationMs}ms) '
      '${sanitizeUriForLogging(uri)}\n  ${_redactText('$error')}',
      level: 1000,
    );
  }

  static Map<String, String> _redactHeaders(Map<String, String> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: _secretKeys.contains(_normalizeKey(entry.key))
            ? _redacted
            : entry.value,
    };
  }

  static String _prettyBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return '<empty>';
    try {
      return _truncate(_prettyJson(sanitizeForLogging(jsonDecode(trimmed))));
    } catch (_) {
      return _truncate(_redactText(trimmed));
    }
  }

  /// Recursively removes credentials and masks phone-number fields.
  @visibleForTesting
  static Object? sanitizeForLogging(Object? value, {String? key}) {
    final normalizedKey = key == null ? '' : _normalizeKey(key);
    if (_secretKeys.contains(normalizedKey)) return _redacted;
    if (_phoneKeys.contains(normalizedKey) && value is String) {
      return _maskPhone(value);
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): sanitizeForLogging(
            entry.value,
            key: entry.key.toString(),
          ),
      };
    }
    if (value is Iterable) {
      return value.map((item) => sanitizeForLogging(item)).toList();
    }
    return value;
  }

  /// Removes sensitive query parameters before a URI reaches the console.
  @visibleForTesting
  static Uri sanitizeUriForLogging(Uri uri) {
    if (!uri.hasQuery) return uri;
    final sanitized = <String, String>{};
    uri.queryParameters.forEach((key, value) {
      final normalizedKey = _normalizeKey(key);
      if (_secretKeys.contains(normalizedKey)) {
        sanitized[key] = _redacted;
      } else if (_phoneKeys.contains(normalizedKey)) {
        sanitized[key] = _maskPhone(value);
      } else {
        sanitized[key] = value;
      }
    });
    return uri.replace(queryParameters: sanitized);
  }

  static String _maskPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return _redacted;
    return '${digits.substring(0, 6)}***${digits.substring(digits.length - 3)}';
  }

  static String _normalizeKey(String key) =>
      key.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();

  static String _redactText(String text) {
    return text
        .replaceAll(
          RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
          'Bearer $_redacted',
        )
        .replaceAll(RegExp(r'\b(?:255|0)\d{8,11}\b'), _redacted);
  }

  static String _prettyJson(Object? value) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(value);
  }

  static String _truncate(String text) {
    if (text.length <= _maxBodyLength) return text;
    return '${text.substring(0, _maxBodyLength)}… [truncated]';
  }
}
