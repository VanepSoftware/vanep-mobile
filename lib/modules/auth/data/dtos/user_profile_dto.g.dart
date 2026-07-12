// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    _UserProfileDto(
      token: json['token'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$UserProfileDtoToJson(_UserProfileDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'email': instance.email,
      'type': instance.type,
    };
