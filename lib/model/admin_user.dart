import 'package:json_annotation/json_annotation.dart';

part 'admin_user.g.dart';

enum AdminRole { admin, superadmin }

@JsonSerializable()
class AdminUser {
  @JsonKey(defaultValue: '')
  final String firstName;
  @JsonKey(defaultValue: '')
  final String lastName;
  @JsonKey(defaultValue: '')
  final String fullName;
  final String? avatar;

  const AdminUser({
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.avatar,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserToJson(this);
}

typedef ApiAdminUser = AdminUser;
