import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';

enum ReviewStatus { published, pending, rejected }

ReviewStatus _reviewStatusFromString(String v) =>
    ReviewStatus.values.firstWhere((e) => e.name == v);

class ApiReview {
  final String id;

  /// Populated [ApiUser] or raw ID string
  final dynamic user;

  /// Populated [ApiProperty] or raw ID string
  final dynamic property;

  final int rating; // 1–5
  final String title;
  final String comment;
  final ReviewStatus status;
  final String createdAt;
  final String updatedAt;

  const ApiReview({
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

  factory ApiReview.fromJson(Map<String, dynamic> j) => ApiReview(
        id: j['_id'] as String,
        user: j['user'] is Map
            ? ApiUser.fromJson(j['user'] as Map<String, dynamic>)
            : j['user'] as String,
        property: j['property'] is Map
            ? ApiProperty.fromJson(j['property'] as Map<String, dynamic>)
            : j['property'] as String,
        rating: j['rating'] as int,
        title: j['title'] as String,
        comment: j['comment'] as String,
        status: _reviewStatusFromString(j['status'] as String),
        createdAt: j['createdAt'] as String,
        updatedAt: j['updatedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'user': user is ApiUser ? (user as ApiUser).toJson() : user,
        'property': property is ApiProperty ? (property as ApiProperty).toJson() : property,
        'rating': rating,
        'title': title,
        'comment': comment,
        'status': status.name,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class RatingBreakdown {
  final int five;
  final int four;
  final int three;
  final int two;
  final int one;

  const RatingBreakdown({
    required this.five,
    required this.four,
    required this.three,
    required this.two,
    required this.one,
  });

  factory RatingBreakdown.fromJson(Map<String, dynamic> j) => RatingBreakdown(
        five: j['5'] as int,
        four: j['4'] as int,
        three: j['3'] as int,
        two: j['2'] as int,
        one: j['1'] as int,
      );

  Map<String, dynamic> toJson() => {
        '5': five,
        '4': four,
        '3': three,
        '2': two,
        '1': one,
      };
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final RatingBreakdown ratingBreakdown;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> j) => ReviewStats(
        averageRating: (j['averageRating'] as num).toDouble(),
        totalReviews: j['totalReviews'] as int,
        ratingBreakdown: RatingBreakdown.fromJson(
            j['ratingBreakdown'] as Map<String, dynamic>),
      );
}
