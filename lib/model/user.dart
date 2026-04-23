import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole { buyer, seller, agent }

@JsonSerializable()
class KycCard {
  final String? number;
  final String? image;
  @JsonKey(defaultValue: false)
  final bool isVerified;

  const KycCard({this.number, this.image, required this.isVerified});

  factory KycCard.fromJson(Map<String, dynamic> json) =>
      _$KycCardFromJson(json);

  Map<String, dynamic> toJson() => _$KycCardToJson(this);
}

@JsonSerializable(explicitToJson: true)
class User {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(defaultValue: '')
  final String firstName;
  @JsonKey(defaultValue: '')
  final String lastName;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(defaultValue: false)
  final bool isGmailVerified;
  final String? phone;
  @JsonKey(defaultValue: false)
  final bool isPhoneVerified;
  @JsonKey(defaultValue: 'buyer')
  final String role;
  final String? avatar;
  @JsonKey(defaultValue: false)
  final bool isVerified;
  final KycCard? panCard;
  final KycCard? aadharCard;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
  final String updatedAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isGmailVerified,
    this.phone,
    required this.isPhoneVerified,
    required this.role,
    this.avatar,
    required this.isVerified,
    this.panCard,
    this.aadharCard,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// Alias so existing code keeps compiling without changes
typedef ApiUser = User;
