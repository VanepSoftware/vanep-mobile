import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/formatters/weekday_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/request_schools.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';

String formatRequestChildren(
  AppLocalizations l10n,
  ClientServiceRequest request,
) {
  return joinFirstNames(l10n, request.items.map((item) => item.dependentName));
}

String formatSchoolGroupLine(
  AppLocalizations l10n,
  SchoolGroup<ClientRequestItem> group,
) {
  final children = l10n.clientProposalsForChild(
    joinFirstNames(l10n, group.items.map((item) => item.dependentName)),
  );
  final school = group.schoolName;
  if (school == null) return children;
  final shift = formatSchoolShift(l10n, group);
  final schoolAndShift = shift == null
      ? school
      : l10n.clientProposalsSchoolAndShift(school, shift);
  return '$children · $schoolAndShift';
}

String formatProposalStartDate(AppLocalizations l10n, DateTime startsOn) {
  final day = startsOn.day == 1
      ? l10n.clientProposalsFirstDayOfMonth
      : '${startsOn.day}';
  final month = withoutAbbreviationDot(
    DateFormat.MMM(l10n.localeName).format(startsOn),
  );
  return l10n.clientProposalsStartingOn(
    l10n.clientProposalsDayMonth(day, month),
  );
}

String formatRequestedDaysAndStart(
  AppLocalizations l10n,
  ClientServiceRequest request,
  DateTime startsOn,
) {
  final weekdays = formatWeekdayList(l10n, requestedWeekdays(request.items));
  return '$weekdays · ${formatProposalStartDate(l10n, startsOn)}';
}

String formatProposalRating(AppLocalizations l10n, double rating) {
  return NumberFormat('0.0', l10n.localeName).format(rating);
}

String formatProposalExpiry(
  AppLocalizations l10n,
  DateTime validUntil,
  DateTime now,
) {
  final daysLeft = calendarDaysBetween(now, validUntil.toLocal());
  return l10n.clientProposalsExpiresIn(daysLeft < 0 ? 0 : daysLeft);
}

String formatSentRequestSummary(
  AppLocalizations l10n,
  ClientServiceRequest request,
  DateTime now,
) {
  final daysAgo = calendarDaysBetween(request.createdAt.toLocal(), now);
  return l10n.clientProposalsSentSummary(
    formatRequestChildren(l10n, request),
    l10n.clientProposalsSentDaysAgo(daysAgo < 0 ? 0 : daysAgo),
  );
}

String formatAnswerHoursLeft(
  AppLocalizations l10n,
  DateTime expiresAt,
  DateTime now,
) {
  final hoursLeft = expiresAt.difference(now).inHours;
  return l10n.clientProposalsHoursLeft(hoursLeft < 0 ? 0 : hoursLeft);
}

String formatChildOpenSummary(AppLocalizations l10n, ProposalsFeed feed) {
  final toAnswer = feed.pending.length;
  final awaiting = feed.awaiting.length;
  if (toAnswer == 0 && awaiting == 0) return l10n.clientProposalsOpenCount(0);
  return [
    if (toAnswer > 0) l10n.clientProposalsToAnswer(toAnswer),
    if (awaiting > 0) l10n.clientProposalsAwaitingCount(awaiting),
  ].join(' · ');
}

String? formatChildAge(AppLocalizations l10n, Dependent child, DateTime today) {
  final years = findAgeInYears(child.birthDate, today: today);
  return years == null ? null : l10n.dependentsAgeYears(years);
}
