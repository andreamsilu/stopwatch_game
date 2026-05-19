/// Response from `POST /api/v1/auth/login` (request OTP).
class OtpLoginResponse {
  const OtpLoginResponse({
    required this.msisdn,
    this.expiresInSeconds,
    this.message,
    this.otp,
  });

  factory OtpLoginResponse.fromJson(Map<String, dynamic> json) {
    return OtpLoginResponse(
      msisdn: json['msisdn'] as String,
      expiresInSeconds: json['expiresInSeconds'] as int?,
      message: json['message'] as String?,
      otp: json['otp'] as String?,
    );
  }

  final String msisdn;
  final int? expiresInSeconds;
  final String? message;

  /// Present in stub/dev mode when the server returns the OTP in the response.
  final String? otp;
}
