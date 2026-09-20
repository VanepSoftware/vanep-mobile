import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_api_error_dto.freezed.dart';
part 'auth_api_error_dto.g.dart';

@freezed
abstract class AuthApiErrorDto with _$AuthApiErrorDto {
  const factory AuthApiErrorDto({
    String? code,
    String? message,
    @Default(<AuthApiFieldErrorDto>[]) List<AuthApiFieldErrorDto> errors,
  }) = _AuthApiErrorDto;

  factory AuthApiErrorDto.fromJson(Map<String, Object?> json) =>
      _$AuthApiErrorDtoFromJson(json);
}

@freezed
abstract class AuthApiFieldErrorDto with _$AuthApiFieldErrorDto {
  const factory AuthApiFieldErrorDto({String? field, String? message}) =
      _AuthApiFieldErrorDto;

  factory AuthApiFieldErrorDto.fromJson(Map<String, Object?> json) =>
      _$AuthApiFieldErrorDtoFromJson(json);
}
