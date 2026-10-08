import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/formatters/phone_formatter.dart';

class ProfilePhoneInputFormatter extends TextInputFormatter {
  const ProfilePhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = extractPhoneDigits(newValue.text);
    final limitedDigits = digits.length > maxBrazilianPhoneDigits
        ? digits.substring(0, maxBrazilianPhoneDigits)
        : digits;
    final formatted = formatProfilePhoneDigits(limitedDigits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String formatProfileDocument(String? raw, String emptyLabel) {
  if (raw == null || raw.trim().isEmpty) return emptyLabel;
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11) {
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.'
        '${digits.substring(6, 9)}-${digits.substring(9)}';
  }
  return raw;
}

String profileDisplayOrEmpty(String? value, String emptyLabel) {
  if (value == null || value.trim().isEmpty) return emptyLabel;
  return value;
}

String formatProfileCooldownDate(DateTime value, Locale locale) {
  final pattern = locale.languageCode == 'pt'
      ? 'dd/MM/yyyy HH:mm'
      : 'M/d/yyyy h:mm a';
  return DateFormat(pattern).format(value.toLocal());
}

int profileCooldownDaysRemaining(DateTime target, {DateTime? now}) {
  final duration = target.difference(now ?? DateTime.now());
  if (duration.isNegative) return 0;
  final days = (duration.inSeconds / (24 * 60 * 60)).ceil();
  return days < 1 ? 1 : days;
}
