import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_home_scenario.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_route_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_route_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_route_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/confirm_stop_passengers.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_home_overview.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_today_route.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/mark_present_in_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/undo_stop_confirmation.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_students_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_vans_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_students_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_vans_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_students_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_vans_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_students.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_linked_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/register_assistant_with_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/validate_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_invite_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_cubit.dart';

AssistantRouteDataSource assistantRouteDataSourceFor(String scenarioName) {
  return MockedAssistantRouteDataSource(
    scenario:
        AssistantHomeScenario.fromName(scenarioName) ??
        AssistantHomeScenario.beforeRoute,
  );
}

void registerAssistantDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<AssistantRemoteDataSource>(
      AssistantRemoteDataSourceImpl(
        dio: authenticatedDio,
        environment: environment,
      ),
    )
    ..registerSingleton<AssistantRepository>(
      AssistantRepositoryImpl(remote: getIt<AssistantRemoteDataSource>()),
    )
    ..registerFactory<ValidateAssistantInvite>(
      () => ValidateAssistantInvite(getIt<AssistantRepository>()),
    )
    ..registerFactory<RegisterAssistantWithInvite>(
      () => RegisterAssistantWithInvite(getIt<AssistantRepository>()),
    )
    ..registerFactory<GetLinkedVans>(
      () => GetLinkedVans(getIt<AssistantRepository>()),
    )
    ..registerFactory<AssistantVanSelectorCubit>(
      () => AssistantVanSelectorCubit(getLinkedVans: getIt<GetLinkedVans>()),
    )
    ..registerSingleton<AssistantVansDataSource>(
      const MockedAssistantVansDataSource(),
    )
    ..registerSingleton<AssistantVansRepository>(
      AssistantVansRepositoryImpl(dataSource: getIt<AssistantVansDataSource>()),
    )
    ..registerFactory<FindAssistantVans>(
      () => FindAssistantVans(getIt<AssistantVansRepository>()),
    )
    ..registerFactory<AssistantVansCubit>(
      () => AssistantVansCubit(
        findAssistantVans: getIt<FindAssistantVans>(),
        respondToInvite: RespondToAssistantInvite(getIt<AssistantRepository>()),
      ),
    )
    ..registerSingleton<AssistantStudentsDataSource>(
      const MockedAssistantStudentsDataSource(),
    )
    ..registerSingleton<AssistantStudentsRepository>(
      AssistantStudentsRepositoryImpl(
        dataSource: getIt<AssistantStudentsDataSource>(),
      ),
    )
    ..registerFactory<FindAssistantStudents>(
      () => FindAssistantStudents(getIt<AssistantStudentsRepository>()),
    )
    ..registerFactory<AssistantStudentsCubit>(
      () => AssistantStudentsCubit(
        findAssistantStudents: getIt<FindAssistantStudents>(),
      ),
    )
    ..registerSingleton<AssistantRouteDataSource>(
      assistantRouteDataSourceFor(environment.assistantHomeScenario),
    )
    ..registerSingleton<AssistantRouteRepository>(
      AssistantRouteRepositoryImpl(
        dataSource: getIt<AssistantRouteDataSource>(),
      ),
    )
    ..registerFactory<FindAssistantHomeOverview>(
      () => FindAssistantHomeOverview(getIt<AssistantRouteRepository>()),
    )
    ..registerFactory<FindAssistantTodayRoute>(
      () => FindAssistantTodayRoute(getIt<AssistantRouteRepository>()),
    )
    ..registerFactory<ConfirmStopPassengers>(
      () => ConfirmStopPassengers(getIt<AssistantRouteRepository>()),
    )
    ..registerFactory<UndoStopConfirmation>(
      () => UndoStopConfirmation(getIt<AssistantRouteRepository>()),
    )
    ..registerFactory<MarkPresentInVan>(
      () => MarkPresentInVan(getIt<AssistantRouteRepository>()),
    )
    ..registerFactory<AssistantHomeCubit>(
      () => AssistantHomeCubit(
        findHomeOverview: getIt<FindAssistantHomeOverview>(),
        findTodayRoute: getIt<FindAssistantTodayRoute>(),
        confirmStopPassengers: getIt<ConfirmStopPassengers>(),
        undoStopConfirmation: getIt<UndoStopConfirmation>(),
        markPresentInVan: getIt<MarkPresentInVan>(),
        respondToInvite: RespondToAssistantInvite(getIt<AssistantRepository>()),
      ),
    )
    ..registerFactoryParam<AssistantInviteCubit, String?, void>(
      (initialCode, _) => AssistantInviteCubit(
        validateInvite: getIt<ValidateAssistantInvite>(),
        registerWithInvite: getIt<RegisterAssistantWithInvite>(),
        initialCode: initialCode,
      ),
    );
}
