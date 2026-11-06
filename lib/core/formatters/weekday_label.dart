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
