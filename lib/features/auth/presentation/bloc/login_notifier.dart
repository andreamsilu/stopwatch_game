import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/features/auth/data/auth_service.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier({AuthService? auth})
    : _auth = auth ?? AuthService.create(),
      super(const LoginState.initial());

  final AuthService _auth;

  void setAuthIntent(AuthIntent intent) {
    state = state.copyWith(
      intent: intent,
      step: LoginStep.phone,
      otpCode: '',
      clearError: true,
      clearAuthenticatedUser: true,
      subscriptionAccepted: false,
    );
  }

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

  void setSubscriptionAccepted(bool value) {
    state = state.copyWith(subscriptionAccepted: value, clearError: true);
  }

  void backToPhone() {
    state = state.copyWith(
      step: LoginStep.phone,
      otpCode: '',
      clearError: true,
    );
  }

  Future<bool> sendOtp() async {
    if (!state.canSendOtp) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final response = await _auth.requestOtp(msisdn: state.normalizedMsisdn);
      final stubOtp = response.otp?.trim();
      state = state.copyWith(
        isSubmitting: false,
        step: LoginStep.otp,
        otpCode: stubOtp != null && stubOtp.length == LoginState.otpLength
            ? stubOtp
            : '',
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('sendOtp failed: $e\n$stack');
      }
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not send verification code. Please try again.',
      );
      return false;
    }
  }

  Future<bool> resendOtp() async {
    state = state.copyWith(isResendingOtp: true, clearError: true);
    try {
      final response = await _auth.requestOtp(msisdn: state.normalizedMsisdn);
      final stubOtp = response.otp?.trim();
      state = state.copyWith(
        isResendingOtp: false,
        otpCode: stubOtp != null && stubOtp.length == LoginState.otpLength
            ? stubOtp
            : state.otpCode,
      );
      return true;
    } on ApiException catch (e) {
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

  Future<bool> verifyOtp() async {
    if (!state.canVerifyOtp) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final user = state.isRegister
          ? await _auth.registerWithOtp(
              msisdn: state.normalizedMsisdn,
              otp: state.otpCode,
            )
          : await _auth.signInWithOtp(
              msisdn: state.normalizedMsisdn,
              otp: state.otpCode,
            );
      state = state.copyWith(
        isSubmitting: false,
        authenticatedUser: user,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('verifyOtp failed: $e\n$stack');
      }
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: state.isRegister
            ? 'Registration failed. Please try again.'
            : 'Sign in failed. Please try again.',
      );
      return false;
    }
  }
}
