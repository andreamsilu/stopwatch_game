import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      clearExistingUser: true,
      clearError: true,
    );
  }

  Future<bool> sendOtp() async {
    if (!state.canSendOtp) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final existing = await _auth.prepareLogin(msisdn: state.normalizedMsisdn);
      state = state.copyWith(
        isSubmitting: false,
        step: LoginStep.otp,
        existingUser: existing,
        otpCode: _auth.isMock ? LoginState.defaultOtpCode : '',
      );
      return true;
    } on ApiException catch (e) {
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
      final existing = await _auth.prepareLogin(msisdn: state.normalizedMsisdn);
      state = state.copyWith(
        isResendingOtp: false,
        existingUser: existing,
        otpCode: _auth.isMock ? LoginState.defaultOtpCode : state.otpCode,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isResendingOtp: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isResendingOtp: false,
        errorMessage: 'Could not refresh. Try again shortly.',
      );
      return false;
    }
  }

  Future<bool> verifyOtpAndRegister() async {
    if (_auth.isMock) {
      if (!state.canVerifyOtp) return false;
    } else if (!state.canConfirmRegistration) {
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final user = await _auth.completeLogin(
        msisdn: state.normalizedMsisdn,
        otp: state.otpCode,
      );

      state = state.copyWith(
        isSubmitting: false,
        registeredUser: user,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not complete registration. Please try again.',
      );
      return false;
    }
  }
}
