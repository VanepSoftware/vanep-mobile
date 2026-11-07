import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
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
  final before = findTimesByDependentSlot(previous);
  final after = findTimesByDependentSlot(current);
  return before.keys.any(
    (key) => after.containsKey(key) && after[key] != before[key],
  );
}

bool haveSameKeys<K, V>(Map<K, V> first, Map<K, V> second) {
  return first.length == second.length && first.keys.every(second.containsKey);
}
