import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_vans_datasource.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/data/repositories/assistant_vans_repository_impl.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_vans_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/get_linked_vans.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/register_assistant_with_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/validate_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_invite_cubit.dart';
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
      AssistantVansRepositoryImpl(dataSource: getIt<AssistantVansDataSource>()),
    )
    ..registerFactory<FindAssistantVans>(
      () => FindAssistantVans(getIt<AssistantVansRepository>()),
    )
    ..registerFactory<AssistantVansCubit>(
      () => AssistantVansCubit(findAssistantVans: getIt<FindAssistantVans>()),
    )
    ..registerFactoryParam<AssistantInviteCubit, String?, void>(
      (initialCode, _) => AssistantInviteCubit(
        validateInvite: getIt<ValidateAssistantInvite>(),
        registerWithInvite: getIt<RegisterAssistantWithInvite>(),
        initialCode: initialCode,
      ),
    );
}
