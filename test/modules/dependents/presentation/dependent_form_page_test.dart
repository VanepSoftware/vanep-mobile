import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_form_page.dart';

void main() {
  test('opening the picker on 2015-03-22 keeps 22 March, not 21', () {
    final today = DateTime(2026, 9, 17);
    final initial = initialBirthDatePickerDay('2015-03-22', today);

    expect(initial.year, 2015);
    expect(initial.month, 3);
    expect(initial.day, 22);
  });

  test('a missing birth date opens the picker on today', () {
    final today = DateTime(2026, 9, 17);

    expect(initialBirthDatePickerDay(null, today), today);
  });
}
