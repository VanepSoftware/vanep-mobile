import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/environment/environment.dart';
import '../../core/network/dio_client.dart';
import 'data/datasources/dependent_remote_datasource.dart';
import 'data/repositories/dependent_repository_impl.dart';
import 'domain/repositories/dependent_repository.dart';
import 'domain/usecases/create_dependent.dart';
import 'domain/usecases/find_my_dependents.dart';
import 'domain/usecases/set_default_dependent.dart';
import 'domain/usecases/update_dependent.dart';

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
    );
}
