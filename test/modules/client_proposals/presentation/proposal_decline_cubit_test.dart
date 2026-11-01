import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_decline_reason.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockDeclineProposal declineProposal;

  const chosen = ProposalDeclineState(
    reason: ProposalDeclineReason.choseAnotherVan,
    message: 'Obrigada, Carlos.',
  );

  setUp(() => declineProposal = MockDeclineProposal());

  ProposalDeclineCubit buildCubit() => ProposalDeclineCubit(
    proposalToken: testVersion2.token,
    declineProposal: declineProposal,
  );

  test('offers five reasons and needs one to decline', () {
    expect(ProposalDeclineReason.values, hasLength(5));
    expect(buildCubit().state.canSend, isFalse);
  });

  blocTest<ProposalDeclineCubit, ProposalDeclineState>(
    'a reason is enough, the message is optional',
    build: buildCubit,
    act: (cubit) => cubit.selectReason(ProposalDeclineReason.priceTooHigh),
    verify: (cubit) => expect(cubit.state.canSend, isTrue),
  );

  blocTest<ProposalDeclineCubit, ProposalDeclineState>(
    'keeps the message written',
    build: buildCubit,
    act: (cubit) => cubit
      ..selectReason(ProposalDeclineReason.choseAnotherVan)
      ..changeMessage('Obrigada, Carlos.'),
    expect: () => [
      const ProposalDeclineState(reason: ProposalDeclineReason.choseAnotherVan),
      chosen,
    ],
  );

  blocTest<ProposalDeclineCubit, ProposalDeclineState>(
    'sends the reason and the message together',
    setUp: () => when(
      () => declineProposal(
        testVersion2.token,
        reason: 'Escolhi outra van. Obrigada, Carlos.',
      ),
    ).thenAnswer((_) async => Ok(testVersion2)),
    build: buildCubit,
    seed: () => chosen,
    act: (cubit) => cubit.send(reasonLabel: 'Escolhi outra van'),
    expect: () => [
      chosen.copyWith(isSending: true),
      chosen.copyWith(declinedProposal: testVersion2),
    ],
  );

  blocTest<ProposalDeclineCubit, ProposalDeclineState>(
    'a failure keeps what was chosen and tells why',
    setUp: () =>
        when(() => declineProposal(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
    build: buildCubit,
    seed: () => chosen,
    act: (cubit) => cubit.send(reasonLabel: 'Escolhi outra van'),
    skip: 1,
    expect: () => [chosen.copyWith(failure: const NegotiationNetworkFailure())],
  );

  blocTest<ProposalDeclineCubit, ProposalDeclineState>(
    'without a reason nothing is sent',
    build: buildCubit,
    act: (cubit) => cubit.send(reasonLabel: ''),
    expect: () => <ProposalDeclineState>[],
    verify: (_) =>
        verifyNever(() => declineProposal(any(), reason: any(named: 'reason'))),
  );

  blocTest<ProposalDeclineCubit, ProposalDeclineState>(
    'a reason and a message over the limit are not sent',
    build: buildCubit,
    seed: () => chosen.copyWith(message: 'a' * 490),
    act: (cubit) => cubit.send(reasonLabel: 'Escolhi outra van'),
    expect: () => <ProposalDeclineState>[],
    verify: (_) =>
        verifyNever(() => declineProposal(any(), reason: any(named: 'reason'))),
  );
}
