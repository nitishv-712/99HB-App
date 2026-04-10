import 'package:flutter/material.dart';
import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/core/storage/token_storage.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  ApiUser? _user;
  String? _error;

  AuthStatus get status => _status;
  ApiUser? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> tokenClear() async {
    await AccessToken().clear();
    await RefreshToken().clear();
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    await AccessToken().save(accessToken);
    await RefreshToken().save(refreshToken);
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _extractMessage(Object e) =>
      e is ApiException ? e.message : e.toString();

  Future<void> init() async {
    final accessToken = await AccessToken().read();
    final refreshToken = await RefreshToken().read();
    if (accessToken == null || refreshToken == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    await fetchMe();
  }

  Future<void> fetchMe() async {
    _setLoading();
    try {
      final res = await AuthService.me();
      _user = ApiUser.fromJson(res.data['user'] as Map<String, dynamic>);
      _status = AuthStatus.authenticated;
    } catch (e) {
      await AccessToken().clear();
      await RefreshToken().clear();
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading();
    try {
      final res = await AuthService.login(email: email, password: password);
      final accessToken = res.data['accessToken'] as String?;
      final refreshToken = res.data['refreshToken'] as String?;
      if (accessToken != null && refreshToken != null) {
        await setTokens(accessToken, refreshToken);
      }
      _user = ApiUser.fromJson(res.data['user'] as Map<String, dynamic>);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_extractMessage(e));
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    UserRole? role,
  }) async {
    _setLoading();
    try {
      final res = await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      final accessToken = res.data['accessToken'] as String?;
      final refreshToken = res.data['refreshToken'] as String?;
      if (accessToken != null && refreshToken != null) {
        await setTokens(accessToken, refreshToken);
      }
      _user = ApiUser.fromJson(res.data['user'] as Map<String, dynamic>);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_extractMessage(e));
      return false;
    }
  }

  Future<bool> googleLogin({required String idToken, String? role}) async {
    _setLoading();
    try {
      final res = await AuthService.googleLogin(idToken: idToken, role: role);
      final accessToken = res.data['token'] as String?;
      final refreshToken = res.data['refreshToken'] as String?;
      if (accessToken != null && refreshToken != null) {
        await setTokens(accessToken, refreshToken);
      }
      _user = ApiUser.fromJson(res.data['user'] as Map<String, dynamic>);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
    } catch (_) {}
    await tokenClear();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> generateOtp({String? email, String? phone}) async {
    try {
      await AuthService.generateOtp(email: email, phone: phone);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String otp,
    String? email,
    String? phone,
  }) async {
    try {
      await AuthService.verifyOtp(otp: otp, email: email, phone: phone);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String otp,
    required String newPassword,
    String? email,
    String? phone,
  }) async {
    try {
      await AuthService.changePassword(
        otp: otp,
        newPassword: newPassword,
        email: email,
        phone: phone,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
