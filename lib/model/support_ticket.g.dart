// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketMessage _$TicketMessageFromJson(Map<String, dynamic> json) =>
    TicketMessage(
      id: json['_id'] as String,
      ticket: json['ticket'] as String? ?? '',
      sender: _userFromJson(json['sender']),
      text: json['text'] as String? ?? '',
      isAdmin: json['isAdmin'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$TicketMessageToJson(TicketMessage instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'ticket': instance.ticket,
      'sender': _userToJson(instance.sender),
      'text': instance.text,
      'isAdmin': instance.isAdmin,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

SupportTicket _$SupportTicketFromJson(Map<String, dynamic> json) =>
    SupportTicket(
      id: json['_id'] as String,
      user: _userFromJson(json['user']),
      subject: json['subject'] as String? ?? '',
      category: $enumDecode(
        _$TicketCategoryEnumMap,
        json['category'],
        unknownValue: TicketCategory.other,
      ),
      priority: $enumDecode(
        _$TicketPriorityEnumMap,
        json['priority'],
        unknownValue: TicketPriority.medium,
      ),
      status: $enumDecode(
        _$TicketStatusEnumMap,
        json['status'],
        unknownValue: TicketStatus.open,
      ),
      assignedTo: _adminFromJson(json['assignedTo']),
      lastMessageAt: json['lastMessageAt'] as String? ?? '',
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      resolvedAt: json['resolvedAt'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$SupportTicketToJson(SupportTicket instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user': _userToJson(instance.user),
      'subject': instance.subject,
      'category': _$TicketCategoryEnumMap[instance.category]!,
      'priority': _$TicketPriorityEnumMap[instance.priority]!,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'assignedTo': _adminToJson(instance.assignedTo),
      'lastMessageAt': instance.lastMessageAt,
      'messageCount': instance.messageCount,
      'resolvedAt': instance.resolvedAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

const _$TicketCategoryEnumMap = {
  TicketCategory.technical: 'technical',
  TicketCategory.billing: 'billing',
  TicketCategory.account: 'account',
  TicketCategory.listing: 'listing',
  TicketCategory.other: 'other',
};

const _$TicketPriorityEnumMap = {
  TicketPriority.low: 'low',
  TicketPriority.medium: 'medium',
  TicketPriority.high: 'high',
};

const _$TicketStatusEnumMap = {
  TicketStatus.open: 'open',
  TicketStatus.inProgress: 'in-progress',
  TicketStatus.resolved: 'resolved',
  TicketStatus.closed: 'closed',
};

TicketDetailResponse _$TicketDetailResponseFromJson(
  Map<String, dynamic> json,
) => TicketDetailResponse(
  ticket: SupportTicket.fromJson(json['ticket'] as Map<String, dynamic>),
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => TicketMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$TicketDetailResponseToJson(
  TicketDetailResponse instance,
) => <String, dynamic>{
  'ticket': instance.ticket.toJson(),
  'messages': instance.messages.map((e) => e.toJson()).toList(),
};
