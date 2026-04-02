import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:homebazaar/core/config/env.dart';

// ─── Exception ────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ─── API Client ───────────────────────────────────────────────────────────────

abstract final class ApiClient {
  static String get _base => Env.apiBaseUrl;

  static Future<T> fetch<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool isMultipart = false,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = Uri.parse('$_base$path');

    final headers = <String, String>{
      if (!isMultipart) 'Content-Type': 'application/json',
      ...?extraHeaders,
    };

    late http.Response res;

    switch (method.toUpperCase()) {
      case 'POST':
        res = await http.post(uri, headers: headers,
            body: body != null ? jsonEncode(body) : null);
      case 'PATCH':
        res = await http.patch(uri, headers: headers,
            body: body != null ? jsonEncode(body) : null);
      case 'PUT':
        res = await http.put(uri, headers: headers,
            body: body != null ? jsonEncode(body) : null);
      case 'DELETE':
        res = await http.delete(uri, headers: headers);
      default:
        res = await http.get(uri, headers: headers);
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      Map<String, dynamic> err = {};
      try { err = jsonDecode(res.body) as Map<String, dynamic>; } catch (_) {}
      throw ApiException(
        err['message'] as String? ?? 'Request failed (${res.statusCode})',
        res.statusCode,
      );
    }

    return jsonDecode(res.body) as T;
  }

  /// Upload a file directly to a presigned URL (e.g. Supabase).
  static Future<void> uploadToPresignedUrl(
    Uri uploadUrl,
    List<int> fileBytes,
    String contentType,
  ) async {
    final res = await http.put(
      uploadUrl,
      headers: {'Content-Type': contentType},
      body: fileBytes,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('Upload failed (${res.statusCode})', res.statusCode);
    }
  }

  /// Build query string from a map, dropping null/empty values.
  static String buildQuery(Map<String, dynamic> params) {
    final filtered = params.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    return filtered.isEmpty ? '' : '?$filtered';
  }
}
