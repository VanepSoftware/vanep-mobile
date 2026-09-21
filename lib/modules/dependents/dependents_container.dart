import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/environment/environment.dart';
import '../../core/network/dio_client.dart';
import '../ibge_locations/domain/usecases/list_cities.dart';
import '../ibge_locations/domain/usecases/list_states.dart';
import '../ibge_locations/domain/usecases/lookup_cep.dart';
import 'data/datasources/dependent_remote_datasource.dart';
import 'data/repositories/dependent_repository_impl.dart';
import 'domain/entities/dependent.dart';
import 'domain/repositories/dependent_repository.dart';
import 'domain/usecases/create_dependent.dart';
import 'domain/usecases/find_my_dependents.dart';
import 'domain/usecases/set_default_dependent.dart';
import 'domain/usecases/update_dependent.dart';
import 'presentation/cubit/dependent_form_cubit.dart';
import 'presentation/cubit/dependents_cubit.dart';

void registerDependentsDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<DependentRemoteDataSource>(
      DependentRemoteDataSource(
        dio: authenticatedDio,
        environment: environment,
      ),
    )
    ..registerSingleton<DependentRepository>(
      DependentRepositoryImpl(remote: getIt<DependentRemoteDataSource>()),
    )
    ..registerFactory<FindMyDependents>(
      () => FindMyDependents(getIt<DependentRepository>()),
    )
    ..registerFactory<CreateDependent>(
      () => CreateDependent(getIt<DependentRepository>()),
    )
    ..registerFactory<UpdateDependent>(
      () => UpdateDependent(getIt<DependentRepository>()),
    )
    ..registerFactory<SetDefaultDependent>(
      () => SetDefaultDependent(getIt<DependentRepository>()),
    )
    ..registerFactory<DependentsCubit>(
      () => DependentsCubit(
        findMyDependents: getIt<FindMyDependents>(),
        setDefaultDependent: getIt<SetDefaultDependent>(),
      ),
    )
    ..registerFactoryParam<DependentFormCubit, Dependent?, void>(
      (dependent, _) => DependentFormCubit(
        createDependent: getIt<CreateDependent>(),
        updateDependent: getIt<UpdateDependent>(),
        lookupCep: getIt<LookupCep>(),
        listStates: getIt<ListStates>(),
        listCities: getIt<ListCities>(),
        dependent: dependent,
      ),
    );
}
