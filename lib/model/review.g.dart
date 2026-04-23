// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: json['_id'] as String,
  user: _userFromJson(json['user']),
  property: _propertyFromJson(json['property']),
  rating: (json['rating'] as num?)?.toInt() ?? 1,
  title: json['title'] as String? ?? '',
  comment: json['comment'] as String? ?? '',
  status: $enumDecode(
    _$ReviewStatusEnumMap,
    json['status'],
    unknownValue: ReviewStatus.pending,
  ),
  createdAt: json['createdAt'] as String? ?? '',
  updatedAt: json['updatedAt'] as String? ?? '',
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  '_id': instance.id,
  'user': _userToJson(instance.user),
  'property': _propertyToJson(instance.property),
  'rating': instance.rating,
  'title': instance.title,
  'comment': instance.comment,
  'status': _$ReviewStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$ReviewStatusEnumMap = {
  ReviewStatus.published: 'published',
  ReviewStatus.pending: 'pending',
  ReviewStatus.rejected: 'rejected',
};

RatingBreakdown _$RatingBreakdownFromJson(Map<String, dynamic> json) =>
    RatingBreakdown(
      five: (json['5'] as num?)?.toInt() ?? 0,
      four: (json['4'] as num?)?.toInt() ?? 0,
      three: (json['3'] as num?)?.toInt() ?? 0,
      two: (json['2'] as num?)?.toInt() ?? 0,
      one: (json['1'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RatingBreakdownToJson(RatingBreakdown instance) =>
    <String, dynamic>{
      '5': instance.five,
      '4': instance.four,
      '3': instance.three,
      '2': instance.two,
      '1': instance.one,
    };

ReviewStats _$ReviewStatsFromJson(Map<String, dynamic> json) => ReviewStats(
  averageRating: _toDouble(json['averageRating']),
  totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
  ratingBreakdown: RatingBreakdown.fromJson(
    json['ratingBreakdown'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ReviewStatsToJson(ReviewStats instance) =>
    <String, dynamic>{
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'ratingBreakdown': instance.ratingBreakdown.toJson(),
    };
