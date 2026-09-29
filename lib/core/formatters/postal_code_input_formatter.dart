import 'package:flutter/services.dart';

import '../domain/postal_address_draft.dart';

String formatBrazilianZip(String raw) {
  final digits = limitZipDigits(raw);
  if (digits.length <= 5) return digits;
  return '${digits.substring(0, 5)}-${digits.substring(5)}';
}

class PostalCodeInputFormatter extends TextInputFormatter {
  const PostalCodeInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatBrazilianZip(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
