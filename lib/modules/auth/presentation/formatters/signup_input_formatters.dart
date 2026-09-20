import 'package:flutter/services.dart';

import '../../domain/value_objects/signup_form.dart';

const int cpfDigitCount = 11;

String formatPartialCpf(String digits) {
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index == 3 || index == 6) buffer.write('.');
    if (index == 9) buffer.write('-');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

class CpfInputFormatter extends TextInputFormatter {
  const CpfInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = extractDigits(newValue.text);
    final limited = digits.length > cpfDigitCount
        ? digits.substring(0, cpfDigitCount)
        : digits;
    final formatted = formatPartialCpf(limited);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

final List<TextInputFormatter> decimalInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];
