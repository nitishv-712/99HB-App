import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseTokenStorage {
  String get key;
  String? _cachedToken;
  bool _isInitialized = false;

  Future<void> save(String token) async {
    _cachedToken = token;
    _isInitialized = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, token);
  }

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(key);
    _isInitialized = true;
    return _cachedToken;
  }

  Future<void> clear() async {
    _cachedToken = null;
    _isInitialized = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<String?> get token async {
    if (!_isInitialized) {
      await read();
    }
    return _cachedToken;
  }
}

final class AccessToken extends BaseTokenStorage {
  @override
  final String key = 'access_token';

  static final AccessToken _instance = AccessToken._internal();
  AccessToken._internal();
  factory AccessToken() => _instance;
}

final class RefreshToken extends BaseTokenStorage {
  @override
  final String key = 'refresh_token';

  static final RefreshToken _instance = RefreshToken._internal();
  RefreshToken._internal();
  factory RefreshToken() => _instance;
}
