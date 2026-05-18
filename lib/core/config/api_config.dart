import 'package:stopwatch_game/core/config/env_config.dart';

class ApiConfig {
  const ApiConfig._();

  static String get baseUrl => EnvConfig.apiBaseUrl;
  static String get apiPrefix => EnvConfig.apiPrefix;

  static String get users => '$baseUrl$apiPrefix/users';
  static String get otpRequest => '$baseUrl$apiPrefix/otp/request';
  static String get otpVerify => '$baseUrl$apiPrefix/otp/verify';
}
