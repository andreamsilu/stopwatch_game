import 'package:stopwatch_game/features/auth/data/models/otp_login_response.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

/// Outcome of `POST /api/v1/auth/login` for register and sign-in.
sealed class AuthLoginResult {
  const AuthLoginResult();

  const factory AuthLoginResult.otpRequired(OtpLoginResponse response) =
      AuthLoginOtpRequired;

  const factory AuthLoginResult.completed(UserModel user) = AuthLoginCompleted;

  const factory AuthLoginResult.message(String text) = AuthLoginMessage;
}

final class AuthLoginOtpRequired extends AuthLoginResult {
  const AuthLoginOtpRequired(this.response);

  final OtpLoginResponse response;
}

final class AuthLoginCompleted extends AuthLoginResult {
  const AuthLoginCompleted(this.user);

  final UserModel user;
}

final class AuthLoginMessage extends AuthLoginResult {
  const AuthLoginMessage(this.text);

  final String text;
}
