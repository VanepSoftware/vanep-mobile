import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

String weekdayLabel(AppLocalizations l10n, Weekday day) {
  return switch (day) {
    Weekday.monday => l10n.weekdayMonday,
    Weekday.tuesday => l10n.weekdayTuesday,
    Weekday.wednesday => l10n.weekdayWednesday,
    Weekday.thursday => l10n.weekdayThursday,
    Weekday.friday => l10n.weekdayFriday,
    Weekday.saturday => l10n.weekdaySaturday,
    Weekday.sunday => l10n.weekdaySunday,
  };
}

String weekdayInitial(AppLocalizations l10n, Weekday day) {
  return switch (day) {
    Weekday.monday => l10n.weekdayInitialMonday,
    Weekday.tuesday => l10n.weekdayInitialTuesday,
    Weekday.wednesday => l10n.weekdayInitialWednesday,
    Weekday.thursday => l10n.weekdayInitialThursday,
    Weekday.friday => l10n.weekdayInitialFriday,
    Weekday.saturday => l10n.weekdayInitialSaturday,
    Weekday.sunday => l10n.weekdayInitialSunday,
  };
}

String weekdayShortLabel(AppLocalizations l10n, Weekday day) {
  return switch (day) {
    Weekday.monday => l10n.weekdayShortMonday,
    Weekday.tuesday => l10n.weekdayShortTuesday,
    Weekday.wednesday => l10n.weekdayShortWednesday,
    Weekday.thursday => l10n.weekdayShortThursday,
    Weekday.friday => l10n.weekdayShortFriday,
    Weekday.saturday => l10n.weekdayShortSaturday,
    Weekday.sunday => l10n.weekdayShortSunday,
  };
}

String formatWeekdayList(AppLocalizations l10n, List<Weekday> weekdays) {
  if (weekdays.length == weekdaysMondayToFriday.length &&
      weekdays.every(weekdaysMondayToFriday.contains)) {
    return l10n.weekdayRangeMondayToFriday;
  }
  return weekdays.map((day) => weekdayShortLabel(l10n, day)).join(', ');
}
