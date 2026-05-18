class RegisterUserRequest {
  const RegisterUserRequest({required this.msisdn});

  final String msisdn;

  Map<String, dynamic> toJson() => {'msisdn': msisdn};
}
