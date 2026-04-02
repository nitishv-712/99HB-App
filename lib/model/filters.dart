import 'package:homebazaar/model/property.dart';

enum SortOrder { newest, oldest, priceAsc, priceDesc, popular }

String _sortToString(SortOrder s) {
  const map = {
    SortOrder.newest: 'newest',
    SortOrder.oldest: 'oldest',
    SortOrder.priceAsc: 'price_asc',
    SortOrder.priceDesc: 'price_desc',
    SortOrder.popular: 'popular',
  };
  return map[s] ?? 'newest';
}

class PropertyFilters {
  final SortOrder? sort;
  final int? page;
  final int? limit;
  final ListingType? type;
  final PropertyType? propType;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final String? minBeds;
  final int? minBaths;
  final bool? featured;
  final String? search;

  const PropertyFilters({
    this.sort,
    this.page,
    this.limit,
    this.type,
    this.propType,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.minBeds,
    this.minBaths,
    this.featured,
    this.search,
  });

  Map<String, dynamic> toQueryParams() {
    final map = <String, dynamic>{};
    if (sort != null) map['sort'] = _sortToString(sort!);
    if (page != null) map['page'] = page;
    if (limit != null) map['limit'] = limit;
    if (type != null) map['type'] = type!.name;
    if (propType != null) {
      const names = {
        PropertyType.house: 'House',
        PropertyType.apartment: 'Apartment',
        PropertyType.villa: 'Villa',
        PropertyType.penthouse: 'Penthouse',
        PropertyType.townhouse: 'Townhouse',
        PropertyType.land: 'Land',
        PropertyType.office: 'Office',
      };
      map['propType'] = names[propType];
    }
    if (city != null) map['city'] = city;
    if (minPrice != null) map['minPrice'] = minPrice;
    if (maxPrice != null) map['maxPrice'] = maxPrice;
    if (minBeds != null) map['minBeds'] = minBeds;
    if (minBaths != null) map['minBaths'] = minBaths;
    if (featured != null) map['featured'] = featured;
    if (search != null) map['search'] = search;
    return map;
  }

  PropertyFilters copyWith({
    SortOrder? sort,
    int? page,
    int? limit,
    ListingType? type,
    PropertyType? propType,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? minBeds,
    int? minBaths,
    bool? featured,
    String? search,
  }) =>
      PropertyFilters(
        sort: sort ?? this.sort,
        page: page ?? this.page,
        limit: limit ?? this.limit,
        type: type ?? this.type,
        propType: propType ?? this.propType,
        city: city ?? this.city,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        minBeds: minBeds ?? this.minBeds,
        minBaths: minBaths ?? this.minBaths,
        featured: featured ?? this.featured,
        search: search ?? this.search,
      );
}

class PaginationParams {
  final int? page;
  final int? limit;

  const PaginationParams({this.page, this.limit});

  Map<String, dynamic> toQueryParams() => {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      };
}
