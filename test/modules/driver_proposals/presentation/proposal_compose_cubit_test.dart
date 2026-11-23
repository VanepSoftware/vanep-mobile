import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_terms.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_compose_cubit.dart';

import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

void main() {
  late MockLoadProposalCompose loadProposalCompose;
  late MockSendDriverProposal sendDriverProposal;

  final ready = ProposalComposeState(
    status: ProposalComposeStatus.ready,
    draft: testProposalComposeDraft(),
  );

  setUpAll(() {
    registerFallbackValue(testProposalComposeDraft());
  });

  setUp(() {
    loadProposalCompose = MockLoadProposalCompose();
    sendDriverProposal = MockSendDriverProposal();
  });

  ProposalComposeCubit buildCubit() {
    return ProposalComposeCubit(
      loadProposalCompose: loadProposalCompose,
      sendDriverProposal: sendDriverProposal,
    );
  }

  blocTest<ProposalComposeCubit, ProposalComposeState>(
    'loads the draft',
    setUp: () => when(
      loadProposalCompose.call,
    ).thenAnswer((_) async => Ok(testProposalComposeDraft())),
    build: buildCubit,
    act: (cubit) => cubit.loadDraft(),
    expect: () => [
      const ProposalComposeState(status: ProposalComposeStatus.loading),
      ready,
    ],
  );

  blocTest<ProposalComposeCubit, ProposalComposeState>(
    'a failed reload keeps the draft',
    setUp: () => when(loadProposalCompose.call).thenAnswer(
      (_) async => const Err(DriverProposalFailure.network),
    ),
    build: buildCubit,
    seed: () => ready,
    act: (cubit) => cubit.loadDraft(),
    expect: () => <ProposalComposeState>[],
  );

  blocTest<ProposalComposeCubit, ProposalComposeState>(
    'changes one student price',
    build: buildCubit,
    seed: () => ready,
    act: (cubit) => cubit.changeStudentPrice('theo', 40000),
    expect: () => [
      ready.withDraft(testProposalComposeDraft(theoCents: 40000)),
    ],
  );

  blocTest<ProposalComposeCubit, ProposalComposeState>(
    'sends a valid proposal',
    setUp: () => when(
      () => sendDriverProposal(any()),
    ).thenAnswer((_) async => const Ok(null)),
    build: buildCubit,
    seed: () => ready,
    act: (cubit) => cubit.sendProposal(),
    expect: () => [ready.sending(), ready.sent()],
  );

  blocTest<ProposalComposeCubit, ProposalComposeState>(
    'does not send a paused draft',
    build: buildCubit,
    seed: () => ready.withDraft(
      testProposalComposeDraft(block: ProposalComposeBlock.overdueInvoice),
    ),
    act: (cubit) => cubit.sendProposal(),
    expect: () => <ProposalComposeState>[],
    verify: (_) => verifyNever(() => sendDriverProposal(any())),
  );

  blocTest<ProposalComposeCubit, ProposalComposeState>(
    'picks another van',
    build: buildCubit,
    seed: () => ready,
    act: (cubit) => cubit.selectVan('master'),
    expect: () => [
      ready.withDraft(testProposalComposeDraft(selectedVanToken: 'master')),
    ],
  );

  blocTest<ProposalComposeCubit, ProposalComposeState>(
    'toggles a day and leg',
    build: buildCubit,
    seed: () => ready,
    act: (cubit) => cubit.toggleSlot(testFridayReturn),
    expect: () => [
      ready.withDraft(
        testProposalComposeDraft().withSlotToggled(testFridayReturn),
      ),
    ],
  );

  blocTest<ProposalComposeCubit, ProposalComposeState>(
    'changes times, payment, conditions and message',
    build: buildCubit,
    seed: () => ready,
    act: (cubit) => cubit
      ..changeTimes(testRouteTimes.copyWith(schoolDepartureMinutes: 1110))
      ..changePayment(testPayment.copyWith(installments: 10))
      ..changeConditions(
        testConditions.copyWith(readjustment: ProposalReadjustment.none),
      )
      ..changeMessage('Tenho vaga para os dois.'),
    verify: (cubit) {
      final draft = cubit.state.draft!;
      expect(draft.times.schoolDepartureMinutes, 1110);
      expect(draft.payment.installments, 10);
      expect(draft.conditions.readjustment, ProposalReadjustment.none);
      expect(draft.message, 'Tenho vaga para os dois.');
    },
  );

  blocTest<ProposalComposeCubit, ProposalComposeState>(
    'ignores a message over the limit and edits while sending',
    build: buildCubit,
    seed: () => ready.sending(),
    act: (cubit) => cubit
      ..changeMessage('x' * (proposalMessageMaxLength + 1))
      ..selectVan('master'),
    expect: () => <ProposalComposeState>[],
  );
}
