import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:homebazaar/core/config/env.dart';
import 'package:homebazaar/core/storage/token_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

final class ApiClient {
  ApiClient._();
  static String get _base => Env.apiBaseUrl;

  static Future<T> fetch<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$_base$path');
    final headers = await _getHeaders(requiresAuth);

    try {
      final request = http.Request(method.toUpperCase(), uri);
      request.headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Connection error: ${e.toString()}');
    }
  }

  static Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    final headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final access = await AccessToken().token;
      final refresh = await RefreshToken().token;

      if (access != null) headers['x-auth-accesstoken'] = access;
      if (refresh != null) headers['x-auth-refreshtoken'] = refresh;
    }
    return headers;
  }

  static Future<T> _handleResponse<T>(http.Response res) async {
    await _updateTokens(res.headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = _parseErrorMessage(res.body, res.statusCode);
      throw ApiException(msg, res.statusCode);
    }
    try {
      return jsonDecode(res.body) as T;
    } catch (e) {
      throw ApiException('Parse error: ${e.toString()}', res.statusCode);
    }
  }

  static Future<void> _updateTokens(Map<String, String> headers) async {
    final newAccess = headers['x-auth-accesstoken'];
    final newRefresh = headers['x-auth-refreshtoken'];

    if (newAccess != null) await AccessToken().save(newAccess);
    if (newRefresh != null) await RefreshToken().save(newRefresh);
  }

  static String _parseErrorMessage(String body, int code) {
    try {
      final data = jsonDecode(body);
      return data['message'] ?? 'Error $code';
    } catch (_) {
      return 'Request failed with status: $code';
    }
  }

  static Future<void> uploadToPresignedUrl(
    Uri uploadUrl,
    List<int> fileBytes,
    String contentType,
  ) async {
    try {
      final res = await http.put(
        uploadUrl,
        headers: {'Content-Type': contentType},
        body: fileBytes,
      );
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException('Upload failed (${res.statusCode})', res.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Upload error: ${e.toString()}', null);
    }
  }

  static String buildQuery(Map<String, dynamic> params) {
    params.removeWhere((k, v) => v == null || v.toString().isEmpty);
    return params.isEmpty
        ? ''
        : '?${Uri(queryParameters: params.map((k, v) => MapEntry(k, v.toString()))).query}';
  }
}
