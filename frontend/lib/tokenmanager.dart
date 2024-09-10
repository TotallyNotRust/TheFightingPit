import 'package:jwt_decode/jwt_decode.dart';

class TokenInvalid implements Exception {}

class TokenManager {
  static String? _token;

  static set token(String? token) {
    _token = token;
  }

  static String? get token {
    if (TokenManager.tokenIsValid) {
      // This should redirect to the main page in the future
      return null;
    }
    return _token;
  }

  static bool get tokenIsValid {
    if (_token == null) return false;
    try {
      var expiration = DateTime.fromMillisecondsSinceEpoch(
          // Expiration is seconds since epoch, so *1000 converts to millis
          Jwt.parseJwt(_token!)["exp"] * 1000);

      return expiration.isAfter(DateTime.now());
    } catch (exception) {
      return false;
    }
  }
}
