import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/api_response.dart';
import 'package:homebazaar/model/comparison.dart';

abstract final class ComparisonsService {
  /// POST /comparisons
  static Future<ApiResponse<ApiComparison>> create({
    required String name,
    required List<String> propertyIds,
    String? description,
    String? notes,
    List<String>? tags,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/comparisons',
      method: 'POST',
      body: {
        'name': name,
        'propertyIds': propertyIds,
        'description': ?description,
        'notes': ?notes,
        'tags': ?tags,
      },
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiComparison.fromJson(
        (d as Map<String, dynamic>)['comparison'] as Map<String, dynamic>,
      ),
    );
  }

  /// GET /comparisons
  static Future<ApiResponse<List<ApiComparison>>> list({
    int? page,
    int? limit,
  }) async {
    final qs = ApiClient.buildQuery({'page': ?page, 'limit': ?limit});
    final json = await ApiClient.fetch<Map<String, dynamic>>('/comparisons$qs');
    return ApiResponse.fromJson(json, (d) {
      final list = d as List;
      return list
          .map((e) => ApiComparison.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// GET /comparisons/:id
  static Future<Map<String, dynamic>> get(String id) =>
      ApiClient.fetch<Map<String, dynamic>>('/comparisons/$id');

  /// PATCH /comparisons/:id
  static Future<ApiResponse<ApiComparison>> update(
    String id, {
    String? name,
    String? description,
    String? notes,
    List<String>? tags,
    bool? isPublic,
    List<String>? propertyIds,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/comparisons/$id',
      method: 'PATCH',
      body: {
        'name': ?name,
        'description': ?description,
        'notes': ?notes,
        'tags': ?tags,
        'isPublic': ?isPublic,
        'propertyIds': ?propertyIds,
      },
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiComparison.fromJson(
        (d as Map<String, dynamic>)['comparison'] as Map<String, dynamic>,
      ),
    );
  }

  /// POST /comparisons/:id/add-property
  static Future<ApiResponse<ApiComparison>> addProperty(
    String id,
    String propertyId,
  ) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/comparisons/$id/add-property',
      method: 'POST',
      body: {'propertyId': propertyId},
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiComparison.fromJson(
        (d as Map<String, dynamic>)['comparison'] as Map<String, dynamic>,
      ),
    );
  }

  /// POST /comparisons/:id/remove-property
  static Future<ApiResponse<ApiComparison>> removeProperty(
    String id,
    String propertyId,
  ) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/comparisons/$id/remove-property',
      method: 'POST',
      body: {'propertyId': propertyId},
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiComparison.fromJson(
        (d as Map<String, dynamic>)['comparison'] as Map<String, dynamic>,
      ),
    );
  }

  /// DELETE /comparisons/:id
  static Future<void> delete(String id) async {
    await ApiClient.fetch<Map<String, dynamic>>(
      '/comparisons/$id',
      method: 'DELETE',
    );
  }
}
