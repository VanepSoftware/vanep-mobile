import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';

part 'driver_attendance_dto.freezed.dart';
part 'driver_attendance_dto.g.dart';

@freezed
abstract class DriverAttendanceDto
    with _$DriverAttendanceDto
    implements DriverAttendance {
  const factory DriverAttendanceDto({
    @JsonKey(name: 'available') required bool acceptingStudents,
    @JsonKey(
      name: 'basePrice',
      fromJson: centsFromPrice,
      toJson: priceFromCents,
    )
    int? basePriceCents,
  }) = _DriverAttendanceDto;

  factory DriverAttendanceDto.fromJson(Map<String, Object?> json) =>
      _$DriverAttendanceDtoFromJson(json);
}

int? centsFromPrice(num? price) => price == null ? null : (price * 100).round();

double? priceFromCents(int? cents) => cents == null ? null : cents / 100;
