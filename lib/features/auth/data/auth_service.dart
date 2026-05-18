import 'package:stopwatch_game/core/api/api_exception.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/core/config/api_config.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/features/auth/data/mock_auth_api_service.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

export 'package:stopwatch_game/core/api/api_exception.dart' show ApiException;

/// User registration and sign-in workflows.
class AuthService {
  AuthService._(this._useMock, this._api)
    : _mock = const MockAuthApiService();

  factory AuthService.create({StopwatchApi? api}) =>
      AuthService._(EnvConfig.useMockAuth, api ?? StopwatchApi.create());

  final bool _useMock;
  final StopwatchApi _api;
  final MockAuthApiService _mock;

  bool get isMock => _useMock;

  Future<UserModel?> lookupUserByMsisdn({required String msisdn}) {
    return _useMock
        ? _mock.getUserByMsisdn(msisdn: msisdn)
        : _fetchUserByMsisdn(msisdn);
  }

  Future<UserModel> getUserById({required int id}) {
    return _useMock ? _mock.getUserById(id: id) : _fetchUserById(id);
  }

  Future<UserModel> registerOrUpdateUser({required String msisdn}) {
    return _useMock
        ? _mock.registerOrUpdateUser(msisdn: msisdn)
        : _postUser(msisdn);
  }

  Future<UserModel?> prepareLogin({required String msisdn}) =>
      lookupUserByMsisdn(msisdn: msisdn);

  Future<UserModel> completeLogin({
    required String msisdn,
    required String otp,
  }) async {
    if (_useMock) {
      return _mock.completeLogin(msisdn: msisdn, otp: otp);
    }
    final registered = await registerOrUpdateUser(msisdn: msisdn);
    return getUserById(id: registered.id);
  }

  Future<UserModel?> _fetchUserByMsisdn(String msisdn) async {
    final response = await _api.get(
      Uri.parse(ApiConfig.users).replace(queryParameters: {'msisdn': msisdn}),
      allowNotFound: true,
    );
    if (response.isNotFound || !response.hasJson) return null;
    return UserModel.fromJson(response.json!);
  }

  Future<UserModel> _fetchUserById(int id) async {
    final response = await _api.get(Uri.parse(ApiConfig.userById(id)));
    if (!response.hasJson) {
      throw ApiException('Could not load user profile.');
    }
    return UserModel.fromJson(response.json!);
  }

  Future<UserModel> _postUser(String msisdn) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.users),
      body: {'msisdn': msisdn},
    );
    if (!response.hasJson) {
      throw ApiException('Registration failed.');
    }
    return UserModel.fromJson(response.json!);
  }
}
