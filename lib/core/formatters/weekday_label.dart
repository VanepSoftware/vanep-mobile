import 'package:vanep_mobile/l10n/app_localizations.dart';

String formatWeekdayName(AppLocalizations l10n, int weekday) {
  return switch (weekday) {
    DateTime.monday => l10n.clientHomeWeekdayMonday,
    DateTime.tuesday => l10n.clientHomeWeekdayTuesday,
    DateTime.wednesday => l10n.clientHomeWeekdayWednesday,
    DateTime.thursday => l10n.clientHomeWeekdayThursday,
    DateTime.friday => l10n.clientHomeWeekdayFriday,
    DateTime.saturday => l10n.clientHomeWeekdaySaturday,
    _ => l10n.clientHomeWeekdaySunday,
  };
}

String formatWeekdayShortName(AppLocalizations l10n, int weekday) {
  return switch (weekday) {
    DateTime.monday => l10n.clientHomeWeekdayShortMonday,
    DateTime.tuesday => l10n.clientHomeWeekdayShortTuesday,
    DateTime.wednesday => l10n.clientHomeWeekdayShortWednesday,
    DateTime.thursday => l10n.clientHomeWeekdayShortThursday,
    DateTime.friday => l10n.clientHomeWeekdayShortFriday,
    DateTime.saturday => l10n.clientHomeWeekdayShortSaturday,
    _ => l10n.clientHomeWeekdayShortSunday,
  };
}
