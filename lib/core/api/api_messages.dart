import 'package:stopwatch_game/core/api/api_exception.dart';
import 'package:stopwatch_game/core/api/api_json.dart';
import 'package:stopwatch_game/core/api/api_response.dart';

/// User-visible text derived from API JSON bodies and errors.
class ApiMessages {
  ApiMessages._();

  /// Prefer [ApiException.message]; otherwise stringify the error.
  static String fromError(Object error) {
    if (error is ApiException) return error.message;
    final text = error.toString().trim();
    return text.isEmpty ? 'Unexpected error.' : text;
  }

  /// Message from a non-success or empty API response body.
  static String fromResponse(ApiResponse response, {String? context}) {
    final fromBody = messageFromBody(response.body);
    if (fromBody != null && fromBody.isNotEmpty) return fromBody;

    if (context != null) {
      return '$context failed (${response.statusCode}).';
    }
    return 'Request failed (${response.statusCode}).';
  }

  /// Extracts a human-readable message from any JSON error body.
  static String? messageFromBody(String body) => ApiJson.messageFromErrorBody(body);

  /// First non-empty message field from a success JSON object.
  static String? fromMap(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    return ApiJson.messageFromMap(json);
  }
}
