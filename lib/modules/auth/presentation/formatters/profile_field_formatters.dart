import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/value_objects/gender.dart';

String profileGenderLabel(Gender? gender, AppLocalizations l10n) {
  return switch (gender) {
    Gender.male => l10n.profileGenderMale,
    Gender.female => l10n.profileGenderFemale,
    Gender.other => l10n.profileGenderOther,
    null => l10n.profileFieldEmpty,
  };
}

String formatProfileBirthDate(String? raw, Locale locale, String emptyLabel) {
  if (raw == null || raw.trim().isEmpty) return emptyLabel;
  final parsed = DateTime.tryParse(raw.trim());
  if (parsed == null) return raw;
  final pattern = locale.languageCode == 'pt' ? 'dd/MM/yyyy' : 'M/d/yyyy';
  return DateFormat(pattern).format(parsed);
}

String formatProfilePhone(String? raw, String emptyLabel) {
  if (raw == null || raw.trim().isEmpty) return emptyLabel;
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-'
        '${digits.substring(7)}';
  }
  if (digits.length == 10) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-'
        '${digits.substring(6)}';
  }
  return raw;
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
