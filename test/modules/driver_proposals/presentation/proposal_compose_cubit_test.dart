import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
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
    act: (cubit) => cubit.changeStudentPrice('pedro', 40000),
    expect: () => [
      ready.withDraft(testProposalComposeDraft(pedroCents: 40000)),
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
}
