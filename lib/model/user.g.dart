// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KycCard _$KycCardFromJson(Map<String, dynamic> json) => KycCard(
  number: json['number'] as String?,
  image: json['image'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
);

Map<String, dynamic> _$KycCardToJson(KycCard instance) => <String, dynamic>{
  'number': instance.number,
  'image': instance.image,
  'isVerified': instance.isVerified,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['_id'] as String,
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  email: json['email'] as String? ?? '',
  isGmailVerified: json['isGmailVerified'] as bool? ?? false,
  phone: json['phone'] as String?,
  isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
  role: json['role'] as String? ?? 'buyer',
  avatar: json['avatar'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
  panCard: json['panCard'] == null
      ? null
      : KycCard.fromJson(json['panCard'] as Map<String, dynamic>),
  aadharCard: json['aadharCard'] == null
      ? null
      : KycCard.fromJson(json['aadharCard'] as Map<String, dynamic>),
  createdAt: json['createdAt'] as String? ?? '',
  updatedAt: json['updatedAt'] as String? ?? '',
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  '_id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'isGmailVerified': instance.isGmailVerified,
  'phone': instance.phone,
  'isPhoneVerified': instance.isPhoneVerified,
  'role': instance.role,
  'avatar': instance.avatar,
  'isVerified': instance.isVerified,
  'panCard': instance.panCard?.toJson(),
  'aadharCard': instance.aadharCard?.toJson(),
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
