import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/driver_van.dart';

part 'driver_van_dto.freezed.dart';
part 'driver_van_dto.g.dart';

@freezed
abstract class DriverVanDto with _$DriverVanDto implements DriverVan {
  const factory DriverVanDto({
    required String token,
    required String plate,
    required String brand,
    required String model,
    required int manufactureYear,
    required String color,
    required int capacity,
    String? photoFrontUrl,
    String? photoSideUrl,
  }) = _DriverVanDto;

  factory DriverVanDto.fromJson(Map<String, Object?> json) =>
      _$DriverVanDtoFromJson(json);
}
