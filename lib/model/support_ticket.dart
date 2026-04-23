import 'package:json_annotation/json_annotation.dart';
import 'package:homebazaar/model/admin_user.dart';
import 'package:homebazaar/model/user.dart';

part 'support_ticket.g.dart';

enum TicketCategory { technical, billing, account, listing, other }
enum TicketPriority { low, medium, high }

enum TicketStatus {
  @JsonValue('open') open,
  @JsonValue('in-progress') inProgress,
  @JsonValue('resolved') resolved,
  @JsonValue('closed') closed,
}

// ── Ticket message ────────────────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class TicketMessage {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(defaultValue: '')
  final String ticket;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final dynamic sender;
  @JsonKey(defaultValue: '')
  final String text;
  @JsonKey(defaultValue: false)
  final bool isAdmin;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
  final String updatedAt;

  const TicketMessage({
    required this.id,
    required this.ticket,
    required this.sender,
    required this.text,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) =>
      _$TicketMessageFromJson(json);

  Map<String, dynamic> toJson() => _$TicketMessageToJson(this);
}

typedef ApiTicketMessage = TicketMessage;

// ── Support ticket ────────────────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class SupportTicket {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final dynamic user;
  @JsonKey(defaultValue: '')
  final String subject;
  @JsonKey(unknownEnumValue: TicketCategory.other)
  final TicketCategory category;
  @JsonKey(unknownEnumValue: TicketPriority.medium)
  final TicketPriority priority;
  @JsonKey(unknownEnumValue: TicketStatus.open)
  final TicketStatus status;
  @JsonKey(fromJson: _adminFromJson, toJson: _adminToJson)
  final dynamic assignedTo;
  @JsonKey(defaultValue: '')
  final String lastMessageAt;
  @JsonKey(defaultValue: 0)
  final int messageCount;
  final String? resolvedAt;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
  final String updatedAt;

  const SupportTicket({
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

  factory SupportTicket.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTicketToJson(this);
}

typedef ApiSupportTicket = SupportTicket;

// ── Ticket detail response ────────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class TicketDetailResponse {
  final SupportTicket ticket;
  @JsonKey(defaultValue: [])
  final List<TicketMessage> messages;

  const TicketDetailResponse({required this.ticket, required this.messages});

  factory TicketDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$TicketDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TicketDetailResponseToJson(this);
}

// ── Converters ────────────────────────────────────────────────────────────────

dynamic _userFromJson(dynamic v) =>
    v is Map<String, dynamic> ? User.fromJson(v) : v;
dynamic _userToJson(dynamic v) => v is User ? v.toJson() : v;

dynamic _adminFromJson(dynamic v) =>
    v is Map<String, dynamic> ? AdminUser.fromJson(v) : v;
dynamic _adminToJson(dynamic v) => v is AdminUser ? v.toJson() : v;
