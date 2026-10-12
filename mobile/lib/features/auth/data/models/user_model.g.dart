// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phone: json['phone'] as String?,
  displayName: json['displayName'] as String?,
  avatarKey: json['avatarKey'] as String?,
  locale: json['locale'] as String? ?? 'en',
  status: json['status'] as String?,
  vendor: json['vendor'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': instance.role,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'displayName': instance.displayName,
      'avatarKey': instance.avatarKey,
      'locale': instance.locale,
      'status': instance.status,
      'vendor': instance.vendor,
    };
