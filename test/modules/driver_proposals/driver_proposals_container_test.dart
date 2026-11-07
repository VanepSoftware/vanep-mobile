import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vanep_mobile/modules/driver_proposals/driver_proposals_container.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_proposal_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_composer_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/request_decline_cubit.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/usecases/list_my_vans.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/decline_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_driver_proposal_versions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_driver_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/send_proposal.dart';

import '../driver_vans/driver_vans_mocks.dart';
import 'driver_proposals_mocks.dart';

void main() {
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.asNewInstance()
      ..registerFactory<ListDriverServiceRequests>(
        MockListDriverServiceRequests.new,
      )
      ..registerFactory<FindDriverServiceRequest>(
        MockFindDriverServiceRequest.new,
      )
      ..registerFactory<FindDriverProposal>(MockFindDriverProposal.new)
      ..registerFactory<ListDriverProposalVersions>(
        MockListDriverProposalVersions.new,
      )
      ..registerFactory<DeclineServiceRequest>(MockDeclineServiceRequest.new)
      ..registerFactory<SendProposal>(MockSendProposal.new)
      ..registerFactory<ListMyVans>(MockListMyVans.new);
    registerDriverProposalsDependencies(getIt);
  });

  test('resolves the negotiations list', () {
    expect(getIt<DriverNegotiationsCubit>(), isA<DriverNegotiationsCubit>());
  });

  test('resolves the request, its decline and its proposal', () {
    expect(
      getIt<DriverServiceRequestCubit>(param1: 'request-1').requestToken,
      'request-1',
    );
    expect(
      getIt<RequestDeclineCubit>(param1: 'request-1').requestToken,
      'request-1',
    );
    final proposal = getIt<DriverProposalCubit>(
      param1: 'request-1',
      param2: 'proposal-v1',
    );
    expect(proposal.proposalToken, 'proposal-v1');
  });

  test('resolves the composer of a first proposal and of a new version', () {
    expect(
      getIt<ProposalComposerCubit>(param1: 'request-1').previousProposalToken,
      isNull,
    );
    expect(
      getIt<ProposalComposerCubit>(
        param1: 'request-1',
        param2: 'proposal-v1',
      ).previousProposalToken,
      'proposal-v1',
    );
  });
}
