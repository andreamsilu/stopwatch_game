import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stopwatch_game/features/auth/data/models/auth_session.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

/// Persists JWT and user profile via [SharedPreferences].
class AuthSessionStorage {
  AuthSessionStorage({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _keyAccessToken = 'auth_access_token';
  static const _keyUserJson = 'auth_user_json';
  static const _keyExpiresAtMs = 'auth_expires_at_ms';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<void> save(AuthSession session) async {
    final prefs = await _prefs;
    await prefs.setString(_keyAccessToken, session.accessToken);
    await prefs.setString(
      _keyUserJson,
      jsonEncode(session.user.toJson()),
    );

    final expiresIn = session.expiresInSeconds;
    if (expiresIn != null && expiresIn > 0) {
      final expiresAt = DateTime.now()
          .add(Duration(seconds: expiresIn))
          .millisecondsSinceEpoch;
      await prefs.setInt(_keyExpiresAtMs, expiresAt);
    } else {
      await prefs.remove(_keyExpiresAtMs);
    }
  }

  Future<AuthSession?> readValidSession() async {
    final prefs = await _prefs;
    final token = prefs.getString(_keyAccessToken);
    final userJson = prefs.getString(_keyUserJson);
    if (token == null || token.isEmpty || userJson == null) {
      return null;
    }

    final expiresAtMs = prefs.getInt(_keyExpiresAtMs);
    if (expiresAtMs != null &&
        DateTime.now().millisecondsSinceEpoch >= expiresAtMs) {
      await clear();
      return null;
    }

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return AuthSession(
        accessToken: token,
        tokenType: 'Bearer',
        user: UserModel.fromJson(userMap),
        expiresInSeconds: expiresAtMs == null
            ? null
            : ((expiresAtMs - DateTime.now().millisecondsSinceEpoch) / 1000)
                  .ceil(),
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyUserJson);
    await prefs.remove(_keyExpiresAtMs);
  }
}
