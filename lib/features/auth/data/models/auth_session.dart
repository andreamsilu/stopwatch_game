import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

/// Response from `POST /api/v1/auth/verify-otp`.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.user,
    this.expiresInSeconds,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresInSeconds: json['expiresInSeconds'] as int?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final String tokenType;
  final int? expiresInSeconds;
  final UserModel user;
}
