import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/api_response.dart';
import 'package:homebazaar/model/misc.dart';

abstract final class SearchHistoryService {
  /// GET /search-history
  static Future<ApiResponse<List<ApiSearchHistory>>> list({
    int? page,
    int? limit,
  }) async {
    final qs = ApiClient.buildQuery({
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    final json =
        await ApiClient.fetch<Map<String, dynamic>>('/search-history$qs');
    return ApiResponse.fromJson(json, (d) {
      return (d as List)
          .map((e) => ApiSearchHistory.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// POST /search-history
  static Future<ApiResponse<ApiSearchHistory>> record({
    required String query,
    Map<String, dynamic>? filters,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/search-history',
      method: 'POST',
      body: {
        'query': query,
        if (filters != null) 'filters': filters,
      },
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiSearchHistory.fromJson(d as Map<String, dynamic>),
    );
  }

  /// DELETE /search-history/:id
  static Future<void> delete(String id) async {
    await ApiClient.fetch<Map<String, dynamic>>(
        '/search-history/$id', method: 'DELETE');
  }

  /// DELETE /search-history — clear all
  static Future<void> deleteAll() async {
    await ApiClient.fetch<Map<String, dynamic>>('/search-history',
        method: 'DELETE');
  }
}
