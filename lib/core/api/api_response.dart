/// Raw HTTP result — no domain models or business rules.
class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.body,
    this.json,
  });

  final int statusCode;
  final String body;
  final Map<String, dynamic>? json;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  bool get isNotFound => statusCode == 404;

  bool get hasJson => json != null;
}
