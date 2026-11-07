import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_state.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/usecases/find_contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_school_days.dart';
import 'package:vanep_mobile/modules/drivers/domain/usecases/find_driver_profile.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/accept_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/decline_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_client_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_client_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_proposal_versions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/request_proposal_adjustment.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/send_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/withdraw_service_request.dart';

class MockFindMyDependents extends Mock implements FindMyDependents {}

class MockListClientServiceRequests extends Mock
    implements ListClientServiceRequests {}

class MockWithdrawServiceRequest extends Mock
    implements WithdrawServiceRequest {}

class MockLoadClientProposals extends Mock implements LoadClientProposals {}

class MockClientProposalsCubit extends MockCubit<ClientProposalsState>
    implements ClientProposalsCubit {}

class MockFindClientProposal extends Mock implements FindClientProposal {}

class MockFindClientServiceRequest extends Mock
    implements FindClientServiceRequest {}

class MockListClientProposalVersions extends Mock
    implements ListClientProposalVersions {}

class MockAcceptProposal extends Mock implements AcceptProposal {}

class MockDeclineProposal extends Mock implements DeclineProposal {}

class MockRequestProposalAdjustment extends Mock
    implements RequestProposalAdjustment {}

class MockFindDriverProfile extends Mock implements FindDriverProfile {}

class MockFindSchoolDays extends Mock implements FindSchoolDays {}

class MockFindContractReadiness extends Mock implements FindContractReadiness {}

class MockSendServiceRequest extends Mock implements SendServiceRequest {}

