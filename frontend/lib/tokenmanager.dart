import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenInvalid implements Exception {}

class TokenManager {

  static String? _token;

  static Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.get("SERVER_ADRESS", fallback: "http://localhost:8000"))
  );

  static Future<int> initialize() async {
    token = (await SharedPreferences.getInstance()).getString("JWT_TOKEN");
    return 0;
  }

  static set token(String? token) {
    dio.options.headers['JWT_TOKEN'] = token;
    _token = token;
    SharedPreferences.getInstance().then((value) => value.setString("JWT_TOKEN", token ?? ''));
  }

   static String? get token {
    if (TokenManager.tokenIsValid) {
      // This should redirect to the main page in the future
      return null;
    }
    return _token;
  }

  static bool get tokenIsValid {
    print("🎈 TOKEN CHECKING: $_token");
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
