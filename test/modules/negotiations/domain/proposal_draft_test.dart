import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/operation_shift.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';

import '../negotiations_fixtures.dart';

final today = DateTime(2026, 10, 1);

const pickup = ClockTime(hour: 12, minute: 5);

const schoolExit = ClockTime(hour: 18, minute: 0);

TestDriverServiceRequest wednesdayOutboundOnlyRequest() {
  return TestDriverServiceRequest(
    items: [
      TestDriverRequestItem(
        days: [
          ...roundTripOn([Weekday.monday, Weekday.tuesday]),
          const TestRequestedDay(
            weekday: Weekday.wednesday,
            needsReturn: false,
          ),
        ],
      ),
    ],
  );
}

ProposalDraft completeDraft() {
  return ProposalDraft.fromRequest(TestDriverServiceRequest())
      .withTotalAmount(408000)
      .withInstallments(12)
      .withDueDay(10)
      .withEndsOn(DateTime(2027, 12, 17))
      .withVehicle('van-master')
      .withTimeOnEveryDay('dep-theo', RouteLeg.outbound, pickup)
      .withTimeOnEveryDay('dep-theo', RouteLeg.homebound, schoolExit);
}

Set<ProposalDraftError> errorsOf(ProposalDraft draft) {
  return validateProposalDraft(draft, today: today);
}

