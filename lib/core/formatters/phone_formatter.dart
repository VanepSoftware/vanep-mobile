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
