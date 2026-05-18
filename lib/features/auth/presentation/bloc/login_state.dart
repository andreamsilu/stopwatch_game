import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

enum LoginStep { phone, confirm }

class LoginState {
  const LoginState({
    required this.step,
    required this.phoneNumber,
    required this.isSubmitting,
    required this.errorMessage,
    required this.existingUser,
    required this.registeredUser,
  });

  static const String defaultPhoneNumber = '712345678';

  const LoginState.initial()
    : step = LoginStep.phone,
      phoneNumber = defaultPhoneNumber,
      isSubmitting = false,
      errorMessage = null,
      existingUser = null,
      registeredUser = null;

  final LoginStep step;
  final String phoneNumber;
  final bool isSubmitting;
  final String? errorMessage;
  final UserModel? existingUser;
  final UserModel? registeredUser;

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

  bool get canContinue => !isSubmitting && normalizedMsisdn.length >= 12;

  bool get canConfirm => !isSubmitting && step == LoginStep.confirm;

  LoginState copyWith({
    LoginStep? step,
    String? phoneNumber,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    UserModel? existingUser,
    bool clearExistingUser = false,
    UserModel? registeredUser,
    bool clearRegisteredUser = false,
  }) {
    return LoginState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      existingUser: clearExistingUser
          ? null
          : (existingUser ?? this.existingUser),
      registeredUser: clearRegisteredUser
          ? null
          : (registeredUser ?? this.registeredUser),
    );
  }
}
