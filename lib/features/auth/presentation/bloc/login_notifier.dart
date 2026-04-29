import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState.initial());

  void updatePhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value);
  }

  Future<bool> submitLogin() async {
    // Temporary bypass: allow login flow without backend validation.
    // Keep this until backend auth is wired.
    state = state.copyWith(isSubmitting: false);
    return true;
  }

  Future<void> requestOtp() async {
    // TODO: Integrate login/OTP API request here.
    // Keep authentication validation and session creation on backend.
  }
}
