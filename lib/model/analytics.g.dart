// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrendPoint _$TrendPointFromJson(Map<String, dynamic> json) => TrendPoint(
  date: json['date'] as String? ?? '',
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TrendPointToJson(TrendPoint instance) =>
    <String, dynamic>{'date': instance.date, 'count': instance.count};

TopProperty _$TopPropertyFromJson(Map<String, dynamic> json) => TopProperty(
  id: json['_id'] as String,
  title: json['title'] as String? ?? '',
  price: _toDouble(json['price']),
  views: (json['views'] as num?)?.toInt() ?? 0,
  saves: (json['saves'] as num?)?.toInt(),
  inquiries: (json['inquiries'] as num?)?.toInt() ?? 0,
  status: $enumDecode(
    _$PropertyStatusEnumMap,
    json['status'],
    unknownValue: PropertyStatus.active,
  ),
  listingType: $enumDecode(
    _$ListingTypeEnumMap,
    json['listingType'],
    unknownValue: ListingType.sale,
  ),
  daysListed: (json['daysListed'] as num?)?.toInt() ?? 0,
  conversionRate: _toDoubleNullable(json['conversionRate']),
);

Map<String, dynamic> _$TopPropertyToJson(TopProperty instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'views': instance.views,
      'saves': instance.saves,
      'inquiries': instance.inquiries,
      'status': _$PropertyStatusEnumMap[instance.status]!,
      'listingType': _$ListingTypeEnumMap[instance.listingType]!,
      'daysListed': instance.daysListed,
      'conversionRate': instance.conversionRate,
    };

const _$PropertyStatusEnumMap = {
  PropertyStatus.pending: 'pending',
  PropertyStatus.active: 'active',
  PropertyStatus.sold: 'sold',
  PropertyStatus.rented: 'rented',
  PropertyStatus.archived: 'archived',
};

const _$ListingTypeEnumMap = {
  ListingType.sale: 'sale',
  ListingType.rent: 'rent',
};

