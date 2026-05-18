import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

enum LoginStep { details, otp }

class LoginState {
  const LoginState({
    required this.step,
    required this.phoneNumber,
    required this.otpCode,
    required this.isSubmitting,
    required this.isResendingOtp,
    required this.errorMessage,
    required this.existingUser,
    required this.registeredUser,
  });

  static const String defaultPhoneNumber = '712345678';
  static const String defaultOtpCode = '123456';

  const LoginState.initial()
    : step = LoginStep.details,
      phoneNumber = defaultPhoneNumber,
      otpCode = '',
      isSubmitting = false,
      isResendingOtp = false,
      errorMessage = null,
      existingUser = null,
      registeredUser = null;

  final LoginStep step;
  final String phoneNumber;
  final String otpCode;
  final bool isSubmitting;
  final bool isResendingOtp;
  final String? errorMessage;
  final UserModel? existingUser;
  final UserModel? registeredUser;

  static const int otpLength = 6;

  String get normalizedMsisdn {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('255')) return digits;
    if (digits.startsWith('0')) return '255${digits.substring(1)}';
    return '255$digits';
  }

  /// Backend still requires `username`; derived from phone when not collected in UI.
  String get derivedUsername => normalizedMsisdn;

  String get maskedPhone {
    final msisdn = normalizedMsisdn;
    if (msisdn.length < 6) return msisdn;
    return '+${msisdn.substring(0, 3)} *** *** ${msisdn.substring(msisdn.length - 3)}';
  }

  bool get canSendOtp => !isSubmitting && normalizedMsisdn.length >= 12;

  bool get canVerifyOtp => !isSubmitting && otpCode.length == otpLength;

  bool get canConfirmRegistration => !isSubmitting && step == LoginStep.otp;

  LoginState copyWith({
    LoginStep? step,
    String? phoneNumber,
    String? otpCode,
    bool? isSubmitting,
    bool? isResendingOtp,
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
      otpCode: otpCode ?? this.otpCode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isResendingOtp: isResendingOtp ?? this.isResendingOtp,
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
