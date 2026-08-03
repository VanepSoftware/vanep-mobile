import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_error_dto.freezed.dart';
part 'profile_error_dto.g.dart';

@freezed
abstract class ProfileErrorDto with _$ProfileErrorDto {
  const factory ProfileErrorDto({
    String? message,
    String? code,
    String? field,
    DateTime? retryAfter,
  }) = _ProfileErrorDto;

  factory ProfileErrorDto.fromJson(Map<String, Object?> json) =>
      _$ProfileErrorDtoFromJson(json);
}
