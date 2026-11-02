import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';

part 'school_day_dto.freezed.dart';
part 'school_day_dto.g.dart';

@freezed
abstract class SchoolDayDto with _$SchoolDayDto {
  const factory SchoolDayDto({
    @JsonKey(fromJson: Weekday.fromApi, toJson: Weekday.toApi) Weekday? weekday,
    @JsonKey(fromJson: SchoolShift.fromApi, toJson: SchoolShift.toApi)
    SchoolShift? schoolShift,
  }) = _SchoolDayDto;

  factory SchoolDayDto.fromJson(Map<String, Object?> json) =>
      _$SchoolDayDtoFromJson(json);
}

SchoolWeek schoolWeekFromJson(List<dynamic>? payload) {
  if (payload == null) return const SchoolWeek.empty();
  return SchoolWeek.fromDays([
    for (final entry in payload.whereType<Map<String, dynamic>>())
      if (SchoolDayDto.fromJson(Map<String, Object?>.from(entry))
          case SchoolDayDto(weekday: final weekday?, schoolShift: final shift?))
        SchoolDay(weekday: weekday, shift: shift),
  ]);
}

Map<String, Object?> schoolWeekToJson(SchoolWeek week) {
  return {
    'days': [
      for (final day in week.days)
        SchoolDayDto(weekday: day.weekday, schoolShift: day.shift).toJson(),
    ],
  };
}
