import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/load_driver_proposal.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_proposal_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_proposal_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/request_decline_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/request_decline_state.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/decline_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_driver_proposal_versions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_driver_service_requests.dart';

import 'driver_proposals_fixtures.dart';

class MockListDriverServiceRequests extends Mock
    implements ListDriverServiceRequests {}

class MockFindDriverServiceRequest extends Mock
    implements FindDriverServiceRequest {}

class MockFindDriverProposal extends Mock implements FindDriverProposal {}

class MockListDriverProposalVersions extends Mock
    implements ListDriverProposalVersions {}

class MockDeclineServiceRequest extends Mock implements DeclineServiceRequest {}

class MockLoadDriverProposal extends Mock implements LoadDriverProposal {}

class MockDriverNegotiationsCubit extends MockCubit<DriverNegotiationsState>
    implements DriverNegotiationsCubit {}

class MockDriverServiceRequestCubit extends MockCubit<DriverServiceRequestState>
    implements DriverServiceRequestCubit {}

class MockDriverProposalCubit extends MockCubit<DriverProposalState>
    implements DriverProposalCubit {}

class MockRequestDeclineCubit extends MockCubit<RequestDeclineState>
    implements RequestDeclineCubit {}

MockDriverNegotiationsCubit readyNegotiationsCubit() {
  final cubit = MockDriverNegotiationsCubit();
  whenListen(
    cubit,
    const Stream<DriverNegotiationsState>.empty(),
    initialState: DriverNegotiationsState(
      status: DriverNegotiationsStatus.ready,
      negotiations: driverNegotiationsOf([newRequestForSiblings]),
    ),
  );
  when(() => cubit.load()).thenAnswer((_) async {});
  return cubit;
}
