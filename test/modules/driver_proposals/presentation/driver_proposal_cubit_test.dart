import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_proposal_detail.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_proposal_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_proposal_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

void main() {
  late MockLoadDriverProposal loadProposal;

  final detail = DriverProposalDetail(
    request: adjustmentRequest,
    proposal: versionWithAdjustment,
    versions: [versionWithAdjustment],
  );

  setUp(() => loadProposal = MockLoadDriverProposal());

  DriverProposalCubit build() => DriverProposalCubit(
    requestToken: 'request-adjust',
    proposalToken: 'proposal-v1',
    loadDriverProposal: loadProposal,
  );

  blocTest<DriverProposalCubit, DriverProposalState>(
    'loads the version with its history',
    setUp: () =>
        when(() => loadProposal('request-adjust', proposalToken: 'proposal-v1'))
            .thenAnswer((_) async => Ok(detail)),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const DriverProposalState(status: DriverProposalStatus.loading),
      DriverProposalState(status: DriverProposalStatus.ready, detail: detail),
    ],
    verify: (cubit) {
      expect(cubit.state.detail!.pendingAdjustment, isNotNull);
      expect(cubit.state.detail!.history, isNotEmpty);
    },
  );

  blocTest<DriverProposalCubit, DriverProposalState>(
    'a proposal that no longer exists is not found',
    setUp: () =>
        when(() => loadProposal('request-adjust', proposalToken: 'proposal-v1'))
            .thenAnswer((_) async => const Err(NegotiationNotFoundFailure())),
    build: build,
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => [
      const DriverProposalState(status: DriverProposalStatus.notFound),
    ],
  );

  blocTest<DriverProposalCubit, DriverProposalState>(
    'a failed first load offers to try again',
    setUp: () =>
        when(() => loadProposal('request-adjust', proposalToken: 'proposal-v1'))
            .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
    build: build,
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => [
      const DriverProposalState(status: DriverProposalStatus.loadFailed),
    ],
  );

  blocTest<DriverProposalCubit, DriverProposalState>(
    'a failed reload keeps the proposal on screen',
    setUp: () =>
        when(() => loadProposal('request-adjust', proposalToken: 'proposal-v1'))
            .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
    build: build,
    seed: () =>
        DriverProposalState(status: DriverProposalStatus.ready, detail: detail),
    act: (cubit) => cubit.load(),
    expect: () => [
      DriverProposalState(
        status: DriverProposalStatus.ready,
        detail: detail,
        actionFailure: const NegotiationNetworkFailure(),
      ),
    ],
  );
}
