import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/postal_code_input_formatter.dart';

TextEditingValue formatTyped(String text) {
  return const PostalCodeInputFormatter().formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(text: text),
  );
}

void main() {
  group('formatBrazilianZip', () {
    test('shows up to five digits without a hyphen', () {
      expect(formatBrazilianZip(''), '');
      expect(formatBrazilianZip('7'), '7');
      expect(formatBrazilianZip('70040'), '70040');
    });

    test('puts the hyphen after the fifth digit', () {
      expect(formatBrazilianZip('700400'), '70040-0');
      expect(formatBrazilianZip('70040010'), '70040-010');
    });

    test('drops non digits and anything past eight digits', () {
      expect(formatBrazilianZip('70040-010'), '70040-010');
      expect(formatBrazilianZip('700400109999'), '70040-010');
    });
  });

  group('PostalCodeInputFormatter', () {
    test('masks what is typed', () {
      expect(formatTyped('70040010').text, '70040-010');
    });

    test('keeps the caret at the end', () {
      final value = formatTyped('70040010');

      expect(value.selection, const TextSelection.collapsed(offset: 9));
    });

    test('ignores letters and symbols', () {
      expect(formatTyped('70a04.0-01/0').text, '70040-010');
    });

    test('stops at eight digits', () {
      expect(formatTyped('7004001099').text, '70040-010');
    });
  });
}
