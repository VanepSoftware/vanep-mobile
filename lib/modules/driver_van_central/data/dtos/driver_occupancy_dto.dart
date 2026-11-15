import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/value_objects/operation_shift.dart';

part 'driver_occupancy_dto.freezed.dart';
part 'driver_occupancy_dto.g.dart';

@freezed
abstract class ShiftOccupancyDto
    with _$ShiftOccupancyDto
    implements ShiftOccupancy {
  const factory ShiftOccupancyDto({
    @JsonKey(fromJson: operationShiftFromApi, toJson: operationShiftToApi)
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

OperationShift operationShiftFromApi(String value) =>
    OperationShift.values.byName(value.toLowerCase());

String operationShiftToApi(OperationShift shift) => shift.name.toUpperCase();

bool isKnownOperationShift(Object? value) =>
    value is String &&
    OperationShift.values.any((shift) => shift.name == value.toLowerCase());

List<ShiftOccupancyDto> knownShiftOccupanciesFromApi(List<dynamic> json) => [
  for (final entry in json.whereType<Map<String, dynamic>>())
    if (isKnownOperationShift(entry['shift']))
      ShiftOccupancyDto.fromJson(Map<String, Object?>.from(entry)),
];
