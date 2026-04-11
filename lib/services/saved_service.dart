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
      return (d as List)
          .map((e) => ApiSavedProperty.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// POST /saved/toggle/:propertyId
  static Future<ApiResponse<Map<String, dynamic>>> toggle(
      String propertyId) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/saved/toggle/$propertyId',
      method: 'POST',
    );
    return ApiResponse.fromJson(json, (d) => d as Map<String, dynamic>);
  }
}
