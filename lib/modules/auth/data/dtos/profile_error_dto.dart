import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_error_dto.freezed.dart';
part 'profile_error_dto.g.dart';

@freezed
abstract class ProfileErrorDto with _$ProfileErrorDto {
  const factory ProfileErrorDto({
    String? message,
    String? detail,
    int? status,
    String? code,
    String? field,
    DateTime? retryAfter,
    @Default(<ProfileFieldErrorDto>[]) List<ProfileFieldErrorDto> errors,
  }) = _ProfileErrorDto;

  factory ProfileErrorDto.fromJson(Map<String, Object?> json) =>
      _$ProfileErrorDtoFromJson(json);
}

@freezed
abstract class ProfileFieldErrorDto with _$ProfileFieldErrorDto {
  const factory ProfileFieldErrorDto({
    String? field,
    String? code,
    String? message,
  }) = _ProfileFieldErrorDto;

  factory ProfileFieldErrorDto.fromJson(Map<String, Object?> json) =>
      _$ProfileFieldErrorDtoFromJson(json);
}
