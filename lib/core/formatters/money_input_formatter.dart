import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const moneyInputMaxDigits = 10;

int? parseMoneyInput(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  return int.parse(digits);
}

String formatMoneyInput(String localeName, int cents) {
  return NumberFormat('#,##0.00', localeName).format(cents / 100);
}

class MoneyInputFormatter extends TextInputFormatter {
  const MoneyInputFormatter({required this.localeName});

  final String localeName;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final kept = digits.length > moneyInputMaxDigits
        ? digits.substring(0, moneyInputMaxDigits)
        : digits;
    final text = kept.isEmpty
        ? ''
        : formatMoneyInput(localeName, int.parse(kept));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
