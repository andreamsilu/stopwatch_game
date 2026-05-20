import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/api/api_messages.dart';
import 'package:stopwatch_game/features/auth/data/auth_service.dart';
import 'package:stopwatch_game/features/auth/data/models/auth_login_result.dart';
import 'package:stopwatch_game/features/auth/data/models/otp_login_response.dart';
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

  /// Clears auth form state after sign-out from the game.
  void reset() {
    state = const LoginState.initial();
  }

  void backToPhone() {
    state = state.copyWith(
      step: LoginStep.phone,
      otpCode: '',
      clearError: true,
      clearInfo: true,
      clearOtpExpiry: true,
    );
  }

  /// `POST /auth/login`.
  ///
  /// Returns `true` when the user is authenticated without an OTP step.
  Future<bool> submitPhone() async {
    if (!state.canSubmitPhone) return false;

    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);
    try {
      final result = await _auth.login(msisdn: state.normalizedMsisdn);
      return _applyLoginResult(result, advanceToOtp: true);
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('submitPhone failed: $e\n$stack');
      }
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: ApiMessages.fromError(e),
      );
      return false;
    }
  }

  Future<bool> resendOtp() async {
    state = state.copyWith(isResendingOtp: true, clearError: true, clearInfo: true);
    try {
      final result = await _auth.login(msisdn: state.normalizedMsisdn);
      return _applyLoginResult(result, advanceToOtp: false);
    } on ApiException catch (e) {
      state = state.copyWith(isResendingOtp: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isResendingOtp: false,
        errorMessage: ApiMessages.fromError(e),
      );
      return false;
    }
  }

  Future<bool> verifyOtp() async {
    if (!state.canVerifyOtp) return false;

    state = state.copyWith(isSubmitting: true, clearError: true, clearInfo: true);
    try {
      final user = await _auth.signInWithOtp(
        msisdn: state.normalizedMsisdn,
        otp: state.otpCode,
      );
      state = state.copyWith(
        isSubmitting: false,
        authenticatedUser: user,
        infoMessage: user.status.isNotEmpty ? user.status : null,
        clearInfo: user.status.isEmpty,
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
        errorMessage: ApiMessages.fromError(e),
      );
      return false;
    }
  }

  bool _applyLoginResult(AuthLoginResult result, {required bool advanceToOtp}) {
    switch (result) {
      case AuthLoginOtpRequired(:final response):
        _applyOtpRequired(response, advanceToOtp: advanceToOtp);
        return false;
      case AuthLoginCompleted(:final user):
        state = state.copyWith(
          isSubmitting: false,
          isResendingOtp: false,
          authenticatedUser: user,
          infoMessage: user.status.isNotEmpty ? user.status : null,
          clearInfo: user.status.isEmpty,
        );
        return true;
      case AuthLoginMessage(:final text):
        state = state.copyWith(
          isSubmitting: false,
          isResendingOtp: false,
          step: LoginStep.phone,
          infoMessage: text.isNotEmpty ? text : null,
          clearInfo: text.isEmpty,
        );
        return false;
    }
  }

  void _applyOtpRequired(OtpLoginResponse response, {required bool advanceToOtp}) {
    final stubOtp = response.otp?.trim();
    final otpCode = stubOtp != null && stubOtp.length == LoginState.otpLength
        ? stubOtp
        : (advanceToOtp ? '' : state.otpCode);

    state = state.copyWith(
      isSubmitting: false,
      isResendingOtp: false,
      step: advanceToOtp ? LoginStep.otp : state.step,
      otpCode: otpCode,
      infoMessage: response.displayMessage,
      clearInfo: response.displayMessage == null,
      otpExpiresInSeconds: response.expiresInSeconds,
      clearOtpExpiry: response.expiresInSeconds == null,
    );
  }
}
