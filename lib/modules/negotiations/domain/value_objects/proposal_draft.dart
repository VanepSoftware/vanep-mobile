import 'dart:math';

import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/operation_shift.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/draft_text.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/weekday_leg.dart';

const proposalMaxInstallments = 12;

const proposalMaxDueDay = 28;

const proposalMaxPeriodMonths = 12;

const proposalMaxValidDays = 7;

const proposalMessageMaxLength = 1000;

enum ProposalDraftError {
  totalAmountRequired,
  totalBelowOneCentPerInstallment,
  installmentsOutOfRange,
  dueDayOutOfRange,
  periodRequired,
  startDateInPast,
  endNotAfterStart,
  periodTooLong,
  studentWithoutLeg,
  timeRequired,
  vehicleRequired,
  validDaysOutOfRange,
  messageTooLong,
  enrollmentFeeNegative,
}

typedef Replace<T> = T Function();

class ScheduleSlotDraft extends Equatable {
  const ScheduleSlotDraft({
    required this.weekday,
    required this.leg,
    required this.shift,
    required this.pickupTime,
  });

  final Weekday weekday;

  final RouteLeg leg;

  final OperationShift shift;

  final ClockTime pickupTime;

  @override
  List<Object?> get props => [weekday, leg, shift, pickupTime];
}

class ProposalDraftItem extends Equatable {
  const ProposalDraftItem({
    required this.dependentToken,
    this.schoolShiftByDay = const {},
    this.requestedSlots = const {},
    this.timesBySlot = const {},
  });

  factory ProposalDraftItem.fromRequestItem(RequestItem item) {
    final requestedSlots = {
      for (final day in item.days) ...[
        if (day.needsOutbound) (day.weekday, RouteLeg.outbound),
        if (day.needsReturn) (day.weekday, RouteLeg.homebound),
      ],
    };
    return ProposalDraftItem(
      dependentToken: item.dependentToken,
      schoolShiftByDay: {
        for (final day in item.days) day.weekday: day.schoolShift,
      },
      requestedSlots: requestedSlots,
      timesBySlot: {for (final slot in requestedSlots) slot: null},
    );
  }

  final String dependentToken;

  final Map<Weekday, SchoolShift?> schoolShiftByDay;

  final Set<WeekdayLeg> requestedSlots;

  final Map<WeekdayLeg, ClockTime?> timesBySlot;

  bool isRequested(Weekday weekday, RouteLeg leg) {
    return requestedSlots.contains((weekday, leg));
  }

  bool isEnabled(Weekday weekday, RouteLeg leg) {
    return timesBySlot.containsKey((weekday, leg));
  }

  ClockTime? timeOf(Weekday weekday, RouteLeg leg) {
    return timesBySlot[(weekday, leg)];
  }

  bool get hasAnyLeg => timesBySlot.isNotEmpty;

  List<ScheduleSlotDraft> get slotsToSend => [
    for (final weekday in Weekday.values)
      for (final leg in RouteLeg.values)
        if (timeOf(weekday, leg) case final time?)
          ScheduleSlotDraft(
            weekday: weekday,
            leg: leg,
            shift: deriveOperationShift(schoolShiftByDay[weekday], leg),
            pickupTime: time,
          ),
  ];

  ProposalDraftItem withLeg(
    Weekday weekday,
    RouteLeg leg, {
    required bool enabled,
  }) {
    if (!enabled) {
      return copyWith(timesBySlot: {...timesBySlot}..remove((weekday, leg)));
    }
    if (!isRequested(weekday, leg) || isEnabled(weekday, leg)) return this;
    return copyWith(timesBySlot: {...timesBySlot, (weekday, leg): null});
  }

  ProposalDraftItem withTime(Weekday weekday, RouteLeg leg, ClockTime time) {
    if (!isEnabled(weekday, leg)) return this;
    return copyWith(timesBySlot: {...timesBySlot, (weekday, leg): time});
  }

  ProposalDraftItem withTimeOnEveryDay(RouteLeg leg, ClockTime time) {
    return copyWith(
      timesBySlot: {
        for (final MapEntry(key: slot, value: current) in timesBySlot.entries)
          slot: slot.$2 == leg ? time : current,
      },
    );
  }

  ProposalDraftItem copyWith({Map<WeekdayLeg, ClockTime?>? timesBySlot}) {
    return ProposalDraftItem(
      dependentToken: dependentToken,
      schoolShiftByDay: schoolShiftByDay,
      requestedSlots: requestedSlots,
      timesBySlot: timesBySlot ?? this.timesBySlot,
    );
  }

  @override
  List<Object?> get props => [
    dependentToken,
    schoolShiftByDay,
    requestedSlots,
    timesBySlot,
  ];
}

