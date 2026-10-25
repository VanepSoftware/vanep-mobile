import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/birth_date_input_formatter.dart';

TextEditingValue formatTyped(String text) {
  return const BirthDateInputFormatter().formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(text: text),
  );
}

void main() {
  group('BirthDateInputFormatter', () {
    test('puts the slashes after the day and the month', () {
      expect(formatTyped('1').text, '1');
      expect(formatTyped('120').text, '12/0');
      expect(formatTyped('12032018').text, '12/03/2018');
    });

    test('ignores what is not a digit and stops at eight digits', () {
      expect(formatTyped('12a03b20189').text, '12/03/2018');
    });
  });

  group('birthDateInputToIso', () {
    test('a full date becomes ISO', () {
      expect(birthDateInputToIso('12/03/2018'), '2018-03-12');
    });

    test('an empty field is no date', () {
      expect(birthDateInputToIso(''), isNull);
      expect(birthDateInputToIso('  '), isNull);
    });

    test('a partial date is kept as typed so validation rejects it', () {
      expect(birthDateInputToIso('12/03'), '12/03');
    });
  });

  group('isoToBirthDateInput', () {
    test('shows an ISO date as day, month and year', () {
      expect(isoToBirthDateInput('2018-03-12'), '12/03/2018');
    });

    test('shows nothing for no date and keeps an unparseable one', () {
      expect(isoToBirthDateInput(null), '');
      expect(isoToBirthDateInput('12/03'), '12/03');
    });
  });
}
