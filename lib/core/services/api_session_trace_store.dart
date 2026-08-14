import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stopwatch_game/core/api/api_logger.dart';
import 'package:uuid/uuid.dart';

enum SessionTraceKind { api, event }

/// A sanitized API exchange or client telemetry event from this app process.
class SessionTraceRecord {
  const SessionTraceRecord({
    required this.id,
    required this.kind,
    required this.occurredAt,
    required this.label,
    this.method,
    this.path,
    this.maskedMsisdn,
    this.statusCode,
    this.durationMs,
    this.request,
    this.response,
    this.error,
  });

  final String id;
  final SessionTraceKind kind;
  final DateTime occurredAt;
  final String label;
  final String? method;
  final String? path;
  final String? maskedMsisdn;
  final int? statusCode;
  final int? durationMs;
  final Object? request;
  final Object? response;
  final String? error;

  bool get succeeded =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

class _PendingApiTrace {
  const _PendingApiTrace({
    required this.id,
    required this.method,
    required this.uri,
    required this.startedAt,
    required this.request,
    required this.maskedMsisdn,
  });

  final String id;
  final String method;
  final Uri uri;
  final DateTime startedAt;
  final Object? request;
  final String? maskedMsisdn;
}

/// In-memory, process-scoped trace store for the temporary admin dashboard.
///
/// Records are sanitized before insertion, capped at [maxRecords], and are
/// discarded when the Flutter process/browser tab is reloaded.
class ApiSessionTraceStore extends ChangeNotifier {
  ApiSessionTraceStore._();

  static final instance = ApiSessionTraceStore._();
  static const maxRecords = 200;
  static const _uuid = Uuid();

  final String sessionId = _uuid.v4();
  final List<SessionTraceRecord> _records = [];
  final Map<String, _PendingApiTrace> _pending = {};

  List<SessionTraceRecord> get records => List.unmodifiable(_records.reversed);

  String? get maskedMsisdn {
    for (final record in _records.reversed) {
      if (record.maskedMsisdn != null) return record.maskedMsisdn;
    }
    return null;
  }

  String beginApiRequest({
    required String method,
    required Uri uri,
    required Map<String, dynamic> body,
  }) {
    final id = _uuid.v4();
    final sanitizedBody = method == 'GET'
        ? null
        : ApiLogger.sanitizeForLogging(body);
    _pending[id] = _PendingApiTrace(
      id: id,
      method: method,
      uri: ApiLogger.sanitizeUriForLogging(uri),
      startedAt: DateTime.now().toUtc(),
      request: sanitizedBody,
      maskedMsisdn: _findMaskedMsisdn(
        ApiLogger.sanitizeForLogging(body),
        ApiLogger.sanitizeUriForLogging(uri),
      ),
    );
    return id;
  }

  void completeApiRequest({
    required String traceId,
    required int statusCode,
    required String responseBody,
  }) {
    final pending = _pending.remove(traceId);
    if (pending == null) return;
    final now = DateTime.now().toUtc();
    _append(
      SessionTraceRecord(
        id: pending.id,
        kind: SessionTraceKind.api,
        occurredAt: pending.startedAt,
        label: '${pending.method} ${pending.uri.path}',
        method: pending.method,
        path: pending.uri.path,
        maskedMsisdn: pending.maskedMsisdn,
        statusCode: statusCode,
        durationMs: now.difference(pending.startedAt).inMilliseconds,
        request: pending.request,
        response: _sanitizeResponse(responseBody),
      ),
    );
  }

  void failApiRequest({required String traceId, required Object error}) {
    final pending = _pending.remove(traceId);
    if (pending == null) return;
    final now = DateTime.now().toUtc();
    _append(
      SessionTraceRecord(
        id: pending.id,
        kind: SessionTraceKind.api,
        occurredAt: pending.startedAt,
        label: '${pending.method} ${pending.uri.path}',
        method: pending.method,
        path: pending.uri.path,
        maskedMsisdn: pending.maskedMsisdn,
        durationMs: now.difference(pending.startedAt).inMilliseconds,
        request: pending.request,
        error: 'Transport error (${error.runtimeType})',
      ),
    );
  }

  void recordEvent(String eventName, Map<String, dynamic> properties) {
    final sanitized = ApiLogger.sanitizeForLogging(properties);
    _append(
      SessionTraceRecord(
        id: _uuid.v4(),
        kind: SessionTraceKind.event,
        occurredAt: DateTime.now().toUtc(),
        label: eventName,
        maskedMsisdn: _findMaskedMsisdn(sanitized, null),
        request: sanitized,
      ),
    );
  }

  void clear() {
    _records.clear();
    _pending.clear();
    notifyListeners();
  }

  void addDemoRecords() {
    recordEvent('auth.login_succeeded', {'method': 'otp'});
    final loginTrace = beginApiRequest(
      method: 'POST',
      uri: Uri.parse('/api/v1/auth/login'),
      body: {'msisdn': '255700000123'},
    );
    completeApiRequest(
      traceId: loginTrace,
      statusCode: 200,
      responseBody:
          '{"status":"OTP_REQUIRED","msisdn":"255700000123","otp":"123456"}',
    );
    recordEvent('navigation.tab_viewed', {'tab': 'play'});
    final historyTrace = beginApiRequest(
      method: 'GET',
      uri: Uri.parse('/api/v1/game/history?page=0&size=20'),
      body: const {},
    );
    completeApiRequest(
      traceId: historyTrace,
      statusCode: 200,
      responseBody: '{"plays":[],"msisdn":"255700000123"}',
    );
  }

  void _append(SessionTraceRecord record) {
    _records.add(record);
    if (_records.length > maxRecords) {
      _records.removeRange(0, _records.length - maxRecords);
    }
    notifyListeners();
  }

  static Object? _sanitizeResponse(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      return ApiLogger.sanitizeForLogging(jsonDecode(trimmed));
    } catch (_) {
      return '<non-JSON response omitted>';
    }
  }

  static String? _findMaskedMsisdn(Object? value, Uri? uri) {
    if (uri != null) {
      for (final key in const ['msisdn', 'phone', 'phoneNumber']) {
        final candidate = uri.queryParameters[key];
        if (candidate != null) return candidate;
      }
    }
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString().toLowerCase();
        if ((key == 'msisdn' || key == 'phone' || key == 'phonenumber') &&
            entry.value is String) {
          return entry.value as String;
        }
        final nested = _findMaskedMsisdn(entry.value, null);
        if (nested != null) return nested;
      }
    }
    if (value is Iterable) {
      for (final item in value) {
        final nested = _findMaskedMsisdn(item, null);
        if (nested != null) return nested;
      }
    }
    return null;
  }
}
