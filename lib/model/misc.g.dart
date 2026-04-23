// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedProperty _$SavedPropertyFromJson(Map<String, dynamic> json) =>
    SavedProperty(
      id: json['_id'] as String,
      user: json['user'] as String? ?? '',
      property: _propertyFromJson(json['property']),
      savedAt: json['savedAt'] as String? ?? '',
    );

Map<String, dynamic> _$SavedPropertyToJson(SavedProperty instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user': instance.user,
      'property': _propertyToJson(instance.property),
      'savedAt': instance.savedAt,
    };

SearchHistory _$SearchHistoryFromJson(Map<String, dynamic> json) =>
    SearchHistory(
      id: json['_id'] as String,
      user: json['user'] as String? ?? '',
      query: json['query'] as String? ?? '',
      filters: json['filters'] as Map<String, dynamic>? ?? {},
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$SearchHistoryToJson(SearchHistory instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user': instance.user,
      'query': instance.query,
      'filters': instance.filters,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

UploadLinkResponse _$UploadLinkResponseFromJson(Map<String, dynamic> json) =>
    UploadLinkResponse(
      uploadUrl: json['uploadUrl'] as String? ?? '',
      viewUrl: json['viewUrl'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
    );

Map<String, dynamic> _$UploadLinkResponseToJson(UploadLinkResponse instance) =>
    <String, dynamic>{
      'uploadUrl': instance.uploadUrl,
      'viewUrl': instance.viewUrl,
      'filePath': instance.filePath,
    };
