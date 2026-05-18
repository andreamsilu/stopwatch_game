import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/features/auth/data/auth_api_service.dart';
import 'package:stopwatch_game/features/auth/data/auth_service.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier({AuthService? auth})
    : _auth = auth ?? AuthService.create(),
      super(const LoginState.initial());

  final AuthService _auth;

  void updatePhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value, clearError: true);
  }

  void updateOtpCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > LoginState.otpLength
        ? digits.substring(0, LoginState.otpLength)
        : digits;
    state = state.copyWith(otpCode: trimmed, clearError: true);
  }

  void backToDetails() {
    state = state.copyWith(
      step: LoginStep.details,
      otpCode: '',
      clearError: true,
    );
  }

  Future<bool> sendOtp() async {
    if (!state.canSendOtp) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _auth.requestOtp(msisdn: state.normalizedMsisdn);
      state = state.copyWith(
        isSubmitting: false,
        step: LoginStep.otp,
        otpCode: LoginState.defaultOtpCode,
      );
      return true;
    } on AuthApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Network error. Check your connection and try again.',
      );
      return false;
    }
  }

  Future<bool> resendOtp() async {
    state = state.copyWith(isResendingOtp: true, clearError: true);
    try {
      await _auth.requestOtp(msisdn: state.normalizedMsisdn);
      state = state.copyWith(isResendingOtp: false);
      return true;
    } on AuthApiException catch (e) {
      state = state.copyWith(isResendingOtp: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isResendingOtp: false,
        errorMessage: 'Could not resend code. Try again shortly.',
      );
      return false;
    }
  }

  Future<bool> verifyOtpAndRegister() async {
    if (!state.canVerifyOtp) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final user = await _auth.verifyOtpAndRegister(
        msisdn: state.normalizedMsisdn,
        otp: state.otpCode,
        channelSource: _auth.channelSourceForPlatform(),
      );
      state = state.copyWith(
        isSubmitting: false,
        registeredUser: user,
      );
      return true;
    } on AuthApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Verification failed. Please try again.',
      );
      return false;
    }
  }
}
