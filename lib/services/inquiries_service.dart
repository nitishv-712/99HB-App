import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/api_response.dart';
import 'package:homebazaar/model/inquiry.dart';

abstract final class InquiriesService {
  /// POST /inquiries
  static Future<ApiResponse<ApiInquiry>> submit({
    required String propertyId,
    required String message,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/inquiries/',
      method: 'POST',
      body: {'property': propertyId, 'message': message},
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiInquiry.fromJson((d as Map<String, dynamic>)['inquiry'] as Map<String, dynamic>),
    );
  }

  /// GET /inquiries
  static Future<ApiResponse<List<ApiInquiry>>> list({
    InquiryStatus? status,
    int? page,
    int? limit,
  }) async {
    final qs = ApiClient.buildQuery({
      if (status != null) 'status': status.name,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    final json = await ApiClient.fetch<Map<String, dynamic>>('/inquiries$qs');
    return ApiResponse.fromJson(json, (d) {
      final list = d as List;
      return list.map((e) => ApiInquiry.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  /// GET /inquiries/me
  static Future<ApiResponse<List<ApiInquiry>>> myInquiries({
    InquiryStatus? status,
    int? page,
    int? limit,
  }) async {
    final qs = ApiClient.buildQuery({
      if (status != null) 'status': status.name,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    final json = await ApiClient.fetch<Map<String, dynamic>>('/inquiries/me$qs');
    return ApiResponse.fromJson(json, (d) {
      final list = d as List;
      return list.map((e) => ApiInquiry.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  /// GET /inquiries/:id
  static Future<ApiResponse<SingleInquiryData>> get(String id) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>('/inquiries/$id');
    return ApiResponse.fromJson(
      json,
      (d) => SingleInquiryData.fromJson(d as Map<String, dynamic>),
    );
  }

  /// POST /inquiries/:id/message
  static Future<void> sendMessage(String id, String text) async {
    await ApiClient.fetch<Map<String, dynamic>>(
      '/inquiries/$id/message',
      method: 'POST',
      body: {'text': text},
    );
  }

  /// PATCH /inquiries/:id/status
  static Future<ApiResponse<ApiInquiry>> updateStatus(
    String id,
    InquiryStatus status,
  ) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/inquiries/$id/status',
      method: 'PATCH',
      body: {'status': status.name},
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiInquiry.fromJson((d as Map<String, dynamic>)['inquiry'] as Map<String, dynamic>),
    );
  }
}
