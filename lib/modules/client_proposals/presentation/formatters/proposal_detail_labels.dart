import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/formatters/installments_formatter.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/formatters/weekday_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/legs_summary.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/leg_times.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_comparison.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/request_schools.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';

String formatProposalPeriod(AppLocalizations l10n, Proposal proposal) {
  return formatCalendarRange(l10n, proposal.startsOn, proposal.endsOn);
}

String formatStudentDetail(
  AppLocalizations l10n,
  ClientRequestItem item,
  DateTime today,
) {
  final years = findAgeInYears(item.dependentBirthDate, today: today);
  final group = groupItemsBySchool([item]).single;
  return [
    if (years != null) l10n.dependentsAgeYears(years),
    if (group.schoolName case final school?)
      switch (formatSchoolShift(l10n, group)) {
        final shift? => l10n.clientProposalsSchoolAndShift(school, shift),
        null => school,
      },
  ].join(' · ');
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

String comparisonFieldLabel(
  AppLocalizations l10n,
  ProposalComparisonField field,
) {
  return switch (field) {
    ProposalComparisonField.amount => l10n.proposalComparisonAmount,
    ProposalComparisonField.installments => l10n.proposalComparisonInstallments,
    ProposalComparisonField.period => l10n.proposalDetailPeriod,
    ProposalComparisonField.dueDay => l10n.proposalDetailDueDay,
    ProposalComparisonField.enrollmentFee => l10n.proposalDetailEnrollmentFee,
    ProposalComparisonField.adjustmentPolicy => l10n.proposalDetailAdjustment,
    ProposalComparisonField.cancellationPolicy =>
      l10n.proposalDetailCancellation,
    ProposalComparisonField.daysAndLegs => l10n.proposalDetailDaysTitle,
    ProposalComparisonField.schedule => l10n.proposalDetailScheduleTitle,
    ProposalComparisonField.vehicle => l10n.proposalComparisonVehicle,
  };
}

List<String> proposalDaysAndLegsLines(
  AppLocalizations l10n,
  Proposal proposal,
) {
  return {
    for (final item in proposal.items) formatSlotsDaysAndLegs(l10n, item.slots),
  }.toList();
}

String formatProposalDaysAndLegs(AppLocalizations l10n, Proposal proposal) {
  return proposalDaysAndLegsLines(l10n, proposal).join(' / ');
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

List<String> proposalScheduleLines(AppLocalizations l10n, Proposal proposal) {
  return {
    for (final item in proposal.items)
      for (final leg in RouteLeg.values)
        ...formatLegTimes(
          l10n,
          timesOfLeg(item.slots, leg),
        ).map((time) => '${routeLegLabel(l10n, leg)} $time'),
  }.toList();
}

List<String> formatComparisonLines(
  AppLocalizations l10n,
  ProposalComparisonField field,
  Proposal proposal,
) {
  return switch (field) {
    ProposalComparisonField.daysAndLegs => proposalDaysAndLegsLines(
      l10n,
      proposal,
    ),
    _ => [formatComparisonValue(l10n, field, proposal)],
  };
}

String formatScheduleChangeTitle(
  AppLocalizations l10n,
  ScheduleChange change, {
  required bool namesChild,
}) {
  return [
    if (namesChild) joinNames(l10n, change.dependentFirstNames),
    routeLegLabel(l10n, change.leg),
    formatWeekdayList(l10n, change.weekdays),
  ].join(' · ');
}

String formatComparisonValue(
  AppLocalizations l10n,
  ProposalComparisonField field,
  Proposal proposal,
) {
  return switch (field) {
    ProposalComparisonField.amount => formatInstallments(
      l10n,
      proposal.installments,
      proposal.installmentAmountCents,
    ),
    ProposalComparisonField.installments =>
      l10n.proposalComparisonInstallmentsValue(proposal.installments),
    ProposalComparisonField.period => formatProposalPeriod(l10n, proposal),
    ProposalComparisonField.dueDay => l10n.proposalDetailDueDayValue(
      proposal.dueDay,
    ),
    ProposalComparisonField.enrollmentFee =>
      switch (proposal.enrollmentFeeCents) {
        final fee? => formatMoney(l10n, fee),
        null => l10n.proposalComparisonNoFee,
      },
    ProposalComparisonField.adjustmentPolicy => adjustmentPolicyLabel(
      l10n,
      proposal.adjustmentPolicy,
    ),
    ProposalComparisonField.cancellationPolicy => cancellationPolicyLabel(
      l10n,
      proposal.cancellationPolicy,
    ),
    ProposalComparisonField.daysAndLegs => formatProposalDaysAndLegs(
      l10n,
      proposal,
    ),
    ProposalComparisonField.schedule => proposalScheduleLines(
      l10n,
      proposal,
    ).join(', '),
    ProposalComparisonField.vehicle => switch (proposal.vehicle) {
      final vehicle? => formatProposalVehicle(l10n, vehicle),
      null => l10n.proposalComparisonNoVehicle,
    },
  };
}
