import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/client_proposals_scenario.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/dependent_proposal_children_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/empty_proposals_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/scenario_client_proposals_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/data/repositories/client_proposals_repository_impl.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/repositories/client_proposals_repository.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';

// TODO(VAN-42): switches between real children with no proposals and fully
// mocked data via CLIENT_PROPOSALS_SCENARIO; register the remote proposals data
// source here once api-java #30 lands and drop the scenario branch.
ClientProposalsRepository clientProposalsRepositoryFor(
  String scenarioName, {
  required FindMyDependents findMyDependents,
}) {
  final scenario = ClientProposalsScenario.fromName(scenarioName);
  if (scenario == null) {
    return ClientProposalsRepositoryImpl(
      proposalsDataSource: const EmptyProposalsDataSource(),
      childrenDataSource: DependentProposalChildrenDataSource(
        findMyDependents: findMyDependents,
      ),
    );
  }
  final scenarioDataSource = ScenarioClientProposalsDataSource(
    scenario: scenario,
  );
  return ClientProposalsRepositoryImpl(
    proposalsDataSource: scenarioDataSource,
    childrenDataSource: scenarioDataSource,
  );
}

void registerClientProposalsDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton<ClientProposalsRepository>(
      () => clientProposalsRepositoryFor(
        getIt<Environment>().clientProposalsScenario,
        findMyDependents: getIt<FindMyDependents>(),
      ),
    )
    ..registerFactory<LoadClientProposals>(
      () => LoadClientProposals(repository: getIt<ClientProposalsRepository>()),
    )
    ..registerFactory<ClientProposalsCubit>(
      () => ClientProposalsCubit(
        loadClientProposals: getIt<LoadClientProposals>(),
      ),
    );
}
