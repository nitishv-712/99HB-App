import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:homebazaar/core/config/env.dart';
import 'package:homebazaar/core/storage/token_storage.dart';

// ─── Exception ────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ─── API Client ───────────────────────────────────────────────────────────────

final class ApiClient {
  ApiClient._(); // Private constructor to prevent instantiation

  static String get _base => Env.apiBaseUrl;

  static Future<T> fetch<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$_base$path');

    final headers = <String, String>{'Content-Type': 'application/json'};

    // Add authorization header if required
    if (requiresAuth) {
      final accessToken = await AccessToken().token;
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['accesstoken'] = 'Bearer $accessToken';
      }
    }

    late http.Response res;

    try {
      switch (method.toUpperCase()) {
        case 'POST':
          res = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'PATCH':
          res = await http.patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'PUT':
          res = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'DELETE':
          res = await http.delete(uri, headers: headers);
        default:
          res = await http.get(uri, headers: headers);
      }
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}', null);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      Map<String, dynamic> err = {};
      try {
        err = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        // Failed to parse error response
      }
      throw ApiException(
        err['message'] as String? ?? 'Request failed (${res.statusCode})',
        res.statusCode,
      );
    }

    try {
      return jsonDecode(res.body) as T;
    } catch (e) {
      throw ApiException(
        'Failed to parse response: ${e.toString()}',
        res.statusCode,
      );
    }
  }

  /// Upload a file directly to a presigned URL (e.g. Supabase).
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

  /// Build query string from a map, dropping null/empty values.
  static String buildQuery(Map<String, dynamic> params) {
    final filtered = params.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
        )
        .join('&');
    return filtered.isEmpty ? '' : '?$filtered';
  }
}
