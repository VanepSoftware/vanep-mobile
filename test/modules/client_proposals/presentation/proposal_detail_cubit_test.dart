import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_proposal_detail.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_detail_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_detail_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockFindClientProposal findProposal;
  late MockFindClientServiceRequest findServiceRequest;
  late MockListClientProposalVersions listVersions;
  late MockAcceptProposal acceptProposal;
  late MockWithdrawServiceRequest withdrawServiceRequest;

  final requestToken = testProposalForSiblings.token;
  final accepted = TestProposal(
    token: testVersion2.token,
    version: 2,
    status: ProposalStatus.accepted,
    acceptedAt: DateTime.utc(2026, 10, 25, 13),
  );

  ProposalDetailState readyState({String? proposalToken}) {
    return ProposalDetailState(
      status: ProposalDetailStatus.ready,
      proposalToken: proposalToken ?? testVersion2.token,
      request: testProposalForSiblings,
      proposal: testVersion2,
      versions: [testVersion1, testVersion2],
    );
  }

  setUp(() {
    findProposal = MockFindClientProposal();
    findServiceRequest = MockFindClientServiceRequest();
    listVersions = MockListClientProposalVersions();
    acceptProposal = MockAcceptProposal();
    withdrawServiceRequest = MockWithdrawServiceRequest();
    when(() => findServiceRequest(requestToken))
        .thenAnswer((_) async => Ok(testProposalForSiblings));
    when(() => findProposal(testVersion2.token))
        .thenAnswer((_) async => Ok(testVersion2));
    when(() => listVersions(requestToken))
        .thenAnswer((_) async => Ok([testVersion1, testVersion2]));
  });

  ProposalDetailCubit buildCubit({String? proposalToken}) {
    return ProposalDetailCubit(
      requestToken: requestToken,
      proposalToken: proposalToken,
      loadProposalDetail: LoadProposalDetail(
        findProposal: findProposal,
        findServiceRequest: findServiceRequest,
        listVersions: listVersions,
      ),
      acceptProposal: acceptProposal,
      withdrawServiceRequest: withdrawServiceRequest,
    );
  }

  group('loading', () {
    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'reads the proposal, the request and the versions',
      build: () => buildCubit(proposalToken: testVersion2.token),
      act: (cubit) => cubit.load(),
      expect: () => [
        ProposalDetailState(
          status: ProposalDetailStatus.loading,
          proposalToken: testVersion2.token,
        ),
        readyState(),
      ],
    );

    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'a request without a proposal reads only the request',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProposalDetailState(status: ProposalDetailStatus.loading),
        ProposalDetailState(
          status: ProposalDetailStatus.ready,
          request: testProposalForSiblings,
        ),
      ],
      verify: (_) {
        verifyNever(() => findProposal(any()));
        verifyNever(() => listVersions(any()));
      },
    );

    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'a negotiation that no longer exists leaves the screen',
      setUp: () =>
          when(() => findProposal(testVersion2.token))
              .thenAnswer((_) async => const Err(NegotiationNotFoundFailure())),
      build: () => buildCubit(proposalToken: testVersion2.token),
      act: (cubit) => cubit.load(),
      expect: () => [
        ProposalDetailState(
          status: ProposalDetailStatus.loading,
          proposalToken: testVersion2.token,
        ),
        ProposalDetailState(
          status: ProposalDetailStatus.notFound,
          proposalToken: testVersion2.token,
        ),
      ],
    );

    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'a first load without connection offers to try again',
      setUp: () =>
          when(() => listVersions(requestToken))
              .thenAnswer((_) async => const Err(NegotiationNetworkFailure())),
      build: () => buildCubit(proposalToken: testVersion2.token),
      act: (cubit) => cubit.load(),
      expect: () => [
        ProposalDetailState(
          status: ProposalDetailStatus.loading,
          proposalToken: testVersion2.token,
        ),
        ProposalDetailState(
          status: ProposalDetailStatus.loadFailed,
          proposalToken: testVersion2.token,
          loadFailure: const NegotiationNetworkFailure(),
        ),
      ],
    );

    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'opening another version reads it',
      setUp: () =>
          when(() => findProposal(testVersion1.token))
              .thenAnswer((_) async => Ok(testVersion1)),
      build: () => buildCubit(proposalToken: testVersion2.token),
      seed: readyState,
      act: (cubit) => cubit.showVersion(testVersion1.token),
      expect: () => [
        readyState().copyWith(proposalToken: testVersion1.token),
        readyState(proposalToken: testVersion1.token)
            .copyWith(proposal: testVersion1),
      ],
    );
  });

  group('accepting', () {
    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'accepts the open version',
      setUp: () =>
          when(() => acceptProposal(testVersion2.token))
              .thenAnswer((_) async => Ok(accepted)),
      build: () => buildCubit(proposalToken: testVersion2.token),
      seed: readyState,
      act: (cubit) => cubit.accept(),
      expect: () => [
        readyState().copyWith(isAccepting: true),
        readyState().copyWith(proposal: accepted, acceptedProposal: accepted),
      ],
    );

    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'a version that changed on the other side shows why and reloads',
      setUp: () => when(() => acceptProposal(testVersion2.token)).thenAnswer(
        (_) async =>
            const Err(NegotiationConflictFailure(detail: 'A versão 3 chegou.')),
      ),
      build: () => buildCubit(proposalToken: testVersion2.token),
      seed: readyState,
      act: (cubit) => cubit.accept(),
      expect: () => [
        readyState().copyWith(isAccepting: true),
        readyState().copyWith(
          actionFailure: const NegotiationConflictFailure(
            detail: 'A versão 3 chegou.',
          ),
        ),
        readyState(),
      ],
      verify: (_) => verify(() => findProposal(testVersion2.token)).called(1),
    );

    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'a proposal that no longer exists leaves the screen',
      setUp: () =>
          when(() => acceptProposal(testVersion2.token))
              .thenAnswer((_) async => const Err(NegotiationNotFoundFailure())),
      build: () => buildCubit(proposalToken: testVersion2.token),
      seed: readyState,
      act: (cubit) => cubit.accept(),
      skip: 1,
      expect: () => [
        readyState().copyWith(status: ProposalDetailStatus.notFound),
      ],
    );

    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'a version that is not open cannot be accepted',
      build: () => buildCubit(proposalToken: testVersion1.token),
      seed: () =>
          readyState(proposalToken: testVersion1.token)
              .copyWith(proposal: testVersion1),
      act: (cubit) => cubit.accept(),
      expect: () => <ProposalDetailState>[],
      verify: (_) => verifyNever(() => acceptProposal(any())),
    );
  });

  blocTest<ProposalDetailCubit, ProposalDetailState>(
    'accepting from the chat loads the version and accepts it',
    setUp: () =>
        when(() => acceptProposal(testVersion2.token))
            .thenAnswer((_) async => Ok(accepted)),
    build: () => buildCubit(proposalToken: testVersion2.token),
    act: (cubit) => cubit.loadAndAccept(),
    expect: () => [
      ProposalDetailState(
        status: ProposalDetailStatus.loading,
        proposalToken: testVersion2.token,
      ),
      readyState(),
      readyState().copyWith(isAccepting: true),
      readyState().copyWith(proposal: accepted, acceptedProposal: accepted),
    ],
  );

  group('cancelling the request', () {
    final requestState = ProposalDetailState(
      status: ProposalDetailStatus.ready,
      request: testRequestForLucas,
    );
    final withdrawn = TestClientServiceRequest(
      token: testRequestForLucas.token,
      status: ServiceRequestStatus.withdrawn,
    );

    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'closes the request and says it was cancelled',
      setUp: () =>
          when(() => withdrawServiceRequest(requestToken))
              .thenAnswer((_) async => Ok(withdrawn)),
      build: buildCubit,
      seed: () => requestState,
      act: (cubit) => cubit.cancelRequest(),
      expect: () => [
        requestState.copyWith(isCancelling: true),
        requestState.copyWith(request: withdrawn, cancelledRequest: withdrawn),
      ],
    );

    blocTest<ProposalDetailCubit, ProposalDetailState>(
      'a request answered meanwhile shows why and reloads',
      setUp: () {
        when(() => withdrawServiceRequest(requestToken)).thenAnswer(
          (_) async =>
              const Err(NegotiationConflictFailure(detail: 'Já respondido.')),
        );
        when(() => findServiceRequest(requestToken))
            .thenAnswer((_) async => Ok(testRequestForLucas));
      },
      build: buildCubit,
      seed: () => requestState,
      act: (cubit) => cubit.cancelRequest(),
      skip: 1,
      expect: () => [
        requestState.copyWith(
          actionFailure: const NegotiationConflictFailure(
            detail: 'Já respondido.',
          ),
        ),
        requestState,
      ],
    );
  });
}
