import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/api_response.dart';
import 'package:homebazaar/model/user.dart';

abstract final class AuthService {
  /// POST /auth/register
  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    UserRole? role,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/auth/register',
      method: 'POST',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role.name,
      },
    );
    return ApiResponse.fromJson(json, (d) => d as Map<String, dynamic>);
  }

  /// POST /auth/login
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/auth/login',
      method: 'POST',
      body: {'email': email, 'password': password},
    );
    return ApiResponse.fromJson(json, (d) => d as Map<String, dynamic>);
  }

  /// POST /auth/logout
  static Future<void> logout() async {
    await ApiClient.fetch<Map<String, dynamic>>('/auth/logout', method: 'POST');
  }

  /// GET /auth/me
  static Future<ApiResponse<Map<String, dynamic>>> me() async {
    final json = await ApiClient.fetch<Map<String, dynamic>>('/auth/me');
    return ApiResponse.fromJson(json, (d) => d as Map<String, dynamic>);
  }

  /// PATCH /auth/password
  static Future<void> changePassword({
    required String otp,
    required String newPassword,
    String? email,
    String? phone,
  }) async {
    await ApiClient.fetch<Map<String, dynamic>>(
      '/auth/password',
      method: 'PATCH',
      body: {
        'otp': otp,
        'newPassword': newPassword,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
    );
  }

  /// POST /auth/otp/generate
  static Future<void> generateOtp({String? email, String? phone}) async {
    await ApiClient.fetch<Map<String, dynamic>>(
      '/auth/otp/generate',
      method: 'POST',
      body: {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
    );
  }

  /// POST /auth/otp/verify
  static Future<void> verifyOtp({
    required String otp,
    String? email,
    String? phone,
  }) async {
    await ApiClient.fetch<Map<String, dynamic>>(
      '/auth/otp/verify',
      method: 'POST',
      body: {
        'otp': otp,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
    );
  }

  /// POST /oauth/google
  static Future<ApiResponse<Map<String, dynamic>>> googleLogin({
    required String idToken,
    String? role,
    String platform = 'android',
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/oauth/google',
      method: 'POST',
      body: {
        'idToken': idToken,
        'provider': 'google',
        'platform': platform,
        if (role != null) 'role': role,
      },
    );
    return ApiResponse.fromJson(json, (d) => d as Map<String, dynamic>);
  }
}
