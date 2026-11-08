import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_adjustment_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_adjustment_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';

import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockRequestProposalAdjustment requestAdjustment;

  const scheduleWithNote = ProposalAdjustmentDraft(
    field: ProposalAdjustmentField.schedule,
    note: 'Pode buscar 10 min antes?',
  );

  setUpAll(() => registerFallbackValue(const ProposalAdjustmentDraft()));

  setUp(() => requestAdjustment = MockRequestProposalAdjustment());

  ProposalAdjustmentCubit buildCubit() => ProposalAdjustmentCubit(
    proposalToken: testVersion2.token,
    requestAdjustment: requestAdjustment,
  );

  test('starts without a subject and cannot be sent', () {
    final cubit = buildCubit();

    expect(cubit.state.draft, const ProposalAdjustmentDraft());
    expect(cubit.state.canSend, isFalse);
  });

  blocTest<ProposalAdjustmentCubit, ProposalAdjustmentState>(
    'a subject with only a message can be sent',
    build: buildCubit,
    act: (cubit) => cubit
      ..selectField(ProposalAdjustmentField.schedule)
      ..changeNote('Pode buscar 10 min antes?'),
    verify: (cubit) => expect(cubit.state.canSend, isTrue),
  );

  blocTest<ProposalAdjustmentCubit, ProposalAdjustmentState>(
    'a subject with only a suggested value can be sent',
    build: buildCubit,
    act: (cubit) => cubit
      ..selectField(ProposalAdjustmentField.price)
      ..changeSuggestedValue('R\$ 290'),
    verify: (cubit) => expect(cubit.state.canSend, isTrue),
  );

  blocTest<ProposalAdjustmentCubit, ProposalAdjustmentState>(
    'a subject without a value or a message cannot be sent',
    build: buildCubit,
    act: (cubit) => cubit
      ..selectField(ProposalAdjustmentField.other)
      ..changeNote('   '),
    verify: (cubit) => expect(cubit.state.canSend, isFalse),
  );

  blocTest<ProposalAdjustmentCubit, ProposalAdjustmentState>(
    'choosing another subject clears the suggested value',
    build: buildCubit,
    act: (cubit) => cubit
      ..selectField(ProposalAdjustmentField.price)
      ..changeSuggestedValue('R\$ 290')
      ..changeNote('Fica melhor assim.')
      ..selectField(ProposalAdjustmentField.installments),
    verify: (cubit) => expect(
      cubit.state.draft,
      const ProposalAdjustmentDraft(
        field: ProposalAdjustmentField.installments,
        note: 'Fica melhor assim.',
      ),
    ),
  );

  blocTest<ProposalAdjustmentCubit, ProposalAdjustmentState>(
    'sends the adjustment of the open version',
    setUp: () =>
        when(() => requestAdjustment(testVersion2.token, scheduleWithNote))
            .thenAnswer((_) async => Ok(testVersion2)),
    build: buildCubit,
    seed: () => const ProposalAdjustmentState(draft: scheduleWithNote),
    act: (cubit) => cubit.send(),
    expect: () => [
      const ProposalAdjustmentState(draft: scheduleWithNote, isSending: true),
      ProposalAdjustmentState(
        draft: scheduleWithNote,
        sentProposal: testVersion2,
      ),
    ],
  );

  blocTest<ProposalAdjustmentCubit, ProposalAdjustmentState>(
    'a rule of the back keeps what was written and tells why',
    setUp: () => when(() => requestAdjustment(any(), any())).thenAnswer(
      (_) async =>
          const Err(NegotiationRejectedFailure(detail: 'Ajuste vazio.')),
    ),
    build: buildCubit,
    seed: () => const ProposalAdjustmentState(draft: scheduleWithNote),
    act: (cubit) => cubit.send(),
    skip: 1,
    expect: () => [
      const ProposalAdjustmentState(
        draft: scheduleWithNote,
        failure: NegotiationRejectedFailure(detail: 'Ajuste vazio.'),
      ),
    ],
  );

  blocTest<ProposalAdjustmentCubit, ProposalAdjustmentState>(
    'cannot send twice nor send an empty adjustment',
    build: buildCubit,
    seed: () =>
        const ProposalAdjustmentState(draft: scheduleWithNote, isSending: true),
    act: (cubit) => cubit.send(),
    expect: () => <ProposalAdjustmentState>[],
    verify: (_) => verifyNever(() => requestAdjustment(any(), any())),
  );
}
