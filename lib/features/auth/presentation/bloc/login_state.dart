import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

enum LoginStep { phone, otp }

class LoginState {
  const LoginState({
    required this.step,
    required this.phoneNumber,
    required this.otpCode,
    required this.isSubmitting,
    required this.isResendingOtp,
    required this.errorMessage,
    required this.infoMessage,
    required this.otpExpiresInSeconds,
    required this.authenticatedUser,
  });

  static const int otpLength = 6;

  const LoginState.initial()
    : step = LoginStep.phone,
      phoneNumber = '',
      otpCode = '',
      isSubmitting = false,
      isResendingOtp = false,
      errorMessage = null,
      infoMessage = null,
      otpExpiresInSeconds = null,
      authenticatedUser = null;

  final LoginStep step;
  final String phoneNumber;
  final String otpCode;
  final bool isSubmitting;
  final bool isResendingOtp;
  final String? errorMessage;
  final String? infoMessage;
  final int? otpExpiresInSeconds;
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

  bool get canSubmitPhone =>
      !isSubmitting && normalizedMsisdn.length >= 12;

  bool get canVerifyOtp => !isSubmitting && otpCode.length == otpLength;

  LoginState copyWith({
    LoginStep? step,
    String? phoneNumber,
    String? otpCode,
    bool? isSubmitting,
    bool? isResendingOtp,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
    int? otpExpiresInSeconds,
    bool clearOtpExpiry = false,
    UserModel? authenticatedUser,
    bool clearAuthenticatedUser = false,
  }) {
    return LoginState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isResendingOtp: isResendingOtp ?? this.isResendingOtp,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      otpExpiresInSeconds: clearOtpExpiry
          ? null
          : (otpExpiresInSeconds ?? this.otpExpiresInSeconds),
      authenticatedUser: clearAuthenticatedUser
          ? null
          : (authenticatedUser ?? this.authenticatedUser),
    );
  }
}
