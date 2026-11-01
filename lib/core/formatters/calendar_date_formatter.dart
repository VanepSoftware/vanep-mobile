import 'package:intl/intl.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';

String withoutAbbreviationDot(String text) => text.replaceAll('.', '');

String formatDayAndMonth(AppLocalizations l10n, DateTime date) {
  return DateFormat('dd/MM', l10n.localeName).format(date.toLocal());
}

String formatDayMonthAndTime(AppLocalizations l10n, DateTime date) {
  return DateFormat('dd/MM HH:mm', l10n.localeName).format(date.toLocal());
}

String formatCalendarDate(AppLocalizations l10n, DateTime date) {
  return withoutAbbreviationDot(
    DateFormat('d MMM yyyy', l10n.localeName).format(date),
  );
}

String formatNumericDate(AppLocalizations l10n, DateTime date) {
  return DateFormat('dd/MM/yyyy', l10n.localeName).format(date);
}

String formatCalendarRange(
  AppLocalizations l10n,
  DateTime start,
  DateTime end,
) {
  final startLabel = start.year == end.year
      ? withoutAbbreviationDot(
          DateFormat('d MMM', l10n.localeName).format(start),
        )
      : formatCalendarDate(l10n, start);
  return l10n.calendarDateRange(startLabel, formatCalendarDate(l10n, end));
}
