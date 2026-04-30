import 'package:json_annotation/json_annotation.dart';
import 'package:homebazaar/model/user.dart';

part 'property.g.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum ListingType {
  @JsonValue('sale')
  sale,
  @JsonValue('rent')
  rent,
}

enum PropertyType {
  @JsonValue('House')
  house,
  @JsonValue('Apartment')
  apartment,
  @JsonValue('Villa')
  villa,
  @JsonValue('Penthouse')
  penthouse,
  @JsonValue('Townhouse')
  townhouse,
  @JsonValue('Land')
  land,
  @JsonValue('Office')
  office,
}

enum PropertyStatus { pending, active, sold, rented, archived }

enum PropertyBadge {
  @JsonValue('Premium')
  premium,
  @JsonValue('New')
  newBadge,
  @JsonValue('Featured')
  featured,
}

// ── Address ───────────────────────────────────────────────────────────────────

@JsonSerializable()
class PropertyAddress {
  final String? street;
  @JsonKey(defaultValue: '')
  final String city;
  final String? state;
  final String? zip;
  @JsonKey(defaultValue: 'IN')
  final String country;

  const PropertyAddress({
    this.street,
    required this.city,
    this.state,
    this.zip,
    this.country = 'IN',
  });

  factory PropertyAddress.fromJson(Map<String, dynamic> json) =>
      _$PropertyAddressFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyAddressToJson(this);
}

// ── Location ──────────────────────────────────────────────────────────────────

@JsonSerializable()
class PropertyLocation {
  final String type;
  final List<double> coordinates;

  const PropertyLocation({required this.type, required this.coordinates});

  factory PropertyLocation.fromJson(Map<String, dynamic> json) =>
      _$PropertyLocationFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyLocationToJson(this);
}

// ── Image ─────────────────────────────────────────────────────────────────────

@JsonSerializable()
class PropertyImage {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String url;
  final String? filename;
  @JsonKey(defaultValue: false)
  final bool isPrimary;

  const PropertyImage({
    required this.id,
    required this.url,
    this.filename,
    required this.isPrimary,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) =>
      _$PropertyImageFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyImageToJson(this);
}

// ── Property ──────────────────────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class Property {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(defaultValue: '')
  final String title;
  final String? description;
  @JsonKey(defaultValue: ListingType.sale, unknownEnumValue: ListingType.sale)
  final ListingType listingType;
  @JsonKey(
    defaultValue: PropertyType.apartment,
    unknownEnumValue: PropertyType.apartment,
  )
  final PropertyType propertyType;
  @JsonKey(
    defaultValue: PropertyStatus.active,
    unknownEnumValue: PropertyStatus.active,
  )
  final PropertyStatus status;
  final PropertyBadge? badge;
  @JsonKey(fromJson: _toDouble)
  final double price;
  @JsonKey(fromJson: _addressFromJson)
  final PropertyAddress address;
  final PropertyLocation? location;
  @JsonKey(defaultValue: 0)
  final int bedrooms;
  final int? bathrooms;
  @JsonKey(fromJson: _toDouble)
  final double sqft;
  final int? yearBuilt;
  @JsonKey(fromJson: _imagesFromJson)
  final List<PropertyImage> images;
  @JsonKey(fromJson: _ownerFromJson, toJson: _ownerToJson)
  final dynamic owner;
  @JsonKey(defaultValue: 0)
  final int views;
  @JsonKey(defaultValue: 0)
  final int saves;
  @JsonKey(defaultValue: 0)
  final int inquiries;
  @JsonKey(defaultValue: false)
  final bool isFeatured;
  @JsonKey(defaultValue: '')
  final String priceLabel;
  @JsonKey(defaultValue: '')
  final String tag;
  @JsonKey(defaultValue: '')
  final String locationString;
  final String? createdAt;
  final String? updatedAt;

  const Property({
    required this.id,
    required this.title,
    this.description,
    required this.listingType,
    required this.propertyType,
    required this.status,
    this.badge,
    required this.price,
    required this.address,
    this.location,
    required this.bedrooms,
    this.bathrooms,
    required this.sqft,
    this.yearBuilt,
    required this.images,
    this.owner,
    required this.views,
    required this.saves,
    required this.inquiries,
    required this.isFeatured,
    required this.priceLabel,
    required this.tag,
    required this.locationString,
    this.createdAt,
    this.updatedAt,
  });

  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    try {
      return images.firstWhere((i) => i.isPrimary).url;
    } catch (_) {
      return images.first.url;
    }
  }

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyToJson(this);
}

typedef ApiProperty = Property;

// ── Converters ────────────────────────────────────────────────────────────────

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

PropertyAddress _addressFromJson(dynamic v) {
  if (v is Map<String, dynamic>) return PropertyAddress.fromJson(v);
  return PropertyAddress(city: v as String? ?? '');
}

List<PropertyImage> _imagesFromJson(dynamic v) {
  final list = v as List? ?? [];
  return list.map((e) {
    if (e is Map<String, dynamic>) return PropertyImage.fromJson(e);
    return PropertyImage(id: '', url: e as String, isPrimary: false);
  }).toList();
}

dynamic _ownerFromJson(dynamic v) =>
    v is Map<String, dynamic> ? User.fromJson(v) : v;

dynamic _ownerToJson(dynamic v) => v is User ? v.toJson() : v;
