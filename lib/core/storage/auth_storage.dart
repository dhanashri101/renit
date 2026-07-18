import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _authorizationHeaderKey = 'authorization_header';

  Future<String?> readToken() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    final String? token = preferences.getString(_tokenKey)?.trim();
    return token == null || token.isEmpty ? null : token;
  }

  /// Returns the exact Authorization header value confirmed by the backend,
  /// for example `Bearer ...` only when that scheme is explicitly provided.
  Future<String?> readAuthorizationHeader() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    final String? value =
        preferences.getString(_authorizationHeaderKey)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  Future<bool> hasUsableSession() async {
    return (await readToken()) != null &&
        (await readAuthorizationHeader()) != null;
  }

  Future<void> saveSession({
    required String token,
    required String authorizationHeader,
  }) async {
    final String cleanToken = token.trim();
    final String cleanAuthorizationHeader = authorizationHeader.trim();

    if (cleanToken.isEmpty || cleanAuthorizationHeader.isEmpty) {
      throw ArgumentError(
        'Token and exact authorization header must both be non-empty.',
      );
    }

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, cleanToken);
    await preferences.setString(
      _authorizationHeaderKey,
      cleanAuthorizationHeader,
    );
  }

  Future<void> clear() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_authorizationHeaderKey);
  }
}
