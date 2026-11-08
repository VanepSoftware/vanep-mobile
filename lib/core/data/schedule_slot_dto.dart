import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/core/data/json_readers.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/schedule/schedule_slot.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';

part 'schedule_slot_dto.freezed.dart';
part 'schedule_slot_dto.g.dart';

@Freezed(toJson: false)
abstract class ScheduleSlotDto with _$ScheduleSlotDto implements ScheduleSlot {
  const factory ScheduleSlotDto({
    @JsonKey(fromJson: readWeekday) required Weekday weekday,
    @JsonKey(fromJson: readRouteLeg) required RouteLeg leg,
    @JsonKey(fromJson: readOperationShift) required OperationShift shift,
    @JsonKey(fromJson: readClockTime) required ClockTime pickupTime,
  }) = _ScheduleSlotDto;

  factory ScheduleSlotDto.fromJson(Map<String, Object?> json) =>
      _$ScheduleSlotDtoFromJson(json);
}
