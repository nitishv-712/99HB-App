// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyAddress _$PropertyAddressFromJson(Map<String, dynamic> json) =>
    PropertyAddress(
      street: json['street'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String?,
      zip: json['zip'] as String?,
      country: json['country'] as String? ?? 'IN',
    );

Map<String, dynamic> _$PropertyAddressToJson(PropertyAddress instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'zip': instance.zip,
      'country': instance.country,
    };

PropertyLocation _$PropertyLocationFromJson(Map<String, dynamic> json) =>
    PropertyLocation(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$PropertyLocationToJson(PropertyLocation instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

PropertyImage _$PropertyImageFromJson(Map<String, dynamic> json) =>
    PropertyImage(
      id: json['_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      filename: json['filename'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );

Map<String, dynamic> _$PropertyImageToJson(PropertyImage instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'url': instance.url,
      'filename': instance.filename,
      'isPrimary': instance.isPrimary,
    };

Property _$PropertyFromJson(Map<String, dynamic> json) => Property(
  id: json['_id'] as String,
  title: json['title'] as String? ?? '',
  description: json['description'] as String?,
  listingType:
      $enumDecodeNullable(
        _$ListingTypeEnumMap,
        json['listingType'],
        unknownValue: ListingType.sale,
      ) ??
      ListingType.sale,
  propertyType:
      $enumDecodeNullable(
        _$PropertyTypeEnumMap,
        json['propertyType'],
        unknownValue: PropertyType.apartment,
      ) ??
      PropertyType.apartment,
  status:
      $enumDecodeNullable(
        _$PropertyStatusEnumMap,
        json['status'],
        unknownValue: PropertyStatus.active,
      ) ??
      PropertyStatus.active,
  badge: $enumDecodeNullable(_$PropertyBadgeEnumMap, json['badge']),
  price: _toDouble(json['price']),
  address: _addressFromJson(json['address']),
  location: json['location'] == null
      ? null
      : PropertyLocation.fromJson(json['location'] as Map<String, dynamic>),
  bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
  bathrooms: (json['bathrooms'] as num?)?.toInt(),
  sqft: _toDouble(json['sqft']),
  yearBuilt: (json['yearBuilt'] as num?)?.toInt(),
  images: _imagesFromJson(json['images']),
  owner: _ownerFromJson(json['owner']),
  views: (json['views'] as num?)?.toInt() ?? 0,
  saves: (json['saves'] as num?)?.toInt() ?? 0,
  inquiries: (json['inquiries'] as num?)?.toInt() ?? 0,
  isFeatured: json['isFeatured'] as bool? ?? false,
  priceLabel: '₹${NumberFormat('#,##,###', 'en_IN').format(json['price'] as int? ?? 0)}',
  tag:
      "For ${json['listingType'].toString()[0].toUpperCase()}${json['listingType'].toString().substring(1)}",
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'listingType': _$ListingTypeEnumMap[instance.listingType]!,
  'propertyType': _$PropertyTypeEnumMap[instance.propertyType]!,
  'status': _$PropertyStatusEnumMap[instance.status]!,
  'badge': _$PropertyBadgeEnumMap[instance.badge],
  'price': instance.price,
  'address': instance.address.toJson(),
  'location': instance.location?.toJson(),
  'bedrooms': instance.bedrooms,
  'bathrooms': instance.bathrooms,
  'sqft': instance.sqft,
  'yearBuilt': instance.yearBuilt,
  'images': instance.images.map((e) => e.toJson()).toList(),
  'owner': _ownerToJson(instance.owner),
  'views': instance.views,
  'saves': instance.saves,
  'inquiries': instance.inquiries,
  'isFeatured': instance.isFeatured,
  'priceLabel': instance.priceLabel,
  'tag': instance.tag,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$ListingTypeEnumMap = {
  ListingType.sale: 'sale',
  ListingType.rent: 'rent',
};

const _$PropertyTypeEnumMap = {
  PropertyType.house: 'House',
  PropertyType.apartment: 'Apartment',
  PropertyType.villa: 'Villa',
  PropertyType.penthouse: 'Penthouse',
  PropertyType.townhouse: 'Townhouse',
  PropertyType.land: 'Land',
  PropertyType.office: 'Office',
};

const _$PropertyStatusEnumMap = {
  PropertyStatus.pending: 'pending',
  PropertyStatus.active: 'active',
  PropertyStatus.sold: 'sold',
  PropertyStatus.rented: 'rented',
  PropertyStatus.archived: 'archived',
};

const _$PropertyBadgeEnumMap = {
  PropertyBadge.premium: 'Premium',
  PropertyBadge.newBadge: 'New',
  PropertyBadge.featured: 'Featured',
};
