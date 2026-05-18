import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/core/config/api_config.dart';
import 'package:stopwatch_game/features/auth/data/models/register_user_request.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

export 'package:stopwatch_game/core/api/api_exception.dart' show ApiException;

/// User registration and sign-in workflows.
class AuthService {
  AuthService({StopwatchApi? api}) : _api = api ?? StopwatchApi.create();

  factory AuthService.create({StopwatchApi? api}) => AuthService(api: api);

  final StopwatchApi _api;

  Future<UserModel?> lookupUserByMsisdn({required String msisdn}) =>
      _fetchUserByMsisdn(msisdn);

  Future<UserModel> getUserById({required int id}) => _fetchUserById(id);

  Future<UserModel> registerOrUpdateUser({required String msisdn}) =>
      _postUser(msisdn);

  Future<UserModel?> prepareLogin({required String msisdn}) =>
      lookupUserByMsisdn(msisdn: msisdn);

  Future<UserModel> signIn({required String msisdn}) async {
    final registered = await registerOrUpdateUser(msisdn: msisdn);
    return getUserById(id: registered.id);
  }

  Future<UserModel?> _fetchUserByMsisdn(String msisdn) async {
    final response = await _api.get(
      Uri.parse(ApiConfig.users).replace(queryParameters: {'msisdn': msisdn}),
      allowNotFound: true,
    );
    if (response.isNotFound || !response.hasJson) return null;
    return response.parse(
      UserModel.fromJson,
      context: 'GET /users?msisdn',
    );
  }

  Future<UserModel> _fetchUserById(int id) async {
    final response = await _api.get(Uri.parse(ApiConfig.userById(id)));
    return response.parse(
      UserModel.fromJson,
      context: 'GET /users/{id}',
    );
  }

  Future<UserModel> _postUser(String msisdn) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.users),
      body: RegisterUserRequest(msisdn: msisdn).toJson(),
    );
    return response.parse(
      UserModel.fromJson,
      context: 'POST /users',
    );
  }
}
