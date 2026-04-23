import 'package:json_annotation/json_annotation.dart';
import 'package:homebazaar/model/property.dart';

part 'misc.g.dart';

// ── Saved property ────────────────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class SavedProperty {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(defaultValue: '')
  final String user;
  @JsonKey(fromJson: _propertyFromJson, toJson: _propertyToJson)
  final dynamic property;
  @JsonKey(defaultValue: '')
  final String savedAt;

  const SavedProperty({
    required this.id,
    required this.user,
    required this.property,
    required this.savedAt,
  });

  factory SavedProperty.fromJson(Map<String, dynamic> json) =>
      _$SavedPropertyFromJson(json);

  Map<String, dynamic> toJson() => _$SavedPropertyToJson(this);
}

typedef ApiSavedProperty = SavedProperty;

// ── Search history ────────────────────────────────────────────────────────────

@JsonSerializable()
class SearchHistory {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(defaultValue: '')
  final String user;
  @JsonKey(defaultValue: '')
  final String query;
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> filters;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
  final String updatedAt;

  const SearchHistory({
    required this.id,
    required this.user,
    required this.query,
    required this.filters,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$SearchHistoryToJson(this);
}

typedef ApiSearchHistory = SearchHistory;

// ── Upload ────────────────────────────────────────────────────────────────────

enum UploadFolder { avatar, aadhar, pancards, properties }

@JsonSerializable()
class UploadLinkResponse {
  @JsonKey(defaultValue: '')
  final String uploadUrl;
  @JsonKey(defaultValue: '')
  final String viewUrl;
  @JsonKey(defaultValue: '')
  final String filePath;

  const UploadLinkResponse({
    required this.uploadUrl,
    required this.viewUrl,
    required this.filePath,
  });

  factory UploadLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadLinkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadLinkResponseToJson(this);
}

// ── Converters ────────────────────────────────────────────────────────────────

dynamic _propertyFromJson(dynamic v) =>
    v is Map<String, dynamic> ? Property.fromJson(v) : v;
dynamic _propertyToJson(dynamic v) => v is Property ? v.toJson() : v;
