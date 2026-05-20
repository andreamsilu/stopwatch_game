import 'package:stopwatch_game/core/api/api_exception.dart';
import 'package:stopwatch_game/core/api/api_json.dart';
import 'package:stopwatch_game/core/api/api_messages.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/core/config/api_config.dart';
import 'package:stopwatch_game/features/auth/data/models/auth_login_result.dart';
import 'package:stopwatch_game/features/auth/data/models/auth_session.dart';
import 'package:stopwatch_game/features/auth/data/models/otp_login_response.dart';
import 'package:stopwatch_game/features/auth/data/models/register_user_request.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

export 'package:stopwatch_game/core/api/api_exception.dart' show ApiException;

/// OTP auth (`/auth/login`, `/auth/verify-otp`), JWT session, and registration.
class AuthService {
  AuthService({
    StopwatchApi? api,
    void Function(AuthSession? session)? onSessionChanged,
  }) : _api = api ?? StopwatchApi.create(),
       _onSessionChanged = onSessionChanged;

  factory AuthService.create({
    StopwatchApi? api,
    void Function(AuthSession? session)? onSessionChanged,
  }) =>
      AuthService(api: api, onSessionChanged: onSessionChanged);

  final StopwatchApi _api;
  final void Function(AuthSession? session)? _onSessionChanged;

  AuthSession? _currentSession;

  AuthSession? get currentSession => _currentSession;

  /// Restores in-memory session after reading [AuthSessionStorage] on app start.
  void restoreSession(AuthSession session) {
    _applySession(session);
  }

  /// `POST /api/v1/auth/login` — used for both register and sign-in.
  Future<AuthLoginResult> login({required String msisdn}) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.authLogin),
      body: {'msisdn': msisdn},
    );

    final json = response.requireJson(context: 'POST /auth/login');
    final parsed = OtpLoginResponse.fromJson(json);

    if (parsed.requiresOtp) {
      return AuthLoginResult.otpRequired(parsed);
    }

    if (json['accessToken'] is String && json['user'] is Map) {
      final session = AuthSession.fromJson(json);
      _applySession(session);
      return AuthLoginResult.completed(session.user);
    }

    if (json.containsKey('id') && json['msisdn'] != null) {
      return AuthLoginResult.completed(UserModel.fromJson(json));
    }

    final text = parsed.displayMessage ?? ApiMessages.fromMap(json) ?? '';
    return AuthLoginResult.message(text);
  }

  /// `POST /api/v1/auth/verify-otp` — sign in; returns JWT + user (no `POST /users`).
  Future<UserModel> signInWithOtp({
    required String msisdn,
    required String otp,
  }) async {
    final session = await _verifyOtpAndApplySession(msisdn: msisdn, otp: otp);
    return session.user;
  }

  /// Verify OTP, then `POST /api/v1/users` with `{ "msisdn" }` (registration only).
  Future<UserModel> registerWithOtp({
    required String msisdn,
    required String otp,
  }) async {
    await _verifyOtpAndApplySession(msisdn: msisdn, otp: otp);
    return registerUser(msisdn: msisdn);
  }

  /// `POST /api/v1/auth/logout` — revokes JWT and clears the local session.
  Future<void> logout() async {
    try {
      await _api.post(Uri.parse(ApiConfig.authLogout));
    } finally {
      _clearSession();
    }
  }

  void _clearSession() {
    _currentSession = null;
    _onSessionChanged?.call(null);
  }

  void _applySession(AuthSession session) {
    _currentSession = session;
    _onSessionChanged?.call(session);
  }

  Future<AuthSession> _verifyOtpAndApplySession({
    required String msisdn,
    required String otp,
  }) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.authVerifyOtp),
      body: {'msisdn': msisdn, 'otp': otp},
    );

    final session = response.parse(
      AuthSession.fromJson,
      context: 'POST /auth/verify-otp',
    );
    _applySession(session);
    return session;
  }

  /// `POST /api/v1/users` — registration only; requires Bearer token from verify-otp.
  Future<UserModel> registerUser({required String msisdn}) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.users),
      body: RegisterUserRequest(msisdn: msisdn).toJson(),
    );
    return response.parse(
      UserModel.fromJson,
      context: 'POST /users',
    );
  }

  Future<UserModel> getUserById({required int id}) async {
    final response = await _api.get(Uri.parse(ApiConfig.userById(id)));
    return response.parse(
      UserModel.fromJson,
      context: 'GET /users/{id}',
    );
  }
}
