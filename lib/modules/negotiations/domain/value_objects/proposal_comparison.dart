import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/weekday_leg.dart';

enum ProposalComparisonField {
  amount,
  installments,
  period,
  dueDay,
  enrollmentFee,
  adjustmentPolicy,
  cancellationPolicy,
  daysAndLegs,
  schedule,
  vehicle,
}

typedef DependentSlot = (String dependentToken, WeekdayLeg slot);

List<ProposalComparisonField> compareProposalVersions(
  Proposal previous,
  Proposal current,
) {
  return [
    for (final field in ProposalComparisonField.values)
      if (hasFieldChanged(field, previous, current)) field,
  ];
}

bool hasFieldChanged(
  ProposalComparisonField field,
  Proposal previous,
  Proposal current,
) {
  return switch (field) {
    ProposalComparisonField.amount => hasAmountChanged(previous, current),
    ProposalComparisonField.installments =>
      previous.installments != current.installments,
    ProposalComparisonField.period =>
      previous.startsOn != current.startsOn ||
          previous.endsOn != current.endsOn,
    ProposalComparisonField.dueDay => previous.dueDay != current.dueDay,
    ProposalComparisonField.enrollmentFee =>
      previous.enrollmentFeeCents != current.enrollmentFeeCents,
    ProposalComparisonField.adjustmentPolicy =>
      previous.adjustmentPolicy != current.adjustmentPolicy,
    ProposalComparisonField.cancellationPolicy =>
      previous.cancellationPolicy != current.cancellationPolicy,
    ProposalComparisonField.daysAndLegs => !haveSameKeys(
      findTimesByDependentSlot(previous),
      findTimesByDependentSlot(current),
    ),
    ProposalComparisonField.schedule => hasScheduleChanged(previous, current),
    ProposalComparisonField.vehicle =>
      previous.vehicle?.plate != current.vehicle?.plate,
  };
}

class PriceChange extends Equatable {
  const PriceChange({
    required this.totalDifferenceCents,
    required this.previousInstallments,
    required this.currentInstallments,
  });

  final int totalDifferenceCents;

  final int previousInstallments;

  final int currentInstallments;

  bool get hasTotalChanged => totalDifferenceCents != 0;

  bool get isCheaper => totalDifferenceCents < 0;

  bool get hasInstallmentsChanged =>
      previousInstallments != currentInstallments;

  bool get isEmpty => !hasTotalChanged && !hasInstallmentsChanged;

  @override
  List<Object?> get props => [
    totalDifferenceCents,
    previousInstallments,
    currentInstallments,
  ];
}

PriceChange comparePrices(Proposal previous, Proposal current) {
  return PriceChange(
    totalDifferenceCents: current.totalAmountCents - previous.totalAmountCents,
    previousInstallments: previous.installments,
    currentInstallments: current.installments,
  );
}

bool hasAmountChanged(Proposal previous, Proposal current) {
  return previous.totalAmountCents != current.totalAmountCents ||
      previous.installmentAmountCents != current.installmentAmountCents;
}

Map<DependentSlot, ClockTime> findTimesByDependentSlot(Proposal proposal) {
  return {
    for (final item in proposal.items)
      for (final slot in item.slots)
        (item.dependentToken, (slot.weekday, slot.leg)): slot.pickupTime,
  };
}

bool hasScheduleChanged(Proposal previous, Proposal current) {
  return findScheduleChanges(previous, current).isNotEmpty;
}

typedef TimeChange = (ClockTime before, ClockTime after);

class ScheduleChange extends Equatable {
  const ScheduleChange({
    required this.dependentFirstNames,
    required this.leg,
    required this.weekdays,
    required this.before,
    required this.after,
  });

  final List<String> dependentFirstNames;

  final RouteLeg leg;

  final List<Weekday> weekdays;

  final ClockTime before;

  final ClockTime after;

  bool isSameChangeAs(ScheduleChange other) {
    return leg == other.leg &&
        before == other.before &&
        after == other.after &&
        haveSameWeekdays(weekdays, other.weekdays);
  }

  ScheduleChange withDependent(String firstName) {
    return ScheduleChange(
      dependentFirstNames: [...dependentFirstNames, firstName],
      leg: leg,
      weekdays: weekdays,
      before: before,
      after: after,
    );
  }

  @override
  List<Object?> get props => [
    dependentFirstNames,
    leg,
    weekdays,
    before,
    after,
  ];
}

bool haveSameWeekdays(List<Weekday> first, List<Weekday> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}

Map<TimeChange, List<Weekday>> findLegChangesOfItem(
  ProposalItem item,
  RouteLeg leg,
  Map<DependentSlot, ClockTime> previousTimes,
) {
  final weekdaysByChange = <TimeChange, List<Weekday>>{};
  for (final weekday in Weekday.values) {
    final slot = item.slots.where(
      (slot) => slot.weekday == weekday && slot.leg == leg,
    );
    if (slot.isEmpty) continue;
    final before = previousTimes[(item.dependentToken, (weekday, leg))];
    final after = slot.first.pickupTime;
    if (before == null || before == after) continue;
    weekdaysByChange.putIfAbsent((before, after), () => []).add(weekday);
  }
  return weekdaysByChange;
}

List<ScheduleChange> findScheduleChanges(Proposal previous, Proposal current) {
  final previousTimes = findTimesByDependentSlot(previous);
  final changes = <ScheduleChange>[];
  for (final leg in RouteLeg.values) {
    for (final item in current.items) {
      final legChanges = findLegChangesOfItem(item, leg, previousTimes);
      for (final MapEntry(key: (before, after), value: weekdays)
          in legChanges.entries) {
        final change = ScheduleChange(
          dependentFirstNames: [item.dependentFirstName],
          leg: leg,
          weekdays: weekdays,
          before: before,
          after: after,
        );
        final index = changes.indexWhere(change.isSameChangeAs);
        if (index < 0) {
          changes.add(change);
        } else {
          changes[index] = changes[index].withDependent(
            item.dependentFirstName,
          );
        }
      }
    }
  }
  return changes;
}

bool haveSameKeys<K, V>(Map<K, V> first, Map<K, V> second) {
  return first.length == second.length && first.keys.every(second.containsKey);
}
