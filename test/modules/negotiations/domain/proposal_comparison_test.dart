import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_comparison.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';

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

  test('the price change follows the total, not the installment', () {
    final change = comparePrices(
      TestProposal(installments: 10, totalAmountCents: 360000),
      TestProposal(
        installments: 12,
        installmentAmountCents: 30000,
        totalAmountCents: 360000,
      ),
    );

    expect(change.hasTotalChanged, isFalse);
    expect(change.hasInstallmentsChanged, isTrue);
    expect(change.isEmpty, isFalse);
  });

  test('a lower total is cheaper by the difference', () {
    final change = comparePrices(
      TestProposal(totalAmountCents: 408000),
      TestProposal(totalAmountCents: 360000),
    );

    expect(change.totalDifferenceCents, -48000);
    expect(change.isCheaper, isTrue);
    expect(change.hasInstallmentsChanged, isFalse);
  });

  test('the same total and installments is no price change', () {
    final change = comparePrices(
      TestProposal(installmentAmountCents: 34000),
      TestProposal(installmentAmountCents: 33000),
    );

    expect(change.isEmpty, isTrue);
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

  group('the schedule changes', () {
    const outboundAt640 = ClockTime(hour: 6, minute: 40);
    const homeboundAt18 = ClockTime(hour: 18, minute: 0);
    const homeboundAt1830 = ClockTime(hour: 18, minute: 30);

    List<TestScheduleSlot> weekWith({
      ClockTime outbound = outboundAt640,
      Map<Weekday, ClockTime> homeboundOn = const {},
    }) {
      return [
        for (final weekday in weekdaysMondayToFriday) ...[
          TestScheduleSlot(
            weekday: weekday,
            leg: RouteLeg.outbound,
            pickupTime: outbound,
          ),
          TestScheduleSlot(
            weekday: weekday,
            leg: RouteLeg.homebound,
            pickupTime: homeboundOn[weekday] ?? homeboundAt18,
          ),
        ],
      ];
    }

    TestProposal proposalWith(Map<String, List<TestScheduleSlot>> slotsOf) {
      return TestProposal(
        items: [
          for (final MapEntry(key: name, value: slots) in slotsOf.entries)
            TestProposalItem(
              dependentToken: 'dep-$name',
              dependentFirstName: name,
              slots: slots,
            ),
        ],
      );
    }

    test('lists only the days that changed, grouped by the same change', () {
      final changes = findScheduleChanges(
        proposalWith({'Ana': weekWith()}),
        proposalWith({
          'Ana': weekWith(
            homeboundOn: {
              Weekday.monday: homeboundAt1830,
              Weekday.wednesday: homeboundAt1830,
            },
          ),
        }),
      );

      expect(changes, [
        const ScheduleChange(
          dependentFirstNames: ['Ana'],
          leg: RouteLeg.homebound,
          weekdays: [Weekday.monday, Weekday.wednesday],
          before: homeboundAt18,
          after: homeboundAt1830,
        ),
      ]);
    });

    test('a change of every outbound is one line with the whole week', () {
      final changes = findScheduleChanges(
        proposalWith({'Ana': weekWith()}),
        proposalWith({
          'Ana': weekWith(outbound: const ClockTime(hour: 6, minute: 50)),
        }),
      );

      expect(changes.single.leg, RouteLeg.outbound);
      expect(changes.single.weekdays, weekdaysMondayToFriday);
    });

    test('siblings with the same change share one line', () {
      final later = weekWith(homeboundOn: {Weekday.friday: homeboundAt1830});
      final changes = findScheduleChanges(
        proposalWith({'Ana': weekWith(), 'Pedro': weekWith()}),
        proposalWith({'Ana': later, 'Pedro': later}),
      );

      expect(changes.single.dependentFirstNames, ['Ana', 'Pedro']);
      expect(changes.single.weekdays, [Weekday.friday]);
    });

    test('siblings with different changes get one line each', () {
      final changes = findScheduleChanges(
        proposalWith({'Ana': weekWith(), 'Pedro': weekWith()}),
        proposalWith({
          'Ana': weekWith(homeboundOn: {Weekday.friday: homeboundAt1830}),
          'Pedro': weekWith(),
        }),
      );

      expect(changes.single.dependentFirstNames, ['Ana']);
    });

    test('a day added or removed is not a schedule change', () {
      final changes = findScheduleChanges(
        proposalWith({'Ana': weekWith()}),
        proposalWith({'Ana': weekWith().take(8).toList()}),
      );

      expect(changes, isEmpty);
    });
  });
}
