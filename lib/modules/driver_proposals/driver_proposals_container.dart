import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/driver_proposals/data/datasources/scenario_proposal_compose_datasource.dart';
import 'package:vanep_mobile/modules/driver_proposals/data/repositories/driver_proposal_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/repositories/driver_proposal_repository.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/proposal_compose_usecases.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_compose_cubit.dart';

void registerDriverProposalDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton<DriverProposalRepository>(
      () => DriverProposalRepositoryImpl(
        dataSource: ScenarioProposalComposeDataSource(
          scenario: driverProposalScenarioFromName(
            getIt<Environment>().driverProposalScenario,
          ),
        ),
      ),
    )
    ..registerFactory<LoadProposalCompose>(
      () => LoadProposalCompose(repository: getIt<DriverProposalRepository>()),
    )
    ..registerFactory<SendDriverProposal>(
      () => SendDriverProposal(repository: getIt<DriverProposalRepository>()),
    )
    ..registerFactory<ProposalComposeCubit>(
      () => ProposalComposeCubit(
        loadProposalCompose: getIt<LoadProposalCompose>(),
        sendDriverProposal: getIt<SendDriverProposal>(),
      ),
    );
}
