// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => AdminUser(
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  fullName: json['fullName'] as String? ?? '',
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$AdminUserToJson(AdminUser instance) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'fullName': instance.fullName,
  'avatar': instance.avatar,
};
