import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';

class TrendPoint {
  final String date; // "YYYY-MM-DD"
  final int count;

  const TrendPoint({required this.date, required this.count});

  factory TrendPoint.fromJson(Map<String, dynamic> j) => TrendPoint(
        date: j['date'] as String,
        count: j['count'] as int,
      );

  Map<String, dynamic> toJson() => {'date': date, 'count': count};
}

class TopProperty {
  final String id;
  final String title;
  final double price;
  final int views;
  final int? saves;
  final int inquiries;
  final PropertyStatus status;
  final ListingType listingType;
  final int daysListed;
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

  factory TopProperty.fromJson(Map<String, dynamic> j) => TopProperty(
        id: j['_id'] as String,
        title: j['title'] as String,
        price: (j['price'] as num).toDouble(),
        views: j['views'] as int,
        saves: j['saves'] as int?,
        inquiries: j['inquiries'] as int,
        status: PropertyStatus.values.firstWhere((e) => e.name == j['status']),
        listingType: j['listingType'] == 'sale' ? ListingType.sale : ListingType.rent,
        daysListed: j['daysListed'] as int,
        conversionRate: j['conversionRate'] != null
            ? (j['conversionRate'] as num).toDouble()
            : null,
      );
}

class InquiryStatusBreakdown {
  final int active;
  final int closed;

  const InquiryStatusBreakdown({required this.active, required this.closed});

  factory InquiryStatusBreakdown.fromJson(Map<String, dynamic> j) =>
      InquiryStatusBreakdown(
        active: j['active'] as int,
        closed: j['closed'] as int,
      );
}

class OwnerAnalytics {
  final int totalListings;
  final int activeListings;
  final int pendingListings;
  final int soldListings;
  final int rentedListings;
  final int archivedListings;
  final int totalViews;
  final int totalSaves;
  final int totalInquiries;
  final double averageViewsPerListing;
  final double averageSavesPerListing;
  final double conversionRate;
  final ({int sale, int rent}) listingsByType;
  final List<TopProperty> topByViews;
  final List<TopProperty> topByInquiries;
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

  factory OwnerAnalytics.fromJson(Map<String, dynamic> j) {
    final lbt = j['listingsByType'] as Map<String, dynamic>;
    return OwnerAnalytics(
      totalListings: j['totalListings'] as int,
      activeListings: j['activeListings'] as int,
      pendingListings: j['pendingListings'] as int,
      soldListings: j['soldListings'] as int,
      rentedListings: j['rentedListings'] as int,
      archivedListings: j['archivedListings'] as int,
      totalViews: j['totalViews'] as int,
      totalSaves: j['totalSaves'] as int,
      totalInquiries: j['totalInquiries'] as int,
      averageViewsPerListing: (j['averageViewsPerListing'] as num).toDouble(),
      averageSavesPerListing: (j['averageSavesPerListing'] as num).toDouble(),
      conversionRate: (j['conversionRate'] as num).toDouble(),
      listingsByType: (sale: lbt['sale'] as int, rent: lbt['rent'] as int),
      topByViews: (j['topByViews'] as List)
          .map((e) => TopProperty.fromJson(e as Map<String, dynamic>))
          .toList(),
      topByInquiries: (j['topByInquiries'] as List)
          .map((e) => TopProperty.fromJson(e as Map<String, dynamic>))
          .toList(),
      inquiryTrend: (j['inquiryTrend'] as List)
          .map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      inquiryStatus: InquiryStatusBreakdown.fromJson(
          j['inquiryStatus'] as Map<String, dynamic>),
    );
  }
}

class _PropertyAnalyticsInquiry {
  final String id;
  final dynamic user; // ApiUser | String
  final String status;
  final String lastMessageAt;
  final String createdAt;

  const _PropertyAnalyticsInquiry({
    required this.id,
    required this.user,
    required this.status,
    required this.lastMessageAt,
    required this.createdAt,
  });

  factory _PropertyAnalyticsInquiry.fromJson(Map<String, dynamic> j) =>
      _PropertyAnalyticsInquiry(
        id: j['_id'] as String,
        user: j['user'] is Map
            ? ApiUser.fromJson(j['user'] as Map<String, dynamic>)
            : j['user'] as String,
        status: j['status'] as String,
        lastMessageAt: j['lastMessageAt'] as String,
        createdAt: j['createdAt'] as String,
      );
}

class PropertyAnalytics {
  final ({
    String id,
    String title,
    double price,
    PropertyStatus status,
    ListingType listingType,
    String createdAt,
    int daysListed,
  }) property;

  final ({
    int totalViews,
    int totalSaves,
    int totalInquiries,
    double conversionRate,
    double saveRate,
    InquiryStatusBreakdown inquiryStatus,
    List<TrendPoint> inquiryTrend,
    List<_PropertyAnalyticsInquiry> inquiries,
  }) analytics;

  const PropertyAnalytics({required this.property, required this.analytics});

  factory PropertyAnalytics.fromJson(Map<String, dynamic> j) {
    final p = j['property'] as Map<String, dynamic>;
    final a = j['analytics'] as Map<String, dynamic>;
    return PropertyAnalytics(
      property: (
        id: p['_id'] as String,
        title: p['title'] as String,
        price: (p['price'] as num).toDouble(),
        status: PropertyStatus.values.firstWhere((e) => e.name == p['status']),
        listingType: p['listingType'] == 'sale' ? ListingType.sale : ListingType.rent,
        createdAt: p['createdAt'] as String,
        daysListed: p['daysListed'] as int,
      ),
      analytics: (
        totalViews: a['totalViews'] as int,
        totalSaves: a['totalSaves'] as int,
        totalInquiries: a['totalInquiries'] as int,
        conversionRate: (a['conversionRate'] as num).toDouble(),
        saveRate: (a['saveRate'] as num).toDouble(),
        inquiryStatus: InquiryStatusBreakdown.fromJson(
            a['inquiryStatus'] as Map<String, dynamic>),
        inquiryTrend: (a['inquiryTrend'] as List)
            .map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        inquiries: (a['inquiries'] as List)
            .map((e) => _PropertyAnalyticsInquiry.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
  }
}
