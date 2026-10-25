import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/find_my_personal_address.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/client_home_scenario.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/empty_daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/scenario_daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/data/repositories/client_home_repository_impl.dart';
import 'package:vanep_mobile/modules/client_home/domain/repositories/client_home_repository.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/load_client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/prioritize_needs_you_items.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_enabled_shortcuts.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_home_headline.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_section_without_van.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';

DailyOverviewDataSource dailyOverviewDataSourceFor(String scenarioName) {
  final scenario = ClientHomeScenario.fromName(scenarioName);
  if (scenario == null) return const EmptyDailyOverviewDataSource();
  return ScenarioDailyOverviewDataSource(scenario: scenario);
}

void registerClientHomeDependencies(GetIt getIt) {
  getIt
    ..registerSingleton<DailyOverviewDataSource>(
      dailyOverviewDataSourceFor(getIt<Environment>().clientHomeScenario),
    )
    ..registerSingleton<ClientHomeRepository>(
      ClientHomeRepositoryImpl(dataSource: getIt<DailyOverviewDataSource>()),
    )
    ..registerFactory<ResolveSectionWithoutVan>(
      () => ResolveSectionWithoutVan(
        findMyPersonalAddress: getIt<FindMyPersonalAddress>(),
        findMyDependents: getIt<FindMyDependents>(),
      ),
    )
    ..registerFactory<LoadClientHome>(
      () => LoadClientHome(
        repository: getIt<ClientHomeRepository>(),
        resolveSectionWithoutVan: getIt<ResolveSectionWithoutVan>(),
        prioritizeNeedsYouItems: const PrioritizeNeedsYouItems(),
        resolveEnabledShortcuts: const ResolveEnabledShortcuts(),
        resolveHomeHeadline: const ResolveHomeHeadline(),
      ),
    )
    ..registerFactory<ClientHomeCubit>(
      () => ClientHomeCubit(loadClientHome: getIt<LoadClientHome>()),
    );
}
