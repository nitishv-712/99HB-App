import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/api_response.dart';
import 'package:homebazaar/model/misc.dart';
import 'package:homebazaar/model/property.dart';

abstract final class UsersService {
  /// GET /users/saved
  static Future<ApiResponse<List<ApiProperty>>> saved() async {
    final json = await ApiClient.fetch<Map<String, dynamic>>('/users/saved');
    return ApiResponse.fromJson(json, (d) {
      final list = (d as Map<String, dynamic>)['properties'] as List? ?? [];
      return list
          .map((e) => ApiProperty.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// GET /users/my-listings
  static Future<ApiResponse<List<ApiProperty>>> myListings({
    PropertyStatus? status,
    int? page,
    int? limit,
  }) async {
    final qs = ApiClient.buildQuery({
      if (status != null) 'status': status.name,
      'page': ?page,
      'limit': ?limit,
    });
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/users/my-listings$qs',
    );
    return ApiResponse.fromJson(json, (d) {
      final list = d as List;
      return list
          .map((e) => ApiProperty.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// PATCH /users/update-profile
  static Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? firstName,
    String? lastName,
    String? avatar,
    String? email,
    String? phone,
    String? panNumber,
    String? panCardImage,
    String? aadharNumber,
    String? aadharCardImage,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/users/update-profile',
      method: 'PATCH',
      body: {
        'firstName': ?firstName,
        'lastName': ?lastName,
        'avatar': ?avatar,
        'email': ?email,
        'phone': ?phone,
        'panNumber': ?panNumber,
        'panCardImage': ?panCardImage,
        'aadharNumber': ?aadharNumber,
        'aadharCardImage': ?aadharCardImage,
      },
    );
    return ApiResponse.fromJson(json, (d) => d as Map<String, dynamic>);
  }

  /// GET /uploads/:name — get presigned upload URL
  static Future<ApiResponse<UploadLinkResponse>> getUploadUrl(
    UploadFolder folder,
  ) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/uploads/${folder.name}',
    );
    return ApiResponse.fromJson(
      json,
      (d) => UploadLinkResponse.fromJson(d as Map<String, dynamic>),
    );
  }

  /// PUT directly to presigned URL
  static Future<void> uploadToSupabase({
    required Uri uploadUrl,
    required List<int> fileBytes,
    required String contentType,
  }) => ApiClient.uploadToPresignedUrl(uploadUrl, fileBytes, contentType);
}
