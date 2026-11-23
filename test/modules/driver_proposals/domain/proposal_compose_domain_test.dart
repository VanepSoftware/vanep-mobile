import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/proposal_compose_usecases.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_schedule.dart';

import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

void main() {
  late MockDriverProposalRepository repository;

  setUpAll(() {
    registerFallbackValue(testProposalComposeDraft());
  });

  setUp(() {
    repository = MockDriverProposalRepository();
  });

  test('the summary covers the whole contract and each installment', () {
    final draft = testProposalComposeDraft();

    expect(draft.monthlyFamilyCents, 62000);
    expect(draft.monthlyReceivedCents, 61500);
    expect(draft.familyTotalCents, 744000);
    expect(draft.commissionTotalCents, 6000);
    expect(draft.receivedTotalCents, 738000);
    expect(draft.canSend, isTrue);
  });

  test('fewer installments shrink every total', () {
    final draft = testProposalComposeDraft(installments: 10);

    expect(draft.familyTotalCents, 620000);
    expect(draft.commissionTotalCents, 5000);
    expect(draft.receivedTotalCents, 615000);
  });

  test('changing one student price leaves the other line alone', () {
    final updated = testProposalComposeDraft().withStudentAmount(
      'theo',
      40000,
    );

    expect(updated.students.first.monthlyAmountCents, 40000);
    expect(updated.students.last.monthlyAmountCents, 30000);
    expect(updated.monthlyFamilyCents, 70000);
  });

  test('an unknown student or van keeps the same draft', () {
    final draft = testProposalComposeDraft();

    expect(identical(draft.withStudentAmount('missing', 100), draft), isTrue);
    expect(identical(draft.withVan('missing'), draft), isTrue);
  });

  test('a zero price or a non-positive receipt cannot be sent', () {
    expect(testProposalComposeDraft(theoCents: 0).canSend, isFalse);
    expect(testProposalComposeDraft(commissionCents: 70000).canSend, isFalse);
  });

  test('a van without seats for every student cannot be sent', () {
    final draft = testProposalComposeDraft().withVan('master');

    expect(draft.selectedVan, testMaster);
    expect(draft.hasSeatsForStudents, isFalse);
    expect(draft.canSend, isFalse);
  });

  test('toggling a slot moves away from the request and back', () {
    final draft = testProposalComposeDraft();
    final changed = draft.withSlotToggled(testFridayReturn);

    expect(draft.matchesRequest, isTrue);
    expect(changed.slots.contains(testFridayReturn), isFalse);
    expect(changed.matchesRequest, isFalse);
    expect(changed.withSlotToggled(testFridayReturn).matchesRequest, isTrue);
  });

  test('legs follow the selected slots', () {
    final outboundOnly = {
      for (final weekday in schoolWeekdays)
        ProposalScheduleSlot(weekday: weekday, leg: RouteLeg.outbound),
    };

    expect(proposalLegsOf(fullSchoolWeekSlots()), ProposalLegs.outboundAndReturn);
    expect(proposalLegsOf(outboundOnly), ProposalLegs.outboundOnly);
    expect(proposalLegsOf({testFridayReturn}), ProposalLegs.returnOnly);
    expect(proposalLegsOf({}), ProposalLegs.none);
  });

  test('no slot, invalid times or an inverted period cannot be sent', () {
    final draft = testProposalComposeDraft();

    expect(draft.copyWith(slots: {}).canSend, isFalse);
    expect(
      draft
          .copyWith(times: testRouteTimes.copyWith(pickupEndMinutes: 11 * 60))
          .canSend,
      isFalse,
    );
    expect(
      draft
          .copyWith(payment: testPayment.copyWith(endDate: DateTime(2027)))
          .canSend,
      isFalse,
    );
  });

  test('an overdue invoice refuses the send before the repository', () async {
    final result = await SendDriverProposal(repository: repository)(
      testProposalComposeDraft(block: ProposalComposeBlock.overdueInvoice),
    );

    expect(
      result,
      const Err<DriverProposalFailure, void>(
        DriverProposalFailure.overdueInvoice,
      ),
    );
    verifyNever(() => repository.send(any()));
  });

  test(
    'not accepting students refuses the send before the repository',
    () async {
      final result = await SendDriverProposal(repository: repository)(
        testProposalComposeDraft(
          block: ProposalComposeBlock.notAcceptingStudents,
        ),
      );

      expect(
        result,
        const Err<DriverProposalFailure, void>(
          DriverProposalFailure.notAcceptingStudents,
        ),
      );
      verifyNever(() => repository.send(any()));
    },
  );

  test('an incomplete draft refuses the send before the repository', () async {
    final result = await SendDriverProposal(repository: repository)(
      testProposalComposeDraft(theoCents: 0),
    );

    expect(
      result,
      const Err<DriverProposalFailure, void>(
        DriverProposalFailure.incompleteDraft,
      ),
    );
    verifyNever(() => repository.send(any()));
  });

  test('a valid draft is sent through the repository', () async {
    final draft = testProposalComposeDraft();
    when(() => repository.send(draft)).thenAnswer((_) async => const Ok(null));

    final result = await SendDriverProposal(repository: repository)(draft);

    expect(result, const Ok<DriverProposalFailure, void>(null));
    verify(() => repository.send(draft)).called(1);
  });

  test('load forwards the repository result', () async {
    final draft = testProposalComposeDraft();
    when(repository.loadCompose).thenAnswer((_) async => Ok(draft));

    final result = await LoadProposalCompose(repository: repository)();

    expect(result, Ok<DriverProposalFailure, ProposalComposeDraft>(draft));
  });
}
