import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/school_week_bar.dart';

void main() {
  test('weekdays in the morning with a full-time thursday', () {
    final week = SchoolWeek.fromDays([
      for (final day in [
        Weekday.monday,
        Weekday.tuesday,
        Weekday.wednesday,
        Weekday.friday,
      ])
        SchoolDay(weekday: day, shift: SchoolShift.morning),
      const SchoolDay(weekday: Weekday.thursday, shift: SchoolShift.fullTime),
    ]);

    final segments = describeSchoolWeekBar(week);

    expect(segments, const [
      SchoolWeekSegment.partTime,
      SchoolWeekSegment.partTime,
      SchoolWeekSegment.partTime,
      SchoolWeekSegment.fullTime,
      SchoolWeekSegment.partTime,
      SchoolWeekSegment.none,
      SchoolWeekSegment.none,
    ]);
  });

  test('afternoon and night are part time too', () {
    final week = SchoolWeek.fromDays(const [
      SchoolDay(weekday: Weekday.saturday, shift: SchoolShift.afternoon),
      SchoolDay(weekday: Weekday.sunday, shift: SchoolShift.night),
    ]);

    final segments = describeSchoolWeekBar(week);

    expect(segments.sublist(5), const [
      SchoolWeekSegment.partTime,
      SchoolWeekSegment.partTime,
    ]);
  });

  test('an empty week has seven empty segments', () {
    final segments = describeSchoolWeekBar(const SchoolWeek.empty());

    expect(segments, List.filled(7, SchoolWeekSegment.none));
  });
}
