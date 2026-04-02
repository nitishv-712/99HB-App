import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/api_response.dart';
import 'package:homebazaar/model/review.dart';

abstract final class ReviewsService {
  /// POST /reviews
  static Future<ApiResponse<ApiReview>> submit({
    required String propertyId,
    required int rating,
    required String title,
    required String comment,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/reviews',
      method: 'POST',
      body: {
        'property': propertyId,
        'rating': rating,
        'title': title,
        'comment': comment,
      },
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiReview.fromJson((d as Map<String, dynamic>)['review'] as Map<String, dynamic>),
    );
  }

  /// GET /reviews/property/:propertyId
  static Future<Map<String, dynamic>> forProperty(
    String propertyId, {
    int? rating,
    String? sort, // "rating-high" | "rating-low" | "oldest"
    int? page,
    int? limit,
  }) async {
    final qs = ApiClient.buildQuery({
      if (rating != null) 'rating': rating,
      if (sort != null) 'sort': sort,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    return ApiClient.fetch<Map<String, dynamic>>(
      '/reviews/property/$propertyId$qs',
    );
  }

  /// GET /reviews/user/my-reviews
  static Future<ApiResponse<List<ApiReview>>> myReviews({int? page, int? limit}) async {
    final qs = ApiClient.buildQuery({
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    final json = await ApiClient.fetch<Map<String, dynamic>>('/reviews/user/my-reviews$qs');
    return ApiResponse.fromJson(json, (d) {
      final list = d as List;
      return list.map((e) => ApiReview.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  /// GET /reviews/:id
  static Future<ApiResponse<ApiReview>> get(String id) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>('/reviews/$id');
    return ApiResponse.fromJson(
      json,
      (d) => ApiReview.fromJson((d as Map<String, dynamic>)['review'] as Map<String, dynamic>),
    );
  }

  /// PATCH /reviews/:id
  static Future<ApiResponse<ApiReview>> update(
    String id, {
    int? rating,
    String? title,
    String? comment,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/reviews/$id',
      method: 'PATCH',
      body: {
        if (rating != null) 'rating': rating,
        if (title != null) 'title': title,
        if (comment != null) 'comment': comment,
      },
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiReview.fromJson((d as Map<String, dynamic>)['review'] as Map<String, dynamic>),
    );
  }

  /// DELETE /reviews/:id
  static Future<void> delete(String id) async {
    await ApiClient.fetch<Map<String, dynamic>>('/reviews/$id', method: 'DELETE');
  }
}
