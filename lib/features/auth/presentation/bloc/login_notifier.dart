import 'package:flutter/foundation.dart';
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

  void backToPhone() {
    state = state.copyWith(
      step: LoginStep.phone,
      clearExistingUser: true,
      clearError: true,
    );
  }

  Future<bool> continueWithPhone() async {
    if (!state.canContinue) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final existing = await _auth.prepareLogin(msisdn: state.normalizedMsisdn);
      state = state.copyWith(
        isSubmitting: false,
        step: LoginStep.confirm,
        existingUser: existing,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('continueWithPhone failed: $e\n$stack');
      }
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _messageForUnexpectedError(
          e,
          fallback: 'Could not verify your number. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> signIn() async {
    if (!state.canConfirm) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final user = await _auth.signIn(msisdn: state.normalizedMsisdn);
      state = state.copyWith(
        isSubmitting: false,
        registeredUser: user,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('signIn failed: $e\n$stack');
      }
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _messageForUnexpectedError(
          e,
          fallback: 'Could not complete registration. Please try again.',
        ),
      );
      return false;
    }
  }

  String _messageForUnexpectedError(Object error, {required String fallback}) {
    if (error is TypeError || error is FormatException) {
      return 'Server returned unexpected data. Please try again.';
    }
    return fallback;
  }
}
