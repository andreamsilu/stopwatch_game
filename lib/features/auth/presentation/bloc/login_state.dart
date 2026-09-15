import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

class LoginState {
  const LoginState({
    required this.phoneNumber,
    required this.isSubmitting,
    required this.errorMessage,
    required this.infoMessage,
    required this.authenticatedUser,
  });

  const LoginState.initial()
    : phoneNumber = '',
      isSubmitting = false,
      errorMessage = null,
      infoMessage = null,
      authenticatedUser = null;

  final String phoneNumber;
  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;
  final UserModel? authenticatedUser;

  String get normalizedMsisdn {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('255')) return digits;
    if (digits.startsWith('0')) return '255${digits.substring(1)}';
    return '255$digits';
  }

  String get maskedPhone {
    final msisdn = normalizedMsisdn;
    if (msisdn.length < 6) return msisdn;
    return '+${msisdn.substring(0, 3)} *** *** ${msisdn.substring(msisdn.length - 3)}';
  }

  bool get canSubmitPhone => !isSubmitting && normalizedMsisdn.length >= 12;

  LoginState copyWith({
    String? phoneNumber,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
    UserModel? authenticatedUser,
    bool clearAuthenticatedUser = false,
  }) {
    return LoginState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      authenticatedUser: clearAuthenticatedUser
          ? null
          : (authenticatedUser ?? this.authenticatedUser),
    );
  }
}