InquiryStatusBreakdown _$InquiryStatusBreakdownFromJson(
  Map<String, dynamic> json,
) => InquiryStatusBreakdown(
  active: (json['active'] as num?)?.toInt() ?? 0,
  closed: (json['closed'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$InquiryStatusBreakdownToJson(
  InquiryStatusBreakdown instance,
) => <String, dynamic>{'active': instance.active, 'closed': instance.closed};

ListingsByType _$ListingsByTypeFromJson(Map<String, dynamic> json) =>
    ListingsByType(
      sale: (json['sale'] as num?)?.toInt() ?? 0,
      rent: (json['rent'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ListingsByTypeToJson(ListingsByType instance) =>
    <String, dynamic>{'sale': instance.sale, 'rent': instance.rent};

OwnerAnalytics _$OwnerAnalyticsFromJson(Map<String, dynamic> json) =>
    OwnerAnalytics(
      totalListings: (json['totalListings'] as num?)?.toInt() ?? 0,
      activeListings: (json['activeListings'] as num?)?.toInt() ?? 0,
      pendingListings: (json['pendingListings'] as num?)?.toInt() ?? 0,
      soldListings: (json['soldListings'] as num?)?.toInt() ?? 0,
      rentedListings: (json['rentedListings'] as num?)?.toInt() ?? 0,
      archivedListings: (json['archivedListings'] as num?)?.toInt() ?? 0,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      totalSaves: (json['totalSaves'] as num?)?.toInt() ?? 0,
      totalInquiries: (json['totalInquiries'] as num?)?.toInt() ?? 0,
      averageViewsPerListing: _toDouble(json['averageViewsPerListing']),
      averageSavesPerListing: _toDouble(json['averageSavesPerListing']),
      conversionRate: _toDouble(json['conversionRate']),
      listingsByType: ListingsByType.fromJson(
        json['listingsByType'] as Map<String, dynamic>,
      ),
      topByViews:
          (json['topByViews'] as List<dynamic>?)
              ?.map((e) => TopProperty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topByInquiries:
          (json['topByInquiries'] as List<dynamic>?)
              ?.map((e) => TopProperty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      inquiryTrend:
          (json['inquiryTrend'] as List<dynamic>?)
              ?.map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      inquiryStatus: InquiryStatusBreakdown.fromJson(
        json['inquiryStatus'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$OwnerAnalyticsToJson(OwnerAnalytics instance) =>
    <String, dynamic>{
      'totalListings': instance.totalListings,
      'activeListings': instance.activeListings,
      'pendingListings': instance.pendingListings,
      'soldListings': instance.soldListings,
      'rentedListings': instance.rentedListings,
      'archivedListings': instance.archivedListings,
      'totalViews': instance.totalViews,
      'totalSaves': instance.totalSaves,
      'totalInquiries': instance.totalInquiries,
      'averageViewsPerListing': instance.averageViewsPerListing,
      'averageSavesPerListing': instance.averageSavesPerListing,
      'conversionRate': instance.conversionRate,
      'listingsByType': instance.listingsByType.toJson(),
      'topByViews': instance.topByViews.map((e) => e.toJson()).toList(),
      'topByInquiries': instance.topByInquiries.map((e) => e.toJson()).toList(),
      'inquiryTrend': instance.inquiryTrend.map((e) => e.toJson()).toList(),
      'inquiryStatus': instance.inquiryStatus.toJson(),
    };

PropertyAnalyticsSummary _$PropertyAnalyticsSummaryFromJson(
  Map<String, dynamic> json,
) => PropertyAnalyticsSummary(
  id: json['_id'] as String,
  title: json['title'] as String? ?? '',
  price: _toDouble(json['price']),
  status: $enumDecode(
    _$PropertyStatusEnumMap,
    json['status'],
    unknownValue: PropertyStatus.active,
  ),
  listingType: $enumDecode(
    _$ListingTypeEnumMap,
    json['listingType'],
    unknownValue: ListingType.sale,
  ),
  createdAt: json['createdAt'] as String? ?? '',
  daysListed: (json['daysListed'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PropertyAnalyticsSummaryToJson(
  PropertyAnalyticsSummary instance,
) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'price': instance.price,
  'status': _$PropertyStatusEnumMap[instance.status]!,
  'listingType': _$ListingTypeEnumMap[instance.listingType]!,
  'createdAt': instance.createdAt,
  'daysListed': instance.daysListed,
};

PropertyAnalyticsInquiry _$PropertyAnalyticsInquiryFromJson(
  Map<String, dynamic> json,
) => PropertyAnalyticsInquiry(
  id: json['_id'] as String,
  user: _userFromJson(json['user']),
  status: json['status'] as String? ?? 'active',
  lastMessageAt: json['lastMessageAt'] as String? ?? '',
  createdAt: json['createdAt'] as String? ?? '',
);

Map<String, dynamic> _$PropertyAnalyticsInquiryToJson(
  PropertyAnalyticsInquiry instance,
) => <String, dynamic>{
  '_id': instance.id,
  'user': _userToJson(instance.user),
  'status': instance.status,
  'lastMessageAt': instance.lastMessageAt,
  'createdAt': instance.createdAt,
};

PropertyAnalyticsData _$PropertyAnalyticsDataFromJson(
  Map<String, dynamic> json,
) => PropertyAnalyticsData(
  totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
  totalSaves: (json['totalSaves'] as num?)?.toInt() ?? 0,
  totalInquiries: (json['totalInquiries'] as num?)?.toInt() ?? 0,
  conversionRate: _toDouble(json['conversionRate']),
  saveRate: _toDouble(json['saveRate']),
  inquiryStatus: InquiryStatusBreakdown.fromJson(
    json['inquiryStatus'] as Map<String, dynamic>,
  ),
  inquiryTrend:
      (json['inquiryTrend'] as List<dynamic>?)
          ?.map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  inquiries:
      (json['inquiries'] as List<dynamic>?)
          ?.map(
            (e) => PropertyAnalyticsInquiry.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$PropertyAnalyticsDataToJson(
  PropertyAnalyticsData instance,
) => <String, dynamic>{
  'totalViews': instance.totalViews,
  'totalSaves': instance.totalSaves,
  'totalInquiries': instance.totalInquiries,
  'conversionRate': instance.conversionRate,
  'saveRate': instance.saveRate,
  'inquiryStatus': instance.inquiryStatus.toJson(),
  'inquiryTrend': instance.inquiryTrend.map((e) => e.toJson()).toList(),
  'inquiries': instance.inquiries.map((e) => e.toJson()).toList(),
};

PropertyAnalytics _$PropertyAnalyticsFromJson(Map<String, dynamic> json) =>
    PropertyAnalytics(
      property: PropertyAnalyticsSummary.fromJson(
        json['property'] as Map<String, dynamic>,
      ),
      analytics: PropertyAnalyticsData.fromJson(
        json['analytics'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PropertyAnalyticsToJson(PropertyAnalytics instance) =>
    <String, dynamic>{
      'property': instance.property.toJson(),
      'analytics': instance.analytics.toJson(),
    };
