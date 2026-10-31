import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_comparison.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';

import '../negotiations_fixtures.dart';

void main() {
  test('two equal versions have no changes', () {
    expect(compareProposalVersions(TestProposal(), TestProposal()), isEmpty);
  });

  test('a lower installment changes only the amount', () {
    final changes = compareProposalVersions(
      TestProposal(),
      TestProposal(totalAmountCents: 360000, installmentAmountCents: 30000),
    );

    expect(changes, [ProposalComparisonField.amount]);
  });

  test('lists every changed term in a fixed order', () {
    final changes = compareProposalVersions(
      TestProposal(),
      TestProposal(
        installments: 10,
        endsOn: DateTime(2027, 11, 30),
        dueDay: 5,
        enrollmentFeeCents: 20000,
        adjustmentPolicy: ProposalAdjustmentPolicy.none,
        cancellationPolicy: ProposalCancellationPolicy.notice30Days,
      ),
    );

    expect(changes, [
      ProposalComparisonField.installments,
      ProposalComparisonField.period,
      ProposalComparisonField.dueDay,
      ProposalComparisonField.enrollmentFee,
      ProposalComparisonField.adjustmentPolicy,
      ProposalComparisonField.cancellationPolicy,
    ]);
  });

  test('dropping a leg changes the days and legs', () {
    final withoutWednesdayReturn = roundTripSlotsOn(weekdaysMondayToFriday)
        .where(
          (slot) =>
              slot.weekday != Weekday.wednesday ||
              slot.leg != RouteLeg.homebound,
        )
        .toList();

    final changes = compareProposalVersions(
      TestProposal(),
      TestProposal(items: [TestProposalItem(slots: withoutWednesdayReturn)]),
    );

    expect(changes, [ProposalComparisonField.daysAndLegs]);
  });

  test('a new pickup time changes the schedule', () {
    final earlierPickup = [
      for (final slot in roundTripSlotsOn(weekdaysMondayToFriday))
        slot.leg == RouteLeg.outbound
            ? TestScheduleSlot(
                weekday: slot.weekday,
                leg: slot.leg,
                pickupTime: const ClockTime(hour: 11, minute: 55),
              )
            : slot,
    ];

    final changes = compareProposalVersions(
      TestProposal(),
      TestProposal(items: [TestProposalItem(slots: earlierPickup)]),
    );

    expect(changes, [ProposalComparisonField.schedule]);
  });

  test('another van changes the vehicle', () {
    final changes = compareProposalVersions(
      TestProposal(),
      TestProposal(
        vehicle: const TestProposalVehicle(plate: 'XYZ9B87', model: 'Sprinter'),
      ),
    );

    expect(changes, [ProposalComparisonField.vehicle]);
  });
}
