import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/formatters/weekday_label.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/leg_times.dart';
import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/formatters/school_shift_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/legs_summary.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/request_schools.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';

String adjustmentPolicyLabel(
  AppLocalizations l10n,
  ProposalAdjustmentPolicy policy,
) {
  return switch (policy) {
    ProposalAdjustmentPolicy.none => l10n.negotiationAdjustmentPolicyNone,
    ProposalAdjustmentPolicy.ipcaAtRenewal =>
      l10n.negotiationAdjustmentPolicyIpcaAtRenewal,
  };
}

String cancellationPolicyLabel(
  AppLocalizations l10n,
  ProposalCancellationPolicy policy,
) {
  return switch (policy) {
    ProposalCancellationPolicy.notice30Days =>
      l10n.negotiationCancellationNotice30Days,
    ProposalCancellationPolicy.notice30DaysWithFee =>
      l10n.negotiationCancellationNotice30DaysWithFee,
  };
}

String adjustmentFieldLabel(
  AppLocalizations l10n,
  ProposalAdjustmentField field,
) {
  return switch (field) {
    ProposalAdjustmentField.price => l10n.negotiationAdjustmentFieldPrice,
    ProposalAdjustmentField.installments =>
      l10n.negotiationAdjustmentFieldInstallments,
    ProposalAdjustmentField.schedule => l10n.negotiationAdjustmentFieldSchedule,
    ProposalAdjustmentField.period => l10n.negotiationAdjustmentFieldPeriod,
    ProposalAdjustmentField.other => l10n.negotiationAdjustmentFieldOther,
  };
}

String clientTurnLabel(AppLocalizations l10n, ClientTurn turn) {
  return switch (turn) {
    ClientTurn.requestSent => l10n.negotiationClientTurnRequestSent,
    ClientTurn.proposalReceived => l10n.negotiationClientTurnProposalReceived,
    ClientTurn.adjustmentRequested =>
      l10n.negotiationClientTurnAdjustmentRequested,
    ClientTurn.accepted => l10n.negotiationClientTurnAccepted,
    ClientTurn.declinedByDriver => l10n.negotiationClientTurnDeclinedByDriver,
    ClientTurn.closedByClient => l10n.negotiationClientTurnClosedByClient,
    ClientTurn.expired => l10n.negotiationClientTurnExpired,
  };
}

String routeLegLabel(AppLocalizations l10n, RouteLeg leg) {
  return switch (leg) {
    RouteLeg.outbound => l10n.negotiationLegOutbound,
    RouteLeg.homebound => l10n.negotiationLegHomebound,
  };
}

String legsSummaryLabel(AppLocalizations l10n, LegsSummary summary) {
  return switch (summary) {
    LegsSummary.roundTrip => l10n.negotiationLegsRoundTrip,
    LegsSummary.outboundOnly => l10n.negotiationLegsOutboundOnly,
    LegsSummary.homeboundOnly => l10n.negotiationLegsHomeboundOnly,
    LegsSummary.mixed => l10n.negotiationLegsMixed,
  };
}

String negotiationFailureMessage(
  AppLocalizations l10n,
  NegotiationFailure failure,
) {
  return switch (failure) {
    NegotiationNetworkFailure() => l10n.negotiationFailureNetwork,
    NegotiationNotFoundFailure() => l10n.negotiationFailureNotFound,
    NegotiationInvalidFailure() => l10n.negotiationFailureInvalid,
    NegotiationConflictFailure(:final detail) ||
    NegotiationRejectedFailure(
      :final detail,
    ) when detail.trim().isNotEmpty => detail,
    _ => l10n.negotiationFailureUnexpected,
  };
}

