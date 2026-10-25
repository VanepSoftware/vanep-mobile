import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';

enum SchoolWeekSegment { none, partTime, fullTime }

List<SchoolWeekSegment> describeSchoolWeekBar(SchoolWeek week) {
  return [
    for (final day in Weekday.values)
      switch (week.shiftOf(day)) {
        null => SchoolWeekSegment.none,
        SchoolShift.fullTime => SchoolWeekSegment.fullTime,
        SchoolShift.morning ||
        SchoolShift.afternoon ||
        SchoolShift.night => SchoolWeekSegment.partTime,
      },
  ];
}
