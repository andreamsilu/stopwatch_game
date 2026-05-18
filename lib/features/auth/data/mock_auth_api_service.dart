import 'package:stopwatch_game/core/api/api_exception.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';

/// Local auth stub — no HTTP. Mock OTP step accepts [LoginState.defaultOtpCode].
class MockAuthApiService {
  const MockAuthApiService();

  static const Duration _latency = Duration(milliseconds: 450);

  UserModel _userFor(String msisdn, {int id = 1}) {
    final now = DateTime.now().toUtc().toIso8601String();
    return UserModel(
      id: id,
      msisdn: msisdn,
      username: msisdn,
      channelSource: 'APP',
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<UserModel?> getUserByMsisdn({required String msisdn}) async {
    await Future<void>.delayed(_latency);
    if (msisdn.endsWith('999')) return null;
    return _userFor(msisdn);
  }

  Future<UserModel> getUserById({required int id}) async {
    await Future<void>.delayed(_latency);
    return _userFor('255712345678', id: id);
  }

  Future<UserModel> registerOrUpdateUser({required String msisdn}) async {
    await Future<void>.delayed(_latency);
    return _userFor(msisdn);
  }

  Future<UserModel> completeLogin({
    required String msisdn,
    required String otp,
  }) async {
    if (otp != LoginState.defaultOtpCode) {
      throw ApiException(
        'Invalid verification code. Use ${LoginState.defaultOtpCode} in mock mode.',
      );
    }
    return registerOrUpdateUser(msisdn: msisdn);
  }
}