String proposalStatusLabel(AppLocalizations l10n, ProposalStatus status) {
  return switch (status) {
    ProposalStatus.sent => l10n.negotiationProposalStatusSent,
    ProposalStatus.accepted => l10n.negotiationProposalStatusAccepted,
    ProposalStatus.superseded => l10n.negotiationProposalStatusSuperseded,
    ProposalStatus.declined => l10n.negotiationProposalStatusDeclined,
    ProposalStatus.expired => l10n.negotiationProposalStatusExpired,
    ProposalStatus.withdrawn => l10n.negotiationProposalStatusWithdrawn,
  };
}

String formatProposalPeriod(AppLocalizations l10n, Proposal proposal) {
  return formatCalendarRange(l10n, proposal.startsOn, proposal.endsOn);
}

String formatClockTime(ClockTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String formatProposalVehicle(AppLocalizations l10n, ProposalVehicle vehicle) {
  return l10n.negotiationVehicle(
    vehicle.model,
    vehicle.manufactureYear,
    vehicle.capacity,
  );
}

String negotiationEventTitle(AppLocalizations l10n, NegotiationEvent event) {
  return switch (event) {
    RequestSentEvent() => l10n.negotiationHistoryRequestSent,
    ProposalSentEvent(:final version) => l10n.proposalDetailVersion(version),
    AdjustmentRequestedEvent(:final field, :final suggestedValue) =>
      l10n.negotiationHistoryAdjustment(
        suggestedValue != null && suggestedValue.trim().isNotEmpty
            ? suggestedValue.trim()
            : adjustmentFieldLabel(l10n, field),
      ),
    ProposalAcceptedEvent() => l10n.negotiationHistoryAccepted,
    ProposalDeclinedEvent() => l10n.negotiationHistoryDeclined,
    RequestDeclinedEvent() => l10n.negotiationHistoryRequestDeclined,
  };
}

String? formatSchoolShift(AppLocalizations l10n, SchoolGroup group) {
  final shift = group.shift;
  if (shift != null) return formatShift(l10n, shift);
  return group.hasVaryingShift ? l10n.negotiationShiftVaries : null;
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
  ServiceRequest request,
  DateTime startsOn,
) {
  final weekdays = formatWeekdayList(l10n, requestedWeekdays(request.items));
  return '$weekdays · ${formatProposalStartDate(l10n, startsOn)}';
}

String formatProposalExpiry(
  AppLocalizations l10n,
  DateTime validUntil,
  DateTime now,
) {
  final daysLeft = calendarDaysBetween(now, validUntil.toLocal());
  return l10n.clientProposalsExpiresIn(daysLeft < 0 ? 0 : daysLeft);
}

String formatWeekdayTime(
  AppLocalizations l10n,
  Weekday weekday,
  ClockTime time,
) {
  return '${weekdayShortLabel(l10n, weekday)} · ${formatClockTime(time)}';
}

List<String> formatLegTimes(AppLocalizations l10n, LegTimes times) {
  final shared = times.shared;
  if (shared != null) return [formatClockTime(shared)];
  return [
    for (final MapEntry(key: weekday, value: time) in times.byDay.entries)
      formatWeekdayTime(l10n, weekday, time),
  ];
}

String formatSlotsDaysAndLegs(AppLocalizations l10n, List<ScheduleSlot> slots) {
  final weekdays = [
    for (final weekday in Weekday.values)
      if (slots.any((slot) => slot.weekday == weekday)) weekday,
  ];
  final legs = summarizeSlots(slots);
  final days = formatWeekdayList(l10n, weekdays);
  return legs == null ? days : '$days · ${legsSummaryLabel(l10n, legs)}';
}

String formatStudentDetail(
  AppLocalizations l10n,
  RequestItem item, {
  required int? ageInYears,
}) {
  final group = groupItemsBySchool([item]).single;
  return [
    if (ageInYears != null) l10n.dependentsAgeYears(ageInYears),
    if (group.schoolName case final school?)
      switch (formatSchoolShift(l10n, group)) {
        final shift? => l10n.clientProposalsSchoolAndShift(school, shift),
        null => school,
      },
  ].join(' · ');
}
