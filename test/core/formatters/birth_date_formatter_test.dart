import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/birth_date_formatter.dart';

void main() {
  test('formatBirthDate formats for locale', () {
    expect(formatBirthDate('1990-05-15', const Locale('pt'), '—'), '15/05/1990');
    expect(formatBirthDate('1990-05-15', const Locale('en'), '—'), '5/15/1990');
    expect(formatBirthDate(null, const Locale('pt'), '—'), '—');
    expect(
      formatBirthDate('not-a-date', const Locale('pt'), '—'),
      'not-a-date',
    );
  });
}
