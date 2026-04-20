import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/api_response.dart';
import 'package:homebazaar/model/misc.dart';

abstract final class SavedService {
  /// GET /saved
  static Future<ApiResponse<List<ApiSavedProperty>>> list({
    int? page,
    int? limit,
  }) async {
    final qs = ApiClient.buildQuery({
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    final json = await ApiClient.fetch<Map<String, dynamic>>('/saved$qs');
    return ApiResponse.fromJson(json, (d) {
      if (d is List) return d
          .map((e) => ApiSavedProperty.fromJson(e as Map<String, dynamic>))
          .toList();
      if (d is Map<String, dynamic>) {
        for (final key in ['savedProperties', 'saved', 'items', 'data']) {
          if (d[key] is List) {
            return (d[key] as List)
                .map((e) => ApiSavedProperty.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
      }
      return <ApiSavedProperty>[];
    });
  }

  /// POST /saved/toggle/:propertyId
  static Future<ApiResponse<Map<String, dynamic>>> toggle(
    String propertyId,
  ) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/saved/toggle/$propertyId',
      method: 'POST',
    );
    return ApiResponse.fromJson(json, (d) => d as Map<String, dynamic>);
  }
}
