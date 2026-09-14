import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String formatBirthDate(String? raw, Locale locale, String emptyLabel) {
  if (raw == null || raw.trim().isEmpty) return emptyLabel;
  final parsed = DateTime.tryParse(raw.trim());
  if (parsed == null) return raw;
  final pattern = locale.languageCode == 'pt' ? 'dd/MM/yyyy' : 'M/d/yyyy';
  return DateFormat(pattern).format(parsed);
}
