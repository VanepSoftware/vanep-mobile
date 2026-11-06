import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/repositories/driver_proposal_repository.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/proposal_compose_usecases.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_compose_cubit.dart';

import 'driver_proposals_fixtures.dart';

class MockDriverProposalRepository extends Mock
    implements DriverProposalRepository {}

class MockLoadProposalCompose extends Mock implements LoadProposalCompose {}

class MockSendDriverProposal extends Mock implements SendDriverProposal {}

class MockProposalComposeCubit extends MockCubit<ProposalComposeState>
    implements ProposalComposeCubit {}

ProposalComposeCubit idleProposalComposeCubit() {
  return ProposalComposeCubit(
    loadProposalCompose: MockLoadProposalCompose(),
    sendDriverProposal: MockSendDriverProposal(),
  );
}

ProposalComposeCubit readyProposalComposeCubit() {
  final cubit = MockProposalComposeCubit();
  when(cubit.loadDraft).thenAnswer((_) async {});
  whenListen(
    cubit,
    const Stream<ProposalComposeState>.empty(),
    initialState: ProposalComposeState(
      status: ProposalComposeStatus.ready,
      draft: testProposalComposeDraft(),
    ),
  );
  return cubit;
}
