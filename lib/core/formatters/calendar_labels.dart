import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

String withoutAbbreviationDot(String text) => text.replaceAll('.', '');

String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1)}';
}

String formatWeekdays(AppLocalizations l10n, List<int> weekdays) {
  if (isMondayToFriday(weekdays)) return l10n.clientProposalsMondayToFriday;
  final weekdayFormat = DateFormat.E(l10n.localeName);
  final referenceMonday = DateTime(2024, 1, 1);
  final names = ([...weekdays]..sort()).map(
    (weekday) => withoutAbbreviationDot(
      weekdayFormat.format(referenceMonday.add(Duration(days: weekday - 1))),
    ),
  );
  return capitalizeFirst(names.join(', '));
}

String formatDayMonth(AppLocalizations l10n, DateTime date) {
  final day = date.day == 1
      ? l10n.clientProposalsFirstDayOfMonth
      : '${date.day}';
  final month = withoutAbbreviationDot(
    DateFormat.MMM(l10n.localeName).format(date),
  );
  return l10n.clientProposalsDayMonth(day, month);
}

String formatStartingOn(AppLocalizations l10n, DateTime startsOn) {
  return l10n.clientProposalsStartingOn(formatDayMonth(l10n, startsOn));
}
