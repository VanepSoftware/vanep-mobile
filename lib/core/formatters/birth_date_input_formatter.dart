import 'package:flutter/services.dart';

import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';

const int birthDateDigitCount = 8;

String formatPartialBirthDate(String digits) {
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index == 2 || index == 4) buffer.write('/');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

String? birthDateInputToIso(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (digits.length < birthDateDigitCount) return text;
  final day = digits.substring(0, 2);
  final month = digits.substring(2, 4);
  final year = digits.substring(4, 8);
  return '$year-$month-$day';
}

String isoToBirthDateInput(String? iso) {
  if (iso == null) return '';
  final parsed = parseIsoCalendarDate(iso);
  if (parsed == null) return iso;
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}

class BirthDateInputFormatter extends TextInputFormatter {
  const BirthDateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > birthDateDigitCount
        ? digits.substring(0, birthDateDigitCount)
        : digits;
    final formatted = formatPartialBirthDate(limited);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
