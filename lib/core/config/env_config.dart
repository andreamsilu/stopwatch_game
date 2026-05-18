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

  /// When `true`, auth skips HTTP and uses local mock OTP (`123456`).
  static bool get useMockAuth {
    final raw = _optional('MOCK_AUTH', 'true').toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}
