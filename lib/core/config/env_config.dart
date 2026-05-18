import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads `API_BASE_URL` and related keys from the project `.env` file.
class EnvConfig {
  EnvConfig._();

  static bool _isLoaded = false;

  static const String _defaultBaseUrl = 'http://188.64.189.38:9090';
  static const String _defaultApiPrefix = '/api/v1';

  static Future<void> load() async {
    if (_isLoaded) return;

    await dotenv.load(fileName: '.env');
    _isLoaded = true;
  }

  static String _optional(String key, String fallback) {
    if (!_isLoaded) {
      throw StateError('EnvConfig.load() must be called before reading $key');
    }
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) return fallback;
    return value;
  }

  static String get apiBaseUrl {
    final raw = _optional('API_BASE_URL', _defaultBaseUrl);
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static String get apiPrefix {
    final raw = _optional('API_PREFIX', _defaultApiPrefix);
    if (!raw.startsWith('/')) return '/$raw';
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static bool _isTruthy(String raw) =>
      raw == 'true' || raw == '1' || raw == 'yes';

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

  static double get gameEntryFee {
    final raw = _optional('GAME_ENTRY_FEE', '0.01');
    return double.tryParse(raw) ?? 0.01;
  }

  static Duration get billingPollInterval {
    final ms = int.tryParse(_optional('BILLING_POLL_INTERVAL_MS', '2000')) ?? 2000;
    return Duration(milliseconds: ms.clamp(500, 30000));
  }

  static Duration get billingPollTimeout {
    final ms = int.tryParse(_optional('BILLING_POLL_TIMEOUT_MS', '120000')) ?? 120000;
    return Duration(milliseconds: ms.clamp(5000, 600000));
  }

  /// Log backend request/response bodies to the console via [ApiLogger].
  static bool get apiLogResponses {
    final raw = _optional('API_LOG_RESPONSES', 'true').toLowerCase();
    return _isTruthy(raw);
  }
}
