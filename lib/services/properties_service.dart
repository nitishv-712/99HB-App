import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/api_response.dart';
import 'package:homebazaar/model/filters.dart';
import 'package:homebazaar/model/property.dart';

abstract final class PropertiesService {
  /// GET /properties
  static Future<ApiResponse<List<ApiProperty>>> list([PropertyFilters filters = const PropertyFilters()]) async {
    final qs = ApiClient.buildQuery(filters.toQueryParams());
    final json = await ApiClient.fetch<Map<String, dynamic>>('/properties$qs');
    return ApiResponse.fromJson(json, (d) {
      final list = d as List;
      return list.map((e) => ApiProperty.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  /// GET /properties/featured
  static Future<ApiResponse<List<ApiProperty>>> featured() async {
    final json = await ApiClient.fetch<Map<String, dynamic>>('/properties/featured');
    return ApiResponse.fromJson(json, (d) {
      final list = (d as Map<String, dynamic>)['properties'] as List;
      return list.map((e) => ApiProperty.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  /// GET /properties/:id
  static Future<ApiResponse<ApiProperty>> get(String id) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>('/properties/$id');
    return ApiResponse.fromJson(
      json,
      (d) => ApiProperty.fromJson((d as Map<String, dynamic>)['property'] as Map<String, dynamic>),
    );
  }

  /// POST /properties
  static Future<ApiResponse<ApiProperty>> create({
    required String title,
    required ListingType listingType,
    required PropertyType propertyType,
    required double price,
    required Map<String, dynamic> address,
    String? description,
    int? bedrooms,
    int? bathrooms,
    double? sqft,
    int? yearBuilt,
    PropertyBadge? badge,
    bool? isFeatured,
    required List<Map<String, dynamic>> images,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/properties',
      method: 'POST',
      body: {
        'title': title,
        'listingType': listingType.name,
        'propertyType': _propertyTypeToString(propertyType),
        'price': price,
        'address': address,
        if (description != null) 'description': description,
        if (bedrooms != null) 'bedrooms': bedrooms,
        if (bathrooms != null) 'bathrooms': bathrooms,
        if (sqft != null) 'sqft': sqft,
        if (yearBuilt != null) 'yearBuilt': yearBuilt,
        if (badge != null) 'badge': _badgeToString(badge),
        if (isFeatured != null) 'isFeatured': isFeatured,
        'images': images,
      },
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiProperty.fromJson((d as Map<String, dynamic>)['property'] as Map<String, dynamic>),
    );
  }

  /// PATCH /properties/:id
  static Future<ApiResponse<ApiProperty>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/properties/$id',
      method: 'PATCH',
      body: body,
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiProperty.fromJson((d as Map<String, dynamic>)['property'] as Map<String, dynamic>),
    );
  }

  /// DELETE /properties/:id
  static Future<void> delete(String id) async {
    await ApiClient.fetch<Map<String, dynamic>>('/properties/$id', method: 'DELETE');
  }
}

String _propertyTypeToString(PropertyType t) {
  const map = {
    PropertyType.house: 'House',
    PropertyType.apartment: 'Apartment',
    PropertyType.villa: 'Villa',
    PropertyType.penthouse: 'Penthouse',
    PropertyType.townhouse: 'Townhouse',
    PropertyType.land: 'Land',
    PropertyType.office: 'Office',
  };
  return map[t] ?? 'House';
}

String _badgeToString(PropertyBadge b) {
  const map = {
    PropertyBadge.premium: 'Premium',
    PropertyBadge.newBadge: 'New',
    PropertyBadge.featured: 'Featured',
  };
  return map[b] ?? '';
}
