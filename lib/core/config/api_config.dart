import 'package:stopwatch_game/core/config/env_config.dart';

class ApiConfig {
  const ApiConfig._();

  static String get baseUrl => EnvConfig.apiBaseUrl;
  static String get apiPrefix => EnvConfig.apiPrefix;

  static String get users => '$baseUrl$apiPrefix/users';

  static String userById(int id) => '$users/$id';

  static String get authLogin => '$baseUrl$apiPrefix/auth/login';

  static String get authVerifyOtp => '$baseUrl$apiPrefix/auth/verify-otp';

  static String get authLogout => '$baseUrl$apiPrefix/auth/logout';
  static String get targetTime => '$baseUrl$apiPrefix/game/target-time';
  static String get gameStart => '$baseUrl$apiPrefix/game/start';
  static String get gameStop => '$baseUrl$apiPrefix/game/stop';
  static String get telemetryEvents => '$baseUrl$apiPrefix/telemetry/events';
  static String get billingTransactions =>
      '$baseUrl$apiPrefix/billing/transactions';

  static String billingTransaction(String requestId) =>
      '$baseUrl$apiPrefix/billing/transactions/${Uri.encodeComponent(requestId)}';

  static String gameSession(String sessionRef) =>
      '$baseUrl$apiPrefix/game/sessions/${Uri.encodeComponent(sessionRef)}';

  static String gameHistory({int page = 0, int size = 20}) {
    final query = Uri(queryParameters: {'page': '$page', 'size': '$size'});
    return '$baseUrl$apiPrefix/game/history${query.query.isEmpty ? '' : '?${query.query}'}';
  }
}
