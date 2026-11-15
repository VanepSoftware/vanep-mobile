import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/formatters/installments_formatter.dart';
import 'package:vanep_mobile/core/formatters/weekday_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/legs_summary.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/request_schools.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';

String formatRequestChild(
  AppLocalizations l10n,
  RequestItem item,
  DateTime today,
) {
  final (name, age) = switch (item) {
    ClientRequestItem() => (
      item.dependentName,
      findAgeInYears(item.dependentBirthDate, today: today),
    ),
    DriverRequestItem() => (item.dependentFirstName, item.dependentAge),
    _ => ('', null),
  };
  if (age == null) return name;
  return l10n.negotiationChatChildWithAge(name, l10n.dependentsAgeYears(age));
}

String? formatRequestSchool(AppLocalizations l10n, RequestItem item) {
  final group = groupItemsBySchool([item]).single;
  final school = group.schoolName;
  if (school == null) return null;
  final shift = formatSchoolShift(l10n, group);
  return shift == null
      ? school
      : l10n.clientProposalsSchoolAndShift(school, shift);
}

List<String> formatRequestDays(AppLocalizations l10n, List<RequestedDay> days) {
  final weekdaysBySummary = <LegsSummary, List<Weekday>>{};
  for (final day in days) {
    final summary = summarizeLegsOfDay(
      needsOutbound: day.needsOutbound,
      needsReturn: day.needsReturn,
    );
    if (summary != null) {
      weekdaysBySummary.putIfAbsent(summary, () => []).add(day.weekday);
    }
  }
  return [
    for (final summary in LegsSummary.values)
      if (weekdaysBySummary[summary] case final weekdays?)
        '${formatWeekdayList(l10n, [for (final weekday in Weekday.values)
          if (weekdays.contains(weekday)) weekday])} · ${legsSummaryLabel(l10n, summary)}',
  ];
}

String formatOpenProposalBanner(AppLocalizations l10n, Proposal proposal) {
  return l10n.negotiationChatBanner(
    proposal.version,
    formatInstallments(
      l10n,
      proposal.installments,
      proposal.installmentAmountCents,
    ),
    formatDayAndMonth(l10n, proposal.validUntil),
  );
}

String formatChatDay(AppLocalizations l10n, DateTime day, DateTime today) {
  return switch (calendarDaysBetween(day, today)) {
    0 => l10n.negotiationChatToday,
    1 => l10n.negotiationChatYesterday,
    _ => formatCalendarDate(l10n, day),
  };
}
