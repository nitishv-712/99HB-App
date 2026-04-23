// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RangeStats _$RangeStatsFromJson(Map<String, dynamic> json) => RangeStats(
  min: _toDouble(json['min']),
  max: _toDouble(json['max']),
  average: _toDoubleNullable(json['average']),
);

Map<String, dynamic> _$RangeStatsToJson(RangeStats instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'average': instance.average,
    };

PricePerSqftEntry _$PricePerSqftEntryFromJson(Map<String, dynamic> json) =>
    PricePerSqftEntry(
      propertyId: json['propertyId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      pricePerSqft: _toDouble(json['pricePerSqft']),
    );

Map<String, dynamic> _$PricePerSqftEntryToJson(PricePerSqftEntry instance) =>
    <String, dynamic>{
      'propertyId': instance.propertyId,
      'title': instance.title,
      'pricePerSqft': instance.pricePerSqft,
    };

ComparisonAnalysis _$ComparisonAnalysisFromJson(
  Map<String, dynamic> json,
) => ComparisonAnalysis(
  totalProperties: (json['totalProperties'] as num?)?.toInt() ?? 0,
  priceRange: RangeStats.fromJson(json['priceRange'] as Map<String, dynamic>),
  bedroomRange: RangeStats.fromJson(
    json['bedroomRange'] as Map<String, dynamic>,
  ),
  bathroomRange: RangeStats.fromJson(
    json['bathroomRange'] as Map<String, dynamic>,
  ),
  sqftRange: RangeStats.fromJson(json['sqftRange'] as Map<String, dynamic>),
  pricePerSqft:
      (json['pricePerSqft'] as List<dynamic>?)
          ?.map((e) => PricePerSqftEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ComparisonAnalysisToJson(ComparisonAnalysis instance) =>
    <String, dynamic>{
      'totalProperties': instance.totalProperties,
      'priceRange': instance.priceRange.toJson(),
      'bedroomRange': instance.bedroomRange.toJson(),
      'bathroomRange': instance.bathroomRange.toJson(),
      'sqftRange': instance.sqftRange.toJson(),
      'pricePerSqft': instance.pricePerSqft.map((e) => e.toJson()).toList(),
    };

Comparison _$ComparisonFromJson(Map<String, dynamic> json) => Comparison(
  id: json['_id'] as String,
  user: json['user'] as String? ?? '',
  name: json['name'] as String? ?? '',
  description: json['description'] as String?,
  propertyIds: _propertyIdsFromJson(json['propertyIds']),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  notes: json['notes'] as String?,
  isPublic: json['isPublic'] as bool? ?? false,
  createdAt: json['createdAt'] as String? ?? '',
  updatedAt: json['updatedAt'] as String? ?? '',
);

Map<String, dynamic> _$ComparisonToJson(Comparison instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user': instance.user,
      'name': instance.name,
      'description': instance.description,
      'propertyIds': _propertyIdsToJson(instance.propertyIds),
      'tags': instance.tags,
      'notes': instance.notes,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
