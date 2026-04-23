import 'package:json_annotation/json_annotation.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';

part 'inquiry.g.dart';

enum InquiryStatus { active, closed }
enum MessageRole { user, owner, admin }

// ── Message ───────────────────────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class Message {
  @JsonKey(name: '_id')
  final String id;
  final String inquiry;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final dynamic sender;
  @JsonKey(unknownEnumValue: MessageRole.user)
  final MessageRole role;
  @JsonKey(defaultValue: '')
  final String text;
  @JsonKey(defaultValue: false)
  final bool visibleToUser;
  @JsonKey(defaultValue: false)
  final bool visibleToOwner;
  @JsonKey(defaultValue: false)
  final bool isEditedByAdmin;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
  final String updatedAt;

  const Message({
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

  String get senderId =>
      sender is User ? (sender as User).id : sender as String;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

typedef ApiMessage = Message;

// ── Inquiry ───────────────────────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class Inquiry {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(fromJson: _propertyFromJson, toJson: _propertyToJson)
  final dynamic property;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final dynamic user;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final dynamic owner;
  @JsonKey(unknownEnumValue: InquiryStatus.active)
  final InquiryStatus status;
  @JsonKey(defaultValue: '')
  final String lastMessageAt;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
  final String updatedAt;

  const Inquiry({
    required this.id,
    required this.property,
    required this.user,
    required this.owner,
    required this.status,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) =>
      _$InquiryFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryToJson(this);
}

typedef ApiInquiry = Inquiry;

// ── Single inquiry detail ─────────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class InquiryDetail {
  final Inquiry inquiry;
  @JsonKey(defaultValue: [])
  final List<Message> messages;

  const InquiryDetail({required this.inquiry, required this.messages});

  factory InquiryDetail.fromJson(Map<String, dynamic> json) =>
      _$InquiryDetailFromJson(json);

  Map<String, dynamic> toJson() => _$InquiryDetailToJson(this);
}

typedef SingleInquiryData = InquiryDetail;

// ── Converters ────────────────────────────────────────────────────────────────

dynamic _userFromJson(dynamic v) =>
    v is Map<String, dynamic> ? User.fromJson(v) : v;
dynamic _userToJson(dynamic v) => v is User ? v.toJson() : v;

dynamic _propertyFromJson(dynamic v) =>
    v is Map<String, dynamic> ? Property.fromJson(v) : v;
dynamic _propertyToJson(dynamic v) => v is Property ? v.toJson() : v;