class ProposalDraft extends Equatable {
  const ProposalDraft({
    required this.serviceRequestToken,
    this.items = const [],
    this.totalAmountCents,
    this.installments,
    this.dueDay,
    this.startsOn,
    this.endsOn,
    this.enrollmentFeeCents,
    this.adjustmentPolicy = ProposalAdjustmentPolicy.ipcaAtRenewal,
    this.cancellationPolicy = ProposalCancellationPolicy.notice30DaysWithFee,
    this.vehicleToken,
    this.validDays = proposalMaxValidDays,
    this.message = '',
  });

  factory ProposalDraft.fromRequest(ServiceRequest request) {
    return ProposalDraft(
      serviceRequestToken: request.token,
      items: [
        for (final item in request.items)
          ProposalDraftItem.fromRequestItem(item),
      ],
      startsOn: request.desiredStartDate,
    );
  }

  factory ProposalDraft.fromProposal(
    Proposal proposal,
    ServiceRequest request,
  ) {
    assert(proposal.serviceRequestToken == request.token);
    final fromRequest = ProposalDraft.fromRequest(request);
    return fromRequest.copyWith(
      items: [
        for (final item in fromRequest.items)
          fillItemFromProposal(item, proposal),
      ],
      totalAmountCents: () => proposal.totalAmountCents,
      installments: () => proposal.installments,
      dueDay: () => proposal.dueDay,
      startsOn: () => proposal.startsOn,
      endsOn: () => proposal.endsOn,
      enrollmentFeeCents: () => proposal.enrollmentFeeCents,
      adjustmentPolicy: proposal.adjustmentPolicy,
      cancellationPolicy: proposal.cancellationPolicy,
      vehicleToken: () => proposal.vehicle?.token,
    );
  }

  final String serviceRequestToken;

  final List<ProposalDraftItem> items;

  final int? totalAmountCents;

  final int? installments;

  final int? dueDay;

  final DateTime? startsOn;

  final DateTime? endsOn;

  final int? enrollmentFeeCents;

  final ProposalAdjustmentPolicy adjustmentPolicy;

  final ProposalCancellationPolicy cancellationPolicy;

  final String? vehicleToken;

  final int validDays;

  final String message;

  String? get messageToSend => trimmedOrNull(message);

  ProposalDraft withLeg(
    String dependentToken,
    Weekday weekday,
    RouteLeg leg, {
    required bool enabled,
  }) {
    return withItem(
      dependentToken,
      (item) => item.withLeg(weekday, leg, enabled: enabled),
    );
  }

  ProposalDraft withTime(
    String dependentToken,
    Weekday weekday,
    RouteLeg leg,
    ClockTime time,
  ) {
    return withItem(
      dependentToken,
      (item) => item.withTime(weekday, leg, time),
    );
  }

  ProposalDraft withTimeOnEveryDay(
    String dependentToken,
    RouteLeg leg,
    ClockTime time,
  ) {
    return withItem(
      dependentToken,
      (item) => item.withTimeOnEveryDay(leg, time),
    );
  }

  ProposalDraft withItem(
    String dependentToken,
    ProposalDraftItem Function(ProposalDraftItem item) change,
  ) {
    return copyWith(
      items: [
        for (final item in items)
          item.dependentToken == dependentToken ? change(item) : item,
      ],
    );
  }

  ProposalDraft withTotalAmount(int? value) {
    return copyWith(totalAmountCents: () => value);
  }

  ProposalDraft withInstallments(int? value) {
    return copyWith(installments: () => value);
  }

  ProposalDraft withDueDay(int? value) => copyWith(dueDay: () => value);

  ProposalDraft withStartsOn(DateTime? value) {
    return copyWith(startsOn: () => value);
  }

  ProposalDraft withEndsOn(DateTime? value) => copyWith(endsOn: () => value);

  ProposalDraft withEnrollmentFee(int? value) {
    return copyWith(enrollmentFeeCents: () => value);
  }

  ProposalDraft withAdjustmentPolicy(ProposalAdjustmentPolicy value) {
    return copyWith(adjustmentPolicy: value);
  }

  ProposalDraft withCancellationPolicy(ProposalCancellationPolicy value) {
    return copyWith(cancellationPolicy: value);
  }

  ProposalDraft withVehicle(String? value) {
    return copyWith(vehicleToken: () => value);
  }

  ProposalDraft withValidDays(int value) => copyWith(validDays: value);

  ProposalDraft withMessage(String value) => copyWith(message: value);

