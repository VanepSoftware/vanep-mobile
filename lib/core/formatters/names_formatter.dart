import 'package:vanep_mobile/l10n/app_localizations.dart';

String firstNameOf(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed.split(RegExp(r'\s+')).first;
}

String joinFirstNames(AppLocalizations l10n, Iterable<String> fullNames) {
  return joinNames(l10n, [for (final name in fullNames) firstNameOf(name)]);
}

String joinNames(AppLocalizations l10n, List<String> names) {
  if (names.isEmpty) return '';
  if (names.length == 1) return names.single;
  final leading = names.sublist(0, names.length - 1).join(', ');
  return '$leading${l10n.namesListLastSeparator}${names.last}';
}
