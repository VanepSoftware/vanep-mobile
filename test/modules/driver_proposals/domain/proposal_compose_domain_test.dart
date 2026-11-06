import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/proposal_compose_usecases.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';

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

  test('received amount is the family total minus the commission', () {
    final draft = testProposalComposeDraft();

    expect(draft.familyAmountCents, 63000);
    expect(draft.receivedCents, 62500);
    expect(draft.canSend, isTrue);
  });

  test('changing one student price leaves the other line alone', () {
    final updated = testProposalComposeDraft().withStudentAmount(
      'pedro',
      40000,
    );

    expect(updated.students.first.monthlyAmountCents, 40000);
    expect(updated.students.last.monthlyAmountCents, 28000);
    expect(updated.familyAmountCents, 68000);
  });

  test('an unknown student keeps the same draft', () {
    final draft = testProposalComposeDraft();

    expect(identical(draft.withStudentAmount('missing', 100), draft), isTrue);
  });

  test('a zero price or a non-positive receipt cannot be sent', () {
    expect(testProposalComposeDraft(pedroCents: 0).canSend, isFalse);
    expect(testProposalComposeDraft(commissionCents: 70000).canSend, isFalse);
  });

  test('schedule groups by weekday and puts outbound before return', () {
    final days = groupProposalSchedule(testProposalSchedule);

    expect(days.map((day) => day.weekday), [
      DateTime.monday,
      DateTime.tuesday,
    ]);
    expect(days.first.slots.map((slot) => slot.leg), [
      RouteLeg.outbound,
      RouteLeg.inbound,
    ]);
  });

  test('an overdue invoice refuses the send before the repository', () async {
    final result = await SendDriverProposal(repository: repository)(
      testProposalComposeDraft(block: ProposalComposeBlock.overdueInvoice),
    );

    expect(result, const Err<DriverProposalFailure, void>(
      DriverProposalFailure.overdueInvoice,
    ));
    verifyNever(() => repository.send(any()));
  });

  test('not accepting students refuses the send before the repository', () async {
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
  });

  test('an invalid price refuses the send before the repository', () async {
    final result = await SendDriverProposal(repository: repository)(
      testProposalComposeDraft(pedroCents: 0),
    );

    expect(
      result,
      const Err<DriverProposalFailure, void>(DriverProposalFailure.invalidAmount),
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
