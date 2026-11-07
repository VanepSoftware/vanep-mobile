import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/withdraw_service_request.dart';

void registerClientProposalsDependencies(GetIt getIt) {
  getIt
    ..registerFactory<LoadClientProposals>(
      () => LoadClientProposals(
        listServiceRequests: getIt<ListClientServiceRequests>(),
        findMyDependents: getIt<FindMyDependents>(),
      ),
    )
    ..registerFactory<ClientProposalsCubit>(
      () => ClientProposalsCubit(
        loadClientProposals: getIt<LoadClientProposals>(),
        listServiceRequests: getIt<ListClientServiceRequests>(),
        withdrawServiceRequest: getIt<WithdrawServiceRequest>(),
      ),
    );
}
