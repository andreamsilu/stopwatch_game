import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:stopwatch_game/core/api/api_exception.dart';
import 'package:uuid/uuid.dart';

/// HMAC request signing for Stopwatch API (`HmacSignatureFilter`).
///
/// Payload: `METHOD + requestURI + body + timestamp + nonce` (no separators).
/// Signature: HMAC-SHA256 hex (lowercase).
class StopwatchHmac {
  StopwatchHmac._();

  static const _uuid = Uuid();

  static const timestampHeader = 'X-TIMESTAMP';
  static const nonceHeader = 'X-NONCE';
  static const signatureHeader = 'X-SIGNATURE';

  /// Routes that never require HMAC (even when enabled on the server).
  static bool isExcluded(String requestUri) {
    final path = _normalizePath(requestUri);
    return path.startsWith('/api/v1/auth/login') ||
        path.startsWith('/api/v1/auth/verify-otp') ||
        path.startsWith('/api/v1/billing/callbacks/') ||
        path.startsWith('/api/v1/disbursements/callbacks/') ||
        path.startsWith('/actuator/') ||
        path.startsWith('/swagger-ui') ||
        path == '/v3/api-docs' ||
        path.startsWith('/v3/api-docs/');
  }

  static String buildPayload({
    required String method,
    required String requestUri,
    required String body,
    required String timestamp,
    required String nonce,
  }) {
    return method.toUpperCase() +
        _normalizePath(requestUri) +
        body +
        timestamp +
        nonce;
  }

  static String hmacSha256Hex(String payload, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(payload);
    return Hmac(sha256, key).convert(bytes).toString();
  }

  static Map<String, String> sign({
    required String method,
    required String requestUri,
    required String body,
    required String secret,
  }) {
    if (secret.isEmpty) {
      throw ApiException(
        'HMAC is enabled but STOPWATCH_SECURITY_HMAC_SECRET is not set.',
      );
    }

    final timestamp = utcTimestamp();
    final nonce = generateNonce();
    final payload = buildPayload(
      method: method,
      requestUri: requestUri,
      body: body,
      timestamp: timestamp,
      nonce: nonce,
    );
    final signature = hmacSha256Hex(payload, secret);

    return {
      timestampHeader: timestamp,
      nonceHeader: nonce,
      signatureHeader: signature,
    };
  }

  /// ISO-8601 UTC timestamp (e.g. `2026-05-19T14:00:00.000Z`).
  static String utcTimestamp() => DateTime.now().toUtc().toIso8601String();

  static String generateNonce() => _uuid.v4();

  static String _normalizePath(String requestUri) {
    final trimmed = requestUri.trim();
    if (trimmed.isEmpty) return '/';
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }
}
