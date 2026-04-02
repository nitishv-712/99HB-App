import 'package:homebazaar/model/admin_user.dart';
import 'package:homebazaar/model/user.dart';

enum TicketCategory { technical, billing, account, listing, other }
enum TicketPriority { low, medium, high }
enum TicketStatus { open, inProgress, resolved, closed }

TicketCategory _categoryFromString(String v) =>
    TicketCategory.values.firstWhere((e) => e.name == v);

TicketPriority _priorityFromString(String v) =>
    TicketPriority.values.firstWhere((e) => e.name == v);

TicketStatus _statusFromString(String v) {
  const map = {
    'open': TicketStatus.open,
    'in-progress': TicketStatus.inProgress,
    'resolved': TicketStatus.resolved,
    'closed': TicketStatus.closed,
  };
  return map[v] ?? TicketStatus.open;
}

String _statusToString(TicketStatus s) {
  const map = {
    TicketStatus.open: 'open',
    TicketStatus.inProgress: 'in-progress',
    TicketStatus.resolved: 'resolved',
    TicketStatus.closed: 'closed',
  };
  return map[s] ?? 'open';
}

class ApiTicketMessage {
  final String id;
  final String ticket;

  /// Populated [ApiUser] or raw ID string
  final dynamic sender;

  final String text;
  final bool isAdmin;
  final String createdAt;
  final String updatedAt;

  const ApiTicketMessage({
    required this.id,
    required this.ticket,
    required this.sender,
    required this.text,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiTicketMessage.fromJson(Map<String, dynamic> j) => ApiTicketMessage(
        id: j['_id'] as String,
        ticket: j['ticket'] as String,
        sender: j['sender'] is Map
            ? ApiUser.fromJson(j['sender'] as Map<String, dynamic>)
            : j['sender'] as String,
        text: j['text'] as String,
        isAdmin: j['isAdmin'] as bool,
        createdAt: j['createdAt'] as String,
        updatedAt: j['updatedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'ticket': ticket,
        'sender': sender is ApiUser ? (sender as ApiUser).toJson() : sender,
        'text': text,
        'isAdmin': isAdmin,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class ApiSupportTicket {
  final String id;

  /// Populated [ApiUser] or raw ID string
  final dynamic user;

  final String subject;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;

  /// Populated [ApiAdminUser], raw ID string, or null
  final dynamic assignedTo;

  final String lastMessageAt;
  final int messageCount;
  final String? resolvedAt;
  final String createdAt;
  final String updatedAt;

  const ApiSupportTicket({
    required this.id,
    required this.user,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedTo,
    required this.lastMessageAt,
    required this.messageCount,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiSupportTicket.fromJson(Map<String, dynamic> j) => ApiSupportTicket(
        id: j['_id'] as String,
        user: j['user'] is Map
            ? ApiUser.fromJson(j['user'] as Map<String, dynamic>)
            : j['user'] as String,
        subject: j['subject'] as String,
        category: _categoryFromString(j['category'] as String),
        priority: _priorityFromString(j['priority'] as String),
        status: _statusFromString(j['status'] as String),
        assignedTo: j['assignedTo'] is Map
            ? ApiAdminUser.fromJson(j['assignedTo'] as Map<String, dynamic>)
            : j['assignedTo'] as String?,
        lastMessageAt: j['lastMessageAt'] as String,
        messageCount: j['messageCount'] as int,
        resolvedAt: j['resolvedAt'] as String?,
        createdAt: j['createdAt'] as String,
        updatedAt: j['updatedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'user': user is ApiUser ? (user as ApiUser).toJson() : user,
        'subject': subject,
        'category': category.name,
        'priority': priority.name,
        'status': _statusToString(status),
        'assignedTo': assignedTo is ApiAdminUser
            ? (assignedTo as ApiAdminUser).toJson()
            : assignedTo,
        'lastMessageAt': lastMessageAt,
        'messageCount': messageCount,
        'resolvedAt': resolvedAt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class TicketDetailResponse {
  final ApiSupportTicket ticket;
  final List<ApiTicketMessage> messages;

  const TicketDetailResponse({required this.ticket, required this.messages});

  factory TicketDetailResponse.fromJson(Map<String, dynamic> j) => TicketDetailResponse(
        ticket: ApiSupportTicket.fromJson(j['ticket'] as Map<String, dynamic>),
        messages: (j['messages'] as List)
            .map((e) => ApiTicketMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class SupportTicketStats {
  final int totalTickets;
  final int openTickets;
  final int inProgressTickets;
  final int resolvedTickets;
  final int closedTickets;
  final int highPriorityTickets;
  final double averageResolutionTimeHours;

  const SupportTicketStats({
    required this.totalTickets,
    required this.openTickets,
    required this.inProgressTickets,
    required this.resolvedTickets,
    required this.closedTickets,
    required this.highPriorityTickets,
    required this.averageResolutionTimeHours,
  });

  factory SupportTicketStats.fromJson(Map<String, dynamic> j) => SupportTicketStats(
        totalTickets: j['totalTickets'] as int,
        openTickets: j['openTickets'] as int,
        inProgressTickets: j['inProgressTickets'] as int,
        resolvedTickets: j['resolvedTickets'] as int,
        closedTickets: j['closedTickets'] as int,
        highPriorityTickets: j['highPriorityTickets'] as int,
        averageResolutionTimeHours:
            (j['averageResolutionTimeHours'] as num).toDouble(),
      );
}
