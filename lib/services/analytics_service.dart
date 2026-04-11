import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/analytics.dart';
import 'package:homebazaar/model/api_response.dart';

abstract final class AnalyticsService {
  /// GET /analytics/overview
  static Future<ApiResponse<OwnerAnalytics>> overview() async {
    final json =
        await ApiClient.fetch<Map<String, dynamic>>('/analytics/overview');
    return ApiResponse.fromJson(
      json,
      (d) => OwnerAnalytics.fromJson(d as Map<String, dynamic>),
    );
  }

  /// GET /analytics/property/:id
  static Future<ApiResponse<PropertyAnalytics>> property(String id) async {
    final json =
        await ApiClient.fetch<Map<String, dynamic>>('/analytics/property/$id');
    return ApiResponse.fromJson(
      json,
      (d) => PropertyAnalytics.fromJson(d as Map<String, dynamic>),
    );
  }
}
