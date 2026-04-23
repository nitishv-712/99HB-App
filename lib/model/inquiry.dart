import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';

enum InquiryStatus { active, closed }

InquiryStatus _inquiryStatusFromString(String v) =>
    v == 'active' ? InquiryStatus.active : InquiryStatus.closed;

enum MessageRole { user, owner, admin }

MessageRole _messageRoleFromString(String v) =>
    MessageRole.values.firstWhere((e) => e.name == v);

class ApiMessage {
  final String id;
  final String inquiry;
  final String sender;
  final MessageRole role;
  final String text;
  final bool visibleToUser;
  final bool visibleToOwner;
  final bool isEditedByAdmin;
  final String createdAt;
  final String updatedAt;

  const ApiMessage({
    required this.id,
    required this.inquiry,
    required this.sender,
    required this.role,
    required this.text,
    required this.visibleToUser,
    required this.visibleToOwner,
    required this.isEditedByAdmin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiMessage.fromJson(Map<String, dynamic> j) => ApiMessage(
        id: j['_id'] as String,
        inquiry: j['inquiry'] as String,
        sender: j['sender'] as String,
        role: _messageRoleFromString(j['role'] as String),
        text: j['text'] as String,
        visibleToUser: j['visibleToUser'] as bool,
        visibleToOwner: j['visibleToOwner'] as bool,
        isEditedByAdmin: j['isEditedByAdmin'] as bool,
        createdAt: j['createdAt'] as String,
        updatedAt: j['updatedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'inquiry': inquiry,
        'sender': sender,
        'role': role.name,
        'text': text,
        'visibleToUser': visibleToUser,
        'visibleToOwner': visibleToOwner,
        'isEditedByAdmin': isEditedByAdmin,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class ApiInquiry {
  final String id;

  /// Populated [ApiProperty] or raw ID string
  final dynamic property;

  /// Populated [ApiUser] or raw ID string
  final dynamic user;

  /// Populated [ApiUser] or raw ID string
  final dynamic owner;

  final InquiryStatus status;
  final String lastMessageAt;
  final String createdAt;
  final String updatedAt;

  const ApiInquiry({
    required this.id,
    required this.property,
    required this.user,
    required this.owner,
    required this.status,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiInquiry.fromJson(Map<String, dynamic> j) => ApiInquiry(
        id: j['_id'] as String,
        property: j['property'] is Map
            ? ApiProperty.fromJson(j['property'] as Map<String, dynamic>)
            : j['property'] as String,
        user: j['user'] is Map
            ? ApiUser.fromJson(j['user'] as Map<String, dynamic>)
            : j['user'] as String,
        owner: j['owner'] is Map
            ? ApiUser.fromJson(j['owner'] as Map<String, dynamic>)
            : j['owner'] as String,
        status: _inquiryStatusFromString(j['status'] as String),
        lastMessageAt: j['lastMessageAt'] as String,
        createdAt: j['createdAt'] as String,
        updatedAt: j['updatedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'property': property is ApiProperty ? (property as ApiProperty).toJson() : property,
        'user': user is ApiUser ? (user as ApiUser).toJson() : user,
        'owner': owner is ApiUser ? (owner as ApiUser).toJson() : owner,
        'status': status.name,
        'lastMessageAt': lastMessageAt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class SingleInquiryData {
  final ApiInquiry inquiry;
  final List<ApiMessage> messages;

  const SingleInquiryData({required this.inquiry, required this.messages});

  factory SingleInquiryData.fromJson(Map<String, dynamic> j) => SingleInquiryData(
        inquiry: ApiInquiry.fromJson(j['inquiry'] as Map<String, dynamic>),
        messages: (j['messages'] as List)
            .map((e) => ApiMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
