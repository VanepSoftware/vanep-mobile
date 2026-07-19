// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverDto _$DriverDtoFromJson(Map<String, dynamic> json) => _DriverDto(
  token: json['token'] as String,
  name: json['name'] as String,
  photoUrl: json['photo'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  experienceYears: (json['experienceYears'] as num?)?.toInt(),
  city: json['city'] as String?,
);

Map<String, dynamic> _$DriverDtoToJson(_DriverDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'name': instance.name,
      'photo': instance.photoUrl,
      'rating': instance.rating,
      'experienceYears': instance.experienceYears,
      'city': instance.city,
    };