  ProposalDraft copyWith({
    List<ProposalDraftItem>? items,
    Replace<int?>? totalAmountCents,
    Replace<int?>? installments,
    Replace<int?>? dueDay,
    Replace<DateTime?>? startsOn,
    Replace<DateTime?>? endsOn,
    Replace<int?>? enrollmentFeeCents,
    ProposalAdjustmentPolicy? adjustmentPolicy,
    ProposalCancellationPolicy? cancellationPolicy,
    Replace<String?>? vehicleToken,
    int? validDays,
    String? message,
  }) {
    return ProposalDraft(
      serviceRequestToken: serviceRequestToken,
      items: items ?? this.items,
      totalAmountCents: totalAmountCents != null
          ? totalAmountCents()
          : this.totalAmountCents,
      installments: installments != null ? installments() : this.installments,
      dueDay: dueDay != null ? dueDay() : this.dueDay,
      startsOn: startsOn != null ? startsOn() : this.startsOn,
      endsOn: endsOn != null ? endsOn() : this.endsOn,
      enrollmentFeeCents: enrollmentFeeCents != null
          ? enrollmentFeeCents()
          : this.enrollmentFeeCents,
      adjustmentPolicy: adjustmentPolicy ?? this.adjustmentPolicy,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      vehicleToken: vehicleToken != null ? vehicleToken() : this.vehicleToken,
      validDays: validDays ?? this.validDays,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    serviceRequestToken,
    items,
    totalAmountCents,
    installments,
    dueDay,
    startsOn,
    endsOn,
    enrollmentFeeCents,
    adjustmentPolicy,
    cancellationPolicy,
    vehicleToken,
    validDays,
    message,
  ];
}

ProposalDraftItem fillItemFromProposal(
  ProposalDraftItem item,
  Proposal proposal,
) {
  final proposalItem = proposal.items
      .where((candidate) => candidate.dependentToken == item.dependentToken)
      .firstOrNull;
  if (proposalItem == null) return item;
  return item.copyWith(
    timesBySlot: {
      for (final slot in proposalItem.slots)
        if (item.isRequested(slot.weekday, slot.leg))
          (slot.weekday, slot.leg): slot.pickupTime,
    },
  );
}

DateTime addCalendarMonths(DateTime date, int months) {
  final monthIndex = date.month - 1 + months;
  final year = date.year + monthIndex ~/ 12;
  final month = monthIndex % 12 + 1;
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, min(date.day, lastDayOfMonth));
}

bool isWithin(int? value, int lowest, int highest) {
  return value != null && value >= lowest && value <= highest;
}

bool isBelowOneCentPerInstallment(int? totalCents, int? installments) {
  return totalCents != null &&
      totalCents > 0 &&
      isWithin(installments, 1, proposalMaxInstallments) &&
      totalCents < installments!;
}

Set<ProposalDraftError> validateProposalDraft(
  ProposalDraft draft, {
  required DateTime today,
}) {
  return {
    if ((draft.totalAmountCents ?? 0) <= 0)
      ProposalDraftError.totalAmountRequired,
    if (isBelowOneCentPerInstallment(
      draft.totalAmountCents,
      draft.installments,
    ))
      ProposalDraftError.totalBelowOneCentPerInstallment,
    if (!isWithin(draft.installments, 1, proposalMaxInstallments))
      ProposalDraftError.installmentsOutOfRange,
    if (!isWithin(draft.dueDay, 1, proposalMaxDueDay))
      ProposalDraftError.dueDayOutOfRange,
    ...findPeriodErrors(draft.startsOn, draft.endsOn, today: today),
    if (draft.items.any((item) => !item.hasAnyLeg))
      ProposalDraftError.studentWithoutLeg,
    if (draft.items.any((item) => item.timesBySlot.containsValue(null)))
      ProposalDraftError.timeRequired,
    if ((draft.vehicleToken ?? '').trim().isEmpty)
      ProposalDraftError.vehicleRequired,
    if (!isWithin(draft.validDays, 1, proposalMaxValidDays))
      ProposalDraftError.validDaysOutOfRange,
    if (isLongerThan(draft.message, proposalMessageMaxLength))
      ProposalDraftError.messageTooLong,
    if ((draft.enrollmentFeeCents ?? 0) < 0)
      ProposalDraftError.enrollmentFeeNegative,
  };
}

Set<ProposalDraftError> findPeriodErrors(
  DateTime? startsOn,
  DateTime? endsOn, {
  required DateTime today,
}) {
  if (startsOn == null || endsOn == null) {
    return {ProposalDraftError.periodRequired};
  }
  final latestEnd = addCalendarMonths(startsOn, proposalMaxPeriodMonths);
  return {
    if (calendarDaysBetween(today, startsOn) < 0)
      ProposalDraftError.startDateInPast,
    if (calendarDaysBetween(startsOn, endsOn) <= 0)
      ProposalDraftError.endNotAfterStart
    else if (calendarDaysBetween(latestEnd, endsOn) > 0)
      ProposalDraftError.periodTooLong,
  };
}
