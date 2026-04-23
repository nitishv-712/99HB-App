// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => AdminUser(
  id: json['_id'] as String,
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  fullName: json['fullName'] as String? ?? '',
  email: json['email'] as String? ?? '',
  phone: json['phone'] as String?,
  role: $enumDecode(
    _$AdminRoleEnumMap,
    json['role'],
    unknownValue: AdminRole.admin,
  ),
  avatar: json['avatar'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdBy: json['createdBy'] as String?,
  lastLoginAt: json['lastLoginAt'] as String?,
  createdAt: json['createdAt'] as String? ?? '',
  updatedAt: json['updatedAt'] as String? ?? '',
);

Map<String, dynamic> _$AdminUserToJson(AdminUser instance) => <String, dynamic>{
  '_id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'fullName': instance.fullName,
  'email': instance.email,
  'phone': instance.phone,
  'role': _$AdminRoleEnumMap[instance.role]!,
  'avatar': instance.avatar,
  'isActive': instance.isActive,
  'createdBy': instance.createdBy,
  'lastLoginAt': instance.lastLoginAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$AdminRoleEnumMap = {
  AdminRole.admin: 'admin',
  AdminRole.superadmin: 'superadmin',
};
