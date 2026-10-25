import 'package:intl/intl.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';

String initialsOf(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  if (words.length == 1) return words.single[0].toUpperCase();
  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}

String joinNames(AppLocalizations l10n, List<String> names) {
  if (names.isEmpty) return '';
  if (names.length == 1) return names.single;
  final leading = names.sublist(0, names.length - 1).join(', ');
  return '$leading${l10n.clientHomeNamesListLastSeparator}${names.last}';
}

String formatWeekday(AppLocalizations l10n, DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => l10n.clientHomeWeekdayMonday,
    DateTime.tuesday => l10n.clientHomeWeekdayTuesday,
    DateTime.wednesday => l10n.clientHomeWeekdayWednesday,
    DateTime.thursday => l10n.clientHomeWeekdayThursday,
    DateTime.friday => l10n.clientHomeWeekdayFriday,
    DateTime.saturday => l10n.clientHomeWeekdaySaturday,
    _ => l10n.clientHomeWeekdaySunday,
  };
}

String formatShortWeekday(AppLocalizations l10n, DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => l10n.clientHomeWeekdayShortMonday,
    DateTime.tuesday => l10n.clientHomeWeekdayShortTuesday,
    DateTime.wednesday => l10n.clientHomeWeekdayShortWednesday,
    DateTime.thursday => l10n.clientHomeWeekdayShortThursday,
    DateTime.friday => l10n.clientHomeWeekdayShortFriday,
    DateTime.saturday => l10n.clientHomeWeekdayShortSaturday,
    _ => l10n.clientHomeWeekdayShortSunday,
  };
}

String formatDateLine(AppLocalizations l10n, DateTime date) {
  return l10n.clientHomeDateLine(
    formatWeekday(l10n, date),
    date.day,
    DateFormat.MMMM(l10n.localeName).format(date),
  );
}

String formatTimeOfDay(AppLocalizations l10n, DateTime moment) {
  return l10n.clientHomeTimeOfDay(
    '${moment.hour}',
    moment.minute.toString().padLeft(2, '0'),
  );
}

String formatClockTime(DateTime moment) => DateFormat.Hm().format(moment);

String formatTimeWindow(AppLocalizations l10n, DateTime start, DateTime end) {
  return '${formatTimeOfDay(l10n, start)}–${formatTimeOfDay(l10n, end)}';
}

String formatDayMonth(DateTime date) => DateFormat('dd/MM').format(date);

String formatMonthName(AppLocalizations l10n, DateTime date) {
  return DateFormat.MMMM(l10n.localeName).format(date);
}

String formatMoney(AppLocalizations l10n, int cents) {
  final format = NumberFormat.currency(
    locale: l10n.localeName,
    symbol: r'R$',
    decimalDigits: cents % 100 == 0 ? 0 : 2,
  );
  return format.format(cents / 100);
}

int calendarDaysBetween(DateTime from, DateTime to) {
  final fromDay = DateTime.utc(from.year, from.month, from.day);
  final toDay = DateTime.utc(to.year, to.month, to.day);
  return toDay.difference(fromDay).inDays;
}

String formatHeadline(
  AppLocalizations l10n,
  HomeHeadline headline,
  String firstName,
) {
  return switch (headline) {
    HomeHeadline.hello => l10n.homeGreeting(firstName),
    HomeHeadline.goodMorning => l10n.clientHomeGoodMorning(firstName),
    HomeHeadline.goodAfternoon => l10n.clientHomeGoodAfternoon(firstName),
    HomeHeadline.goodEvening => l10n.clientHomeGoodEvening(firstName),
    HomeHeadline.goodWeekend => l10n.clientHomeGoodWeekend,
    HomeHeadline.vanArriving => l10n.clientHomeVanArriving,
    HomeHeadline.allGood => l10n.clientHomeAllGood,
  };
}

String formatShift(AppLocalizations l10n, SchoolShift shift) {
  return switch (shift) {
    SchoolShift.morning => l10n.clientHomeShiftMorning,
    SchoolShift.afternoon => l10n.clientHomeShiftAfternoon,
  };
}

String formatLeg(AppLocalizations l10n, TripLeg leg) {
  return switch (leg) {
    TripLeg.going => l10n.clientHomeLegGoing,
    TripLeg.returning => l10n.clientHomeLegReturning,
  };
}

String formatStage(AppLocalizations l10n, TripStage stage) {
  return switch (stage) {
    TripStage.boarding => l10n.clientHomeStageBoarding,
    TripStage.school => l10n.clientHomeStageSchool,
    TripStage.departure => l10n.clientHomeStageDeparture,
    TripStage.home => l10n.clientHomeStageHome,
  };
}

String formatMilestone(AppLocalizations l10n, DayMilestoneKind kind) {
  return switch (kind) {
    DayMilestoneKind.homeBoarding => l10n.clientHomeMilestoneHomeBoarding,
    DayMilestoneKind.schoolArrival => l10n.clientHomeMilestoneSchoolArrival,
    DayMilestoneKind.schoolDeparture => l10n.clientHomeMilestoneSchoolDeparture,
    DayMilestoneKind.homeArrival => l10n.clientHomeMilestoneHomeArrival,
  };
}

String formatStopChange(AppLocalizations l10n, StopChange change) {
  return switch (change.leg) {
    TripLeg.going => l10n.clientHomeStopChangeGoing(
      change.childName,
      change.placeLabel,
    ),
    TripLeg.returning => l10n.clientHomeStopChangeReturning(
      change.childName,
      change.placeLabel,
    ),
  };
}

String formatShortcut(AppLocalizations l10n, HomeShortcut shortcut) {
  return switch (shortcut) {
    HomeShortcut.reportAbsence => l10n.clientHomeShortcutReportAbsence,
    HomeShortcut.seeOnMap => l10n.clientHomeShortcutSeeOnMap,
    HomeShortcut.adjustStop => l10n.clientHomeShortcutAdjustStop,
    HomeShortcut.payments => l10n.clientHomeShortcutPayments,
    HomeShortcut.proposals => l10n.clientHomeShortcutProposals,
    HomeShortcut.contracts => l10n.clientHomeShortcutContracts,
  };
}
