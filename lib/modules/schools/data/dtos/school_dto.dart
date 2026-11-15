import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';

part 'school_dto.freezed.dart';
part 'school_dto.g.dart';

@freezed
abstract class SchoolDto with _$SchoolDto {
  const factory SchoolDto({required String token, required String name}) =
      _SchoolDto;

  factory SchoolDto.fromJson(Map<String, Object?> json) =>
      _$SchoolDtoFromJson(json);
}

School schoolFromDto(SchoolDto dto) {
  return School(token: dto.token, name: dto.name);
}

School schoolFromJson(Map<String, Object?> json) {
  return schoolFromDto(SchoolDto.fromJson(json));
}
