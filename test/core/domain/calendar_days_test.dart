import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/calendar_days.dart';

void main() {
  test('counts calendar days between two dates', () {
    expect(
      calendarDaysBetween(DateTime(2026, 11, 20), DateTime(2026, 11, 29)),
      9,
    );
  });
}
