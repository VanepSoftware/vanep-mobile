import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/calendar_days.dart';

void main() {
  test('counts calendar days between two dates', () {
    expect(
      calendarDaysBetween(DateTime(2026, 11, 20), DateTime(2026, 11, 29)),
      9,
    );
  });

  test('adds months keeping the day', () {
    expect(addCalendarMonths(DateTime(2026, 11, 20), 7), DateTime(2027, 6, 20));
  });

  test('clamps to the last day of a shorter month', () {
    expect(addCalendarMonths(DateTime(2026, 7, 31), 7), DateTime(2027, 2, 28));
    expect(addCalendarMonths(DateTime(2028, 2, 29), 12), DateTime(2029, 2, 28));
  });
}
