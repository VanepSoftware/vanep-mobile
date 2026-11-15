import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';

void main() {
  test('reads the time the back sends with seconds', () {
    expect(ClockTime.fromApi('12:05:00'), const ClockTime(hour: 12, minute: 5));
  });

  test('reads a time without seconds', () {
    expect(ClockTime.fromApi('07:30'), const ClockTime(hour: 7, minute: 30));
  });

  test('rejects what is not a time of day', () {
    expect(ClockTime.fromApi(null), isNull);
    expect(ClockTime.fromApi(''), isNull);
    expect(ClockTime.fromApi('24:00'), isNull);
    expect(ClockTime.fromApi('12:60'), isNull);
    expect(ClockTime.fromApi('meio-dia'), isNull);
    expect(ClockTime.fromApi(1205), isNull);
  });

  test('writes hours and minutes with two digits', () {
    expect(const ClockTime(hour: 7, minute: 5).toApi(), '07:05');
    expect(const ClockTime(hour: 18, minute: 30).toApi(), '18:30');
  });

  test('orders times of the same day', () {
    const morning = ClockTime(hour: 7, minute: 5);
    const later = ClockTime(hour: 7, minute: 15);

    expect(later.isAfter(morning), isTrue);
    expect(morning.isAfter(later), isFalse);
    expect(morning.isAfter(morning), isFalse);
    expect(morning.compareTo(later), lessThan(0));
  });
}
