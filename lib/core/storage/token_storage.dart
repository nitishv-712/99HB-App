import 'package:shared_preferences/shared_preferences.dart';

abstract final class TokenStorage {
  static const _key = 'auth_token';
  static String? _token;

  static Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  static Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<String?> token() async {
    _token ??= await read();
    return _token;
  }
}
