import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_state.dart';

import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockLoadClientProposals loadClientProposals;

  final readyState = ClientProposalsState(
    status: ClientProposalsStatus.ready,
    proposals: testClientProposals(),
  );

  setUp(() {
    loadClientProposals = MockLoadClientProposals();
  });

  ClientProposalsCubit buildCubit() =>
      ClientProposalsCubit(loadClientProposals: loadClientProposals);

  void loadReturns(Result<ClientProposalsFailure, ClientProposals> result) {
    when(loadClientProposals.call).thenAnswer((_) async => result);
  }

  blocTest<ClientProposalsCubit, ClientProposalsState>(
    'loads the proposals',
    setUp: () => loadReturns(Ok(testClientProposals())),
    build: buildCubit,
    act: (cubit) => cubit.loadProposals(),
    expect: () => [
      const ClientProposalsState(status: ClientProposalsStatus.loading),
      readyState,
    ],
  );

  blocTest<ClientProposalsCubit, ClientProposalsState>(
    'a failed first load shows the failure',
    setUp: () => loadReturns(const Err(ClientProposalsFailure.network)),
    build: buildCubit,
    act: (cubit) => cubit.loadProposals(),
    expect: () => [
      const ClientProposalsState(status: ClientProposalsStatus.loading),
      const ClientProposalsState(
        status: ClientProposalsStatus.loadFailed,
        failure: ClientProposalsFailure.network,
      ),
    ],
  );

  blocTest<ClientProposalsCubit, ClientProposalsState>(
    'a failed reload keeps the content',
    setUp: () => loadReturns(const Err(ClientProposalsFailure.network)),
    build: buildCubit,
    seed: () => readyState,
    act: (cubit) => cubit.loadProposals(),
    expect: () => <ClientProposalsState>[],
  );

  blocTest<ClientProposalsCubit, ClientProposalsState>(
    'selects a child and a tab',
    build: buildCubit,
    seed: () => readyState,
    act: (cubit) => cubit
      ..selectChild(testAna.token)
      ..selectTab(ProposalsTab.closed),
    expect: () => [
      readyState.withSelectedChild(testAna.token),
      readyState.withSelectedChild(testAna.token).withTab(ProposalsTab.closed),
    ],
    verify: (cubit) {
      expect(cubit.state.selectedChild, testAna);
      expect(cubit.state.visibleFeed.closed, [testFernandaClosed]);
    },
  );

  blocTest<ClientProposalsCubit, ClientProposalsState>(
    'a reload keeps the selection while the child still exists',
    setUp: () => loadReturns(Ok(testClientProposals())),
    build: buildCubit,
    seed: () => readyState.withSelectedChild(testAna.token),
    act: (cubit) => cubit.loadProposals(),
    expect: () => <ClientProposalsState>[],
  );

  blocTest<ClientProposalsCubit, ClientProposalsState>(
    'a reload clears the selection of a removed child',
    setUp: () =>
        loadReturns(Ok(testClientProposals(children: const [testPedro]))),
    build: buildCubit,
    seed: () => readyState.withSelectedChild(testAna.token),
    act: (cubit) => cubit.loadProposals(),
    expect: () => [
      ClientProposalsState(
        status: ClientProposalsStatus.ready,
        proposals: testClientProposals(children: const [testPedro]),
      ),
    ],
  );
}
