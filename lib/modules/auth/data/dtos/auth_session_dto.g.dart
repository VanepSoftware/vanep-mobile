// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSessionDto _$AuthSessionDtoFromJson(Map<String, dynamic> json) =>
    _AuthSessionDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      profile: UserProfileDto.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthSessionDtoToJson(_AuthSessionDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'profile': instance.profile,
    };
