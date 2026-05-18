import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/features/auth/data/auth_api_service.dart';
import 'package:stopwatch_game/features/auth/data/mock_auth_api_service.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

/// Auth gateway used by [LoginNotifier] — real API or mock based on `.env`.
class AuthService {
  AuthService._(this._useMock)
    : _api = AuthApiService(),
      _mock = const MockAuthApiService();

  factory AuthService.create() => AuthService._(EnvConfig.useMockAuth);

  final bool _useMock;
  final AuthApiService _api;
  final MockAuthApiService _mock;

  bool get isMock => _useMock;

  String channelSourceForPlatform() => _useMock
      ? _mock.channelSourceForPlatform()
      : _api.channelSourceForPlatform();

  Future<void> requestOtp({required String msisdn}) => _useMock
      ? _mock.requestOtp(msisdn: msisdn)
      : _api.requestOtp(msisdn: msisdn);

  Future<UserModel> verifyOtpAndRegister({
    required String msisdn,
    required String otp,
    required String channelSource,
  }) => _useMock
      ? _mock.verifyOtpAndRegister(
          msisdn: msisdn,
          otp: otp,
          channelSource: channelSource,
        )
      : _api.verifyOtpAndRegister(
          msisdn: msisdn,
          otp: otp,
          channelSource: channelSource,
        );
}
