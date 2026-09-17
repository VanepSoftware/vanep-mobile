import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';

void main() {
  test('parseIsoCalendarDate keeps the calendar day, not UTC midnight', () {
    final parsed = parseIsoCalendarDate('2015-03-22');

    expect(parsed, isNotNull);
    expect(parsed!.year, 2015);
    expect(parsed.month, 3);
    expect(parsed.day, 22);
    expect(parsed.isUtc, isFalse);
  });

  test('formatIsoCalendarDate round-trips the parsed day', () {
    final parsed = parseIsoCalendarDate('2015-03-22')!;

    expect(formatIsoCalendarDate(parsed), '2015-03-22');
  });

  test('an impossible calendar day is rejected', () {
    expect(parseIsoCalendarDate('2026-02-31'), isNull);
    expect(parseIsoCalendarDate('nao-e-data'), isNull);
    expect(parseIsoCalendarDate(''), isNull);
    expect(parseIsoCalendarDate(null), isNull);
  });
}
