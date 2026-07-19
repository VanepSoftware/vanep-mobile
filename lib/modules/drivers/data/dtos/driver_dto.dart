import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/driver.dart';

part 'driver_dto.freezed.dart';
part 'driver_dto.g.dart';

@freezed
abstract class DriverDto with _$DriverDto implements Driver {
  const factory DriverDto({
    required String token,
    required String name,
    @JsonKey(name: 'photo') String? photoUrl,
    double? rating,
    int? experienceYears,
    String? city,
  }) = _DriverDto;

  factory DriverDto.fromJson(Map<String, Object?> json) =>
      _$DriverDtoFromJson(json);
}
