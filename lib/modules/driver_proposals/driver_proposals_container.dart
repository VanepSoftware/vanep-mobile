import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/load_driver_proposal.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/load_proposal_composer.dart';
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

void registerDriverProposalsDependencies(GetIt getIt) {
  getIt
    ..registerFactory<LoadDriverProposal>(
      () => LoadDriverProposal(
        findProposal: getIt<FindDriverProposal>(),
        findServiceRequest: getIt<FindDriverServiceRequest>(),
        listVersions: getIt<ListDriverProposalVersions>(),
      ),
    )
    ..registerFactory<LoadProposalComposer>(
      () => LoadProposalComposer(
        findServiceRequest: getIt<FindDriverServiceRequest>(),
        findProposal: getIt<FindDriverProposal>(),
        listMyVans: getIt<ListMyVans>(),
      ),
    )
    ..registerFactory<DriverNegotiationsCubit>(
      () => DriverNegotiationsCubit(
        listServiceRequests: getIt<ListDriverServiceRequests>(),
      ),
    )
    ..registerFactoryParam<DriverServiceRequestCubit, String, void>(
      (requestToken, _) => DriverServiceRequestCubit(
        requestToken: requestToken,
        findServiceRequest: getIt<FindDriverServiceRequest>(),
      ),
    )
    ..registerFactoryParam<RequestDeclineCubit, String, void>(
      (requestToken, _) => RequestDeclineCubit(
        requestToken: requestToken,
        declineServiceRequest: getIt<DeclineServiceRequest>(),
      ),
    )
    ..registerFactoryParam<DriverProposalCubit, String, String>(
      (requestToken, proposalToken) => DriverProposalCubit(
        requestToken: requestToken,
        proposalToken: proposalToken,
        loadDriverProposal: getIt<LoadDriverProposal>(),
      ),
    )
    ..registerFactoryParam<ProposalComposerCubit, String, String?>(
      (requestToken, previousProposalToken) => ProposalComposerCubit(
        requestToken: requestToken,
        previousProposalToken: previousProposalToken,
        loadProposalComposer: getIt<LoadProposalComposer>(),
        listMyVans: getIt<ListMyVans>(),
        sendProposal: getIt<SendProposal>(),
      ),
    );
}
