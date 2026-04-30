import 'package:json_annotation/json_annotation.dart';
import 'package:homebazaar/model/property.dart';

part 'comparison.g.dart';

@JsonSerializable()
class RangeStats {
  @JsonKey(fromJson: _toDouble)
  final double min;
  @JsonKey(fromJson: _toDouble)
  final double max;
  @JsonKey(fromJson: _toDoubleNullable)
  final double? average;

  const RangeStats({required this.min, required this.max, this.average});

  factory RangeStats.fromJson(Map<String, dynamic> json) =>
      _$RangeStatsFromJson(json);

  Map<String, dynamic> toJson() => _$RangeStatsToJson(this);
}

@JsonSerializable()
class PricePerSqftEntry {
  @JsonKey(defaultValue: '')
  final String propertyId;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(fromJson: _toDouble)
  final double pricePerSqft;

  const PricePerSqftEntry({
    required this.propertyId,
    required this.title,
    required this.pricePerSqft,
  });

  factory PricePerSqftEntry.fromJson(Map<String, dynamic> json) =>
      _$PricePerSqftEntryFromJson(json);

  Map<String, dynamic> toJson() => _$PricePerSqftEntryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ComparisonAnalysis {
  @JsonKey(defaultValue: 0)
  final int totalProperties;
  final RangeStats priceRange;
  final RangeStats bedroomRange;
  final RangeStats bathroomRange;
  final RangeStats sqftRange;
  @JsonKey(defaultValue: [])
  final List<PricePerSqftEntry> pricePerSqft;

  const ComparisonAnalysis({
    required this.totalProperties,
    required this.priceRange,
    required this.bedroomRange,
    required this.bathroomRange,
    required this.sqftRange,
    required this.pricePerSqft,
  });

  factory ComparisonAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ComparisonAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$ComparisonAnalysisToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Comparison {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(defaultValue: '')
  final String user;
  @JsonKey(defaultValue: '')
  final String name;
  final String? description;
  @JsonKey(fromJson: _propertyIdsFromJson, toJson: _propertyIdsToJson)
  final List<dynamic> propertyIds;
  @JsonKey(defaultValue: [])
  final List<String> tags;
  final String? notes;
  @JsonKey(defaultValue: false)
  final bool isPublic;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
  final String updatedAt;

  const Comparison({
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

  factory Comparison.fromJson(Map<String, dynamic> json) =>
      _$ComparisonFromJson(json);

  Map<String, dynamic> toJson() => _$ComparisonToJson(this);
}

typedef ApiComparison = Comparison;

// ── Converters ────────────────────────────────────────────────────────────────

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
double? _toDoubleNullable(dynamic v) => (v as num?)?.toDouble();

List<dynamic> _propertyIdsFromJson(dynamic v) {
  final list = v as List? ?? [];
  return list.map((e) {
    if (e is Map<String, dynamic>) return Property.fromJson(e);
    return e as String;
  }).toList();
}

List<dynamic> _propertyIdsToJson(List<dynamic> v) =>
    v.map((e) => e is Property ? e.toJson() : e).toList();
