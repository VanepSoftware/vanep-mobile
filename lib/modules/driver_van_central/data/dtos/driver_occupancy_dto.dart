import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/core/data/json_readers.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';

part 'driver_occupancy_dto.freezed.dart';
part 'driver_occupancy_dto.g.dart';

@freezed
abstract class ShiftOccupancyDto
    with _$ShiftOccupancyDto
    implements ShiftOccupancy {
  const factory ShiftOccupancyDto({
    @JsonKey(fromJson: readOperationShift, toJson: OperationShift.toApi)
    required OperationShift shift,
    required int passengers,
  }) = _ShiftOccupancyDto;

  factory ShiftOccupancyDto.fromJson(Map<String, Object?> json) =>
      _$ShiftOccupancyDtoFromJson(json);
}

@freezed
abstract class DriverOccupancyDto
    with _$DriverOccupancyDto
    implements DriverOccupancy {
  const factory DriverOccupancyDto({
    @JsonKey(fromJson: knownShiftOccupanciesFromApi)
    required List<ShiftOccupancyDto> shifts,
    required int students,
    required int studentsWithFamily,
  }) = _DriverOccupancyDto;

  factory DriverOccupancyDto.fromJson(Map<String, Object?> json) =>
      _$DriverOccupancyDtoFromJson(json);
}

List<ShiftOccupancyDto> knownShiftOccupanciesFromApi(List<dynamic> json) => [
  for (final entry in json.whereType<Map<String, dynamic>>())
    if (OperationShift.fromApi(entry['shift']) != null)
      ShiftOccupancyDto.fromJson(Map<String, Object?>.from(entry)),
];
