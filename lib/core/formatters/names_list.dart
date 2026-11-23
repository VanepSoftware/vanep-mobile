import 'package:vanep_mobile/l10n/app_localizations.dart';

String joinNames(AppLocalizations l10n, List<String> names) {
  if (names.isEmpty) return '';
  if (names.length == 1) return names.single;
  final leading = names.sublist(0, names.length - 1).join(', ');
  return '$leading${l10n.clientHomeNamesListLastSeparator}${names.last}';
}
