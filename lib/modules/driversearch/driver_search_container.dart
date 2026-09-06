import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/environment/environment.dart';
import '../../core/network/dio_client.dart';
import 'data/datasources/driver_search_remote_datasource.dart';
import 'data/repositories/driver_search_repository_impl.dart';
import 'domain/repositories/driver_search_repository.dart';
import 'domain/usecases/search_drivers_by_place.dart';

void registerDriverSearchDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<DriverSearchRemoteDataSource>(
      DriverSearchRemoteDataSource(
        dio: authenticatedDio,
        environment: environment,
      ),
    )
    ..registerSingleton<DriverSearchRepository>(
      DriverSearchRepositoryImpl(
        remote: getIt<DriverSearchRemoteDataSource>(),
      ),
    )
    ..registerFactory<SearchDriversByPlace>(
      () => SearchDriversByPlace(getIt<DriverSearchRepository>()),
    );
}
