import 'package:homebazaar/model/user.dart';

enum ListingType { sale, rent }
enum PropertyType { house, apartment, villa, penthouse, townhouse, land, office }
enum PropertyStatus { pending, active, sold, rented, archived }
enum PropertyBadge { premium, newBadge, featured }

ListingType _listingTypeFromString(String v) =>
    v == 'sale' ? ListingType.sale : ListingType.rent;

PropertyType _propertyTypeFromString(String v) {
  const map = {
    'House': PropertyType.house,
    'Apartment': PropertyType.apartment,
    'Villa': PropertyType.villa,
    'Penthouse': PropertyType.penthouse,
    'Townhouse': PropertyType.townhouse,
    'Land': PropertyType.land,
    'Office': PropertyType.office,
  };
  return map[v] ?? PropertyType.house;
}

PropertyStatus _propertyStatusFromString(String v) =>
    PropertyStatus.values.firstWhere((e) => e.name == v);

PropertyBadge? _badgeFromString(String? v) {
  if (v == null) return null;
  const map = {
    'Premium': PropertyBadge.premium,
    'New': PropertyBadge.newBadge,
    'Featured': PropertyBadge.featured,
  };
  return map[v];
}

String _badgeToString(PropertyBadge? b) {
  if (b == null) return '';
  const map = {
    PropertyBadge.premium: 'Premium',
    PropertyBadge.newBadge: 'New',
    PropertyBadge.featured: 'Featured',
  };
  return map[b] ?? '';
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

class PropertyAddress {
  final String? street;
  final String city;
  final String? state;
  final String? zip;
  final String country;

  const PropertyAddress({
    this.street,
    required this.city,
    this.state,
    this.zip,
    this.country = 'IN',
  });

  factory PropertyAddress.fromJson(Map<String, dynamic> j) => PropertyAddress(
        street: j['street'] as String?,
        city: j['city'] as String,
        state: j['state'] as String?,
        zip: j['zip'] as String?,
        country: (j['country'] as String?) ?? 'IN',
      );

  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'state': state,
        'zip': zip,
        'country': country,
      };
}

class PropertyLocation {
  /// Always "Point"
  final String type;

  /// [longitude, latitude]
  final List<double> coordinates;

  const PropertyLocation({required this.type, required this.coordinates});

  factory PropertyLocation.fromJson(Map<String, dynamic> j) => PropertyLocation(
        type: j['type'] as String,
        coordinates: (j['coordinates'] as List).map((e) => (e as num).toDouble()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'coordinates': coordinates,
      };
}

class PropertyImage {
  final String id;
  final String url;
  final String? filename;
  final bool isPrimary;

  const PropertyImage({
    required this.id,
    required this.url,
    this.filename,
    required this.isPrimary,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> j) => PropertyImage(
        id: j['_id'] as String,
        url: j['url'] as String,
        filename: j['filename'] as String?,
        isPrimary: j['isPrimary'] as bool,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'url': url,
        'filename': filename,
        'isPrimary': isPrimary,
      };
}

class ApiProperty {
  final String id;
  final String title;
  final String? description;
  final ListingType listingType;
  final PropertyType propertyType;
  final PropertyStatus status;
  final PropertyBadge? badge;
  final double price;
  final PropertyAddress address;
  final PropertyLocation location;
  final int bedrooms;
  final int bathrooms;
  final double sqft;
  final int? yearBuilt;
  final List<PropertyImage> images;

  /// Either a populated [ApiUser] or a raw ID string
  final dynamic owner;

  final int views;
  final int saves;
  final int inquiries;
  final bool isFeatured;

  /// Virtual — e.g. "₹45,00,000" or "₹25,000/mo"
  final String priceLabel;

  /// Virtual — "For Sale" | "For Rent"
  final String tag;

  /// Virtual — "City, State"
  final String locationString;

  final String createdAt;
  final String updatedAt;

  const ApiProperty({
    required this.id,
    required this.title,
    this.description,
    required this.listingType,
    required this.propertyType,
    required this.status,
    this.badge,
    required this.price,
    required this.address,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
    this.yearBuilt,
    required this.images,
    required this.owner,
    required this.views,
    required this.saves,
    required this.inquiries,
    required this.isFeatured,
    required this.priceLabel,
    required this.tag,
    required this.locationString,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiProperty.fromJson(Map<String, dynamic> j) => ApiProperty(
        id: j['_id'] as String,
        title: j['title'] as String,
        description: j['description'] as String?,
        listingType: _listingTypeFromString(j['listingType'] as String),
        propertyType: _propertyTypeFromString(j['propertyType'] as String),
        status: _propertyStatusFromString(j['status'] as String),
        badge: _badgeFromString(j['badge'] as String?),
        price: (j['price'] as num).toDouble(),
        address: PropertyAddress.fromJson(j['address'] as Map<String, dynamic>),
        location: PropertyLocation.fromJson(j['location'] as Map<String, dynamic>),
        bedrooms: j['bedrooms'] as int,
        bathrooms: j['bathrooms'] as int,
        sqft: (j['sqft'] as num).toDouble(),
        yearBuilt: j['yearBuilt'] as int?,
        images: (j['images'] as List)
            .map((e) => PropertyImage.fromJson(e as Map<String, dynamic>))
            .toList(),
        owner: j['owner'] is Map
            ? ApiUser.fromJson(j['owner'] as Map<String, dynamic>)
            : j['owner'] as String,
        views: j['views'] as int,
        saves: j['saves'] as int,
        inquiries: j['inquiries'] as int,
        isFeatured: j['isFeatured'] as bool,
        priceLabel: j['priceLabel'] as String,
        tag: j['tag'] as String,
        locationString: j['locationString'] as String,
        createdAt: j['createdAt'] as String,
        updatedAt: j['updatedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'listingType': listingType.name,
        'propertyType': _propertyTypeToString(propertyType),
        'status': status.name,
        'badge': _badgeToString(badge),
        'price': price,
        'address': address.toJson(),
        'location': location.toJson(),
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'sqft': sqft,
        'yearBuilt': yearBuilt,
        'images': images.map((e) => e.toJson()).toList(),
        'owner': owner is ApiUser ? (owner as ApiUser).toJson() : owner,
        'views': views,
        'saves': saves,
        'inquiries': inquiries,
        'isFeatured': isFeatured,
        'priceLabel': priceLabel,
        'tag': tag,
        'locationString': locationString,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  /// Convenience: primary image URL or null
  String? get primaryImageUrl {
    try {
      return images.firstWhere((i) => i.isPrimary).url;
    } catch (_) {
      return images.isNotEmpty ? images.first.url : null;
    }
  }
}
