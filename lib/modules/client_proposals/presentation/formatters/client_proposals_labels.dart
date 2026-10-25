import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/formatters/calendar_labels.dart';
import 'package:vanep_mobile/core/formatters/school_shift_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposal.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';

String formatProposalRating(AppLocalizations l10n, double rating) {
  return NumberFormat('0.0', l10n.localeName).format(rating);
}

String formatDriverReputation(AppLocalizations l10n, ProposalDriver driver) {
  final rating = driver.rating;
  final vehicle = '${driver.vehicleModel} ${driver.vehicleYear}';
  if (rating == null) {
    final gender = driver.gender == Gender.female ? 'female' : 'other';
    return '${l10n.clientProposalsNewOnVanep(gender)} · $vehicle';
  }
  return '${formatProposalRating(l10n, rating)} · $vehicle';
}

String formatProposalChildAndSchool(
  AppLocalizations l10n,
  PendingProposal proposal,
) {
  final school = l10n.clientProposalsSchoolAndShift(
    proposal.schoolName,
    formatShift(l10n, proposal.shift),
  );
  return '${l10n.clientProposalsForChild(proposal.childName)} · $school';
}

String formatProposalSchedule(AppLocalizations l10n, PendingProposal proposal) {
  final weekdays = formatWeekdays(l10n, proposal.weekdays);
  return '$weekdays · ${formatStartingOn(l10n, proposal.startsOn)}';
}

String formatProposalExpiry(
  AppLocalizations l10n,
  DateTime expiresAt,
  DateTime now,
) {
  final daysLeft = calendarDaysBetween(now, expiresAt);
  return l10n.clientProposalsExpiresIn(daysLeft < 0 ? 0 : daysLeft);
}

String formatSentRequestSummary(
  AppLocalizations l10n,
  SentRequest request,
  DateTime now,
) {
  final daysAgo = calendarDaysBetween(request.sentAt, now);
  return l10n.clientProposalsSentSummary(
    request.childName,
    l10n.clientProposalsSentDaysAgo(daysAgo < 0 ? 0 : daysAgo),
  );
}

String formatAnswerHoursLeft(
  AppLocalizations l10n,
  DateTime answerBy,
  DateTime now,
) {
  final hoursLeft = answerBy.difference(now).inHours;
  return l10n.clientProposalsHoursLeft(hoursLeft < 0 ? 0 : hoursLeft);
}

String formatProposalOutcome(AppLocalizations l10n, ProposalOutcome outcome) {
  return switch (outcome) {
    ProposalOutcome.accepted => l10n.clientProposalsOutcomeAccepted,
    ProposalOutcome.declined => l10n.clientProposalsOutcomeDeclined,
    ProposalOutcome.expired => l10n.clientProposalsOutcomeExpired,
    ProposalOutcome.cancelled => l10n.clientProposalsOutcomeCancelled,
  };
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

String? formatChildAge(
  AppLocalizations l10n,
  ProposalChild child,
  DateTime today,
) {
  final years = findAgeInYears(child.birthDate, today: today);
  return years == null ? null : l10n.dependentsAgeYears(years);
}
