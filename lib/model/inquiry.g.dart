// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['_id'] as String,
  inquiry: json['inquiry'] as String,
  sender: _userFromJson(json['sender']),
  role: $enumDecode(
    _$MessageRoleEnumMap,
    json['role'],
    unknownValue: MessageRole.user,
  ),
  text: json['text'] as String? ?? '',
  visibleToUser: json['visibleToUser'] as bool? ?? false,
  visibleToOwner: json['visibleToOwner'] as bool? ?? false,
  isEditedByAdmin: json['isEditedByAdmin'] as bool? ?? false,
  createdAt: json['createdAt'] as String? ?? '',
  updatedAt: json['updatedAt'] as String? ?? '',
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  '_id': instance.id,
  'inquiry': instance.inquiry,
  'sender': _userToJson(instance.sender),
  'role': _$MessageRoleEnumMap[instance.role]!,
  'text': instance.text,
  'visibleToUser': instance.visibleToUser,
  'visibleToOwner': instance.visibleToOwner,
  'isEditedByAdmin': instance.isEditedByAdmin,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.owner: 'owner',
  MessageRole.admin: 'admin',
};

Inquiry _$InquiryFromJson(Map<String, dynamic> json) => Inquiry(
  id: json['_id'] as String,
  property: _propertyFromJson(json['property']),
  user: _userFromJson(json['user']),
  owner: _userFromJson(json['owner']),
  status: $enumDecode(
    _$InquiryStatusEnumMap,
    json['status'],
    unknownValue: InquiryStatus.active,
  ),
  lastMessageAt: json['lastMessageAt'] as String? ?? '',
  createdAt: json['createdAt'] as String? ?? '',
  updatedAt: json['updatedAt'] as String? ?? '',
);

Map<String, dynamic> _$InquiryToJson(Inquiry instance) => <String, dynamic>{
  '_id': instance.id,
  'property': _propertyToJson(instance.property),
  'user': _userToJson(instance.user),
  'owner': _userToJson(instance.owner),
  'status': _$InquiryStatusEnumMap[instance.status]!,
  'lastMessageAt': instance.lastMessageAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$InquiryStatusEnumMap = {
  InquiryStatus.active: 'active',
  InquiryStatus.closed: 'closed',
};

InquiryDetail _$InquiryDetailFromJson(Map<String, dynamic> json) =>
    InquiryDetail(
      inquiry: Inquiry.fromJson(json['inquiry'] as Map<String, dynamic>),
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$InquiryDetailToJson(InquiryDetail instance) =>
    <String, dynamic>{
      'inquiry': instance.inquiry.toJson(),
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };
