import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/find_my_personal_address.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/client_home_scenario.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/remote_daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/scenario_daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/data/repositories/client_home_repository_impl.dart';
import 'package:vanep_mobile/modules/client_home/domain/repositories/client_home_repository.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/find_negotiation_highlights.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/load_client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/prioritize_needs_you_items.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_enabled_shortcuts.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_home_headline.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_section_without_van.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';

// TODO(VAN-41): CLIENT_HOME_SCENARIO still swaps in mocked data for the parts
// the API does not serve yet (no route today, children without a van, live
// trip, needs-you items). Without it the van of the day comes from the API.
DailyOverviewDataSource dailyOverviewDataSourceFor(
  String scenarioName, {
  required DailyOverviewDataSource remote,
}) {
  final scenario = ClientHomeScenario.fromName(scenarioName);
  if (scenario == null) return remote;
  return ScenarioDailyOverviewDataSource(scenario: scenario);
}

void registerClientHomeDependencies(GetIt getIt) {
  getIt
    ..registerSingleton<DailyOverviewDataSource>(
      dailyOverviewDataSourceFor(
        getIt<Environment>().clientHomeScenario,
        remote: RemoteDailyOverviewDataSource(
          dio: getIt<Dio>(instanceName: authenticatedDioName),
          environment: getIt<Environment>(),
        ),
      ),
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
    ..registerFactory<FindNegotiationHighlights>(
      () => FindNegotiationHighlights(
        listServiceRequests: getIt<ListClientServiceRequests>(),
      ),
    )
    ..registerFactory<LoadClientHome>(
      () => LoadClientHome(
        repository: getIt<ClientHomeRepository>(),
        resolveSectionWithoutVan: getIt<ResolveSectionWithoutVan>(),
        findNegotiationHighlights: getIt<FindNegotiationHighlights>(),
        prioritizeNeedsYouItems: const PrioritizeNeedsYouItems(),
        resolveEnabledShortcuts: const ResolveEnabledShortcuts(),
        resolveHomeHeadline: const ResolveHomeHeadline(),
      ),
    )
    ..registerFactory<ClientHomeCubit>(
      () => ClientHomeCubit(loadClientHome: getIt<LoadClientHome>()),
    );
}
