import 'package:json_annotation/json_annotation.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';

part 'analytics.g.dart';

@JsonSerializable()
class TrendPoint {
  @JsonKey(defaultValue: '')
  final String date;
  @JsonKey(defaultValue: 0)
  final int count;

  const TrendPoint({required this.date, required this.count});

  factory TrendPoint.fromJson(Map<String, dynamic> json) =>
      _$TrendPointFromJson(json);

  Map<String, dynamic> toJson() => _$TrendPointToJson(this);
}

@JsonSerializable()
class TopProperty {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(fromJson: _toDouble)
  final double price;
  @JsonKey(defaultValue: 0)
  final int views;
  final int? saves;
  @JsonKey(defaultValue: 0)
  final int inquiries;
  @JsonKey(unknownEnumValue: PropertyStatus.active)
  final PropertyStatus status;
  @JsonKey(unknownEnumValue: ListingType.sale)
  final ListingType listingType;
  @JsonKey(defaultValue: 0)
  final int daysListed;
  @JsonKey(fromJson: _toDoubleNullable)
  final double? conversionRate;

  const TopProperty({
    required this.id,
    required this.title,
    required this.price,
    required this.views,
    this.saves,
    required this.inquiries,
    required this.status,
    required this.listingType,
    required this.daysListed,
    this.conversionRate,
  });

  factory TopProperty.fromJson(Map<String, dynamic> json) =>
      _$TopPropertyFromJson(json);

  Map<String, dynamic> toJson() => _$TopPropertyToJson(this);
}

@JsonSerializable()
class InquiryStatusBreakdown {
  @JsonKey(defaultValue: 0)
  final int active;
  @JsonKey(defaultValue: 0)
  final int closed;

  const InquiryStatusBreakdown({required this.active, required this.closed});

  factory InquiryStatusBreakdown.fromJson(Map<String, dynamic> json) =>
      _$InquiryStatusBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryStatusBreakdownToJson(this);
}

@JsonSerializable()
class ListingsByType {
  @JsonKey(defaultValue: 0)
  final int sale;
  @JsonKey(defaultValue: 0)
  final int rent;

  const ListingsByType({required this.sale, required this.rent});

  factory ListingsByType.fromJson(Map<String, dynamic> json) =>
      _$ListingsByTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ListingsByTypeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OwnerAnalytics {
  @JsonKey(defaultValue: 0)
  final int totalListings;
  @JsonKey(defaultValue: 0)
  final int activeListings;
  @JsonKey(defaultValue: 0)
  final int pendingListings;
  @JsonKey(defaultValue: 0)
  final int soldListings;
  @JsonKey(defaultValue: 0)
  final int rentedListings;
  @JsonKey(defaultValue: 0)
  final int archivedListings;
  @JsonKey(defaultValue: 0)
  final int totalViews;
  @JsonKey(defaultValue: 0)
  final int totalSaves;
  @JsonKey(defaultValue: 0)
  final int totalInquiries;
  @JsonKey(fromJson: _toDouble)
  final double averageViewsPerListing;
  @JsonKey(fromJson: _toDouble)
  final double averageSavesPerListing;
  @JsonKey(fromJson: _toDouble)
  final double conversionRate;
  final ListingsByType listingsByType;
  @JsonKey(defaultValue: [])
  final List<TopProperty> topByViews;
  @JsonKey(defaultValue: [])
  final List<TopProperty> topByInquiries;
  @JsonKey(defaultValue: [])
  final List<TrendPoint> inquiryTrend;
  final InquiryStatusBreakdown inquiryStatus;

  const OwnerAnalytics({
    required this.totalListings,
    required this.activeListings,
    required this.pendingListings,
    required this.soldListings,
    required this.rentedListings,
    required this.archivedListings,
    required this.totalViews,
    required this.totalSaves,
    required this.totalInquiries,
    required this.averageViewsPerListing,
    required this.averageSavesPerListing,
    required this.conversionRate,
    required this.listingsByType,
    required this.topByViews,
    required this.topByInquiries,
    required this.inquiryTrend,
    required this.inquiryStatus,
  });

  factory OwnerAnalytics.fromJson(Map<String, dynamic> json) =>
      _$OwnerAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerAnalyticsToJson(this);
}

// ── Property analytics ────────────────────────────────────────────────────────

@JsonSerializable()
class PropertyAnalyticsSummary {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(fromJson: _toDouble)
  final double price;
  @JsonKey(unknownEnumValue: PropertyStatus.active)
  final PropertyStatus status;
  @JsonKey(unknownEnumValue: ListingType.sale)
  final ListingType listingType;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: 0)
  final int daysListed;

  const PropertyAnalyticsSummary({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    required this.listingType,
    required this.createdAt,
    required this.daysListed,
  });

  factory PropertyAnalyticsSummary.fromJson(Map<String, dynamic> json) =>
      _$PropertyAnalyticsSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyAnalyticsSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PropertyAnalyticsInquiry {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final dynamic user;
  @JsonKey(defaultValue: 'active')
  final String status;
  @JsonKey(defaultValue: '')
  final String lastMessageAt;
  @JsonKey(defaultValue: '')
  final String createdAt;

  const PropertyAnalyticsInquiry({
    required this.id,
    required this.user,
    required this.status,
    required this.lastMessageAt,
    required this.createdAt,
  });

  factory PropertyAnalyticsInquiry.fromJson(Map<String, dynamic> json) =>
      _$PropertyAnalyticsInquiryFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyAnalyticsInquiryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PropertyAnalyticsData {
  @JsonKey(defaultValue: 0)
  final int totalViews;
  @JsonKey(defaultValue: 0)
  final int totalSaves;
  @JsonKey(defaultValue: 0)
  final int totalInquiries;
  @JsonKey(fromJson: _toDouble)
  final double conversionRate;
  @JsonKey(fromJson: _toDouble)
  final double saveRate;
  final InquiryStatusBreakdown inquiryStatus;
  @JsonKey(defaultValue: [])
  final List<TrendPoint> inquiryTrend;
  @JsonKey(defaultValue: [])
  final List<PropertyAnalyticsInquiry> inquiries;

  const PropertyAnalyticsData({
    required this.totalViews,
    required this.totalSaves,
    required this.totalInquiries,
    required this.conversionRate,
    required this.saveRate,
    required this.inquiryStatus,
    required this.inquiryTrend,
    required this.inquiries,
  });

  factory PropertyAnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$PropertyAnalyticsDataFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyAnalyticsDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PropertyAnalytics {
  final PropertyAnalyticsSummary property;
  final PropertyAnalyticsData analytics;

  const PropertyAnalytics({required this.property, required this.analytics});

  factory PropertyAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PropertyAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyAnalyticsToJson(this);
}

// ── Converters ────────────────────────────────────────────────────────────────

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
double? _toDoubleNullable(dynamic v) => (v as num?)?.toDouble();

dynamic _userFromJson(dynamic v) =>
    v is Map<String, dynamic> ? User.fromJson(v) : v;
dynamic _userToJson(dynamic v) => v is User ? v.toJson() : v;
