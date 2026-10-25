import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/formatters/calendar_labels.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/formatters/school_shift_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/conversation_labels.dart';

const weekdayKeys = {
  DateTime.monday: 'monday',
  DateTime.tuesday: 'tuesday',
  DateTime.wednesday: 'wednesday',
  DateTime.thursday: 'thursday',
  DateTime.friday: 'friday',
  DateTime.saturday: 'saturday',
  DateTime.sunday: 'sunday',
};

String formatCounterpartRole(
  AppLocalizations l10n,
  ConversationParticipant viewerSide,
  ConversationNegotiation negotiation,
) {
  if (viewerSide == ConversationParticipant.driver) {
    return l10n.conversationRoleClient;
  }
  final proposal = negotiation.currentProposal;
  if (proposal == null) return l10n.conversationRoleDriver;
  return '${l10n.conversationRoleDriver} · '
      '${proposal.vehicleModel} ${proposal.vehicleYear}';
}

String formatChatDay(AppLocalizations l10n, DateTime day) =>
    DateFormat.MMMMd(l10n.localeName).format(day);

String formatShortDate(DateTime date) => DateFormat('dd/MM').format(date);

String formatQuoteRequestChild(
  AppLocalizations l10n,
  QuoteRequestEvent request,
) {
  final age = request.childAge;
  final child = age == null
      ? request.childName
      : l10n.conversationNegotiationChildWithAge(request.childName, age);
  final school = l10n.clientProposalsSchoolAndShift(
    request.schoolName,
    formatShift(l10n, request.shift),
  );
  return '$child · $school';
}

String formatOneWayWeekdays(AppLocalizations l10n, List<int> weekdays) {
  final names = ([...weekdays]..sort()).map(
    (weekday) => l10n.conversationNegotiationWeekday(weekdayKeys[weekday]!),
  );
  return l10n.conversationNegotiationOneWayOn(names.join(', '));
}

String formatQuoteRequestSchedule(
  AppLocalizations l10n,
  QuoteRequestEvent request,
) {
  final weekdays = formatWeekdays(l10n, request.weekdays);
  if (request.oneWayWeekdays.isEmpty) return weekdays;
  return '$weekdays · ${formatOneWayWeekdays(l10n, request.oneWayWeekdays)}';
}

String formatQuoteRequestStart(
  AppLocalizations l10n,
  QuoteRequestEvent request,
) => capitalizeFirst(formatStartingOn(l10n, request.startsOn));

String formatQuoteRequestBoarding(
  AppLocalizations l10n,
  QuoteRequestEvent request,
) => l10n.conversationNegotiationBoardingAt(request.boardingPlace);

String formatMonthlyFee(AppLocalizations l10n, int cents) =>
    '${formatMoney(l10n, cents)}${l10n.clientProposalsPerMonth}';

String formatProposalInstallments(
  AppLocalizations l10n,
  ProposalVersionEvent proposal,
) => l10n.conversationNegotiationInstallments(
  proposal.installments,
  proposal.dueDay,
);

String formatProposalPeriod(
  AppLocalizations l10n,
  ProposalVersionEvent proposal,
) {
  final end = proposal.endsOn;
  return l10n.conversationNegotiationPeriod(
    formatDayMonth(l10n, proposal.startsOn),
    '${formatDayMonth(l10n, end)} ${end.year}',
  );
}

String formatProposalExpiry(
  AppLocalizations l10n,
  ProposalVersionEvent proposal,
) => l10n.conversationNegotiationExpiresOn(formatShortDate(proposal.expiresAt));

String formatProposalBannerTerms(
  AppLocalizations l10n,
  ProposalVersionEvent proposal,
) {
  final expiry = l10n.conversationNegotiationBannerExpiry(
    formatShortDate(proposal.expiresAt),
  );
  return ' · ${formatMonthlyFee(l10n, proposal.monthlyFeeCents)} · $expiry';
}

String formatSentByViewer(AppLocalizations l10n, NegotiationEvent event) => l10n
    .conversationNegotiationSentByYou(formatConversationTime(event.occurredAt));
