import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Console logging for [StopwatchApi] request/response traffic.
///
/// View logs:
/// - **Web:** Chrome DevTools → Console (filter `StopwatchApi`)
/// - **Desktop / `flutter run`:** terminal + VS Code Debug Console
class ApiLogger {
  ApiLogger._();

  static bool enabled = true;

  static const _name = 'StopwatchApi';
  static const _maxBodyLength = 4000;

  static void _emit(String message, {int level = 800}) {
    // Single sink — using both debugPrint and developer.log duplicates lines on web.
    debugPrint('[$_name] $message');
    if (!kIsWeb) {
      developer.log(message, name: _name, level: level);
    }
  }

  static void logRequest({
    required String method,
    required Uri uri,
    Map<String, dynamic>? body,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer()
      ..writeln('→ $method $uri');

    if (body != null && body.isNotEmpty) {
      buffer.writeln('  request: ${_prettyJson(body)}');
    }

    _emit(buffer.toString().trimRight());
  }

  static void logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
    required int durationMs,
  }) {
    if (!enabled) return;

    final buffer = StringBuffer()
      ..writeln('← $method $statusCode (${durationMs}ms) $uri');

    if (body.trim().isEmpty) {
      buffer.writeln('  response: <empty>');
    } else {
      buffer.writeln('  response: ${_prettyBody(body)}');
    }

    _emit(buffer.toString().trimRight());
  }

  static void logError({
    required String method,
    required Uri uri,
    required Object error,
    required int durationMs,
  }) {
    if (!enabled) return;

    _emit('✕ $method ERROR (${durationMs}ms) $uri\n  $error', level: 1000);
  }

  static String _prettyBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return '<empty>';

    try {
      final decoded = jsonDecode(trimmed);
      return _truncate(_prettyJson(decoded));
    } catch (_) {
      return _truncate(trimmed);
    }
  }

  static String _prettyJson(Object value) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(value);
  }

  static String _truncate(String text) {
    if (text.length <= _maxBodyLength) return text;
    return '${text.substring(0, _maxBodyLength)}… [truncated]';
  }
}
