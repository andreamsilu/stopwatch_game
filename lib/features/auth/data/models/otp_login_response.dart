/// Response from `POST /api/v1/auth/login` (register and sign-in).
class OtpLoginResponse {
  const OtpLoginResponse({
    required this.msisdn,
    this.status,
    this.expiresInSeconds,
    this.message,
    this.otp,
  });

  factory OtpLoginResponse.fromJson(Map<String, dynamic> json) {
    return OtpLoginResponse(
      msisdn: json['msisdn'] as String,
      status: json['status'] as String?,
      expiresInSeconds: json['expiresInSeconds'] as int?,
      message: json['message'] as String?,
      otp: json['otp'] as String?,
    );
  }

  final String msisdn;
  final String? status;
  final int? expiresInSeconds;
  final String? message;

  /// Present in stub/dev mode when the server returns the OTP in the response.
  final String? otp;

  String get normalizedStatus => status?.trim().toUpperCase() ?? '';

  bool get requiresOtp => normalizedStatus == 'OTP_REQUIRED';

  String? get displayMessage {
    if (message != null && message!.trim().isNotEmpty) return message!.trim();
    if (status != null && status!.trim().isNotEmpty) return status!.trim();
    return null;
  }
}
