import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

const int maxBrazilianPhoneDigits = 11;

String extractPhoneDigits(String raw) => raw.replaceAll(RegExp(r'\D'), '');

String formatProfilePhoneDigits(String digits) {
  if (digits.isEmpty) return '';
  if (digits.length <= 2) return '($digits';

  final areaCode = digits.substring(0, 2);
  final localNumber = digits.substring(2);
  final isMobile = digits.length >= maxBrazilianPhoneDigits;
  final localPrefixLength = isMobile ? 5 : 4;

  if (localNumber.length <= localPrefixLength) {
    return '($areaCode) $localNumber';
  }

  final localPrefix = localNumber.substring(0, localPrefixLength);
  final localSuffix = localNumber.substring(localPrefixLength);
  return '($areaCode) $localPrefix-$localSuffix';
}

String formatProfilePhone(String? raw, String emptyLabel) {
  if (raw == null || raw.trim().isEmpty) return emptyLabel;
  final digits = extractPhoneDigits(raw);
  if (digits.length != 10 && digits.length != maxBrazilianPhoneDigits) {
    return raw;
  }
  return formatProfilePhoneDigits(digits);
}

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
