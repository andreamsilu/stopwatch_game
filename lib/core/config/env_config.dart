import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stopwatch_game/core/config/env_file_loader.dart';

/// Loads `API_BASE_URL` and related keys from the project `.env` file.
class EnvConfig {
  EnvConfig._();

  static bool _isLoaded = false;
  static bool? _hmacEnabledResolved;

  static const String _defaultApiPrefix = '/api/v1';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
    await loadEnvFromDiskIfPresent();
    _isLoaded = true;

    _hmacEnabledResolved = _parseBool(
      'STOPWATCH_SECURITY_HMAC_ENABLED',
      defaultValue: false,
    );

    debugPrint(
      '[EnvConfig] STOPWATCH_SECURITY_HMAC_ENABLED='
      '${dotenv.env['STOPWATCH_SECURITY_HMAC_ENABLED']?.trim() ?? '<unset>'} '
      '→ signing ${_hmacEnabledResolved! ? "ON" : "OFF"}',
    );
    if (kIsWeb && kDebugMode) {
      debugPrint(
        '[EnvConfig] Web uses bundled .env — after editing .env, stop the app '
        'and run again (or `flutter build web`) so assets refresh.',
      );
    }
  }

  static String _optional(String key, String fallback) {
    if (!_isLoaded) {
      throw StateError('EnvConfig.load() must be called before reading $key');
    }
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) return fallback;
    return value;
  }

  static String _required(String key) {
    if (!_isLoaded) {
      throw StateError('EnvConfig.load() must be called before reading $key');
    }
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('$key must be set in the project .env file');
    }
    return value;
  }

  static String get apiBaseUrl {
    final raw = _required('API_BASE_URL');
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static String get apiPrefix {
    final raw = _optional('API_PREFIX', _defaultApiPrefix);
    if (!raw.startsWith('/')) return '/$raw';
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static bool _isTruthy(String raw) =>
      raw == 'true' || raw == '1' || raw == 'yes';

  static bool _parseBool(String key, {required bool defaultValue}) {
    final raw = _optional(
      key,
      defaultValue ? 'true' : 'false',
    ).toLowerCase();
    if (_isTruthy(raw)) return true;
    if (raw == 'false' || raw == '0' || raw == 'no' || raw == 'off') {
      return false;
    }
    return defaultValue;
  }

  /// API allows only `APP`, `SMS`, or `WEB` (uppercase). Values like `web` in `.env` are normalized.
  static String get gameChannel {
    final raw = _optional('GAME_CHANNEL', 'SMS').toUpperCase();
    switch (raw) {
      case 'APP':
      case 'SMS':
      case 'WEB':
        return raw;
      default:
        return 'SMS';
    }
  }

  static Duration get billingPollInterval {
    final ms = int.tryParse(_optional('BILLING_POLL_INTERVAL_MS', '2000')) ?? 2000;
    return Duration(milliseconds: ms.clamp(500, 30000));
  }

  static Duration get billingPollTimeout {
    final ms = int.tryParse(_optional('BILLING_POLL_TIMEOUT_MS', '30000')) ?? 30000;
    return Duration(milliseconds: ms.clamp(5000, 600000));
  }

  /// Maximum delay between billing status polls after backoff (see [billingPollBackoffMultiplier]).
  static Duration get billingPollBackoffMax {
    final ms = int.tryParse(_optional('BILLING_POLL_BACKOFF_MAX_MS', '12000')) ??
        12000;
    final intervalMs = billingPollInterval.inMilliseconds;
    return Duration(milliseconds: ms.clamp(intervalMs, 120000));
  }

  /// Multiplied by the current delay after each non-terminal poll (typical 1.25–2.0).
  static double get billingPollBackoffMultiplier {
    final raw = double.tryParse(
      _optional('BILLING_POLL_BACKOFF_MULTIPLIER', '1.5'),
    );
    final m = raw ?? 1.5;
    if (m.isNaN) return 1.5;
    return m.clamp(1.05, 3.0);
  }

  /// Log backend request/response bodies to the console via [ApiLogger].
  static bool get apiLogResponses {
    final raw = _optional('API_LOG_RESPONSES', 'true').toLowerCase();
    return _isTruthy(raw);
  }

  /// When true, signed requests include `X-TIMESTAMP`, `X-NONCE`, `X-SIGNATURE`.
  static bool get hmacEnabled {
    if (_hmacEnabledResolved != null) return _hmacEnabledResolved!;
    return _parseBool('STOPWATCH_SECURITY_HMAC_ENABLED', defaultValue: false);
  }

  /// Shared secret for HMAC-SHA256 (must match backend `stopwatch.security.hmac.secret`).
  static String get hmacSecret =>
      _optional('STOPWATCH_SECURITY_HMAC_SECRET', '');

}
