// ignore_for_file: use_null_aware_elements
import 'package:homebazaar/core/network/api_client.dart';
import 'package:homebazaar/model/api_response.dart';
import 'package:homebazaar/model/support_ticket.dart';

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
      (d) => ApiSupportTicket.fromJson(
          (d as Map<String, dynamic>)['ticket'] as Map<String, dynamic>),
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
      if (status != null) 'status': _statusToString(status),
      if (category != null) 'category': category.name,
      if (priority != null) 'priority': priority.name,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    final json = await ApiClient.fetch<Map<String, dynamic>>('/support$qs');
    return ApiResponse.fromJson(json, (d) {
      return (d as List)
          .map((e) => ApiSupportTicket.fromJson(e as Map<String, dynamic>))
          .toList();
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
    final json =
        await ApiClient.fetch<Map<String, dynamic>>('/support/$id$qs');
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
      (d) => ApiTicketMessage.fromJson(
          (d as Map<String, dynamic>)['message'] as Map<String, dynamic>),
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
      (d) => ApiSupportTicket.fromJson(
          (d as Map<String, dynamic>)['ticket'] as Map<String, dynamic>),
    );
  }

  static String _statusToString(TicketStatus s) {
    const map = {
      TicketStatus.open: 'open',
      TicketStatus.inProgress: 'in-progress',
      TicketStatus.resolved: 'resolved',
      TicketStatus.closed: 'closed',
    };
    return map[s] ?? 'open';
  }
}
