import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
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
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_active_trip_route.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_linked_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/record_no_show.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/register_assistant_with_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/update_checklist_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/validate_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_checklist_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_invite_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_students_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_cubit.dart';

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
    ..registerSingleton<AssistantVansDataSource>(
      const MockedAssistantVansDataSource(),
    )
    ..registerSingleton<AssistantVansRepository>(
      AssistantVansRepositoryImpl(
        remote: getIt<AssistantRemoteDataSource>(),
        dataSource: getIt<AssistantVansDataSource>(),
      ),
    )
    ..registerFactory<FindAssistantVans>(
      () => FindAssistantVans(getIt<AssistantVansRepository>()),
    )
    ..registerFactory<RespondToAssistantInvite>(
      () => RespondToAssistantInvite(getIt<AssistantRepository>()),
    )
    ..registerFactory<AssistantVansCubit>(
      () => AssistantVansCubit(
        findAssistantVans: getIt<FindAssistantVans>(),
        respondToAssistantInvite: getIt<RespondToAssistantInvite>(),
      ),
    )
    ..registerFactory<GetActiveTripRoute>(
      () => GetActiveTripRoute(getIt<AssistantRepository>()),
    )
    ..registerFactory<UpdateChecklistStatus>(
      () => UpdateChecklistStatus(getIt<AssistantRepository>()),
    )
    ..registerFactory<RecordNoShow>(
      () => RecordNoShow(getIt<AssistantRepository>()),
    )
    ..registerFactory<AssistantVanSelectorCubit>(
      () => AssistantVanSelectorCubit(getLinkedVans: getIt<GetLinkedVans>()),
    )
    ..registerFactory<AssistantChecklistCubit>(
      () => AssistantChecklistCubit(
        getActiveTripRoute: getIt<GetActiveTripRoute>(),
        updateChecklistStatus: getIt<UpdateChecklistStatus>(),
        recordNoShow: getIt<RecordNoShow>(),
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
    ..registerFactoryParam<AssistantInviteCubit, String?, void>(
      (initialCode, _) => AssistantInviteCubit(
        validateInvite: getIt<ValidateAssistantInvite>(),
        registerWithInvite: getIt<RegisterAssistantWithInvite>(),
        initialCode: initialCode,
      ),
    );
}
