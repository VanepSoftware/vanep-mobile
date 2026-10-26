import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/proposal_children_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/proposals_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/repositories/client_proposals_repository.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_state.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';

class MockClientProposalsRepository extends Mock
    implements ClientProposalsRepository {}

class MockProposalsDataSource extends Mock implements ProposalsDataSource {}

class MockProposalChildrenDataSource extends Mock
    implements ProposalChildrenDataSource {}

class MockFindMyDependents extends Mock implements FindMyDependents {}

class MockLoadClientProposals extends Mock implements LoadClientProposals {}

class MockClientProposalsCubit extends MockCubit<ClientProposalsState>
    implements ClientProposalsCubit {}
