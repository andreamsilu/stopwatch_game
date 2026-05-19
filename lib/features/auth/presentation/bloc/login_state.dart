import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

enum AuthIntent { register, login }

enum LoginStep { phone, otp }

class LoginState {
  const LoginState({
    required this.intent,
    required this.step,
    required this.phoneNumber,
    required this.otpCode,
    required this.isSubmitting,
    required this.isResendingOtp,
    required this.errorMessage,
    required this.infoMessage,
    required this.authenticatedUser,
    required this.subscriptionAccepted,
  });

  static const String defaultPhoneNumber = '712345678';
  static const int otpLength = 6;

  const LoginState.initial()
    : intent = AuthIntent.register,
      step = LoginStep.phone,
      phoneNumber = defaultPhoneNumber,
      otpCode = '',
      isSubmitting = false,
      isResendingOtp = false,
      errorMessage = null,
      infoMessage = null,
      authenticatedUser = null,
      subscriptionAccepted = false;

  final AuthIntent intent;
  final LoginStep step;
  final String phoneNumber;
  final String otpCode;
  final bool isSubmitting;
  final bool isResendingOtp;
  final String? errorMessage;
  final String? infoMessage;
  final UserModel? authenticatedUser;
  final bool subscriptionAccepted;

  bool get isRegister => intent == AuthIntent.register;
  bool get isLogin => intent == AuthIntent.login;

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

  bool get canSendOtp =>
      !isSubmitting &&
      normalizedMsisdn.length >= 12 &&
      (!isRegister || subscriptionAccepted);

  bool get canVerifyOtp => !isSubmitting && otpCode.length == otpLength;

  LoginState copyWith({
    AuthIntent? intent,
    LoginStep? step,
    String? phoneNumber,
    String? otpCode,
    bool? isSubmitting,
    bool? isResendingOtp,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
    UserModel? authenticatedUser,
    bool clearAuthenticatedUser = false,
    bool? subscriptionAccepted,
  }) {
    return LoginState(
      intent: intent ?? this.intent,
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isResendingOtp: isResendingOtp ?? this.isResendingOtp,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      authenticatedUser: clearAuthenticatedUser
          ? null
          : (authenticatedUser ?? this.authenticatedUser),
      subscriptionAccepted:
          subscriptionAccepted ?? this.subscriptionAccepted,
    );
  }
}
