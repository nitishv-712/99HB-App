import 'package:homebazaar/model/property.dart';

class PricePerSqftEntry {
  final String propertyId;
  final String title;
  final double pricePerSqft;

  const PricePerSqftEntry({
    required this.propertyId,
    required this.title,
    required this.pricePerSqft,
  });

  factory PricePerSqftEntry.fromJson(Map<String, dynamic> j) => PricePerSqftEntry(
        propertyId: j['propertyId'] as String,
        title: j['title'] as String,
        pricePerSqft: (j['pricePerSqft'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        'title': title,
        'pricePerSqft': pricePerSqft,
      };
}

class _RangeStats {
  final double min;
  final double max;
  final double? average;

  const _RangeStats({required this.min, required this.max, this.average});

  factory _RangeStats.fromJson(Map<String, dynamic> j) => _RangeStats(
        min: (j['min'] as num).toDouble(),
        max: (j['max'] as num).toDouble(),
        average: j['average'] != null ? (j['average'] as num).toDouble() : null,
      );

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        if (average != null) 'average': average,
      };
}

class ComparisonAnalysis {
  final int totalProperties;
  final _RangeStats priceRange;
  final _RangeStats bedroomRange;
  final _RangeStats bathroomRange;
  final _RangeStats sqftRange;
  final List<PricePerSqftEntry> pricePerSqft;

  const ComparisonAnalysis({
    required this.totalProperties,
    required this.priceRange,
    required this.bedroomRange,
    required this.bathroomRange,
    required this.sqftRange,
    required this.pricePerSqft,
  });

  factory ComparisonAnalysis.fromJson(Map<String, dynamic> j) => ComparisonAnalysis(
        totalProperties: j['totalProperties'] as int,
        priceRange: _RangeStats.fromJson(j['priceRange'] as Map<String, dynamic>),
        bedroomRange: _RangeStats.fromJson(j['bedroomRange'] as Map<String, dynamic>),
        bathroomRange: _RangeStats.fromJson(j['bathroomRange'] as Map<String, dynamic>),
        sqftRange: _RangeStats.fromJson(j['sqftRange'] as Map<String, dynamic>),
        pricePerSqft: (j['pricePerSqft'] as List)
            .map((e) => PricePerSqftEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ApiComparison {
  final String id;
  final String user;
  final String name;
  final String? description;

  /// Populated [ApiProperty] list or raw ID strings
  final List<dynamic> propertyIds;

  final List<String> tags;
  final String? notes;
  final bool isPublic;
  final String createdAt;
  final String updatedAt;

  const ApiComparison({
    required this.id,
    required this.user,
    required this.name,
    this.description,
    required this.propertyIds,
    required this.tags,
    this.notes,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiComparison.fromJson(Map<String, dynamic> j) => ApiComparison(
        id: j['_id'] as String,
        user: j['user'] as String,
        name: j['name'] as String,
        description: j['description'] as String?,
        propertyIds: (j['propertyIds'] as List).map((e) {
          if (e is Map<String, dynamic>) return ApiProperty.fromJson(e);
          return e as String;
        }).toList(),
        tags: List<String>.from(j['tags'] as List),
        notes: j['notes'] as String?,
        isPublic: j['isPublic'] as bool,
        createdAt: j['createdAt'] as String,
        updatedAt: j['updatedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'user': user,
        'name': name,
        'description': description,
        'propertyIds': propertyIds.map((e) => e is ApiProperty ? e.toJson() : e).toList(),
        'tags': tags,
        'notes': notes,
        'isPublic': isPublic,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
