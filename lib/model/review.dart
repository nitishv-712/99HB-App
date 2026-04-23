import 'package:json_annotation/json_annotation.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';

part 'review.g.dart';

enum ReviewStatus { published, pending, rejected }

@JsonSerializable(explicitToJson: true)
class Review {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final dynamic user;
  @JsonKey(fromJson: _propertyFromJson, toJson: _propertyToJson)
  final dynamic property;
  @JsonKey(defaultValue: 1)
  final int rating;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String comment;
  @JsonKey(unknownEnumValue: ReviewStatus.pending)
  final ReviewStatus status;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
  final String updatedAt;

  const Review({
    required this.id,
    required this.user,
    required this.property,
    required this.rating,
    required this.title,
    required this.comment,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}

typedef ApiReview = Review;

// ── Rating breakdown ──────────────────────────────────────────────────────────

@JsonSerializable()
class RatingBreakdown {
  @JsonKey(name: '5', defaultValue: 0)
  final int five;
  @JsonKey(name: '4', defaultValue: 0)
  final int four;
  @JsonKey(name: '3', defaultValue: 0)
  final int three;
  @JsonKey(name: '2', defaultValue: 0)
  final int two;
  @JsonKey(name: '1', defaultValue: 0)
  final int one;

  const RatingBreakdown({
    required this.five,
    required this.four,
    required this.three,
    required this.two,
    required this.one,
  });

  factory RatingBreakdown.fromJson(Map<String, dynamic> json) =>
      _$RatingBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$RatingBreakdownToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReviewStats {
  @JsonKey(fromJson: _toDouble)
  final double averageRating;
  @JsonKey(defaultValue: 0)
  final int totalReviews;
  final RatingBreakdown ratingBreakdown;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) =>
      _$ReviewStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewStatsToJson(this);
}

// ── Converters ────────────────────────────────────────────────────────────────

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

dynamic _userFromJson(dynamic v) =>
    v is Map<String, dynamic> ? User.fromJson(v) : v;
dynamic _userToJson(dynamic v) => v is User ? v.toJson() : v;

dynamic _propertyFromJson(dynamic v) =>
    v is Map<String, dynamic> ? Property.fromJson(v) : v;
dynamic _propertyToJson(dynamic v) => v is Property ? v.toJson() : v;
