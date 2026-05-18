import 'package:flutter/foundation.dart';
import 'package:stopwatch_game/features/auth/data/auth_api_service.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';

/// Local auth stub — no HTTP. Accepts [LoginState.defaultOtpCode] only.
class MockAuthApiService {
  const MockAuthApiService();

  static const Duration _latency = Duration(milliseconds: 450);

  String channelSourceForPlatform() {
    if (kIsWeb) return 'WEB';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ANDROID';
      case TargetPlatform.iOS:
        return 'IOS';
      default:
        return 'DESKTOP';
    }
  }

  Future<void> requestOtp({required String msisdn}) async {
    await Future<void>.delayed(_latency);
  }

  Future<UserModel> verifyOtpAndRegister({
    required String msisdn,
    required String otp,
    required String channelSource,
  }) async {
    await Future<void>.delayed(_latency);

    if (otp != LoginState.defaultOtpCode) {
      throw AuthApiException('Invalid verification code. Use ${LoginState.defaultOtpCode} in mock mode.');
    }

    final now = DateTime.now().toUtc().toIso8601String();
    return UserModel(
      id: 1,
      msisdn: msisdn,
      username: AuthApiService.usernameFromMsisdn(msisdn),
      channelSource: channelSource,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );
  }
}
