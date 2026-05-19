/// Holds the current Bearer access token for authenticated API calls.
class AuthTokenStore {
  String? _accessToken;

  String? get accessToken => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void clear() => _accessToken = null;
}
