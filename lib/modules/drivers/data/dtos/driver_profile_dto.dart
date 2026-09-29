import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/driver_profile.dart';

part 'driver_profile_dto.freezed.dart';
part 'driver_profile_dto.g.dart';

@freezed
abstract class DriverProfileVehicleDto
    with _$DriverProfileVehicleDto
    implements DriverProfileVehicle {
  const factory DriverProfileVehicleDto({
    required String token,
    required String brand,
    required String model,
    required int manufactureYear,
    required String color,
    required int capacity,
    @JsonKey(name: 'photoFront') String? photoFrontUrl,
    @JsonKey(name: 'photoSide') String? photoSideUrl,
  }) = _DriverProfileVehicleDto;

  factory DriverProfileVehicleDto.fromJson(Map<String, Object?> json) =>
      _$DriverProfileVehicleDtoFromJson(json);
}

@freezed
abstract class DriverProfileDto
    with _$DriverProfileDto
    implements DriverProfile {
  const factory DriverProfileDto({
    required String token,
    required String name,
    String? phone,
    @JsonKey(name: 'photo') String? photoUrl,
    double? rating,
    String? bio,
    int? experienceYears,
    double? basePrice,
    @Default(false) bool available,
    @Default(<String>[]) List<String> serviceAreas,
    @Default(<DriverProfileVehicleDto>[])
    List<DriverProfileVehicleDto> vehicles,
  }) = _DriverProfileDto;

  factory DriverProfileDto.fromJson(Map<String, Object?> json) =>
      _$DriverProfileDtoFromJson(json);
}
