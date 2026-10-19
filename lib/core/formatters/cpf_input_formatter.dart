import 'package:flutter/services.dart';

import 'package:vanep_mobile/core/domain/cpf.dart';

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
    final digits = extractCpfDigits(newValue.text);
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
