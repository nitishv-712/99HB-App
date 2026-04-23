import 'package:json_annotation/json_annotation.dart';

part 'admin_user.g.dart';

enum AdminRole { admin, superadmin }

@JsonSerializable()
class AdminUser {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(defaultValue: '')
  final String firstName;
  @JsonKey(defaultValue: '')
  final String lastName;
  @JsonKey(defaultValue: '')
  final String fullName;
  @JsonKey(defaultValue: '')
  final String email;
  final String? phone;
  @JsonKey(unknownEnumValue: AdminRole.admin)
  final AdminRole role;
  final String? avatar;
  @JsonKey(defaultValue: true)
  final bool isActive;
  final String? createdBy;
  final String? lastLoginAt;
  @JsonKey(defaultValue: '')
  final String createdAt;
  @JsonKey(defaultValue: '')
  final String updatedAt;

  const AdminUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    required this.isActive,
    this.createdBy,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserToJson(this);
}

typedef ApiAdminUser = AdminUser;
