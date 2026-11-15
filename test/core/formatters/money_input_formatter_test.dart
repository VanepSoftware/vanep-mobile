import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/money_input_formatter.dart';

TextEditingValue typed(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

void main() {
  const formatter = MoneyInputFormatter(localeName: 'pt');

  test('typed digits fill the cents first', () {
    expect(formatter.formatEditUpdate(typed(''), typed('2')).text, '0,02');
    expect(
      formatter.formatEditUpdate(typed(''), typed('29000')).text,
      '290,00',
    );
    expect(
      formatter.formatEditUpdate(typed(''), typed('1234567')).text,
      '12.345,67',
    );
  });

  test(
    'ignores anything that is not a digit and keeps the cursor at the end',
    () {
      final value = formatter.formatEditUpdate(typed(''), typed('R\$ 3a3,33'));

      expect(value.text, '33,33');
      expect(value.selection.baseOffset, value.text.length);
    },
  );

  test('erasing every digit leaves the field empty', () {
    expect(formatter.formatEditUpdate(typed('0,02'), typed('')).text, '');
  });

  test('reads the cents back from the text', () {
    expect(parseMoneyInput('290,00'), 29000);
    expect(parseMoneyInput('12.345,67'), 1234567);
    expect(parseMoneyInput(''), isNull);
  });

  test('writes cents as the text of the field', () {
    expect(formatMoneyInput('pt', 33333), '333,33');
    expect(formatMoneyInput('pt', 0), '0,00');
  });
}
