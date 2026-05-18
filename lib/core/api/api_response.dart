import 'package:stopwatch_game/core/api/api_json.dart';
import 'package:stopwatch_game/core/api/api_exception.dart';

/// Raw HTTP result — JSON available via [json] or [requireJson].
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

  /// Parsed JSON object; throws [ApiException] if missing or invalid.
  Map<String, dynamic> requireJson({String? context}) {
    if (json != null) return json!;
    return ApiJson.decodeObject(body, context: context);
  }

  /// Maps JSON to a model using [fromJson].
  T parse<T>(T Function(Map<String, dynamic> json) fromJson, {String? context}) {
    return fromJson(requireJson(context: context));
  }
}
