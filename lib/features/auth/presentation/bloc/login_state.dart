class LoginState {
  const LoginState({required this.phoneNumber, required this.isSubmitting});

  const LoginState.initial()
    : phoneNumber = '255712345678',
      isSubmitting = false;

  final String phoneNumber;
  final bool isSubmitting;

  bool get canContinue => !isSubmitting;

  LoginState copyWith({String? phoneNumber, bool? isSubmitting}) {
    return LoginState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
