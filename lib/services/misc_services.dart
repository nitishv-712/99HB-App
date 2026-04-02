import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/api_response.dart';
import 'package:homebazaar/model/analytics.dart';
import 'package:homebazaar/model/misc.dart';
import 'package:homebazaar/model/support_ticket.dart';

// ─── Saved Searches (bookmarked properties) ───────────────────────────────────

abstract final class SavedSearchesService {
  /// GET /saved
  static Future<ApiResponse<List<ApiSavedProperty>>> list({int? page, int? limit}) async {
    final qs = ApiClient.buildQuery({
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    final json = await ApiClient.fetch<Map<String, dynamic>>('/saved$qs');
    return ApiResponse.fromJson(json, (d) {
      final list = d as List;
      return list.map((e) => ApiSavedProperty.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  /// POST /saved/toggle/:propertyId
  static Future<ApiResponse<Map<String, dynamic>>> toggle(String propertyId) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/saved/toggle/$propertyId',
      method: 'POST',
    );
    return ApiResponse.fromJson(json, (d) => d as Map<String, dynamic>);
  }
}

// ─── Search History ───────────────────────────────────────────────────────────

abstract final class SearchHistoryService {
  /// GET /search-history
  static Future<ApiResponse<List<ApiSearchHistory>>> list({int? page, int? limit}) async {
    final qs = ApiClient.buildQuery({
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    final json = await ApiClient.fetch<Map<String, dynamic>>('/search-history$qs');
    return ApiResponse.fromJson(json, (d) {
      final list = d as List;
      return list.map((e) => ApiSearchHistory.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  /// POST /search-history
  static Future<ApiResponse<ApiSearchHistory>> record({
    required String query,
    Map<String, dynamic>? filters,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/search-history',
      method: 'POST',
      body: {
        'query': query,
        if (filters != null) 'filters': filters,
      },
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiSearchHistory.fromJson(d as Map<String, dynamic>),
    );
  }

  /// DELETE /search-history/:id
  static Future<void> delete(String id) async {
    await ApiClient.fetch<Map<String, dynamic>>('/search-history/$id', method: 'DELETE');
  }

  /// DELETE /search-history — clear all
  static Future<void> deleteAll() async {
    await ApiClient.fetch<Map<String, dynamic>>('/search-history', method: 'DELETE');
  }
}

// ─── Newsletter ───────────────────────────────────────────────────────────────

abstract final class NewsletterService {
  /// POST /newsletter/subscribe
  static Future<void> subscribe(String email) async {
    await ApiClient.fetch<Map<String, dynamic>>(
      '/newsletter/subscribe',
      method: 'POST',
      body: {'email': email},
    );
  }

  /// POST /newsletter/unsubscribe
  static Future<void> unsubscribe(String email) async {
    await ApiClient.fetch<Map<String, dynamic>>(
      '/newsletter/unsubscribe',
      method: 'POST',
      body: {'email': email},
    );
  }
}

// ─── Analytics ────────────────────────────────────────────────────────────────

abstract final class AnalyticsService {
  /// GET /analytics/overview
  static Future<ApiResponse<OwnerAnalytics>> overview() async {
    final json = await ApiClient.fetch<Map<String, dynamic>>('/analytics/overview');
    return ApiResponse.fromJson(
      json,
      (d) => OwnerAnalytics.fromJson(d as Map<String, dynamic>),
    );
  }

  /// GET /analytics/property/:id
  static Future<ApiResponse<PropertyAnalytics>> property(String id) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>('/analytics/property/$id');
    return ApiResponse.fromJson(
      json,
      (d) => PropertyAnalytics.fromJson(d as Map<String, dynamic>),
    );
  }
}

// ─── Support Tickets ──────────────────────────────────────────────────────────

abstract final class SupportService {
  /// POST /support
  static Future<ApiResponse<ApiSupportTicket>> create({
    required String subject,
    required TicketCategory category,
    required String message,
    TicketPriority? priority,
  }) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/support',
      method: 'POST',
      body: {
        'subject': subject,
        'category': category.name,
        'message': message,
        if (priority != null) 'priority': priority.name,
      },
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiSupportTicket.fromJson((d as Map<String, dynamic>)['ticket'] as Map<String, dynamic>),
    );
  }

  /// GET /support
  static Future<ApiResponse<List<ApiSupportTicket>>> list({
    TicketStatus? status,
    TicketCategory? category,
    TicketPriority? priority,
    int? page,
    int? limit,
  }) async {
    final qs = ApiClient.buildQuery({
      if (status != null) 'status': _ticketStatusToString(status),
      if (category != null) 'category': category.name,
      if (priority != null) 'priority': priority.name,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    final json = await ApiClient.fetch<Map<String, dynamic>>('/support$qs');
    return ApiResponse.fromJson(json, (d) {
      final list = d as List;
      return list.map((e) => ApiSupportTicket.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  /// GET /support/:id
  static Future<ApiResponse<TicketDetailResponse>> get(
    String id, {
    int? page,
    int? limit,
  }) async {
    final qs = ApiClient.buildQuery({
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    final json = await ApiClient.fetch<Map<String, dynamic>>('/support/$id$qs');
    return ApiResponse.fromJson(
      json,
      (d) => TicketDetailResponse.fromJson(d as Map<String, dynamic>),
    );
  }

  /// POST /support/:id/messages
  static Future<ApiResponse<ApiTicketMessage>> addMessage(
    String id,
    String message,
  ) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/support/$id/messages',
      method: 'POST',
      body: {'message': message},
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiTicketMessage.fromJson((d as Map<String, dynamic>)['message'] as Map<String, dynamic>),
    );
  }

  /// POST /support/:id/close
  static Future<ApiResponse<ApiSupportTicket>> close(String id) async {
    final json = await ApiClient.fetch<Map<String, dynamic>>(
      '/support/$id/close',
      method: 'POST',
    );
    return ApiResponse.fromJson(
      json,
      (d) => ApiSupportTicket.fromJson((d as Map<String, dynamic>)['ticket'] as Map<String, dynamic>),
    );
  }
}

String _ticketStatusToString(TicketStatus s) {
  const map = {
    TicketStatus.open: 'open',
    TicketStatus.inProgress: 'in-progress',
    TicketStatus.resolved: 'resolved',
    TicketStatus.closed: 'closed',
  };
  return map[s] ?? 'open';
}