void main() {
  group('from a request', () {
    test('starts with every requested leg and the requested start', () {
      final draft = ProposalDraft.fromRequest(wednesdayOutboundOnlyRequest());
      final item = draft.items.single;

      expect(draft.serviceRequestToken, 'request-1');
      expect(draft.startsOn, DateTime(2027, 2, 1));
      expect(item.isEnabled(Weekday.wednesday, RouteLeg.outbound), isTrue);
      expect(item.isEnabled(Weekday.wednesday, RouteLeg.homebound), isFalse);
      expect(item.isEnabled(Weekday.monday, RouteLeg.homebound), isTrue);
    });

    test('starts with the canvas conditions and a 7 day validity', () {
      final draft = ProposalDraft.fromRequest(TestDriverServiceRequest());

      expect(draft.validDays, 7);
      expect(draft.adjustmentPolicy, ProposalAdjustmentPolicy.ipcaAtRenewal);
      expect(
        draft.cancellationPolicy,
        ProposalCancellationPolicy.notice30DaysWithFee,
      );
    });
  });

  group('from a proposal', () {
    test('copies the current version', () {
      final draft = ProposalDraft.fromProposal(
        TestProposal(enrollmentFeeCents: 20000),
        TestDriverServiceRequest(),
      );

      expect(draft.totalAmountCents, 408000);
      expect(draft.installments, 12);
      expect(draft.dueDay, 10);
      expect(draft.startsOn, DateTime(2027, 2, 1));
      expect(draft.endsOn, DateTime(2027, 12, 17));
      expect(draft.enrollmentFeeCents, 20000);
      expect(
        draft.items.single.timeOf(Weekday.monday, RouteLeg.outbound),
        pickup,
      );
      expect(
        draft.items.single.timeOf(Weekday.monday, RouteLeg.homebound),
        schoolExit,
      );
    });

    test('keeps off the legs the version left out', () {
      final draft = ProposalDraft.fromProposal(
        TestProposal(
          items: [
            TestProposalItem(slots: roundTripSlotsOn([Weekday.monday])),
          ],
        ),
        TestDriverServiceRequest(),
      );

      expect(
        draft.items.single.isEnabled(Weekday.tuesday, RouteLeg.outbound),
        isFalse,
      );
    });

    test('starts from the same van, with a new validity and message', () {
      final draft = ProposalDraft.fromProposal(
        TestProposal(),
        TestDriverServiceRequest(),
      );

      expect(draft.vehicleToken, 'van-master');
      expect(draft.validDays, 7);
      expect(draft.message, isEmpty);
    });

    test('a version read without the van token asks for the van', () {
      final draft = ProposalDraft.fromProposal(
        TestProposal(vehicle: const TestProposalVehicle(token: null)),
        TestDriverServiceRequest(),
      );

      expect(draft.vehicleToken, isNull);
    });
  });

  test('a complete draft is valid', () {
    expect(errorsOf(completeDraft()), isEmpty);
  });

  test('the total needs to be above zero', () {
    expect(errorsOf(completeDraft().withTotalAmount(0)), {
      ProposalDraftError.totalAmountRequired,
    });
  });

  test('the total covers at least one cent per installment', () {
    final draft = completeDraft().withInstallments(12);

    expect(errorsOf(draft.withTotalAmount(12)), isEmpty);
    expect(errorsOf(draft.withTotalAmount(11)), {
      ProposalDraftError.totalBelowOneCentPerInstallment,
    });
  });

  test('installments go from 1 to 12', () {
    expect(errorsOf(completeDraft().withInstallments(1)), isEmpty);
    expect(errorsOf(completeDraft().withInstallments(13)), {
      ProposalDraftError.installmentsOutOfRange,
    });
    expect(errorsOf(completeDraft().withInstallments(null)), {
      ProposalDraftError.installmentsOutOfRange,
    });
  });

  test('the due day goes from 1 to 28', () {
    expect(errorsOf(completeDraft().withDueDay(28)), isEmpty);
    expect(errorsOf(completeDraft().withDueDay(29)), {
      ProposalDraftError.dueDayOutOfRange,
    });
  });

  group('period', () {
    test('starts today or later', () {
      final endingInJune = completeDraft().withEndsOn(DateTime(2027, 6, 30));

      expect(errorsOf(endingInJune.withStartsOn(today)), isEmpty);
      expect(errorsOf(endingInJune.withStartsOn(DateTime(2026, 9, 30))), {
        ProposalDraftError.startDateInPast,
      });
    });

    test('needs both dates', () {
      expect(errorsOf(completeDraft().withStartsOn(null)), {
        ProposalDraftError.periodRequired,
      });
      expect(errorsOf(completeDraft().withEndsOn(null)), {
        ProposalDraftError.periodRequired,
      });
    });

    test('ends after it starts', () {
      expect(errorsOf(completeDraft().withEndsOn(DateTime(2027, 2, 1))), {
        ProposalDraftError.endNotAfterStart,
      });
    });

    test('lasts up to 12 months', () {
      expect(
        errorsOf(completeDraft().withEndsOn(DateTime(2028, 2, 1))),
        isEmpty,
      );
      expect(errorsOf(completeDraft().withEndsOn(DateTime(2028, 2, 2))), {
        ProposalDraftError.periodTooLong,
      });
    });

    test('a start on February 29 ends by February 28', () {
      final draft = completeDraft().withStartsOn(DateTime(2028, 2, 29));

      expect(errorsOf(draft.withEndsOn(DateTime(2029, 2, 28))), isEmpty);
      expect(errorsOf(draft.withEndsOn(DateTime(2029, 3, 1))), {
        ProposalDraftError.periodTooLong,
      });
    });
  });

  group('legs and times', () {
    test('a leg the family did not ask for cannot be turned on', () {
      final draft = ProposalDraft.fromRequest(wednesdayOutboundOnlyRequest())
          .withLeg(
            'dep-theo',
            Weekday.wednesday,
            RouteLeg.homebound,
            enabled: true,
          );

      expect(
        draft.items.single.isEnabled(Weekday.wednesday, RouteLeg.homebound),
        isFalse,
      );
    });

    test('every student keeps at least one leg', () {
      var draft = completeDraft();
      for (final weekday in weekdaysMondayToFriday) {
        for (final leg in RouteLeg.values) {
          draft = draft.withLeg('dep-theo', weekday, leg, enabled: false);
        }
      }

      expect(errorsOf(draft), {ProposalDraftError.studentWithoutLeg});
    });

    test('a leg turned back on needs its time again', () {
      final draft = completeDraft()
          .withLeg(
            'dep-theo',
            Weekday.monday,
            RouteLeg.homebound,
            enabled: false,
          )
          .withLeg(
            'dep-theo',
            Weekday.monday,
            RouteLeg.homebound,
            enabled: true,
          );

      expect(
        draft.items.single.timeOf(Weekday.monday, RouteLeg.homebound),
        isNull,
      );
      expect(errorsOf(draft), {ProposalDraftError.timeRequired});
    });

    test('a time changes only its own day', () {
      final draft = completeDraft().withTime(
        'dep-theo',
        Weekday.monday,
        RouteLeg.homebound,
        const ClockTime(hour: 18, minute: 30),
      );
      final item = draft.items.single;

      expect(
        item.timeOf(Weekday.monday, RouteLeg.homebound),
        const ClockTime(hour: 18, minute: 30),
      );
      expect(item.timeOf(Weekday.tuesday, RouteLeg.homebound), schoolExit);
    });

    test('the same time goes to every day of a leg', () {
      final item = completeDraft().items.single;

      expect(
        weekdaysMondayToFriday.map(
          (weekday) => item.timeOf(weekday, RouteLeg.outbound),
        ),
        everyElement(pickup),
      );
    });

    test('slots to send carry the shift of the school period', () {
      final draft =
          ProposalDraft.fromRequest(
                TestDriverServiceRequest(
                  items: [
                    TestDriverRequestItem(
                      days: [
                        const TestRequestedDay(
                          weekday: Weekday.monday,
                          schoolShift: SchoolShift.fullTime,
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .withTimeOnEveryDay('dep-theo', RouteLeg.outbound, pickup)
              .withTimeOnEveryDay('dep-theo', RouteLeg.homebound, schoolExit);

      expect(draft.items.single.slotsToSend, [
        const ScheduleSlotDraft(
          weekday: Weekday.monday,
          leg: RouteLeg.outbound,
          shift: OperationShift.morning,
          pickupTime: ClockTime(hour: 12, minute: 5),
        ),
        const ScheduleSlotDraft(
          weekday: Weekday.monday,
          leg: RouteLeg.homebound,
          shift: OperationShift.afternoon,
          pickupTime: ClockTime(hour: 18, minute: 0),
        ),
      ]);
    });
  });

  test('a van is required', () {
    expect(errorsOf(completeDraft().withVehicle(null)), {
      ProposalDraftError.vehicleRequired,
    });
  });

  test('the validity goes from 1 to 7 days', () {
    expect(errorsOf(completeDraft().withValidDays(1)), isEmpty);
    expect(errorsOf(completeDraft().withValidDays(8)), {
      ProposalDraftError.validDaysOutOfRange,
    });
  });

  test('the message has up to 1000 characters', () {
    expect(errorsOf(completeDraft().withMessage('a' * 1000)), isEmpty);
    expect(errorsOf(completeDraft().withMessage('a' * 1001)), {
      ProposalDraftError.messageTooLong,
    });
  });

  test('the message goes without surrounding spaces, or not at all', () {
    expect(
      completeDraft().withMessage(' Até breve. ').messageToSend,
      'Até breve.',
    );
    expect(completeDraft().withMessage('  ').messageToSend, isNull);
  });

  test('the enrollment fee may be zero but not negative', () {
    expect(errorsOf(completeDraft().withEnrollmentFee(0)), isEmpty);
    expect(errorsOf(completeDraft().withEnrollmentFee(-1)), {
      ProposalDraftError.enrollmentFeeNegative,
    });
  });
}
